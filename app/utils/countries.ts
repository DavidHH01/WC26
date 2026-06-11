// Resuelve las imágenes de banderas en app/assets/images/countries/
// Vite procesa los assets y devuelve la URL final servible.
const files = import.meta.glob('../assets/images/countries/*.jpg', {
  eager: true,
  import: 'default',
}) as Record<string, string>

// Mapa { slug: url } → slug = nombre de archivo sin extensión (p.ej. 'spain')
const flagImages: Record<string, string> = {}
for (const [path, url] of Object.entries(files)) {
  const slug = path.split('/').pop()!.replace('.jpg', '')
  flagImages[slug] = url
}

// Código ISO (el de la BD) → slug del archivo de bandera
const codeToSlug: Record<string, string> = {
  ALG: 'algeria',     ARG: 'argentina',  AUS: 'australia',   AUT: 'austria',     BEL: 'belgium',
  BIH: 'bosnia',      BRA: 'brazil',     CAN: 'canada',      CPV: 'capeverde',   COL: 'colombia',
  CRO: 'croatia',     CUW: 'curazao',    CZE: 'czechia',     ECU: 'ecuador',     EGY: 'egypt',
  ENG: 'england',     FRA: 'france',     GER: 'germany',     GHA: 'ghana',       HAI: 'haiti',
  IRN: 'iran',        IRQ: 'iraq',       CIV: 'ivorycoast',  JPN: 'japan',       JOR: 'jordan',
  MEX: 'mexico',      MAR: 'morocco',    NED: 'netherlands', NZL: 'newzealand',  NOR: 'norway',
  PAN: 'panama',      PAR: 'paraguay',   POR: 'portugal',    QAT: 'qatar',       COD: 'rdcongo',
  KSA: 'saudiarabia', SCO: 'scotland',   SEN: 'senegal',     RSA: 'southafrica', KOR: 'southkorea',
  ESP: 'spain',       SWE: 'sweden',     SUI: 'switzerland', TUN: 'tunisia',     TUR: 'turkiye',
  URU: 'uruguay',     USA: 'usa',        UZB: 'uzbekistan',
}

// Devuelve la URL de la bandera para un código de país, o undefined
export function flagByCode(code?: string | null): string | undefined {
  if (!code) return undefined
  const slug = codeToSlug[code]
  return slug ? flagImages[slug] : undefined
}
