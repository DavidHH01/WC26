// Resuelve las imágenes PNG de jugadores en app/assets/images/players/
// Vite procesa los assets y devuelve la URL final servible.
const files = import.meta.glob('../assets/images/players/*.png', {
  eager: true,
  import: 'default',
}) as Record<string, string>

// Mapa { slug: url } → slug = nombre de archivo sin extensión (p.ej. 'messi')
export const playerImages: Record<string, string> = {}
for (const [path, url] of Object.entries(files)) {
  const slug = path.split('/').pop()!.replace('.png', '')
  playerImages[slug] = url
}

// Estrellas destacadas del torneo (slug debe coincidir con el archivo PNG)
export interface StarPlayer {
  slug: string
  name: string
  team: string
  code: string   // código ISO del país (para la bandera)
  accent: string // color del equipo para el glow
}

export const starPlayers: StarPlayer[] = [
  { slug: 'messi',        name: 'Lionel Messi',      team: 'Argentina',  code: 'ARG', accent: '#6CA9E0' },
  { slug: 'mbappe',       name: 'Kylian Mbappé',     team: 'Francia',    code: 'FRA', accent: '#2A398D' },
  { slug: 'lamine_yamal', name: 'Lamine Yamal',      team: 'España',     code: 'ESP', accent: '#E61D25' },
  { slug: 'ronaldo',      name: 'Cristiano Ronaldo', team: 'Portugal',   code: 'POR', accent: '#3CAC3B' },
  { slug: 'kane',         name: 'Harry Kane',        team: 'Inglaterra', code: 'ENG', accent: '#C9A84C' },
]

// Busca una imagen de jugador por nombre completo (para la tabla de goleadores)
export function playerImageByName(name: string): string | undefined {
  const star = starPlayers.find(s => s.name.toLowerCase() === name?.toLowerCase())
  return star ? playerImages[star.slug] : undefined
}
