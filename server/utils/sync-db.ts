/**
 * sync-db.ts — Lógica central de sincronización FIFA → Supabase
 *
 * Función reutilizable por:
 * - server/plugins/auto-sync.ts  (cron automático cada 60s)
 * - server/api/admin/sync.post.ts (botón manual del panel admin)
 */

import type { SupabaseClient } from '@supabase/supabase-js'
import type { FIFAMatch, FIFAScorer } from './fifa-api'

export interface SyncResult {
  success:        boolean
  matchesUpdated: number
  scorersUpdated: number
  errors:         string[]
  log:            string[]
  source:         string
  timestamp:      string
}

export async function syncToDatabase(
  client: SupabaseClient,
  opts: { matches?: boolean; scorers?: boolean } = {}
): Promise<SyncResult> {
  const syncMatches = opts.matches !== false
  const syncScorers = opts.scorers !== false

  const log: string[]    = []
  const errors: string[] = []
  let matchesUpdated = 0
  let scorersUpdated = 0
  let source = ''

  // ── Fetch nuestra BD: partidos con códigos de países ──────────────────────
  const { data: dbMatches } = await client
    .from('matches')
    .select(`
      id, status, home_score, away_score,
      home_country:countries!home_country_id(code),
      away_country:countries!away_country_id(code)
    `)
    .eq('stage', 'group')

  // ── Sync partidos ──────────────────────────────────────────────────────────
  if (syncMatches && dbMatches) {
    try {
      const { scrapeOrFetchMatches } = await import('./scraper')
      const { matches: fifaMatches, source: src } = await scrapeOrFetchMatches()
      source = src
      log.push(`[${src}] FIFA devolvió ${fifaMatches.length} partidos`)

      for (const fm of fifaMatches) {
        if (!fm.homeCode || !fm.awayCode) continue

        // Solo hay datos que actualizar si el partido está en juego o terminado
        if (fm.status === 'scheduled' && fm.homeScore == null) continue

        // Encontrar el partido en nuestra BD por códigos de equipos
        const dbMatch = (dbMatches as any[]).find(
          (m: any) => m.home_country?.code === fm.homeCode
                   && m.away_country?.code === fm.awayCode
        )
        if (!dbMatch) {
          // No logueamos "no encontrado" para evitar spam (puede ser fase de grupos futura)
          continue
        }

        // ¿Hay cambios reales?
        const needsUpdate =
          dbMatch.status     !== fm.status     ||
          dbMatch.home_score !== fm.homeScore  ||
          dbMatch.away_score !== fm.awayScore

        if (!needsUpdate) continue

        const payload: Record<string, any> = { status: fm.status }
        if (fm.homeScore !== null && fm.awayScore !== null) {
          payload.home_score = fm.homeScore
          payload.away_score = fm.awayScore
        }

        const { error } = await client
          .from('matches')
          .update(payload)
          .eq('id', dbMatch.id)

        if (error) {
          errors.push(`${fm.homeCode} vs ${fm.awayCode}: ${error.message}`)
        } else {
          matchesUpdated++
          log.push(`✓ ${fm.homeCode} ${fm.homeScore ?? '?'}–${fm.awayScore ?? '?'} ${fm.awayCode} [${fm.status}]`)
        }
      }
    } catch (e: any) {
      errors.push(`Error sync partidos: ${e.message}`)
    }
  }

  // ── Sync goleadores ────────────────────────────────────────────────────────
  if (syncScorers) {
    try {
      const { scrapeOrFetchScorers } = await import('./scraper')
      const { scorers: fifaScorers, source: src } = await scrapeOrFetchScorers()
      if (!source) source = src
      log.push(`[${src}] FIFA devolvió ${fifaScorers.length} goleadores`)

      if (fifaScorers.length > 0) {
        // Obtener IDs de países
        const { data: countries } = await client.from('countries').select('id, code')
        const codeToId = Object.fromEntries((countries ?? []).map((c: any) => [c.code, c.id]))

        for (const fs of fifaScorers) {
          if (!fs.playerName || fs.goals === 0) continue
          const countryId = fs.teamCode ? codeToId[fs.teamCode] : null

          const { error } = await client
            .from('top_scorers')
            .upsert(
              {
                player_name: fs.playerName,
                country_id:  countryId,
                goals:       fs.goals,
                assists:     fs.assists,
                matches:     fs.matches,
                updated_at:  new Date().toISOString(),
              },
              { onConflict: 'player_name' }
            )

          if (error) {
            errors.push(`Goleador ${fs.playerName}: ${error.message}`)
          } else {
            scorersUpdated++
          }
        }
      }
    } catch (e: any) {
      errors.push(`Error sync goleadores: ${e.message}`)
    }
  }

  return {
    success: errors.length === 0,
    matchesUpdated,
    scorersUpdated,
    errors,
    log,
    source,
    timestamp: new Date().toISOString(),
  }
}
