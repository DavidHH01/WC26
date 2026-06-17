-- ============================================================
-- WC26 — Cálculo automático de la clasificación de grupos
-- ============================================================
-- La vista public.group_standings lee columnas almacenadas en la tabla
-- countries (played, wins, draws, losses, goals_for, goals_against,
-- group_points), pero nada las rellenaba al terminar un partido.
--
-- Aquí creamos:
--   1) recalculate_group_standings(): recalcula TODAS las estadísticas de
--      cada selección a partir de los partidos de grupo ya finalizados.
--   2) Un trigger que la ejecuta cada vez que cambia un partido.
--   3) Una ejecución inicial para poblar los datos existentes.
--
-- Reglas: victoria = 3 pts, empate = 1 pt, derrota = 0 pts.
-- ============================================================

CREATE OR REPLACE FUNCTION public.recalculate_group_standings()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  WITH stats AS (
    SELECT
      ct.id AS country_id,
      COUNT(m.id) AS played,
      COUNT(*) FILTER (WHERE
        (m.home_country_id = ct.id AND m.home_score > m.away_score) OR
        (m.away_country_id = ct.id AND m.away_score > m.home_score)
      ) AS wins,
      COUNT(*) FILTER (WHERE m.home_score = m.away_score) AS draws,
      COUNT(*) FILTER (WHERE
        (m.home_country_id = ct.id AND m.home_score < m.away_score) OR
        (m.away_country_id = ct.id AND m.away_score < m.home_score)
      ) AS losses,
      COALESCE(SUM(CASE WHEN m.home_country_id = ct.id THEN m.home_score ELSE m.away_score END), 0) AS goals_for,
      COALESCE(SUM(CASE WHEN m.home_country_id = ct.id THEN m.away_score ELSE m.home_score END), 0) AS goals_against
    FROM public.countries ct
    LEFT JOIN public.matches m
      ON  m.stage  = 'group'
      AND m.status = 'finished'
      AND m.home_score IS NOT NULL
      AND m.away_score IS NOT NULL
      AND (m.home_country_id = ct.id OR m.away_country_id = ct.id)
    GROUP BY ct.id
  )
  UPDATE public.countries c
  SET played        = s.played,
      wins          = s.wins,
      draws         = s.draws,
      losses        = s.losses,
      goals_for     = s.goals_for,
      goals_against = s.goals_against,
      group_points  = s.wins * 3 + s.draws
  FROM stats s
  WHERE c.id = s.country_id;
END;
$$;


-- ── Trigger que recalcula al cambiar cualquier partido ───────────
CREATE OR REPLACE FUNCTION public.trg_recalc_group_standings()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public.recalculate_group_standings();
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS recalc_group_standings ON public.matches;
CREATE TRIGGER recalc_group_standings
  AFTER INSERT OR DELETE OR UPDATE OF status, home_score, away_score
  ON public.matches
  FOR EACH STATEMENT
  EXECUTE FUNCTION public.trg_recalc_group_standings();


-- ── Poblar los datos ya existentes una vez ───────────────────────
SELECT public.recalculate_group_standings();
