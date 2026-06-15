/**
 * GET /api/cron/sync?secret=TU_CRON_SECRET
 * Versión GET para probar el cron manualmente desde el navegador.
 * Mismo comportamiento que el POST (usado por cron-job.org).
 */

import { createClient } from '@supabase/supabase-js'
import { syncToDatabase } from '../../utils/sync-db'

export default defineEventHandler(async (event) => {
  const cronSecret = process.env.CRON_SECRET ?? ''

  if (cronSecret) {
    const querySecret = (getQuery(event).secret as string) ?? ''
    if (querySecret !== cronSecret) {
      throw createError({ statusCode: 401, message: 'Unauthorized — añade ?secret=TU_CRON_SECRET' })
    }
  }

  const supabaseUrl    = process.env.SUPABASE_URL ?? ''
  const serviceRoleKey = process.env.SUPABASE_SERVICE_KEY
                      ?? process.env.SUPABASE_SERVICE_ROLE_KEY
                      ?? ''

  if (!supabaseUrl || !serviceRoleKey) {
    throw createError({ statusCode: 500, message: 'Missing Supabase credentials' })
  }

  const client = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  })

  const result = await syncToDatabase(client, { matches: true, scorers: true })

  if (result.matchesUpdated > 0 || result.scorersUpdated > 0) {
    console.log(`[Cron GET] ✓ ${result.matchesUpdated} partidos · ${result.scorersUpdated} goleadores`)
  }

  return {
    ok: true,
    matchesUpdated: result.matchesUpdated,
    scorersUpdated: result.scorersUpdated,
    source: result.source,
    errors: result.errors,
    log: result.log,
    timestamp: result.timestamp,
  }
})
