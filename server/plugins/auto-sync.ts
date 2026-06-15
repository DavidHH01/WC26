/**
 * auto-sync.ts — Plugin de Nitro para sincronización automática
 *
 * Se ejecuta al arrancar el servidor y lanza un bucle que scrapea
 * FIFA.com cada 60 segundos, actualizando resultados y goleadores
 * en Supabase sin necesidad de intervención manual.
 *
 * Requiere: SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY en el .env
 */

import { createClient } from '@supabase/supabase-js'
import { syncToDatabase } from '../utils/sync-db'

export default defineNitroPlugin(async () => {
  // ── Leer configuración ───────────────────────────────────────────────────
  const config         = useRuntimeConfig()
  const supabaseUrl    = (process.env.SUPABASE_URL ?? '') as string
  const serviceRoleKey = (config.supabaseServiceRoleKey ?? process.env.SUPABASE_SERVICE_ROLE_KEY ?? '') as string

  if (!supabaseUrl || !serviceRoleKey) {
    console.warn('[AutoSync] ⚠️  SUPABASE_SERVICE_ROLE_KEY no configurada — sync automático desactivado.')
    console.warn('[AutoSync]    Añade SUPABASE_SERVICE_ROLE_KEY a tu .env para activarlo.')
    return
  }

  // Cliente de Supabase con rol de servicio (bypasa RLS)
  const client = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  })

  let consecutiveErrors = 0
  const MAX_ERRORS      = 5   // tras 5 errores seguidos, esperar 10 min antes de reintentar
  const INTERVAL_MS     = 60_000  // 60 segundos

  // ── Función de sync ──────────────────────────────────────────────────────
  async function doSync() {
    try {
      const result = await syncToDatabase(client, { matches: true, scorers: true })

      consecutiveErrors = 0  // reset on success

      // Solo logueamos si hay cambios (para no llenar la consola)
      if (result.matchesUpdated > 0 || result.scorersUpdated > 0) {
        console.log(
          `[AutoSync] ✓ ${result.matchesUpdated} partidos · ${result.scorersUpdated} goleadores`
          + ` [${result.source}] ${new Date().toLocaleTimeString('es-ES')}`
        )
        for (const line of result.log) {
          if (line.startsWith('✓')) console.log(`[AutoSync]   ${line}`)
        }
      }

      if (result.errors.length > 0) {
        for (const err of result.errors) console.warn(`[AutoSync] ⚠️  ${err}`)
      }
    } catch (e: any) {
      consecutiveErrors++
      console.error(`[AutoSync] ✗ Error (${consecutiveErrors}/${MAX_ERRORS}): ${e.message}`)

      if (consecutiveErrors >= MAX_ERRORS) {
        console.error('[AutoSync] Demasiados errores seguidos — pausando 10 min.')
        consecutiveErrors = 0
        await new Promise(r => setTimeout(r, 10 * 60 * 1000))
      }
    }
  }

  // ── Arranque con delay para que el servidor esté listo ───────────────────
  console.log('[AutoSync] ✓ Plugin cargado — primera sync en 5s, luego cada 60s.')

  // Esperamos 5 segundos a que el servidor esté completamente iniciado
  await new Promise(r => setTimeout(r, 5_000))

  // Primera ejecución
  await doSync()

  // Intervalo cada 60 segundos
  const timer = setInterval(doSync, INTERVAL_MS)

  // Limpieza al cerrar el servidor
  // Nitro expone `onClose` en el contexto del plugin (Nitro v2.5+)
  // Si no está disponible, el timer se limpiará solo al morir el proceso
  // @ts-ignore
  if (typeof globalThis.__nitroApp?.hooks?.hook === 'function') {
    // @ts-ignore
    globalThis.__nitroApp.hooks.hook('close', () => {
      clearInterval(timer)
      console.log('[AutoSync] Detenido.')
    })
  }
})
