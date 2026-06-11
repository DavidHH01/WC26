-- ============================================================
-- WC26 — 72 partidos fase de grupos
-- Horarios en hora española (CEST, UTC+2)
-- ============================================================

-- Helper: obtener id de un país por su código
-- Se usa como subquery en cada INSERT

-- ════════════════════════════════════════════════════════════
-- JORNADA 1
-- ════════════════════════════════════════════════════════════

INSERT INTO public.matches (stage, group_id, match_round, match_date,
  home_country_id, away_country_id, home_fifa_points, away_fifa_points, status)
VALUES

-- Grupo A
('group', (SELECT id FROM public.groups WHERE name='A'), 1, '2026-06-11 21:00:00+02',
  (SELECT id FROM public.countries WHERE code='MEX'),
  (SELECT id FROM public.countries WHERE code='RSA'),
  (SELECT fifa_points FROM public.countries WHERE code='MEX'),
  (SELECT fifa_points FROM public.countries WHERE code='RSA'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='A'), 1, '2026-06-12 04:00:00+02',
  (SELECT id FROM public.countries WHERE code='KOR'),
  (SELECT id FROM public.countries WHERE code='CZE'),
  (SELECT fifa_points FROM public.countries WHERE code='KOR'),
  (SELECT fifa_points FROM public.countries WHERE code='CZE'), 'scheduled'),

-- Grupo B
('group', (SELECT id FROM public.groups WHERE name='B'), 1, '2026-06-12 21:00:00+02',
  (SELECT id FROM public.countries WHERE code='CAN'),
  (SELECT id FROM public.countries WHERE code='BIH'),
  (SELECT fifa_points FROM public.countries WHERE code='CAN'),
  (SELECT fifa_points FROM public.countries WHERE code='BIH'), 'scheduled'),

-- Grupo D
('group', (SELECT id FROM public.groups WHERE name='D'), 1, '2026-06-13 03:00:00+02',
  (SELECT id FROM public.countries WHERE code='USA'),
  (SELECT id FROM public.countries WHERE code='PAR'),
  (SELECT fifa_points FROM public.countries WHERE code='USA'),
  (SELECT fifa_points FROM public.countries WHERE code='PAR'), 'scheduled'),

-- Grupo B
('group', (SELECT id FROM public.groups WHERE name='B'), 1, '2026-06-13 21:00:00+02',
  (SELECT id FROM public.countries WHERE code='QAT'),
  (SELECT id FROM public.countries WHERE code='SUI'),
  (SELECT fifa_points FROM public.countries WHERE code='QAT'),
  (SELECT fifa_points FROM public.countries WHERE code='SUI'), 'scheduled'),

-- Grupo C
('group', (SELECT id FROM public.groups WHERE name='C'), 1, '2026-06-14 00:00:00+02',
  (SELECT id FROM public.countries WHERE code='BRA'),
  (SELECT id FROM public.countries WHERE code='MAR'),
  (SELECT fifa_points FROM public.countries WHERE code='BRA'),
  (SELECT fifa_points FROM public.countries WHERE code='MAR'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='C'), 1, '2026-06-14 03:00:00+02',
  (SELECT id FROM public.countries WHERE code='HAI'),
  (SELECT id FROM public.countries WHERE code='SCO'),
  (SELECT fifa_points FROM public.countries WHERE code='HAI'),
  (SELECT fifa_points FROM public.countries WHERE code='SCO'), 'scheduled'),

-- Grupo D
('group', (SELECT id FROM public.groups WHERE name='D'), 1, '2026-06-14 06:00:00+02',
  (SELECT id FROM public.countries WHERE code='AUS'),
  (SELECT id FROM public.countries WHERE code='TUR'),
  (SELECT fifa_points FROM public.countries WHERE code='AUS'),
  (SELECT fifa_points FROM public.countries WHERE code='TUR'), 'scheduled'),

-- Grupo E
('group', (SELECT id FROM public.groups WHERE name='E'), 1, '2026-06-14 19:00:00+02',
  (SELECT id FROM public.countries WHERE code='GER'),
  (SELECT id FROM public.countries WHERE code='CUW'),
  (SELECT fifa_points FROM public.countries WHERE code='GER'),
  (SELECT fifa_points FROM public.countries WHERE code='CUW'), 'scheduled'),

