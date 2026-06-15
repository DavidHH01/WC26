/**
 * FIFA API client para WC 2026
 *
 * FIFA.com usa una API REST pública (la misma que usa su web) en api.fifa.com.
 * El ID de competición del Mundial masculino es siempre 17.
 * El ID de temporada (idSeason) varía por edición — lo descubrimos automáticamente
 * desde la propia página de FIFA o lo puedes fijar en la variable de entorno FIFA_SEASON_ID.
 */

const COMPETITION_ID = process.env.FIFA_COMPETITION_ID ?? '17'
const SEASON_ID      = process.env.FIFA_SEASON_ID      ?? ''  // se autodescubre si está vacío
const FIFA_API       = 'https://api.fifa.com/api/v3'

const HEADERS = {
  'User-Agent':      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
  'Accept':          'application/json, text/plain, */*',
  'Accept-Language': 'es-ES,es;q=0.9,en;q=0.8',
  'Origin':          'https://www.fifa.com',
  'Referer':         'https://www.fifa.com/',
}

// ── Mapeo nombre FIFA → código de nuestra BD ────────────────────
export const TEAM_TO_CODE: Record<string, string> = {
  // Inglés / codes FIFA
  'Mexico': 'MEX', 'South Africa': 'RSA', 'South Korea': 'KOR',
  'Czech Republic': 'CZE', 'Czechia': 'CZE',
  'Canada': 'CAN', 'Bosnia and Herzegovina': 'BIH', 'Bosnia & Herzegovina': 'BIH',
  'Qatar': 'QAT', 'Switzerland': 'SUI',
  'Brazil': 'BRA', 'Morocco': 'MAR', 'Haiti': 'HAI', 'Scotland': 'SCO',
  'United States': 'USA',
  'Paraguay': 'PAR', 'Australia': 'AUS', 'Turkey': 'TUR', 'Türkiye': 'TUR',
  'Germany': 'GER', 'Curaçao': 'CUW', 'Curacao': 'CUW',
  "Côte d'Ivoire": 'CIV', 'Ivory Coast': 'CIV', 'Ecuador': 'ECU',
  'Netherlands': 'NED', 'Japan': 'JPN', 'Sweden': 'SWE', 'Tunisia': 'TUN',
  'Belgium': 'BEL', 'Egypt': 'EGY', 'Iran': 'IRN', 'New Zealand': 'NZL',
  'Spain': 'ESP', 'Cape Verde': 'CPV', 'Saudi Arabia': 'KSA', 'Uruguay': 'URU',
  'France': 'FRA', 'Senegal': 'SEN', 'Iraq': 'IRQ', 'Norway': 'NOR',
  'Argentina': 'ARG', 'Algeria': 'ALG', 'Austria': 'AUT', 'Jordan': 'JOR',
  'Portugal': 'POR',
  'DR Congo': 'COD', 'Congo DR': 'COD', 'Democratic Republic of Congo': 'COD',
  'Uzbekistan': 'UZB', 'Colombia': 'COL',
  'England': 'ENG', 'Croatia': 'CRO', 'Ghana': 'GHA', 'Panama': 'PAN',
  // Español
  'México': 'MEX', 'Sudáfrica': 'RSA', 'Corea del Sur': 'KOR',
  'República Checa': 'CZE', 'Canadá': 'CAN', 'Bosnia y Herzegovina': 'BIH',
  'Catar': 'QAT', 'Suiza': 'SUI', 'Brasil': 'BRA', 'Marruecos': 'MAR',
  'Haití': 'HAI', 'Escocia': 'SCO', 'Estados Unidos': 'USA',
  'Turquía': 'TUR', 'Alemania': 'GER', 'Curazao': 'CUW',
  'Costa de Marfil': 'CIV', 'Países Bajos': 'NED', 'Japón': 'JPN',
  'Suecia': 'SWE', 'Túnez': 'TUN', 'Bélgica': 'BEL', 'Egipto': 'EGY',
  'Irán': 'IRN', 'Nueva Zelanda': 'NZL', 'España': 'ESP', 'Cabo Verde': 'CPV',
  'Arabia Saudí': 'KSA', 'Arabia Saudita': 'KSA', 'Francia': 'FRA',
  'Irak': 'IRQ', 'Noruega': 'NOR', 'Argelia': 'ALG', 'Jordania': 'JOR',
  'RD Congo': 'COD', 'República Democrática del Congo': 'COD',
  'Uzbekistán': 'UZB', 'Inglaterra': 'ENG',
  'Croacia': 'CRO', 'Panamá': 'PAN',
  // Códigos directos FIFA (3 letras) — por si la API devuelve el código
  'MEX': 'MEX', 'RSA': 'RSA', 'KOR': 'KOR', 'CZE': 'CZE', 'CAN': 'CAN',
  'BIH': 'BIH', 'QAT': 'QAT', 'SUI': 'SUI', 'BRA': 'BRA', 'MAR': 'MAR',
  'HAI': 'HAI', 'SCO': 'SCO', 'USA': 'USA', 'PAR': 'PAR', 'AUS': 'AUS',
  'TUR': 'TUR', 'GER': 'GER', 'CUW': 'CUW', 'CIV': 'CIV', 'ECU': 'ECU',
  'NED': 'NED', 'JPN': 'JPN', 'SWE': 'SWE', 'TUN': 'TUN', 'BEL': 'BEL',
  'EGY': 'EGY', 'IRN': 'IRN', 'NZL': 'NZL', 'ESP': 'ESP', 'CPV': 'CPV',
  'KSA': 'KSA', 'URU': 'URU', 'FRA': 'FRA', 'SEN': 'SEN', 'IRQ': 'IRQ',
  'NOR': 'NOR', 'ARG': 'ARG', 'ALG': 'ALG', 'AUT': 'AUT', 'JOR': 'JOR',
  'POR': 'POR', 'COD': 'COD', 'UZB': 'UZB', 'COL': 'COL', 'ENG': 'ENG',
  'CRO': 'CRO', 'GHA': 'GHA', 'PAN': 'PAN',
}

