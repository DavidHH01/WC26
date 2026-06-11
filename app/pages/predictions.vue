<script setup lang="ts">
const supabase = useSupabaseClient()
const user = useSupabaseUser()

// ── Fetch matches ─────────────────────────────────────────────
const { data: matches, pending: loadingMatches } = await useAsyncData('group-matches', async () => {
  const { data } = await supabase
    .from('matches')
    .select(`
      id, match_round, match_date, status,
      home_score, away_score, home_fifa_points, away_fifa_points,
      home_country:countries!home_country_id(id, name, code, flag),
      away_country:countries!away_country_id(id, name, code, flag),
      group:groups(name)
    `)
    .eq('stage', 'group')
    .order('match_date')
  return data ?? []
})

// ── Fetch user predictions ────────────────────────────────────
const { data: savedPreds, refresh: refreshPreds } = await useAsyncData('my-preds', async () => {
  if (!user.value) return []
  const { data } = await supabase
    .from('predictions')
    .select('id, match_id, home_score, away_score, points_earned')
  return data ?? []
})

// ── Local input state ─────────────────────────────────────────
type Input = { home: number | null; away: number | null }
const inputs  = reactive<Record<number, Input>>({})
const dirty   = reactive<Record<number, boolean>>({})
const saving  = reactive<Record<number, boolean>>({})
const saveErr = reactive<Record<number, string>>({})

// Initialize all match inputs (ensures inputs[m.id] always exists → clean v-model)
watch(matches, (ms) => {
  ms?.forEach(m => {
    if (!inputs[m.id]) inputs[m.id] = { home: null, away: null }
  })
}, { immediate: true })

// Overwrite with saved predictions (only if not dirty)
watch(savedPreds, (preds) => {
  preds?.forEach(p => {
    if (!dirty[p.match_id]) {
      inputs[p.match_id] = { home: p.home_score, away: p.away_score }
    }
  })
}, { immediate: true })

function predFor(matchId: number) {
  return savedPreds.value?.find(p => p.match_id === matchId)
}

function onInput(matchId: number) {
  dirty[matchId] = true
  delete saveErr[matchId]
}

async function save(matchId: number) {
  const { home, away } = inputs[matchId] ?? {}
  if (home === null || home === undefined || away === null || away === undefined) return

  saving[matchId] = true
  const { error } = await supabase
    .from('predictions')
    .upsert({ user_id: user.value!.id, match_id: matchId, home_score: home, away_score: away },
             { onConflict: 'user_id,match_id' })

  if (error) saveErr[matchId] = 'Error al guardar'
  else        dirty[matchId] = false

  await refreshPreds()
  saving[matchId] = false
}

// ── Tabs / round ──────────────────────────────────────────────
const round = ref(1)

// Auto-select current round
const now = new Date()
const currentRound = matches.value?.find(m => {
  const diff = (new Date(m.match_date).getTime() - now.getTime()) / 864e5
  return diff > -4 && diff < 8
})?.match_round ?? 1
round.value = currentRound

const roundMatches = computed(() =>
  (matches.value ?? []).filter(m => m.match_round === round.value)
)

// ── Stats ─────────────────────────────────────────────────────
const total     = computed(() => matches.value?.length ?? 0)
const predicted = computed(() => savedPreds.value?.length ?? 0)
const progress  = computed(() => total.value ? Math.round((predicted.value / total.value) * 100) : 0)

// ── Helpers ───────────────────────────────────────────────────
function fmtDate(s: string) {
  return new Intl.DateTimeFormat('es-ES', {
    weekday: 'short', day: 'numeric', month: 'short',
    timeZone: 'Europe/Madrid',
  }).format(new Date(s))
}
function fmtTime(s: string) {
  return new Intl.DateTimeFormat('es-ES', {
    hour: '2-digit', minute: '2-digit',
    timeZone: 'Europe/Madrid',
  }).format(new Date(s))
}

function resultLabel(pts: number) {
  if (pts >= 3) return pts > 3 ? `Exacto (+bonus)` : 'Exacto'
  if (pts >= 1) return pts > 1 ? `Acertado (+bonus)` : 'Acertado'
  return 'Fallado'
}
function resultClass(pts: number) {
  if (pts >= 3) return 'text-wc-green'
  if (pts >= 1) return 'text-blue-400'
  return 'text-gray-500'
}