-- Grupo F
('group', (SELECT id FROM public.groups WHERE name='F'), 1, '2026-06-14 22:00:00+02',
  (SELECT id FROM public.countries WHERE code='NED'),
  (SELECT id FROM public.countries WHERE code='JPN'),
  (SELECT fifa_points FROM public.countries WHERE code='NED'),
  (SELECT fifa_points FROM public.countries WHERE code='JPN'), 'scheduled'),

-- Grupo E
('group', (SELECT id FROM public.groups WHERE name='E'), 1, '2026-06-15 01:00:00+02',
  (SELECT id FROM public.countries WHERE code='CIV'),
  (SELECT id FROM public.countries WHERE code='ECU'),
  (SELECT fifa_points FROM public.countries WHERE code='CIV'),
  (SELECT fifa_points FROM public.countries WHERE code='ECU'), 'scheduled'),

-- Grupo F
('group', (SELECT id FROM public.groups WHERE name='F'), 1, '2026-06-15 04:00:00+02',
  (SELECT id FROM public.countries WHERE code='SWE'),
  (SELECT id FROM public.countries WHERE code='TUN'),
  (SELECT fifa_points FROM public.countries WHERE code='SWE'),
  (SELECT fifa_points FROM public.countries WHERE code='TUN'), 'scheduled'),

-- Grupo H
('group', (SELECT id FROM public.groups WHERE name='H'), 1, '2026-06-15 18:00:00+02',
  (SELECT id FROM public.countries WHERE code='ESP'),
  (SELECT id FROM public.countries WHERE code='CPV'),
  (SELECT fifa_points FROM public.countries WHERE code='ESP'),
  (SELECT fifa_points FROM public.countries WHERE code='CPV'), 'scheduled'),

-- Grupo G
('group', (SELECT id FROM public.groups WHERE name='G'), 1, '2026-06-15 21:00:00+02',
  (SELECT id FROM public.countries WHERE code='BEL'),
  (SELECT id FROM public.countries WHERE code='EGY'),
  (SELECT fifa_points FROM public.countries WHERE code='BEL'),
  (SELECT fifa_points FROM public.countries WHERE code='EGY'), 'scheduled'),

-- Grupo H
('group', (SELECT id FROM public.groups WHERE name='H'), 1, '2026-06-16 00:00:00+02',
  (SELECT id FROM public.countries WHERE code='KSA'),
  (SELECT id FROM public.countries WHERE code='URU'),
  (SELECT fifa_points FROM public.countries WHERE code='KSA'),
  (SELECT fifa_points FROM public.countries WHERE code='URU'), 'scheduled'),

-- Grupo G
('group', (SELECT id FROM public.groups WHERE name='G'), 1, '2026-06-16 03:00:00+02',
  (SELECT id FROM public.countries WHERE code='IRN'),
  (SELECT id FROM public.countries WHERE code='NZL'),
  (SELECT fifa_points FROM public.countries WHERE code='IRN'),
  (SELECT fifa_points FROM public.countries WHERE code='NZL'), 'scheduled'),

-- Grupo I
('group', (SELECT id FROM public.groups WHERE name='I'), 1, '2026-06-16 21:00:00+02',
  (SELECT id FROM public.countries WHERE code='FRA'),
  (SELECT id FROM public.countries WHERE code='SEN'),
  (SELECT fifa_points FROM public.countries WHERE code='FRA'),
  (SELECT fifa_points FROM public.countries WHERE code='SEN'), 'scheduled'),

-- Grupo I
('group', (SELECT id FROM public.groups WHERE name='I'), 1, '2026-06-17 00:00:00+02',
  (SELECT id FROM public.countries WHERE code='IRQ'),
  (SELECT id FROM public.countries WHERE code='NOR'),
  (SELECT fifa_points FROM public.countries WHERE code='IRQ'),
  (SELECT fifa_points FROM public.countries WHERE code='NOR'), 'scheduled'),

-- Grupo J
('group', (SELECT id FROM public.groups WHERE name='J'), 1, '2026-06-17 03:00:00+02',
  (SELECT id FROM public.countries WHERE code='ARG'),
  (SELECT id FROM public.countries WHERE code='ALG'),
  (SELECT fifa_points FROM public.countries WHERE code='ARG'),
  (SELECT fifa_points FROM public.countries WHERE code='ALG'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='J'), 1, '2026-06-17 06:00:00+02',
  (SELECT id FROM public.countries WHERE code='AUT'),
  (SELECT id FROM public.countries WHERE code='JOR'),
  (SELECT fifa_points FROM public.countries WHERE code='AUT'),
  (SELECT fifa_points FROM public.countries WHERE code='JOR'), 'scheduled'),

