/**
 * GET /api/status
 * Endpoint público de salud — muestra el estado del sistema.
 * Útil para verificar en producción que todo funciona.
 */

import { createClient } from '@supabase/supabase-js'

export default defineEventHandler(async () => {
  const supabaseUrl    = process.env.SUPABASE_URL ?? ''
  const serviceRoleKey = process.env.SUPABASE_SERVICE_KEY
                      ?? process.env.SUPABASE_SERVICE_ROLE_KEY
                      ?? ''

  const status: Record<string, any> = {
    timestamp: new Date().toISOString(),
    env: {
      supabase:    !!supabaseUrl,
      serviceKey:  !!serviceRoleKey,
      fifaSeason:  process.env.FIFA_SEASON_ID ?? 'autodiscover',
      cronSecret:  !!process.env.CRON_SECRET,
    },
  }

  // Verificar conexión a Supabase
  if (supabaseUrl && serviceRoleKey) {
    try {
      const client = createClient(supabaseUrl, serviceRoleKey, {
        auth: { persistSession: false },
      })

      // Contar partidos y su estado
      const { data: matchStats } = await client
        .from('matches')
        .select('status')
        .eq('stage', 'group')

      const counts = (matchStats ?? []).reduce((acc: any, m: any) => {
        acc[m.status] = (acc[m.status] ?? 0) + 1
        return acc
      }, {})

      // Último goleador actualizado
      const { data: lastScorer } = await client
        .from('top_scorers')
        .select('player_name, goals, updated_at')
        .order('updated_at', { ascending: false })
        .limit(1)
        .single()

      // Usuarios con predicciones
      const { count: usersWithPreds } = await client
        .from('profiles')
        .select('id', { count: 'exact', head: true })
        .gt('total_predicted', 0)

      status.db = {
        connected: true,
        matches: counts,
        lastScorerUpdate: lastScorer?.updated_at ?? null,
        lastScorer: lastScorer ? `${lastScorer.player_name} (${lastScorer.goals} goles)` : null,
        usersWithPredictions: usersWithPreds ?? 0,
      }
    } catch (e: any) {
      status.db = { connected: false, error: e.message }
    }
  } else {
    status.db = { connected: false, error: 'Missing credentials' }
  }

  // Verificar acceso a FIFA API
  try {
    const res = await fetch(
      `https://api.fifa.com/api/v3/calendar/matches?language=en&count=1&idCompetition=17&idSeason=${process.env.FIFA_SEASON_ID ?? '285023'}`,
      {
        headers: { 'User-Agent': 'Mozilla/5.0', 'Origin': 'https://www.fifa.com' },
        signal: AbortSignal.timeout(5000),
      }
    )
    const data = await res.json()
    status.fifa = {
      reachable: res.ok,
      status: res.status,
      sampleMatch: data?.Results?.[0]
        ? `${data.Results[0].Home?.ShortClubName} vs ${data.Results[0].Away?.ShortClubName}`
        : null,
    }
  } catch (e: any) {
    status.fifa = { reachable: false, error: e.message }
  }

  return status
})
