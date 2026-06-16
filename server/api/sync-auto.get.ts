/**
 * GET /api/sync-auto
 *
 * Sincronización AUTOMÁTICA disparada por la propia web.
 * No requiere secreto ni cron externo: cada vez que un usuario carga la web,
 * el cliente llama a este endpoint y los datos se actualizan solos.
 *
 * Para no saturar la API de FIFA, hay un THROTTLE en el servidor: aunque lo
 * llamen 100 visitantes, solo sincroniza una vez cada SYNC_THROTTLE_MS.
 *
 * Ventajas frente al cron externo:
 *   · No se "para" nunca (no depende de cron-job.org ni de setInterval).
 *   · Cero configuración en producción.
 *   · Durante los partidos (cuando hay gente mirando) se actualiza solo.
 */

import { createClient } from '@supabase/supabase-js'
import { syncToDatabase } from '../utils/sync-db'

// Throttle a nivel de instancia (memoria del proceso).
// En Vercel cada instancia "caliente" recuerda esto durante varios minutos,
// así que basta para limitar las llamadas a FIFA a ~1 cada 30s por instancia.
const SYNC_THROTTLE_MS = 30_000
let lastSyncAt = 0
let lastResult: { matchesUpdated: number; scorersUpdated: number; timestamp: string } | null = null
let inFlight: Promise<any> | null = null

export default defineEventHandler(async () => {
  const now = Date.now()

  // Si sincronizamos hace poco, devolvemos el último resultado sin tocar FIFA
  if (now - lastSyncAt < SYNC_THROTTLE_MS && lastResult) {
    return { ok: true, throttled: true, ...lastResult }
  }

  // Si ya hay una sincronización en curso, reutilizamos su promesa
  if (inFlight) {
    await inFlight
    return { ok: true, coalesced: true, ...(lastResult ?? {}) }
  }

  const supabaseUrl    = process.env.SUPABASE_URL ?? ''
  const serviceRoleKey = process.env.SUPABASE_SERVICE_KEY
                      ?? process.env.SUPABASE_SERVICE_ROLE_KEY
                      ?? ''

  if (!supabaseUrl || !serviceRoleKey) {
    return { ok: false, error: 'Missing Supabase credentials' }
  }

  lastSyncAt = now

  inFlight = (async () => {
    const client = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    })
    const result = await syncToDatabase(client, { matches: true, scorers: true })
    lastResult = {
      matchesUpdated: result.matchesUpdated,
      scorersUpdated: result.scorersUpdated,
      timestamp:      result.timestamp,
    }
    if (result.matchesUpdated > 0 || result.scorersUpdated > 0) {
      console.log(`[AutoSync] ✓ ${result.matchesUpdated} partidos · ${result.scorersUpdated} goleadores [${result.source}]`)
    }
    if (result.errors.length) {
      for (const e of result.errors) console.warn(`[AutoSync] ⚠️  ${e}`)
    }
    return result
  })()

  try {
    await inFlight
  } catch (e: any) {
    return { ok: false, error: e.message }
  } finally {
    inFlight = null
  }

  return { ok: true, ...(lastResult ?? {}) }
})