-- Grupo K
('group', (SELECT id FROM public.groups WHERE name='K'), 1, '2026-06-17 19:00:00+02',
  (SELECT id FROM public.countries WHERE code='POR'),
  (SELECT id FROM public.countries WHERE code='COD'),
  (SELECT fifa_points FROM public.countries WHERE code='POR'),
  (SELECT fifa_points FROM public.countries WHERE code='COD'), 'scheduled'),

-- Grupo L
('group', (SELECT id FROM public.groups WHERE name='L'), 1, '2026-06-17 22:00:00+02',
  (SELECT id FROM public.countries WHERE code='ENG'),
  (SELECT id FROM public.countries WHERE code='CRO'),
  (SELECT fifa_points FROM public.countries WHERE code='ENG'),
  (SELECT fifa_points FROM public.countries WHERE code='CRO'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='L'), 1, '2026-06-18 01:00:00+02',
  (SELECT id FROM public.countries WHERE code='GHA'),
  (SELECT id FROM public.countries WHERE code='PAN'),
  (SELECT fifa_points FROM public.countries WHERE code='GHA'),
  (SELECT fifa_points FROM public.countries WHERE code='PAN'), 'scheduled'),

-- Grupo K
('group', (SELECT id FROM public.groups WHERE name='K'), 1, '2026-06-18 04:00:00+02',
  (SELECT id FROM public.countries WHERE code='UZB'),
  (SELECT id FROM public.countries WHERE code='COL'),
  (SELECT fifa_points FROM public.countries WHERE code='UZB'),
  (SELECT fifa_points FROM public.countries WHERE code='COL'), 'scheduled'),

-- ════════════════════════════════════════════════════════════
-- JORNADA 2
-- ════════════════════════════════════════════════════════════

-- Grupo A
('group', (SELECT id FROM public.groups WHERE name='A'), 2, '2026-06-18 18:00:00+02',
  (SELECT id FROM public.countries WHERE code='CZE'),
  (SELECT id FROM public.countries WHERE code='RSA'),
  (SELECT fifa_points FROM public.countries WHERE code='CZE'),
  (SELECT fifa_points FROM public.countries WHERE code='RSA'), 'scheduled'),

-- Grupo B
('group', (SELECT id FROM public.groups WHERE name='B'), 2, '2026-06-18 21:00:00+02',
  (SELECT id FROM public.countries WHERE code='SUI'),
  (SELECT id FROM public.countries WHERE code='BIH'),
  (SELECT fifa_points FROM public.countries WHERE code='SUI'),
  (SELECT fifa_points FROM public.countries WHERE code='BIH'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='B'), 2, '2026-06-19 00:00:00+02',
  (SELECT id FROM public.countries WHERE code='CAN'),
  (SELECT id FROM public.countries WHERE code='QAT'),
  (SELECT fifa_points FROM public.countries WHERE code='CAN'),
  (SELECT fifa_points FROM public.countries WHERE code='QAT'), 'scheduled'),

-- Grupo A
('group', (SELECT id FROM public.groups WHERE name='A'), 2, '2026-06-19 03:00:00+02',
  (SELECT id FROM public.countries WHERE code='MEX'),
  (SELECT id FROM public.countries WHERE code='KOR'),
  (SELECT fifa_points FROM public.countries WHERE code='MEX'),
  (SELECT fifa_points FROM public.countries WHERE code='KOR'), 'scheduled'),

-- Grupo D
('group', (SELECT id FROM public.groups WHERE name='D'), 2, '2026-06-19 21:00:00+02',
  (SELECT id FROM public.countries WHERE code='USA'),
  (SELECT id FROM public.countries WHERE code='AUS'),
  (SELECT fifa_points FROM public.countries WHERE code='USA'),
  (SELECT fifa_points FROM public.countries WHERE code='AUS'), 'scheduled'),

