/**
 * POST /api/admin/sync
 *
 * Endpoint para el panel de administración — permite lanzar
 * una sincronización manual desde el botón "↻ Sync ahora".
 *
 * La lógica de sync está en server/utils/sync-db.ts (compartida
 * con el plugin auto-sync que corre cada 60s automáticamente).
 */

import { serverSupabaseServiceRole } from '#supabase/server'
import { syncToDatabase } from '../../utils/sync-db'

export default defineEventHandler(async (event) => {
  // ── Auth: solo admins ─────────────────────────────────────────────────────
  const client = await serverSupabaseServiceRole(event)

  const auth = getHeader(event, 'authorization')
  if (!auth?.startsWith('Bearer ')) {
    throw createError({ statusCode: 401, message: 'No autorizado' })
  }

  const token = auth.replace('Bearer ', '')
  const { data: { user }, error: authErr } = await client.auth.getUser(token)
  if (authErr || !user) throw createError({ statusCode: 401, message: 'Token inválido' })

  const { data: profile } = await client
    .from('profiles')
    .select('is_admin')
    .eq('id', user.id)
    .single()

  if (!(profile as any)?.is_admin) throw createError({ statusCode: 403, message: 'Solo admins' })

  // ── Opciones del body ─────────────────────────────────────────────────────
  const body = await readBody(event).catch(() => ({}))
  const opts = {
    matches: body.matches !== false,
    scorers: body.scorers !== false,
  }

  // ── Ejecutar sync ─────────────────────────────────────────────────────────
  const result = await syncToDatabase(client, opts)

  return result
})
