/**
 * FIFA.com HTML Scraper — WC 2026
 *
 * Scrapea directamente las páginas web de FIFA.com extrayendo los datos
 * del JSON __NEXT_DATA__ que Next.js embebe en el HTML del servidor.
 * Si el parseo HTML falla, usa como fallback la API interna de FIFA
 * (la misma que utiliza su propia web).
 */

import { TEAM_TO_CODE, resolveCode } from './fifa-api'
import type { FIFAMatch, FIFAScorer } from './fifa-api'

const FIFA_BASE = 'https://www.fifa.com'

const SCRAPE_HEADERS = {
  'User-Agent':      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
  'Accept':          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
  'Accept-Language': 'en-US,en;q=0.9',
  'Cache-Control':   'no-cache',
  'Pragma':          'no-cache',
}

// ─── Extraer __NEXT_DATA__ del HTML ─────────────────────────────────────────
function extractNextData(html: string): Record<string, any> | null {
  // Next.js embebe el estado en <script id="__NEXT_DATA__" type="application/json">
  const m = html.match(/<script[^>]+id="__NEXT_DATA__"[^>]*>\s*(\{[\s\S]*?\})\s*<\/script>/)
  if (!m?.[1]) return null
  try { return JSON.parse(m[1]) } catch { return null }
}

// ─── Normalizar estado de partido ────────────────────────────────────────────
function normalizeStatus(raw: any): 'scheduled' | 'live' | 'finished' {
  if (typeof raw === 'number') {
    if (raw === 1) return 'live'
    if (raw === 3 || raw === 5 || raw === 4) return 'finished'
    return 'scheduled'
  }
  if (typeof raw === 'string') {
    const s = raw.toUpperCase()
    if (s.includes('LIVE') || s === 'INPROGRESS' || s === 'IN_PROGRESS') return 'live'
    if (s.includes('FINISH') || s.includes('COMPLET') || s.includes('FINAL') || s.includes('ENDED')) return 'finished'
    return 'scheduled'
  }
  return 'scheduled'
}

// ─── Resolver nombre de equipo a código ──────────────────────────────────────
function resolveTeamCode(team: any): string | null {
  if (!team) return null

  // Código directo FIFA (3 letras)
  const direct = team.CountryCode ?? team.OfficialCode ?? team.ShortName ?? team.Abbreviation
    ?? team.AbbreviatedFederation ?? team.TeamCode ?? team.code ?? null
  if (direct && TEAM_TO_CODE[direct]) return TEAM_TO_CODE[direct]
  if (direct && /^[A-Z]{3}$/.test(direct)) return direct

  // Nombre del equipo
  const names: string[] = []
  if (typeof team.Name === 'string') names.push(team.Name)
  if (Array.isArray(team.Name)) team.Name.forEach((n: any) => n?.Description && names.push(n.Description))
  if (typeof team.LongName === 'string') names.push(team.LongName)
  if (typeof team.ShortName === 'string') names.push(team.ShortName)
  if (typeof team.DisplayName === 'string') names.push(team.DisplayName)
  if (typeof team.name === 'string') names.push(team.name)
  if (typeof team.internationalName === 'string') names.push(team.internationalName)

  for (const name of names) {
    if (TEAM_TO_CODE[name]) return TEAM_TO_CODE[name]
  }

  return null
}

// ─── Buscar recursivamente objetos que parezcan partidos ─────────────────────
function findMatchObjects(obj: any, depth = 0): any[] {
  if (depth > 12 || obj === null || typeof obj !== 'object') return []

  // ¿Parece un partido?
  const isMatch = (
    (obj.HomeTeam || obj.home_team || obj.homeTeam || obj.home) &&
    (obj.AwayTeam || obj.away_team || obj.awayTeam || obj.away)
  )
  if (isMatch) return [obj]

  const results: any[] = []

  if (Array.isArray(obj)) {
    for (const item of obj) {
      results.push(...findMatchObjects(item, depth + 1))
    }
    return results
  }

  // Claves prioritarias que suelen contener partidos
  const matchKeys = ['matches', 'Matches', 'results', 'Results', 'fixtures', 'events',
                     'matchList', 'games', 'calendar', 'fixture']
  for (const key of matchKeys) {
    if (key in obj) {
      results.push(...findMatchObjects(obj[key], depth + 1))
    }
  }

  // Si no encontramos nada, buscamos en todas las claves
  if (results.length === 0) {
    for (const val of Object.values(obj)) {
      results.push(...findMatchObjects(val, depth + 1))
    }
  }

  return results
}