-- Grupo C
('group', (SELECT id FROM public.groups WHERE name='C'), 2, '2026-06-20 00:00:00+02',
  (SELECT id FROM public.countries WHERE code='MAR'),
  (SELECT id FROM public.countries WHERE code='SCO'),
  (SELECT fifa_points FROM public.countries WHERE code='MAR'),
  (SELECT fifa_points FROM public.countries WHERE code='SCO'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='C'), 2, '2026-06-20 02:30:00+02',
  (SELECT id FROM public.countries WHERE code='BRA'),
  (SELECT id FROM public.countries WHERE code='HAI'),
  (SELECT fifa_points FROM public.countries WHERE code='BRA'),
  (SELECT fifa_points FROM public.countries WHERE code='HAI'), 'scheduled'),

-- Grupo D
('group', (SELECT id FROM public.groups WHERE name='D'), 2, '2026-06-20 05:00:00+02',
  (SELECT id FROM public.countries WHERE code='TUR'),
  (SELECT id FROM public.countries WHERE code='PAR'),
  (SELECT fifa_points FROM public.countries WHERE code='TUR'),
  (SELECT fifa_points FROM public.countries WHERE code='PAR'), 'scheduled'),

-- Grupo F
('group', (SELECT id FROM public.groups WHERE name='F'), 2, '2026-06-20 19:00:00+02',
  (SELECT id FROM public.countries WHERE code='NED'),
  (SELECT id FROM public.countries WHERE code='SWE'),
  (SELECT fifa_points FROM public.countries WHERE code='NED'),
  (SELECT fifa_points FROM public.countries WHERE code='SWE'), 'scheduled'),

-- Grupo E
('group', (SELECT id FROM public.groups WHERE name='E'), 2, '2026-06-20 22:00:00+02',
  (SELECT id FROM public.countries WHERE code='GER'),
  (SELECT id FROM public.countries WHERE code='CIV'),
  (SELECT fifa_points FROM public.countries WHERE code='GER'),
  (SELECT fifa_points FROM public.countries WHERE code='CIV'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='E'), 2, '2026-06-21 02:00:00+02',
  (SELECT id FROM public.countries WHERE code='ECU'),
  (SELECT id FROM public.countries WHERE code='CUW'),
  (SELECT fifa_points FROM public.countries WHERE code='ECU'),
  (SELECT fifa_points FROM public.countries WHERE code='CUW'), 'scheduled'),

-- Grupo F
('group', (SELECT id FROM public.groups WHERE name='F'), 2, '2026-06-21 06:00:00+02',
  (SELECT id FROM public.countries WHERE code='TUN'),
  (SELECT id FROM public.countries WHERE code='JPN'),
  (SELECT fifa_points FROM public.countries WHERE code='TUN'),
  (SELECT fifa_points FROM public.countries WHERE code='JPN'), 'scheduled'),

-- Grupo H
('group', (SELECT id FROM public.groups WHERE name='H'), 2, '2026-06-21 18:00:00+02',
  (SELECT id FROM public.countries WHERE code='ESP'),
  (SELECT id FROM public.countries WHERE code='KSA'),
  (SELECT fifa_points FROM public.countries WHERE code='ESP'),
  (SELECT fifa_points FROM public.countries WHERE code='KSA'), 'scheduled'),

-- Grupo G
('group', (SELECT id FROM public.groups WHERE name='G'), 2, '2026-06-21 21:00:00+02',
  (SELECT id FROM public.countries WHERE code='BEL'),
  (SELECT id FROM public.countries WHERE code='IRN'),
  (SELECT fifa_points FROM public.countries WHERE code='BEL'),
  (SELECT fifa_points FROM public.countries WHERE code='IRN'), 'scheduled'),

-- Grupo H
('group', (SELECT id FROM public.groups WHERE name='H'), 2, '2026-06-22 00:00:00+02',
  (SELECT id FROM public.countries WHERE code='URU'),
  (SELECT id FROM public.countries WHERE code='CPV'),
  (SELECT fifa_points FROM public.countries WHERE code='URU'),
  (SELECT fifa_points FROM public.countries WHERE code='CPV'), 'scheduled'),

-- Grupo G
('group', (SELECT id FROM public.groups WHERE name='G'), 2, '2026-06-22 03:00:00+02',
  (SELECT id FROM public.countries WHERE code='NZL'),
  (SELECT id FROM public.countries WHERE code='EGY'),
  (SELECT fifa_points FROM public.countries WHERE code='NZL'),
  (SELECT fifa_points FROM public.countries WHERE code='EGY'), 'scheduled'),

