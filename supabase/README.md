# Supabase — WC26

## Ejecutar migraciones

Ve al **SQL Editor** de tu proyecto Supabase y ejecuta en orden:

1. `migrations/001_initial_schema.sql` — tablas, RLS, triggers, vistas
2. `migrations/002_seed_countries.sql` — 48 países y grupos

## Grupos oficiales (48 selecciones)

| Grupo | Equipos |
|-------|---------|
| A | México · Sudáfrica · Corea del Sur · Rep. Checa |
| B | Canadá · Bosnia y Herzegovina · Catar · Suiza |
| C | Brasil · Marruecos · Haití · Escocia |
| D | Estados Unidos · Paraguay · Australia · Turquía |
| E | Alemania · Curazao · Costa de Marfil · Ecuador |
| F | Países Bajos · Japón · Suecia · Túnez |
| G | Bélgica · Egipto · Irán · Nueva Zelanda |
| H | España · Cabo Verde · Arabia Saudí · Uruguay |
| I | Francia · Senegal · Irak · Noruega |
| J | Argentina · Argelia · Austria · Jordania |
| K | Portugal · RD Congo · Uzbekistán · Colombia |
| L | Inglaterra · Croacia · Ghana · Panamá |

## Tablas

| Tabla          | Descripción                                          |
|----------------|------------------------------------------------------|
| `groups`       | Grupos A–L (12 grupos, 4 equipos cada uno)          |
| `countries`    | 48 países con estadísticas de fase de grupos         |
| `matches`      | Todos los partidos: grupos + eliminatorias           |
| `profiles`     | Perfiles de usuario (auto-creado al registrarse)     |
| `predictions`  | Predicciones por usuario y partido                   |
| `top_scorers`  | Estadísticas de goleadores                           |

## Vistas

| Vista              | Descripción                          |
|--------------------|--------------------------------------|
| `leaderboard`      | Ranking global por puntos            |
| `group_standings`  | Clasificación por grupo              |

## Sistema de puntos

| Acierto              | Puntos |
|----------------------|--------|
| Resultado exacto     | **3**  |
| Ganador/empate correcto | **1** |
| Fallo total          | 0      |

Los puntos se calculan automáticamente via trigger cuando un partido
pasa a estado `finished` con los marcadores rellenados.

## Variables de entorno

```env
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_KEY=<anon-key>
```