// ─── Parsear un objeto de partido en nuestro formato ────────────────────────
function parseMatchObject(m: any): FIFAMatch | null {
  const home = m.HomeTeam ?? m.home_team ?? m.homeTeam ?? m.home ?? m.homeCompetitor ?? null
  const away = m.AwayTeam ?? m.away_team ?? m.awayTeam ?? m.away ?? m.awayCompetitor ?? null

  if (!home || !away) return null

  const homeCode = resolveTeamCode(home) ?? resolveCode(home)
  const awayCode = resolveTeamCode(away) ?? resolveCode(away)

  // Marcador
  const homeScore = home.Score ?? home.score ?? home.goals ?? m.HomeScore ?? m.homeScore ?? null
  const awayScore = away.Score ?? away.score ?? away.goals ?? m.AwayScore ?? m.awayScore ?? null

  // Estado
  const rawStatus = m.MatchStatus ?? m.matchStatus ?? m.status ?? m.State ?? m.state ?? 'scheduled'
  const status = normalizeStatus(rawStatus)

  // Fecha
  const date = m.Date ?? m.date ?? m.StartDate ?? m.matchDate ?? m.kickOffTime ?? ''

  return {
    idMatch:   String(m.IdMatch ?? m.id ?? m.MatchId ?? Math.random()),
    homeCode,
    awayCode,
    homeScore: typeof homeScore === 'number' ? homeScore : (homeScore != null ? parseInt(homeScore) : null),
    awayScore: typeof awayScore === 'number' ? awayScore : (awayScore != null ? parseInt(awayScore) : null),
    status,
    date:      typeof date === 'string' ? date : '',
  }
}

// ─── Buscar recursivamente goleadores ───────────────────────────────────────
function findScorerObjects(obj: any, depth = 0): any[] {
  if (depth > 12 || obj === null || typeof obj !== 'object') return []

  // ¿Parece un goleador?
  const hasName  = obj.PlayerName ?? obj.playerName ?? obj.name ?? obj.Name
  const hasGoals = obj.Goals != null || obj.goals != null || obj.GoalCount != null
  if (hasName && hasGoals) return [obj]

  const results: any[] = []

  if (Array.isArray(obj)) {
    for (const item of obj) results.push(...findScorerObjects(item, depth + 1))
    return results
  }

  const scorerKeys = ['topScorers', 'TopScorers', 'scorers', 'players', 'statistics',
                      'goals', 'goalScorers', 'goalscorers', 'playerStats']
  for (const key of scorerKeys) {
    if (key in obj) results.push(...findScorerObjects(obj[key], depth + 1))
  }

  if (results.length === 0) {
    for (const val of Object.values(obj)) results.push(...findScorerObjects(val, depth + 1))
  }

  return results
}

// ─── Parsear objeto goleador ─────────────────────────────────────────────────
function parseScorerObject(s: any): FIFAScorer | null {
  const playerName = s.PlayerName ?? s.playerName ?? s.name ?? s.Name
    ?? s.Player?.Name ?? s.player?.name ?? null
  if (!playerName || typeof playerName !== 'string') return null

  const goals   = parseInt(s.Goals ?? s.goals ?? s.GoalCount ?? '0') || 0
  const assists = parseInt(s.Assists ?? s.assists ?? s.AssistCount ?? '0') || 0
  const matches = parseInt(s.MatchesPlayed ?? s.matchesPlayed ?? s.PlayedMatchs ?? '0') || 0

  const teamRaw = s.Team ?? s.team ?? s.TeamName ?? s.Country ?? s.country ?? null
  const teamCode = resolveTeamCode({ Name: teamRaw, name: teamRaw, code: teamRaw })

  if (goals === 0) return null

  return { playerName, teamCode, goals, assists, matches }
}