-- Grupo I
('group', (SELECT id FROM public.groups WHERE name='I'), 2, '2026-06-22 18:00:00+02',
  (SELECT id FROM public.countries WHERE code='FRA'),
  (SELECT id FROM public.countries WHERE code='IRQ'),
  (SELECT fifa_points FROM public.countries WHERE code='FRA'),
  (SELECT fifa_points FROM public.countries WHERE code='IRQ'), 'scheduled'),

-- Grupo J
('group', (SELECT id FROM public.groups WHERE name='J'), 2, '2026-06-22 21:00:00+02',
  (SELECT id FROM public.countries WHERE code='ARG'),
  (SELECT id FROM public.countries WHERE code='AUT'),
  (SELECT fifa_points FROM public.countries WHERE code='ARG'),
  (SELECT fifa_points FROM public.countries WHERE code='AUT'), 'scheduled'),

-- Grupo I
('group', (SELECT id FROM public.groups WHERE name='I'), 2, '2026-06-23 00:00:00+02',
  (SELECT id FROM public.countries WHERE code='NOR'),
  (SELECT id FROM public.countries WHERE code='SEN'),
  (SELECT fifa_points FROM public.countries WHERE code='NOR'),
  (SELECT fifa_points FROM public.countries WHERE code='SEN'), 'scheduled'),

-- Grupo J
('group', (SELECT id FROM public.groups WHERE name='J'), 2, '2026-06-23 03:00:00+02',
  (SELECT id FROM public.countries WHERE code='JOR'),
  (SELECT id FROM public.countries WHERE code='ALG'),
  (SELECT fifa_points FROM public.countries WHERE code='JOR'),
  (SELECT fifa_points FROM public.countries WHERE code='ALG'), 'scheduled'),

-- Grupo K
('group', (SELECT id FROM public.groups WHERE name='K'), 2, '2026-06-23 19:00:00+02',
  (SELECT id FROM public.countries WHERE code='POR'),
  (SELECT id FROM public.countries WHERE code='UZB'),
  (SELECT fifa_points FROM public.countries WHERE code='POR'),
  (SELECT fifa_points FROM public.countries WHERE code='UZB'), 'scheduled'),

-- Grupo L
('group', (SELECT id FROM public.groups WHERE name='L'), 2, '2026-06-23 22:00:00+02',
  (SELECT id FROM public.countries WHERE code='ENG'),
  (SELECT id FROM public.countries WHERE code='GHA'),
  (SELECT fifa_points FROM public.countries WHERE code='ENG'),
  (SELECT fifa_points FROM public.countries WHERE code='GHA'), 'scheduled'),

-- Grupo K
('group', (SELECT id FROM public.groups WHERE name='K'), 2, '2026-06-24 01:00:00+02',
  (SELECT id FROM public.countries WHERE code='COL'),
  (SELECT id FROM public.countries WHERE code='COD'),
  (SELECT fifa_points FROM public.countries WHERE code='COL'),
  (SELECT fifa_points FROM public.countries WHERE code='COD'), 'scheduled'),

-- Grupo L
('group', (SELECT id FROM public.groups WHERE name='L'), 2, '2026-06-24 04:00:00+02',
  (SELECT id FROM public.countries WHERE code='PAN'),
  (SELECT id FROM public.countries WHERE code='CRO'),
  (SELECT fifa_points FROM public.countries WHERE code='PAN'),
  (SELECT fifa_points FROM public.countries WHERE code='CRO'), 'scheduled'),

-- ════════════════════════════════════════════════════════════
-- JORNADA 3 — Simultáneos por grupo
-- ════════════════════════════════════════════════════════════

-- Grupo A (simultáneo)
('group', (SELECT id FROM public.groups WHERE name='A'), 3, '2026-06-24 21:00:00+02',
  (SELECT id FROM public.countries WHERE code='CZE'),
  (SELECT id FROM public.countries WHERE code='MEX'),
  (SELECT fifa_points FROM public.countries WHERE code='CZE'),
  (SELECT fifa_points FROM public.countries WHERE code='MEX'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='A'), 3, '2026-06-24 21:00:00+02',
  (SELECT id FROM public.countries WHERE code='RSA'),
  (SELECT id FROM public.countries WHERE code='KOR'),
  (SELECT fifa_points FROM public.countries WHERE code='RSA'),
  (SELECT fifa_points FROM public.countries WHERE code='KOR'), 'scheduled'),

