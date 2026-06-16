/**
 * Plugin de cliente: dispara la sincronización automática FIFA → BD.
 *
 * Mientras un usuario tenga la web abierta, cada 60s se llama a /api/sync-auto,
 * que actualiza marcadores, estados (programado/en vivo/finalizado) y goleadores.
 * El servidor tiene throttle, así que aunque haya muchos usuarios solo se
 * consulta a FIFA una vez cada ~30s.
 *
 * Resultado: los resultados y la clasificación se actualizan solos, sin cron
 * externo y sin tocar el panel de admin.
 */
export default defineNuxtPlugin(() => {
  if (import.meta.server) return

  const INTERVAL_MS = 60_000
  let timer: ReturnType<typeof setInterval> | null = null

  const trigger = () => {
    // Solo si la pestaña está visible (no malgastar llamadas en segundo plano)
    if (document.visibilityState !== 'visible') return
    $fetch('/api/sync-auto').catch(() => { /* silencioso: no romper la UI */ })
  }

  // Primera sincronización al cargar
  trigger()

  // Sincronización periódica
  timer = setInterval(trigger, INTERVAL_MS)

  // Cuando el usuario vuelve a la pestaña, sincroniza al instante
  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') trigger()
  })

  // Limpieza al salir
  window.addEventListener('beforeunload', () => {
    if (timer) clearInterval(timer)
  })
})
