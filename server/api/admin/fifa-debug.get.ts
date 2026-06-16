/**
 * GET /api/admin/fifa-debug
 * Endpoint de diagnóstico para encontrar el Season ID correcto de la API FIFA.
 * Solo accesible desde el servidor (no expuesto en producción de forma sensible).
 */
export default defineEventHandler(async () => {
  const FIFA_API = 'https://api.fifa.com/api/v3'
  const COMPETITION_ID = '17'
  const HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/125.0.0.0 Safari/537.36',
    'Accept': 'application/json',
    'Origin': 'https://www.fifa.com',
    'Referer': 'https://www.fifa.com/',
  }

  const results: Record<string, any> = {}

  // 1. Endpoint de la competición
  try {
    const r = await fetch(`${FIFA_API}/competitions/${COMPETITION_ID}?language=en`, { headers: HEADERS })
    results.competition = r.ok ? await r.json() : `HTTP ${r.status}`
  } catch (e: any) { results.competition = `Error: ${e.message}` }

  // 2. Listado de temporadas
  try {
    const r = await fetch(`${FIFA_API}/competitions/${COMPETITION_ID}/seasons?language=en&count=10`, { headers: HEADERS })
    results.seasons = r.ok ? await r.json() : `HTTP ${r.status}`
  } catch (e: any) { results.seasons = `Error: ${e.message}` }

  // 3. Filtrar por fecha 2026 — la clave para encontrar el Season ID
  const dateFilters = [
    `from=2026-06-01`,
    `datefrom=2026-06-01`,
    `startDate=2026-06-01&endDate=2026-07-31`,
    `DateFrom=2026-06-01`,
    `dateFrom=2026-06-01&dateTo=2026-07-31`,
  ]
  results.dateFilterTests = {}
  for (const filter of dateFilters) {
    try {
      const url = `${FIFA_API}/calendar/matches?language=en&count=3&idCompetition=${COMPETITION_ID}&${filter}`
      const r = await fetch(url, { headers: HEADERS })
      const text = await r.text()
      let parsed: any
      try { parsed = JSON.parse(text) } catch { parsed = text.slice(0, 200) }
      results.dateFilterTests[filter] = {
        status: r.status,
        firstIdSeason: parsed?.Results?.[0]?.IdSeason ?? null,
        firstDate: parsed?.Results?.[0]?.Date ?? null,
        count: parsed?.Results?.length ?? 0,
      }
    } catch (e: any) { results.dateFilterTests[filter] = `Error: ${e.message}` }
  }

  // 4. Intentar orden descendente (más reciente primero)
  try {
    const url = `${FIFA_API}/calendar/matches?language=en&count=3&idCompetition=${COMPETITION_ID}&sortOrder=desc`
    const r = await fetch(url, { headers: HEADERS })
    results.descOrder = r.ok ? {
      data: await r.json(),
    } : `HTTP ${r.status}`
  } catch (e: any) { results.descOrder = `Error: ${e.message}` }

  // 5. Prueba candidatos ampliada
  const candidates = [
    '316459', '315096', '311234', '308001', '305500', '303235', '300765',
    '298032', '295368', '290945', '288018', '285063', '282610',
  ]
  results.candidateHits = []
  for (const c of candidates) {
    try {
      const r = await fetch(`${FIFA_API}/calendar/matches?language=en&count=1&idCompetition=${COMPETITION_ID}&idSeason=${c}`, { headers: HEADERS })
      if (r.ok) {
        const d = await r.json()
        if (d?.Results?.length > 0) {
          results.candidateHits.push({ id: c, count: d.Results.length, firstDate: d.Results[0]?.Date })
        }
      }
    } catch {}
  }

  // 6. Raw scorers endpoints
  const seasonId = '285023'
  const scorerEndpoints = [
    `${FIFA_API}/topscorers?language=en&idCompetition=${COMPETITION_ID}&idSeason=${seasonId}`,
    `${FIFA_API}/award/players?language=en&idCompetition=${COMPETITION_ID}&idSeason=${seasonId}&type=goal`,
    `${FIFA_API}/calendar/matches?language=en&count=5&idCompetition=${COMPETITION_ID}&idSeason=${seasonId}&from=2026-06-11`,
  ]
  results.scorerRaw = {}
  for (const url of scorerEndpoints) {
    const key = (url.split('?')[0] ?? url).split('/').slice(-2).join('/')
    try {
      const r = await fetch(url, { headers: HEADERS })
      const text = await r.text()
      let parsed: any
      try { parsed = JSON.parse(text) } catch { parsed = text.slice(0, 500) }
      // Solo devolvemos las primeras 2 filas para no saturar
      results.scorerRaw[key + '?...'] = {
        status: r.status,
        count: parsed?.Results?.length ?? parsed?.TopScorers?.length ?? 0,
        firstItem: parsed?.Results?.[0] ?? parsed?.TopScorers?.[0] ?? parsed,
      }
    } catch (e: any) {
      results.scorerRaw[key + '?...'] = `Error: ${e.message}`
    }
  }

  // 7. Partidos ya jugados (para ver si tienen scores)
  try {
    const r = await fetch(
      `${FIFA_API}/calendar/matches?language=en&count=10&idCompetition=${COMPETITION_ID}&idSeason=${seasonId}&from=2026-06-11`,
      { headers: HEADERS }
    )
    if (r.ok) {
      const d = await r.json()
      results.matches2026 = (d.Results ?? []).map((m: any) => ({
        date: m.Date,
        home: m.Home?.ShortClubName ?? m.Home?.Abbreviation,
        away: m.Away?.ShortClubName ?? m.Away?.Abbreviation,
        homeScore: m.Home?.Score,
        awayScore: m.Away?.Score,
        status: m.MatchStatus,
        idSeason: m.IdSeason,
      }))
    }
  } catch (e: any) { results.matches2026 = `Error: ${e.message}` }

  return results
})