-- Grupo B (simultáneo)
('group', (SELECT id FROM public.groups WHERE name='B'), 3, '2026-06-25 00:00:00+02',
  (SELECT id FROM public.countries WHERE code='SUI'),
  (SELECT id FROM public.countries WHERE code='CAN'),
  (SELECT fifa_points FROM public.countries WHERE code='SUI'),
  (SELECT fifa_points FROM public.countries WHERE code='CAN'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='B'), 3, '2026-06-25 00:00:00+02',
  (SELECT id FROM public.countries WHERE code='BIH'),
  (SELECT id FROM public.countries WHERE code='QAT'),
  (SELECT fifa_points FROM public.countries WHERE code='BIH'),
  (SELECT fifa_points FROM public.countries WHERE code='QAT'), 'scheduled'),

-- Grupo C (simultáneo)
('group', (SELECT id FROM public.groups WHERE name='C'), 3, '2026-06-25 03:00:00+02',
  (SELECT id FROM public.countries WHERE code='SCO'),
  (SELECT id FROM public.countries WHERE code='BRA'),
  (SELECT fifa_points FROM public.countries WHERE code='SCO'),
  (SELECT fifa_points FROM public.countries WHERE code='BRA'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='C'), 3, '2026-06-25 03:00:00+02',
  (SELECT id FROM public.countries WHERE code='MAR'),
  (SELECT id FROM public.countries WHERE code='HAI'),
  (SELECT fifa_points FROM public.countries WHERE code='MAR'),
  (SELECT fifa_points FROM public.countries WHERE code='HAI'), 'scheduled'),

-- Grupo D (simultáneo)
('group', (SELECT id FROM public.groups WHERE name='D'), 3, '2026-06-25 06:00:00+02',
  (SELECT id FROM public.countries WHERE code='TUR'),
  (SELECT id FROM public.countries WHERE code='USA'),
  (SELECT fifa_points FROM public.countries WHERE code='TUR'),
  (SELECT fifa_points FROM public.countries WHERE code='USA'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='D'), 3, '2026-06-25 06:00:00+02',
  (SELECT id FROM public.countries WHERE code='PAR'),
  (SELECT id FROM public.countries WHERE code='AUS'),
  (SELECT fifa_points FROM public.countries WHERE code='PAR'),
  (SELECT fifa_points FROM public.countries WHERE code='AUS'), 'scheduled'),

-- Grupo E (simultáneo)
('group', (SELECT id FROM public.groups WHERE name='E'), 3, '2026-06-25 19:00:00+02',
  (SELECT id FROM public.countries WHERE code='ECU'),
  (SELECT id FROM public.countries WHERE code='GER'),
  (SELECT fifa_points FROM public.countries WHERE code='ECU'),
  (SELECT fifa_points FROM public.countries WHERE code='GER'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='E'), 3, '2026-06-25 19:00:00+02',
  (SELECT id FROM public.countries WHERE code='CUW'),
  (SELECT id FROM public.countries WHERE code='CIV'),
  (SELECT fifa_points FROM public.countries WHERE code='CUW'),
  (SELECT fifa_points FROM public.countries WHERE code='CIV'), 'scheduled'),

-- Grupo F (simultáneo)
('group', (SELECT id FROM public.groups WHERE name='F'), 3, '2026-06-25 22:00:00+02',
  (SELECT id FROM public.countries WHERE code='TUN'),
  (SELECT id FROM public.countries WHERE code='NED'),
  (SELECT fifa_points FROM public.countries WHERE code='TUN'),
  (SELECT fifa_points FROM public.countries WHERE code='NED'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='F'), 3, '2026-06-25 22:00:00+02',
  (SELECT id FROM public.countries WHERE code='JPN'),
  (SELECT id FROM public.countries WHERE code='SWE'),
  (SELECT fifa_points FROM public.countries WHERE code='JPN'),
  (SELECT fifa_points FROM public.countries WHERE code='SWE'), 'scheduled'),

-- Grupo G (simultáneo)
('group', (SELECT id FROM public.groups WHERE name='G'), 3, '2026-06-26 01:00:00+02',
  (SELECT id FROM public.countries WHERE code='NZL'),
  (SELECT id FROM public.countries WHERE code='BEL'),
  (SELECT fifa_points FROM public.countries WHERE code='NZL'),
  (SELECT fifa_points FROM public.countries WHERE code='BEL'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='G'), 3, '2026-06-26 01:00:00+02',
  (SELECT id FROM public.countries WHERE code='EGY'),
  (SELECT id FROM public.countries WHERE code='IRN'),
  (SELECT fifa_points FROM public.countries WHERE code='EGY'),
  (SELECT fifa_points FROM public.countries WHERE code='IRN'), 'scheduled'),