function teamName(team: any, locale = 'en-US'): string {
  if (!team) return ''
  const names = team.TeamName ?? team.Name ?? []
  if (Array.isArray(names)) {
    return names.find((n: any) => n.Locale === locale)?.Description
        ?? names[0]?.Description
        ?? team.IdTeam ?? ''
  }
  return String(names)
}

export function resolveCode(team: any): string | null {
  // 1. Código FIFA directo (algunos endpoints lo incluyen como ShortClubName o AbbreviatedFederation)
  const direct = team?.ShortClubName ?? team?.AbbreviatedFederation ?? team?.TeamName3 ?? null
  if (direct && TEAM_TO_CODE[direct]) return TEAM_TO_CODE[direct]

  // 2. Nombre en inglés
  const en = teamName(team, 'en-US')
  if (TEAM_TO_CODE[en]) return TEAM_TO_CODE[en]

  // 3. Nombre en español
  const es = teamName(team, 'es-ES')
  if (TEAM_TO_CODE[es]) return TEAM_TO_CODE[es]

  // 4. Cualquier nombre disponible
  const any = teamName(team)
  return TEAM_TO_CODE[any] ?? null
}

// ── Autodescubrimiento del Season ID ────────────────────────────
let _cachedSeasonId: string | null = SEASON_ID || null

