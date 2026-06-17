/**
 * GET /api/bracket
 *
 * Devuelve el cuadro de eliminatorias (Round of 32 → Final) directamente
 * desde la API de FIFA. Solo visualización: los equipos aparecen como
 * placeholders (1E, 3ABCDF, W74…) y se rellenan automáticamente cuando FIFA
 * resuelve cada cruce al avanzar el torneo.
 *
 * Cacheado en memoria 60s para no machacar a FIFA en cada visita.
 */
import { resolveCode } from '../utils/fifa-api'

const FIFA_API = 'https://api.fifa.com/api/v3'
const COMPETITION_ID = process.env.FIFA_COMPETITION_ID ?? '17'
const HEADERS = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
  'Accept': 'application/json, text/plain, */*',
  'Origin': 'https://www.fifa.com',
  'Referer': 'https://www.fifa.com/',
}

const STAGE_MAP: Record<string, string> = {
  'Round of 32': 'r32',
  'Round of 16': 'r16',
  'Quarter-final': 'qf',
  'Quarter-finals': 'qf',
  'Semi-final': 'sf',
  'Semi-finals': 'sf',
  'Play-off for third place': 'third',
  'Final': 'final',
}

interface BracketTeam {
  code: string | null
  name: string | null
  placeholder: string
}
interface BracketMatch {
  number: number
  stage: string
  date: string
  status: 'scheduled' | 'live' | 'finished'
  home: BracketTeam
  away: BracketTeam
  homeScore: number | null
  awayScore: number | null
  homePens: number | null
  awayPens: number | null
}

function teamName(team: any): string | null {
  if (!team) return null
  const names = team.TeamName ?? team.Name ?? []
  if (Array.isArray(names)) {
    return names.find((n: any) => n.Locale === 'en-GB')?.Description
        ?? names[0]?.Description
        ?? team.ShortClubName ?? null
  }
  return team.ShortClubName ?? null
}

let cache: { at: number; data: BracketMatch[] } | null = null
const TTL = 60_000

export default defineEventHandler(async () => {
  if (cache && Date.now() - cache.at < TTL) {
    return { ok: true, cached: true, matches: cache.data }
  }

  const seasonId = process.env.FIFA_SEASON_ID ?? '285023'
  const url = `${FIFA_API}/calendar/matches?language=en&count=200&idCompetition=${COMPETITION_ID}&idSeason=${seasonId}`

  let arr: any[] = []
  try {
    const res = await fetch(url, { headers: HEADERS, signal: AbortSignal.timeout(10_000) })
    if (!res.ok) throw new Error(`FIFA ${res.status}`)
    const data = await res.json()
    arr = data?.Results ?? []
  } catch (e: any) {
    // Si FIFA falla, devolvemos la última caché si existe
    if (cache) return { ok: true, stale: true, matches: cache.data }
    return { ok: false, error: e.message, matches: [] }
  }

  const ko = arr
    .filter((m: any) => (m.MatchNumber ?? 0) >= 73)
    .sort((a: any, b: any) => (a.MatchNumber ?? 0) - (b.MatchNumber ?? 0))

  const matches: BracketMatch[] = ko.map((m: any) => {
    const home = m.Home
    const away = m.Away
    const homeScore: number | null = home?.Score ?? m.HomeTeamScore ?? null
    const awayScore: number | null = away?.Score ?? m.AwayTeamScore ?? null
    const officiality: number = m.OfficialityStatus ?? 0
    const hasScore = homeScore !== null && awayScore !== null

    let status: 'scheduled' | 'live' | 'finished' = 'scheduled'
    if (officiality >= 1 && hasScore) status = 'finished'
    else if (hasScore) status = 'live'

    const stageName = m.StageName?.[0]?.Description ?? ''

    return {
      number: m.MatchNumber,
      stage: STAGE_MAP[stageName] ?? 'r32',
      date: m.Date ?? '',
      status,
      home: { code: resolveCode(home), name: teamName(home), placeholder: m.PlaceHolderA ?? '' },
      away: { code: resolveCode(away), name: teamName(away), placeholder: m.PlaceHolderB ?? '' },
      homeScore,
      awayScore,
      homePens: m.HomeTeamPenaltyScore ?? null,
      awayPens: m.AwayTeamPenaltyScore ?? null,
    }
  })

  cache = { at: Date.now(), data: matches }
  return { ok: true, matches }
})
