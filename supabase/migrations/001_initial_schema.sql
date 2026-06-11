-- ============================================================
-- WC26 — Mundial de Fútbol 2026
-- Schema inicial
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- GRUPOS (A–L, 12 grupos en WC2026 con 48 equipos)
-- ────────────────────────────────────────────────────────────
CREATE TABLE public.groups (
  id   SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE  -- 'A', 'B', ... 'L'
);

-- Seed inmediato de los 12 grupos
INSERT INTO public.groups (name) VALUES
  ('A'), ('B'), ('C'), ('D'), ('E'), ('F'),
  ('G'), ('H'), ('I'), ('J'), ('K'), ('L');


-- ────────────────────────────────────────────────────────────
-- PAÍSES (48 equipos participantes)
-- ────────────────────────────────────────────────────────────
CREATE TABLE public.countries (
  id       SERIAL PRIMARY KEY,
  name     TEXT NOT NULL UNIQUE,
  code     TEXT NOT NULL UNIQUE,  -- ISO 3166-1 alpha-3: ESP, FRA, BRA...
  flag     TEXT,                  -- emoji de bandera: 🇪🇸
  group_id INTEGER REFERENCES public.groups(id) ON DELETE SET NULL,

  -- Estadísticas de fase de grupos
  played        INTEGER NOT NULL DEFAULT 0,
  wins          INTEGER NOT NULL DEFAULT 0,
  draws         INTEGER NOT NULL DEFAULT 0,
  losses        INTEGER NOT NULL DEFAULT 0,
  goals_for     INTEGER NOT NULL DEFAULT 0,
  goals_against INTEGER NOT NULL DEFAULT 0,
  group_points  INTEGER NOT NULL DEFAULT 0,  -- pts en el grupo (3V/1E/0D)

  -- Fase de eliminatorias
  eliminated_round TEXT  -- NULL = aún en competición, 'group'/'r32'/'r16'/'qf'/'sf'/'final'
);


-- ────────────────────────────────────────────────────────────
-- PARTIDOS
-- ────────────────────────────────────────────────────────────
CREATE TABLE public.matches (
  id              SERIAL PRIMARY KEY,

  -- Equipos (NULL en fases iniciales del cuadro hasta que se definen)
  home_country_id INTEGER REFERENCES public.countries(id) ON DELETE SET NULL,
  away_country_id INTEGER REFERENCES public.countries(id) ON DELETE SET NULL,

  -- Resultado (NULL hasta que se juega)
  home_score INTEGER,
  away_score INTEGER,

  -- Clasificación del partido
  stage TEXT NOT NULL CHECK (stage IN (
    'group',
    'round_of_32',
    'round_of_16',
    'quarter_final',
    'semi_final',
    'third_place',
    'final'
  )),
  group_id INTEGER REFERENCES public.groups(id) ON DELETE SET NULL,  -- solo fase de grupos

  -- Cuadro / bracket
  match_number    INTEGER UNIQUE,     -- número oficial del partido (1–104)
  bracket_slot    TEXT,               -- ej. 'R32-1', 'R16-3', 'QF-2', 'SF-1', 'F'

  -- Info del partido
  match_date      TIMESTAMPTZ,
  venue           TEXT,
  city            TEXT,
  country_host    TEXT CHECK (country_host IN ('USA', 'CAN', 'MEX')),

  -- Estado
  status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN (
    'scheduled',  -- por jugar
    'live',       -- en juego
    'finished'    -- terminado
  )),

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ────────────────────────────────────────────────────────────
-- PERFILES DE USUARIO
-- Se crea automáticamente al registrarse (via trigger)
-- ────────────────────────────────────────────────────────────
CREATE TABLE public.profiles (
  id         UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username   TEXT UNIQUE NOT NULL,
  avatar_url TEXT,

  -- Puntuación acumulada
  total_points     INTEGER NOT NULL DEFAULT 0,
  exact_scores     INTEGER NOT NULL DEFAULT 0,  -- resultado exacto
  correct_results  INTEGER NOT NULL DEFAULT 0,  -- ganador/empate correcto
  total_predicted  INTEGER NOT NULL DEFAULT 0,  -- total de predicciones

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ────────────────────────────────────────────────────────────
-- PREDICCIONES
-- Una predicción por usuario por partido, bloqueada al iniciar
-- ────────────────────────────────────────────────────────────
CREATE TABLE public.predictions (
  id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID    NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  match_id INTEGER NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,

  -- Lo que predice el usuario
  home_score INTEGER NOT NULL CHECK (home_score >= 0),
  away_score INTEGER NOT NULL CHECK (away_score >= 0),

  -- Calculado automáticamente cuando el partido termina
  points_earned INTEGER NOT NULL DEFAULT 0,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE (user_id, match_id)  -- una sola predicción por partido
);


-- ────────────────────────────────────────────────────────────
-- MÁXIMOS GOLEADORES
-- ────────────────────────────────────────────────────────────
CREATE TABLE public.top_scorers (
  id          SERIAL PRIMARY KEY,
  player_name TEXT    NOT NULL,
  country_id  INTEGER REFERENCES public.countries(id) ON DELETE CASCADE,
  position    TEXT,           -- 'GK', 'DF', 'MF', 'FW'
  goals       INTEGER NOT NULL DEFAULT 0,
  assists     INTEGER NOT NULL DEFAULT 0,
  matches     INTEGER NOT NULL DEFAULT 0,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ════════════════════════════════════════════════════════════
-- FUNCIONES Y TRIGGERS
-- ════════════════════════════════════════════════════════════

-- ── 1. Crear perfil automáticamente al registrarse ──────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, username)
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'username',
      split_part(NEW.email, '@', 1)
    )
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();