function isDirtyAndValid(matchId: number) {
  if (!dirty[matchId]) return false
  const { home, away } = inputs[matchId] ?? {}
  return home !== null && home !== undefined && away !== null && away !== undefined
}
</script>

<template>
  <div class="container mx-auto px-4 max-w-4xl py-8">

    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-8">
      <div>
        <h1 class="font-display font-black text-4xl sm:text-5xl uppercase tracking-wide mb-1">
          Predicciones
        </h1>
        <p class="text-gray-400 text-sm">Fase de grupos · {{ predicted }}/{{ total }} guardadas</p>
      </div>

      <!-- Progress -->
      <div class="sm:w-48">
        <div class="flex justify-between text-xs text-gray-500 mb-1.5">
          <span>{{ progress }}% completado</span>
          <span>{{ predicted }}/{{ total }}</span>
        </div>
        <div class="h-1.5 bg-dark-600 rounded-full overflow-hidden">
          <div
            class="h-full bg-wc-green rounded-full transition-all duration-500"
            :style="{ width: `${progress}%` }"
          />
        </div>
      </div>
    </div>

    <!-- Estrellas del torneo -->
    <StarPlayers />

    <!-- Cómo funciona la puntuación -->
    <ScoringInfo />

    <!-- Round tabs -->
    <div class="flex gap-2 mb-8">
      <button
        v-for="r in [1, 2, 3]"
        :key="r"
        :class="round === r ? 'btn-primary btn-sm' : 'btn-secondary btn-sm'"
        @click="round = r"
      >
        Jornada {{ r }}
      </button>
    </div>

    <!-- Loading -->
    <div v-if="loadingMatches" class="space-y-3">
      <AppCard v-for="i in 6" :key="i" pad="md" class="animate-pulse">
        <div class="h-16 bg-dark-600 rounded" />
      </AppCard>
    </div>

    <!-- Match cards -->
    <div v-else class="space-y-3">
      <AppCard
        v-for="m in roundMatches"
        :key="m.id"
        pad="none"
        :class="m.status === 'live' ? 'border-wc-red/60' : ''"
      >
        <!-- Card header: group + date -->
        <div class="flex items-center justify-between px-4 pt-3 pb-2 border-b border-dark-500">
          <div class="flex items-center gap-2">
            <span class="font-display font-black text-xs uppercase tracking-widest
                         bg-dark-600 text-gray-300 px-2 py-0.5 rounded-sm">
              Grupo {{ m.group?.name }}
            </span>
            <span v-if="m.status === 'live'" class="flex items-center gap-1 text-xs text-wc-red font-bold uppercase">
              <span class="w-1.5 h-1.5 rounded-full bg-wc-red animate-pulse inline-block" />
              En vivo
            </span>
            <span v-else-if="m.status === 'finished'" class="text-xs text-gray-500">Finalizado</span>
          </div>
          <span class="text-xs text-gray-500 font-medium">
            {{ fmtDate(m.match_date) }} · {{ fmtTime(m.match_date) }}
          </span>
        </div>

        <!-- Teams + scores -->
        <div class="px-4 py-4">
          <div class="flex items-center gap-3">

            <!-- Home team -->
            <div class="flex-1 flex items-center gap-2 min-w-0">
              <CountryFlag :code="m.home_country?.code" :name="m.home_country?.name" :size="24" />
              <span class="font-display font-bold uppercase text-sm tracking-wide truncate">
                {{ m.home_country?.name }}
              </span>
            </div>

            <!-- Scores -->
            <div class="flex items-center gap-2 shrink-0">
              <!-- FINISHED: show actual result -->
              <template v-if="m.status === 'finished'">
                <span class="font-display font-black text-3xl w-10 text-center">
                  {{ m.home_score }}
                </span>
                <span class="text-gray-500 font-bold">—</span>
                <span class="font-display font-black text-3xl w-10 text-center">
                  {{ m.away_score }}
                </span>
              </template>

              <!-- SCHEDULED/LIVE: prediction inputs -->
              <template v-else>
                <input
                  v-model.number="inputs[m.id].home"
                  type="number" min="0" max="20"
                  :disabled="m.status !== 'scheduled'"
                  class="score-input"
                  placeholder="—"
                  @input="onInput(m.id)"
                >
                <span class="text-gray-500 font-bold">—</span>
                <input
                  v-model.number="inputs[m.id].away"
                  type="number" min="0" max="20"
                  :disabled="m.status !== 'scheduled'"
                  class="score-input"
                  placeholder="—"
                  @input="onInput(m.id)"
                >
              </template>
            </div>

            <!-- Away team -->
            <div class="flex-1 flex items-center justify-end gap-2 min-w-0">
              <span class="font-display font-bold uppercase text-sm tracking-wide truncate text-right">
                {{ m.away_country?.name }}
              </span>
              <CountryFlag :code="m.away_country?.code" :name="m.away_country?.name" :size="24" />
            </div>
          </div>

          <!-- Prediction row (only if match is scheduled/live or user has a prediction) -->
          <div
            v-if="m.status !== 'finished' || predFor(m.id)"
            class="flex items-center justify-between mt-3 pt-3 border-t border-dark-500/50"
          >
            <!-- Left: save button (scheduled) or prediction recap (finished) -->
            <div class="flex items-center gap-3">
              <template v-if="m.status === 'finished' && predFor(m.id)">
                <span class="text-xs text-gray-400">
                  Tu predicción:
                  <strong class="text-white">
                    {{ predFor(m.id)!.home_score }}–{{ predFor(m.id)!.away_score }}
                  </strong>
                </span>
              </template>
              <template v-else-if="m.status === 'scheduled'">
                <button
                  :disabled="saving[m.id] || !isDirtyAndValid(m.id)"
                  :class="isDirtyAndValid(m.id) ? 'btn-primary btn-sm' : 'btn-secondary btn-sm'"
                  @click="save(m.id)"
                >
                  {{ saving[m.id] ? 'Guardando…' : predFor(m.id) ? 'Actualizar' : 'Guardar' }}
                </button>
                <span v-if="saveErr[m.id]" class="text-xs text-red-400">{{ saveErr[m.id] }}</span>
              </template>
            </div>

            <!-- Right: points earned or status -->
            <div class="text-right">
              <template v-if="m.status === 'finished' && predFor(m.id)">
                <span
                  :class="['font-display font-black text-lg', resultClass(predFor(m.id)!.points_earned)]"
                >
                  +{{ predFor(m.id)!.points_earned }} pts
                </span>
                <p :class="['text-xs mt-0.5', resultClass(predFor(m.id)!.points_earned)]">
                  {{ resultLabel(predFor(m.id)!.points_earned) }}
                </p>
              </template>
              <template v-else-if="!predFor(m.id)">
                <span class="text-xs text-gray-600">Sin predicción</span>
              </template>
              <template v-else>
                <span class="text-xs text-gray-400 flex items-center gap-1">
                  <span class="w-1.5 h-1.5 rounded-full bg-wc-green inline-block" />
                  Guardado
                </span>
              </template>
            </div>
          </div>
        </div>
      </AppCard>

      <!-- Empty state -->
      <AppCard v-if="roundMatches.length === 0" pad="xl" class="text-center">
        <p class="text-3xl mb-3">📅</p>
        <p class="font-display font-bold text-xl uppercase tracking-wide text-gray-500">
          Sin partidos en esta jornada
        </p>
      </AppCard>
    </div>
  </div>
</template>

<style scoped>
.score-input {
  width: 2.75rem;
  height: 2.75rem;
  text-align: center;
  font-family: 'Barlow Condensed', sans-serif;
  font-weight: 800;
  font-size: 1.35rem;
  background: #141C35;
  border: 2px solid #2A3D6E;
  border-radius: 4px;
  color: white;
  outline: none;
  transition: border-color 0.15s;
}
.score-input:focus { border-color: #E61D25; }
.score-input:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  border-color: #1F2D52;
}
/* Hide browser spin arrows */
.score-input::-webkit-outer-spin-button,
.score-input::-webkit-inner-spin-button { -webkit-appearance: none; }
.score-input[type=number] { -moz-appearance: textfield; }
</style>
