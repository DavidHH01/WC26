/**
 * POST /api/cron/sync
 *
 * Endpoint para sincronización automática via cron externo.
 * Compatible con Vercel (serverless), Railway, Render, etc.
 *
 * Llamar desde cron-job.org o similar cada 60 segundos:
 *   POST https://tuapp.vercel.app/api/cron/sync
 *   Header: x-cron-secret: <CRON_SECRET del .env>
 *
 * También funciona como Vercel Cron Job (plan Pro):
 *   vercel.json → { "crons": [{ "path": "/api/cron/sync", "schedule": "* * * * *" }] }
 */

import { createClient } from '@supabase/supabase-js'
import { syncToDatabase } from '../../utils/sync-db'

// Acepta GET y POST para poder probarlo desde el navegador
export default defineEventHandler(async (event) => {
  // ── Validar token secreto ────────────────────────────────────────────────
  const cronSecret = process.env.CRON_SECRET ?? ''

  if (cronSecret) {
    // Acepta el secreto en cabecera x-cron-secret o como query param ?secret=
    const headerSecret = getHeader(event, 'x-cron-secret') ?? ''
    const querySecret  = (getQuery(event).secret as string) ?? ''

    if (headerSecret !== cronSecret && querySecret !== cronSecret) {
      throw createError({ statusCode: 401, message: 'Unauthorized — añade ?secret=TU_CRON_SECRET a la URL' })
    }
  }

  // ── Crear cliente Supabase con service role ──────────────────────────────
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

  // ── Ejecutar sync ────────────────────────────────────────────────────────
  const result = await syncToDatabase(client, { matches: true, scorers: true })

  // Log en consola del servidor (visible en Vercel logs)
  if (result.matchesUpdated > 0 || result.scorersUpdated > 0) {
    console.log(`[Cron] ✓ ${result.matchesUpdated} partidos · ${result.scorersUpdated} goleadores [${result.source}]`)
    for (const line of result.log) {
      if (line.startsWith('✓')) console.log(`[Cron]   ${line}`)
    }
  }
  if (result.errors.length > 0) {
    for (const err of result.errors) console.warn(`[Cron] ⚠️  ${err}`)
  }

  return {
    ok: true,
    matchesUpdated: result.matchesUpdated,
    scorersUpdated: result.scorersUpdated,
    errors: result.errors,
    timestamp: result.timestamp,
  }
})
