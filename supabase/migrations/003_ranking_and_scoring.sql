-- ============================================================
-- WC26 — Ranking FIFA y sistema de puntuación dinámico
-- ============================================================

-- ── Añadir puntos FIFA a países ──────────────────────────────
ALTER TABLE public.countries
  ADD COLUMN IF NOT EXISTS fifa_points NUMERIC(7,2);

-- ── Añadir snapshot de puntos FIFA en cada partido ───────────
-- (se guardan al crear el partido para que el cálculo sea inmutable
--  aunque el ranking cambie en el futuro)
ALTER TABLE public.matches
  ADD COLUMN IF NOT EXISTS home_fifa_points NUMERIC(7,2),
  ADD COLUMN IF NOT EXISTS away_fifa_points NUMERIC(7,2);

-- ── También guardar el round (jornada) en partidos de grupos ─
ALTER TABLE public.matches
  ADD COLUMN IF NOT EXISTS match_round INTEGER;  -- 1, 2, 3 en grupos


-- ============================================================
-- FUNCIÓN DE PUNTUACIÓN CON RANKING FIFA
-- ============================================================
-- Sistema:
--   Base:  3 pts → resultado exacto
--          1 pt  → ganador/empate correcto
--          0 pts → fallo
--
--   Bonus por sorpresa (underdog gana y lo acertaste):
--          +FLOOR(diff_FIFA / 100), máximo +5
--          Ej: España (1876) pierde contra Cabo Verde (1469)
--              diff = 407 → FLOOR(407/100) = 4 pts extra
--
--   Bonus partido débil (media FIFA < 1550):
--          +1 pt si aciertas resultado
--          Ej: Jordania (1391) vs Irak (1447), media = 1419 → +1
--
--   Máximo posible: 3 + 5 + 1 = 9 pts
-- ============================================================
CREATE OR REPLACE FUNCTION public.calculate_prediction_points(
  p_home_actual  INTEGER,
  p_away_actual  INTEGER,
  p_home_pred    INTEGER,
  p_away_pred    INTEGER,
  p_home_fifa    NUMERIC DEFAULT NULL,
  p_away_fifa    NUMERIC DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  v_base          INTEGER := 0;
  v_bonus         INTEGER := 0;
  v_rating_diff   NUMERIC := 0;
  v_avg_rating    NUMERIC := 0;
  v_actual_result TEXT;
  v_pred_result   TEXT;
  v_stronger      TEXT;
BEGIN
  -- Resultado real
  IF    p_home_actual > p_away_actual THEN v_actual_result := 'home';
  ELSIF p_home_actual < p_away_actual THEN v_actual_result := 'away';
  ELSE                                      v_actual_result := 'draw';
  END IF;

  -- Resultado predicho
  IF    p_home_pred > p_away_pred THEN v_pred_result := 'home';
  ELSIF p_home_pred < p_away_pred THEN v_pred_result := 'away';
  ELSE                                  v_pred_result := 'draw';
  END IF;

  -- Puntos base
  IF p_home_pred = p_home_actual AND p_away_pred = p_away_actual THEN
    v_base := 3;
  ELSIF v_pred_result = v_actual_result THEN
    v_base := 1;
  ELSE
    RETURN 0;
  END IF;

  -- Bonificaciones FIFA (solo si tenemos los puntos de ambos equipos)
  IF p_home_fifa IS NOT NULL AND p_away_fifa IS NOT NULL THEN
    v_rating_diff := ABS(p_home_fifa - p_away_fifa);
    v_avg_rating  := (p_home_fifa + p_away_fifa) / 2.0;

    -- Equipo más fuerte (mayor puntuación FIFA)
    IF p_home_fifa >= p_away_fifa THEN v_stronger := 'home';
    ELSE                               v_stronger := 'away';
    END IF;

    -- Bonus sorpresa: gana el underdog y lo predijiste correctamente
    IF v_actual_result <> 'draw' AND v_actual_result <> v_stronger THEN
      v_bonus := v_bonus + LEAST(5, FLOOR(v_rating_diff / 100)::INTEGER);
    END IF;

    -- Bonus partido débil: ambos equipos por debajo del umbral
    IF v_avg_rating < 1550 THEN
      v_bonus := v_bonus + 1;
    END IF;
  END IF;

  RETURN v_base + v_bonus;
END;
$$;


-- ── Actualizar trigger para pasar puntos FIFA ─────────────────
CREATE OR REPLACE FUNCTION public.update_points_on_match_finish()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.status = 'finished'
     AND NEW.home_score IS NOT NULL
     AND NEW.away_score IS NOT NULL
     AND (
       OLD.status <> 'finished'
       OR OLD.home_score IS DISTINCT FROM NEW.home_score
       OR OLD.away_score IS DISTINCT FROM NEW.away_score
     )
  THEN
    -- Recalcular puntos de cada predicción con ranking FIFA
    UPDATE public.predictions
    SET
      points_earned = public.calculate_prediction_points(
        NEW.home_score, NEW.away_score,
        home_score,    away_score,
        NEW.home_fifa_points,
        NEW.away_fifa_points
      ),
      updated_at = NOW()
    WHERE match_id = NEW.id;

    -- Actualizar totales en perfiles
    UPDATE public.profiles p
    SET
      total_points    = (SELECT COALESCE(SUM(points_earned), 0) FROM public.predictions WHERE user_id = p.id),
      exact_scores    = (SELECT COUNT(*) FROM public.predictions WHERE user_id = p.id AND points_earned = 3),
      correct_results = (SELECT COUNT(*) FROM public.predictions WHERE user_id = p.id AND points_earned >= 1),
      total_predicted = (SELECT COUNT(*) FROM public.predictions WHERE user_id = p.id),
      updated_at      = NOW()
    WHERE p.id IN (
      SELECT user_id FROM public.predictions WHERE match_id = NEW.id
    );
  END IF;

  RETURN NEW;
END;
$$;
