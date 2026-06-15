-- Constraint unique en player_name para poder hacer upsert desde el scraper
ALTER TABLE public.top_scorers
  ADD CONSTRAINT top_scorers_player_name_key UNIQUE (player_name);
