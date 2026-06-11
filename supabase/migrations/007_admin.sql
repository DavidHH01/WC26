-- ============================================================
-- WC26 — Columna is_admin en perfiles
-- ============================================================
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT false;

-- Para marcar a un usuario como admin, ejecuta:
-- UPDATE public.profiles SET is_admin = true WHERE username = 'tu_usuario';
-- O por email:
-- UPDATE public.profiles SET is_admin = true
--   WHERE id = (SELECT id FROM auth.users WHERE email = 'tu@email.com');