export async function getSeasonId(): Promise<string> {
  if (_cachedSeasonId) return _cachedSeasonId

  // Intenta extraerlo de la página del torneo
  try {
    const res = await fetch(
      'https://www.fifa.com/en/tournaments/mens/worldcup/canadamexicousa2026',
      { headers: HEADERS }
    )
    const html = await res.text()

    // Busca en __NEXT_DATA__ o en URLs de la página
    const patterns = [
      /"idSeason":"?(\d{5,7})"?/,
      /idSeason=(\d{5,7})/,
      /"IdSeason":"?(\d{5,7})"?/,
    ]
    for (const pat of patterns) {
      const m = html.match(pat)
      if (m?.[1]) {
        _cachedSeasonId = m[1]
        console.log(`[FIFA] Season ID autodescubierto: ${_cachedSeasonId}`)
        return _cachedSeasonId
      }
    }
  } catch (e) {
    console.warn('[FIFA] No se pudo autodescubrir el Season ID:', e)
  }

  // Fallback: prueba los IDs más probables para 2026
  for (const candidate of ['278514', '285063', '290945', '299814']) {
    try {
      const res = await fetch(
        `${FIFA_API}/calendar/matches?language=en&count=1&idCompetition=${COMPETITION_ID}&idSeason=${candidate}`,
        { headers: HEADERS }
      )
      const data = await res.json()
      if (data?.Results?.length > 0) {
        _cachedSeasonId = candidate
        console.log(`[FIFA] Season ID por prueba: ${_cachedSeasonId}`)
        return _cachedSeasonId
      }
    } catch {}
  }

  throw new Error('No se pudo determinar el Season ID de FIFA 2026. Configura FIFA_SEASON_ID en .env')
}

// ── Fetch de partidos ────────────────────────────────────────────
export interface FIFAMatch {
  idMatch: string
  homeCode: string | null
  awayCode: string | null
  homeScore: number | null
  awayScore: number | null
  status: 'scheduled' | 'live' | 'finished'
  date: string
}

export async function fetchFIFAMatches(): Promise<FIFAMatch[]> {
  const seasonId = await getSeasonId()
  const url = `${FIFA_API}/calendar/matches?language=en&count=200&idCompetition=${COMPETITION_ID}&idSeason=${seasonId}`
  const res = await fetch(url, { headers: HEADERS })
  if (!res.ok) throw new Error(`FIFA API respondió ${res.status} para partidos`)

  const data = await res.json()
  const results: FIFAMatch[] = []

  for (const m of data?.Results ?? []) {
    // MatchStatus: 0=programado, 1=en vivo, 3=finalizado, 4=aplazado
    const statusCode: number = m.MatchStatus ?? 0
    let status: 'scheduled' | 'live' | 'finished' = 'scheduled'
    if (statusCode === 1)                        status = 'live'
    else if (statusCode === 3 || statusCode === 5) status = 'finished'

    const home = m.Home ?? m.HomeTeam
    const away = m.Away ?? m.AwayTeam

    results.push({
      idMatch:   String(m.IdMatch),
      homeCode:  resolveCode(home),
      awayCode:  resolveCode(away),
      homeScore: home?.Score ?? null,
      awayScore: away?.Score ?? null,
      status,
      date:      m.Date ?? m.LocalDate ?? '',
    })
  }

  return results
}

// ── Fetch de goleadores ──────────────────────────────────────────
export interface FIFAScorer {
  playerName: string
  teamCode: string | null
  goals: number
  assists: number
  matches: number
}

export async function fetchFIFAScorers(): Promise<FIFAScorer[]> {
  const seasonId = await getSeasonId()

  // Intenta el endpoint de goleadores
  const endpoints = [
    `${FIFA_API}/topscorers?language=en&idCompetition=${COMPETITION_ID}&idSeason=${seasonId}`,
    `${FIFA_API}/award/players?language=en&idCompetition=${COMPETITION_ID}&idSeason=${seasonId}&type=goal`,
  ]

  for (const url of endpoints) {
    try {
      const res = await fetch(url, { headers: HEADERS })
      if (!res.ok) continue
      const data = await res.json()
      const list = data?.Results ?? data?.TopScorers ?? []
      if (!list.length) continue

      return list.map((s: any) => {
        const name = (teamName(s.Player ?? s, 'en-US')
                  || teamName(s.Player ?? s, 'es-ES')
                  || s.PlayerName) ?? ''
        return {
          playerName: name,
          teamCode:   resolveCode(s),
          goals:      s.Goals ?? s.GoalCount ?? 0,
          assists:    s.Assists ?? s.AssistCount ?? 0,
          matches:    s.PlayedMatchs ?? s.MatchesPlayed ?? 0,
        }
      })
    } catch {}
  }

  return []
}
