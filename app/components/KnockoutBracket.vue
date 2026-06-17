<script setup lang="ts">
/**
 * KnockoutBracket — visualización del cuadro de eliminatorias del Mundial 2026
 * (primer Mundial de 48 equipos: 16avos → octavos → cuartos → semis →
 *  3.er puesto + final). Los datos vienen de /api/bracket (FIFA), y los equipos
 * se rellenan solos cuando FIFA resuelve cada cruce.
 */
interface BracketTeam { code: string | null; name: string | null; placeholder: string }
interface BracketMatch {
  number: number
  stage: string
  date: string
  status: 'scheduled' | 'live' | 'finished'
  home: BracketTeam
  away: BracketTeam
  homeScore: number | null
  awayScore: number | null
  homePens: number | null
  awayPens: number | null
}

const { data, pending } = await useFetch<{ ok: boolean; matches: BracketMatch[] }>('/api/bracket')

const STAGES: { key: string; label: string }[] = [
  { key: 'r32',   label: 'Dieciseisavos de final' },
  { key: 'r16',   label: 'Octavos de final' },
  { key: 'qf',    label: 'Cuartos de final' },
  { key: 'sf',    label: 'Semifinales' },
  { key: 'third', label: 'Tercer puesto' },
  { key: 'final', label: 'Final' },
]

const byStage = computed(() => {
  const all = data.value?.matches ?? []
  return STAGES
    .map(s => ({ ...s, matches: all.filter(m => m.stage === s.key) }))
    .filter(s => s.matches.length > 0)
})

// ── Formateo de placeholders FIFA → texto legible ───────────────
function fmtPlaceholder(p: string): string {
  if (!p) return 'Por determinar'
  let m
  if ((m = p.match(/^([12])([A-Z])$/))) return `${m[1]}.º Grupo ${m[2]}`
  if ((m = p.match(/^3([A-Z]+)$/)))      return `3.º (${m[1]!.split('').join('·')})`
  if ((m = p.match(/^W(\d+)$/)))         return `Ganador P${m[1]}`
  if ((m = p.match(/^RU(\d+)$/)))        return `Perdedor P${m[1]}`
  return p
}

function fmtDate(s: string): string {
  if (!s) return ''
  return new Intl.DateTimeFormat('es-ES', {
    day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit',
    timeZone: 'Europe/Madrid',
  }).format(new Date(s))
}

// ¿Qué lado ganó? (marcador o penaltis)
function winner(m: BracketMatch): 'home' | 'away' | null {
  if (m.status !== 'finished' || m.homeScore === null || m.awayScore === null) return null
  if (m.homeScore !== m.awayScore) return m.homeScore > m.awayScore ? 'home' : 'away'
  if (m.homePens !== null && m.awayPens !== null && m.homePens !== m.awayPens) {
    return m.homePens > m.awayPens ? 'home' : 'away'
  }
  return null
}
</script>

<template>
  <div>
    <!-- Loading -->
    <div v-if="pending" class="space-y-3">
      <AppCard v-for="i in 4" :key="i" pad="md" class="animate-pulse">
        <div class="h-20 bg-dark-600 rounded" />
      </AppCard>
    </div>

    <!-- Sin datos -->
    <AppCard v-else-if="!byStage.length" pad="xl" class="text-center">
      <p class="text-3xl mb-3">🏆</p>
      <p class="font-display font-bold text-xl uppercase tracking-wide text-gray-400">
        Cuadro no disponible
      </p>
      <p class="text-sm text-gray-500 mt-1">Se mostrará cuando FIFA publique las eliminatorias.</p>
    </AppCard>

    <!-- Rondas -->
    <div v-else class="space-y-8">
      <section v-for="stage in byStage" :key="stage.key">
        <h3 class="section-label mb-4 flex items-center gap-2">
          <span class="w-1 h-4 bg-wc-red inline-block rounded-full" />
          {{ stage.label }}
        </h3>

        <div
          class="grid gap-3"
          :class="stage.key === 'final' || stage.key === 'third'
            ? 'grid-cols-1 max-w-md'
            : 'grid-cols-1 sm:grid-cols-2'"
        >
          <AppCard
            v-for="m in stage.matches"
            :key="m.number"
            pad="none"
            :class="m.status === 'live' ? 'border-wc-red/60' : ''"
          >
            <!-- Cabecera: nº partido + fecha/estado -->
            <div class="flex items-center justify-between px-3 py-1.5 border-b border-dark-500/60">
              <span class="font-display font-bold text-xs text-gray-500 tracking-wider">P{{ m.number }}</span>
              <span v-if="m.status === 'live'" class="flex items-center gap-1 text-xs text-wc-red font-bold uppercase">
                <span class="w-1.5 h-1.5 rounded-full bg-wc-red animate-pulse inline-block" /> En vivo
              </span>
              <span v-else class="text-xs text-gray-500">{{ fmtDate(m.date) }}</span>
            </div>

            <!-- Equipos -->
            <div class="divide-y divide-dark-500/40">
              <!-- Local -->
              <div
                class="flex items-center gap-2 px-3 py-2"
                :class="winner(m) === 'home' ? 'bg-wc-green/10' : (winner(m) === 'away' ? 'opacity-50' : '')"
              >
                <template v-if="m.home.code">
                  <CountryFlag :code="m.home.code" :name="m.home.name" :size="20" />
                  <span class="font-semibold truncate flex-1" :class="winner(m) === 'home' ? 'text-wc-green' : ''">
                    {{ m.home.name }}
                  </span>
                </template>
                <span v-else class="text-sm text-gray-500 italic truncate flex-1">
                  {{ fmtPlaceholder(m.home.placeholder) }}
                </span>
                <span v-if="m.homeScore !== null" class="font-display font-black text-lg tabular-nums">
                  {{ m.homeScore }}<span v-if="m.homePens !== null" class="text-xs text-gray-400"> ({{ m.homePens }})</span>
                </span>
              </div>
              <!-- Visitante -->
              <div
                class="flex items-center gap-2 px-3 py-2"
                :class="winner(m) === 'away' ? 'bg-wc-green/10' : (winner(m) === 'home' ? 'opacity-50' : '')"
              >
                <template v-if="m.away.code">
                  <CountryFlag :code="m.away.code" :name="m.away.name" :size="20" />
                  <span class="font-semibold truncate flex-1" :class="winner(m) === 'away' ? 'text-wc-green' : ''">
                    {{ m.away.name }}
                  </span>
                </template>
                <span v-else class="text-sm text-gray-500 italic truncate flex-1">
                  {{ fmtPlaceholder(m.away.placeholder) }}
                </span>
                <span v-if="m.awayScore !== null" class="font-display font-black text-lg tabular-nums">
                  {{ m.awayScore }}<span v-if="m.awayPens !== null" class="text-xs text-gray-400"> ({{ m.awayPens }})</span>
                </span>
              </div>
            </div>
          </AppCard>
        </div>
      </section>
    </div>
  </div>
</template>