-- Grupo H (simultáneo)
('group', (SELECT id FROM public.groups WHERE name='H'), 3, '2026-06-26 04:00:00+02',
  (SELECT id FROM public.countries WHERE code='URU'),
  (SELECT id FROM public.countries WHERE code='ESP'),
  (SELECT fifa_points FROM public.countries WHERE code='URU'),
  (SELECT fifa_points FROM public.countries WHERE code='ESP'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='H'), 3, '2026-06-26 04:00:00+02',
  (SELECT id FROM public.countries WHERE code='CPV'),
  (SELECT id FROM public.countries WHERE code='KSA'),
  (SELECT fifa_points FROM public.countries WHERE code='CPV'),
  (SELECT fifa_points FROM public.countries WHERE code='KSA'), 'scheduled'),

-- Grupo I (simultáneo)
('group', (SELECT id FROM public.groups WHERE name='I'), 3, '2026-06-26 19:00:00+02',
  (SELECT id FROM public.countries WHERE code='NOR'),
  (SELECT id FROM public.countries WHERE code='FRA'),
  (SELECT fifa_points FROM public.countries WHERE code='NOR'),
  (SELECT fifa_points FROM public.countries WHERE code='FRA'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='I'), 3, '2026-06-26 19:00:00+02',
  (SELECT id FROM public.countries WHERE code='SEN'),
  (SELECT id FROM public.countries WHERE code='IRQ'),
  (SELECT fifa_points FROM public.countries WHERE code='SEN'),
  (SELECT fifa_points FROM public.countries WHERE code='IRQ'), 'scheduled'),

-- Grupo J (simultáneo)
('group', (SELECT id FROM public.groups WHERE name='J'), 3, '2026-06-26 22:00:00+02',
  (SELECT id FROM public.countries WHERE code='JOR'),
  (SELECT id FROM public.countries WHERE code='ARG'),
  (SELECT fifa_points FROM public.countries WHERE code='JOR'),
  (SELECT fifa_points FROM public.countries WHERE code='ARG'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='J'), 3, '2026-06-26 22:00:00+02',
  (SELECT id FROM public.countries WHERE code='ALG'),
  (SELECT id FROM public.countries WHERE code='AUT'),
  (SELECT fifa_points FROM public.countries WHERE code='ALG'),
  (SELECT fifa_points FROM public.countries WHERE code='AUT'), 'scheduled'),

-- Grupo K (simultáneo)
('group', (SELECT id FROM public.groups WHERE name='K'), 3, '2026-06-27 01:00:00+02',
  (SELECT id FROM public.countries WHERE code='COL'),
  (SELECT id FROM public.countries WHERE code='POR'),
  (SELECT fifa_points FROM public.countries WHERE code='COL'),
  (SELECT fifa_points FROM public.countries WHERE code='POR'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='K'), 3, '2026-06-27 01:00:00+02',
  (SELECT id FROM public.countries WHERE code='COD'),
  (SELECT id FROM public.countries WHERE code='UZB'),
  (SELECT fifa_points FROM public.countries WHERE code='COD'),
  (SELECT fifa_points FROM public.countries WHERE code='UZB'), 'scheduled'),

-- Grupo L (simultáneo)
('group', (SELECT id FROM public.groups WHERE name='L'), 3, '2026-06-27 04:00:00+02',
  (SELECT id FROM public.countries WHERE code='PAN'),
  (SELECT id FROM public.countries WHERE code='ENG'),
  (SELECT fifa_points FROM public.countries WHERE code='PAN'),
  (SELECT fifa_points FROM public.countries WHERE code='ENG'), 'scheduled'),

('group', (SELECT id FROM public.groups WHERE name='L'), 3, '2026-06-27 04:00:00+02',
  (SELECT id FROM public.countries WHERE code='CRO'),
  (SELECT id FROM public.countries WHERE code='GHA'),
  (SELECT fifa_points FROM public.countries WHERE code='CRO'),
  (SELECT fifa_points FROM public.countries WHERE code='GHA'), 'scheduled');
