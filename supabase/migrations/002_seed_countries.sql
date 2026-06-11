-- ============================================================
-- WC26 — Seed de países (48 selecciones, grupos oficiales)
-- ============================================================

INSERT INTO public.countries (name, code, flag, group_id) VALUES

-- ── GRUPO A ──────────────────────────────────────────────────
('México',                'MEX', '🇲🇽', (SELECT id FROM public.groups WHERE name='A')),
('Sudáfrica',             'RSA', '🇿🇦', (SELECT id FROM public.groups WHERE name='A')),
('Corea del Sur',         'KOR', '🇰🇷', (SELECT id FROM public.groups WHERE name='A')),
('República Checa',       'CZE', '🇨🇿', (SELECT id FROM public.groups WHERE name='A')),

-- ── GRUPO B ──────────────────────────────────────────────────
('Canadá',                'CAN', '🇨🇦', (SELECT id FROM public.groups WHERE name='B')),
('Bosnia y Herzegovina',  'BIH', '🇧🇦', (SELECT id FROM public.groups WHERE name='B')),
('Catar',                 'QAT', '🇶🇦', (SELECT id FROM public.groups WHERE name='B')),
('Suiza',                 'SUI', '🇨🇭', (SELECT id FROM public.groups WHERE name='B')),

-- ── GRUPO C ──────────────────────────────────────────────────
('Brasil',                'BRA', '🇧🇷', (SELECT id FROM public.groups WHERE name='C')),
('Marruecos',             'MAR', '🇲🇦', (SELECT id FROM public.groups WHERE name='C')),
('Haití',                 'HAI', '🇭🇹', (SELECT id FROM public.groups WHERE name='C')),
('Escocia',               'SCO', '🏴󠁧󠁢󠁳󠁣󠁴󠁿', (SELECT id FROM public.groups WHERE name='C')),

-- ── GRUPO D ──────────────────────────────────────────────────
('Estados Unidos',        'USA', '🇺🇸', (SELECT id FROM public.groups WHERE name='D')),
('Paraguay',              'PAR', '🇵🇾', (SELECT id FROM public.groups WHERE name='D')),
('Australia',             'AUS', '🇦🇺', (SELECT id FROM public.groups WHERE name='D')),
('Turquía',               'TUR', '🇹🇷', (SELECT id FROM public.groups WHERE name='D')),

-- ── GRUPO E ──────────────────────────────────────────────────
('Alemania',              'GER', '🇩🇪', (SELECT id FROM public.groups WHERE name='E')),
('Curazao',               'CUW', '🇨🇼', (SELECT id FROM public.groups WHERE name='E')),
('Costa de Marfil',       'CIV', '🇨🇮', (SELECT id FROM public.groups WHERE name='E')),
('Ecuador',               'ECU', '🇪🇨', (SELECT id FROM public.groups WHERE name='E')),

-- ── GRUPO F ──────────────────────────────────────────────────
('Países Bajos',          'NED', '🇳🇱', (SELECT id FROM public.groups WHERE name='F')),
('Japón',                 'JPN', '🇯🇵', (SELECT id FROM public.groups WHERE name='F')),
('Suecia',                'SWE', '🇸🇪', (SELECT id FROM public.groups WHERE name='F')),
('Túnez',                 'TUN', '🇹🇳', (SELECT id FROM public.groups WHERE name='F')),

-- ── GRUPO G ──────────────────────────────────────────────────
('Bélgica',               'BEL', '🇧🇪', (SELECT id FROM public.groups WHERE name='G')),
('Egipto',                'EGY', '🇪🇬', (SELECT id FROM public.groups WHERE name='G')),
('Irán',                  'IRN', '🇮🇷', (SELECT id FROM public.groups WHERE name='G')),
('Nueva Zelanda',         'NZL', '🇳🇿', (SELECT id FROM public.groups WHERE name='G')),

-- ── GRUPO H ──────────────────────────────────────────────────
('España',                'ESP', '🇪🇸', (SELECT id FROM public.groups WHERE name='H')),
('Cabo Verde',            'CPV', '🇨🇻', (SELECT id FROM public.groups WHERE name='H')),
('Arabia Saudí',          'KSA', '🇸🇦', (SELECT id FROM public.groups WHERE name='H')),
('Uruguay',               'URU', '🇺🇾', (SELECT id FROM public.groups WHERE name='H')),

-- ── GRUPO I ──────────────────────────────────────────────────
('Francia',               'FRA', '🇫🇷', (SELECT id FROM public.groups WHERE name='I')),
('Senegal',               'SEN', '🇸🇳', (SELECT id FROM public.groups WHERE name='I')),
('Irak',                  'IRQ', '🇮🇶', (SELECT id FROM public.groups WHERE name='I')),
('Noruega',               'NOR', '🇳🇴', (SELECT id FROM public.groups WHERE name='I')),

-- ── GRUPO J ──────────────────────────────────────────────────
('Argentina',             'ARG', '🇦🇷', (SELECT id FROM public.groups WHERE name='J')),
('Argelia',               'ALG', '🇩🇿', (SELECT id FROM public.groups WHERE name='J')),
('Austria',               'AUT', '🇦🇹', (SELECT id FROM public.groups WHERE name='J')),
('Jordania',              'JOR', '🇯🇴', (SELECT id FROM public.groups WHERE name='J')),

-- ── GRUPO K ──────────────────────────────────────────────────
('Portugal',              'POR', '🇵🇹', (SELECT id FROM public.groups WHERE name='K')),
('RD Congo',              'COD', '🇨🇩', (SELECT id FROM public.groups WHERE name='K')),
('Uzbekistán',            'UZB', '🇺🇿', (SELECT id FROM public.groups WHERE name='K')),
('Colombia',              'COL', '🇨🇴', (SELECT id FROM public.groups WHERE name='K')),

-- ── GRUPO L ──────────────────────────────────────────────────
('Inglaterra',            'ENG', '🏴󠁧󠁢󠁥󠁮󠁧󠁿', (SELECT id FROM public.groups WHERE name='L')),
('Croacia',               'CRO', '🇭🇷', (SELECT id FROM public.groups WHERE name='L')),
('Ghana',                 'GHA', '🇬🇭', (SELECT id FROM public.groups WHERE name='L')),
('Panamá',                'PAN', '🇵🇦', (SELECT id FROM public.groups WHERE name='L'));