// ─── Scraper principal: página de resultados ─────────────────────────────────
export async function scrapeMatches(): Promise<FIFAMatch[]> {
  const url = `${FIFA_BASE}/en/tournaments/mens/worldcup/canadamexicousa2026/scores-fixtures`
  console.log(`[Scraper] Scrapeando ${url}`)

  let html: string
  try {
    const res = await fetch(url, { headers: SCRAPE_HEADERS, signal: AbortSignal.timeout(15_000) })
    if (!res.ok) throw new Error(`HTTP ${res.status}`)
    html = await res.text()
  } catch (e: any) {
    throw new Error(`No se pudo obtener la página de FIFA: ${e.message}`)
  }

  const nextData = extractNextData(html)
  if (!nextData) {
    throw new Error('No se encontró __NEXT_DATA__ en el HTML de FIFA')
  }

  // Buscar partidos en el JSON
  const matchObjects = findMatchObjects(nextData)

  if (matchObjects.length === 0) {
    // Puede que FIFA tenga los datos en otra estructura; loguear para diagnóstico
    const keys = JSON.stringify(Object.keys(nextData.props?.pageProps ?? {}))
    throw new Error(`__NEXT_DATA__ encontrado pero sin partidos. Claves pageProps: ${keys}`)
  }

  const matches: FIFAMatch[] = []
  for (const m of matchObjects) {
    const parsed = parseMatchObject(m)
    if (parsed?.homeCode && parsed?.awayCode) {
      matches.push(parsed)
    }
  }

  console.log(`[Scraper] ✓ ${matches.length} partidos parseados del HTML`)
  return matches
}

// ─── Scraper de goleadores ────────────────────────────────────────────────────
export async function scrapeScorers(): Promise<FIFAScorer[]> {
  // FIFA tiene los goleadores en la página de estadísticas
  const urls = [
    `${FIFA_BASE}/en/tournaments/mens/worldcup/canadamexicousa2026/statistics`,
    `${FIFA_BASE}/en/tournaments/mens/worldcup/canadamexicousa2026/scores-fixtures`,
  ]

  for (const url of urls) {
    try {
      const res = await fetch(url, { headers: SCRAPE_HEADERS, signal: AbortSignal.timeout(15_000) })
      if (!res.ok) continue
      const html = await res.text()
      const nextData = extractNextData(html)
      if (!nextData) continue

      const scorerObjects = findScorerObjects(nextData)
      if (!scorerObjects.length) continue

      const scorers: FIFAScorer[] = []
      for (const s of scorerObjects) {
        const parsed = parseScorerObject(s)
        if (parsed) scorers.push(parsed)
      }

      if (scorers.length > 0) {
        console.log(`[Scraper] ✓ ${scorers.length} goleadores parseados de ${url}`)
        return scorers
      }
    } catch {}
  }

  return []
}

// ─── Wrapper con fallback a FIFA API ─────────────────────────────────────────
export async function scrapeOrFetchMatches(): Promise<{ matches: FIFAMatch[]; source: string }> {
  // Primero intenta scraping HTML
  try {
    const matches = await scrapeMatches()
    if (matches.length > 0) return { matches, source: 'html-scrape' }
  } catch (e: any) {
    console.warn(`[Scraper] HTML parse falló (${e.message}), usando API FIFA...`)
  }

  // Fallback: API interna de FIFA (misma que usa su web)
  const { fetchFIFAMatches } = await import('./fifa-api')
  const matches = await fetchFIFAMatches()
  return { matches, source: 'api-fallback' }
}

export async function scrapeOrFetchScorers(): Promise<{ scorers: FIFAScorer[]; source: string }> {
  try {
    const scorers = await scrapeScorers()
    if (scorers.length > 0) return { scorers, source: 'html-scrape' }
  } catch (e: any) {
    console.warn(`[Scraper] Goleadores HTML parse falló (${e.message}), usando API FIFA...`)
  }

  const { fetchFIFAScorers } = await import('./fifa-api')
  const scorers = await fetchFIFAScorers()
  return { scorers, source: 'api-fallback' }
}
