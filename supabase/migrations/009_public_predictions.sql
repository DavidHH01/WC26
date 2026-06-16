-- ============================================================
-- WC26 — Predicciones de otros visibles en partidos FINALIZADOS
-- ============================================================
-- Permite a cualquier usuario autenticado ver las predicciones del resto,
-- pero ÚNICAMENTE para partidos cuyo estado ya es 'finished'.
--
-- Las predicciones de partidos 'scheduled' o 'live' siguen siendo PRIVADAS
-- (la política existente "Usuario ve sus predicciones" sigue cubriendo eso),
-- así que nadie puede copiar antes de que el partido empiece.
--
-- Las políticas RLS de tipo PERMISSIVE se combinan con OR: con esta nueva
-- política, un usuario puede ver SUS predicciones (cualquier estado) O las de
-- CUALQUIERA en partidos finalizados.
-- ============================================================

DROP POLICY IF EXISTS "Predicciones visibles en partidos finalizados" ON public.predictions;

CREATE POLICY "Predicciones visibles en partidos finalizados"
  ON public.predictions FOR SELECT
  USING (
    (SELECT status FROM public.matches WHERE id = match_id) = 'finished'
  );