-- ── 2. Calcular puntos de una predicción ────────────────────
--   3 pts → resultado exacto
--   1 pt  → ganador/empate correcto pero marcador erróneo
--   0 pts → fallo total
CREATE OR REPLACE FUNCTION public.calculate_prediction_points(
  p_home_actual  INTEGER,
  p_away_actual  INTEGER,
  p_home_pred    INTEGER,
  p_away_pred    INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  -- Resultado exacto
  IF p_home_pred = p_home_actual AND p_away_pred = p_away_actual THEN
    RETURN 3;
  END IF;

  -- Ganador / empate correcto
  IF (p_home_actual > p_away_actual AND p_home_pred > p_away_pred) OR
     (p_home_actual < p_away_actual AND p_home_pred < p_away_pred) OR
     (p_home_actual = p_away_actual AND p_home_pred = p_away_pred) THEN
    RETURN 1;
  END IF;

  RETURN 0;
END;
$$;


-- ── 3. Actualizar puntos cuando se cierra un partido ────────
CREATE OR REPLACE FUNCTION public.update_points_on_match_finish()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Solo actuar cuando el partido pasa a 'finished'
  IF NEW.status = 'finished'
     AND NEW.home_score IS NOT NULL
     AND NEW.away_score IS NOT NULL
     AND (OLD.status <> 'finished' OR OLD.home_score IS DISTINCT FROM NEW.home_score OR OLD.away_score IS DISTINCT FROM NEW.away_score)
  THEN
    -- Actualizar puntos de cada predicción de este partido
    UPDATE public.predictions
    SET
      points_earned = public.calculate_prediction_points(
        NEW.home_score, NEW.away_score,
        home_score, away_score
      ),
      updated_at = NOW()
    WHERE match_id = NEW.id;

    -- Recalcular totales del perfil para todos los afectados
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

CREATE TRIGGER on_match_finished
  AFTER UPDATE ON public.matches
  FOR EACH ROW
  EXECUTE FUNCTION public.update_points_on_match_finish();


-- ── 4. Actualizar updated_at automáticamente ────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_predictions_updated_at
  BEFORE UPDATE ON public.predictions
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


-- ════════════════════════════════════════════════════════════
-- VISTAS
-- ════════════════════════════════════════════════════════════

-- ── Clasificación global (leaderboard) ──────────────────────
CREATE VIEW public.leaderboard AS
SELECT
  p.id,
  p.username,
  p.avatar_url,
  p.total_points,
  p.exact_scores,
  p.correct_results,
  p.total_predicted,
  RANK() OVER (ORDER BY p.total_points DESC, p.exact_scores DESC) AS rank
FROM public.profiles p
ORDER BY p.total_points DESC, p.exact_scores DESC;

-- ── Clasificación de grupo ───────────────────────────────────
CREATE VIEW public.group_standings AS
SELECT
  g.name  AS group_name,
  c.id,
  c.name,
  c.code,
  c.flag,
  c.played,
  c.wins,
  c.draws,
  c.losses,
  c.goals_for,
  c.goals_against,
  (c.goals_for - c.goals_against) AS goal_diff,
  c.group_points,
  RANK() OVER (
    PARTITION BY g.id
    ORDER BY c.group_points DESC,
             (c.goals_for - c.goals_against) DESC,
             c.goals_for DESC
  ) AS position
FROM public.countries c
JOIN public.groups    g ON c.group_id = g.id
ORDER BY g.name, position;


-- ════════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS)
-- ════════════════════════════════════════════════════════════

ALTER TABLE public.profiles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.countries     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.predictions   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.top_scorers   ENABLE ROW LEVEL SECURITY;

-- Tablas públicas de solo lectura (grupos, países, partidos, goleadores)
CREATE POLICY "Lectura pública de grupos"
  ON public.groups FOR SELECT USING (true);

CREATE POLICY "Lectura pública de países"
  ON public.countries FOR SELECT USING (true);

CREATE POLICY "Lectura pública de partidos"
  ON public.matches FOR SELECT USING (true);

CREATE POLICY "Lectura pública de goleadores"
  ON public.top_scorers FOR SELECT USING (true);

-- Perfiles: cualquiera puede leer, solo el propietario puede actualizar
CREATE POLICY "Perfiles visibles para todos"
  ON public.profiles FOR SELECT USING (true);

CREATE POLICY "Usuario actualiza su propio perfil"
  ON public.profiles FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- El trigger necesita poder insertar perfiles
CREATE POLICY "Sistema puede insertar perfiles"
  ON public.profiles FOR INSERT WITH CHECK (true);

-- Predicciones: cada usuario ve y gestiona solo las suyas
CREATE POLICY "Usuario ve sus predicciones"
  ON public.predictions FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuario crea sus predicciones"
  ON public.predictions FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuario actualiza sus predicciones"
  ON public.predictions FOR UPDATE
  USING (
    auth.uid() = user_id
    AND (SELECT status FROM public.matches WHERE id = match_id) = 'scheduled'
  )
  WITH CHECK (auth.uid() = user_id);


-- ════════════════════════════════════════════════════════════
-- ÍNDICES
-- ════════════════════════════════════════════════════════════

CREATE INDEX idx_countries_group    ON public.countries(group_id);
CREATE INDEX idx_matches_stage      ON public.matches(stage);
CREATE INDEX idx_matches_group      ON public.matches(group_id);
CREATE INDEX idx_matches_status     ON public.matches(status);
CREATE INDEX idx_matches_date       ON public.matches(match_date);
CREATE INDEX idx_predictions_user   ON public.predictions(user_id);
CREATE INDEX idx_predictions_match  ON public.predictions(match_id);
CREATE INDEX idx_top_scorers_goals  ON public.top_scorers(goals DESC);
