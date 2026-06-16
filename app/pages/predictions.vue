<script setup lang="ts">
const supabase = useSupabaseClient()
const user = useSupabaseUser()

// ── Types ─────────────────────────────────────────────────────
interface PredCountry {
  id: number
  name: string
  code: string
  flag: string
}
interface PredMatch {
  id: number
  match_round: number
  match_date: string
  status: string
  home_score: number | null
  away_score: number | null
  home_fifa_points: number | null
  away_fifa_points: number | null
  home_country: PredCountry | null
  away_country: PredCountry | null
  group: { name: string } | null
}
interface Prediction {
  id: number
  match_id: number
  home_score: number | null
  away_score: number | null
  points_earned: number | null
}

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
  return (data ?? []) as PredMatch[]
})

// ── Fetch user predictions ────────────────────────────────────
const { data: savedPreds, refresh: refreshPreds } = await useAsyncData('my-preds', async () => {
  if (!user.value) return [] as Prediction[]
  // IMPORTANTE: filtrar por user_id. Desde la migración 009, la RLS también
  // deja ver predicciones de OTROS en partidos finalizados, así que sin este
  // filtro se colarían y el contador subiría por encima de 72.
  const { data } = await supabase
    .from('predictions')
    .select('id, match_id, home_score, away_score, points_earned')
    .eq('user_id', user.value.id)
  return (data ?? []) as Prediction[]
})

// ── Local input state ─────────────────────────────────────────
type Input = { home: number | null; away: number | null }
const inputs  = reactive({} as Record<number, Input>)
const dirty   = reactive<Record<number, boolean>>({})
const saving  = reactive<Record<number, boolean>>({})
const saveErr = reactive<Record<number, string>>({})

// Helper: ensures inputs[id] always exists (safe for v-model)
function getInput(id: number): Input {
  if (!inputs[id]) inputs[id] = { home: null, away: null }
  return inputs[id]
}

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
  const { error } = await (supabase
    .from('predictions') as any)
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

// Bloquea el partido si ya empezó (por hora) o no está programado
function isLocked(m: any): boolean {
  if (m.status !== 'scheduled') return true
  return new Date(m.match_date) <= new Date()
}

// Puntos potenciales que puede dar un partido según los rankings FIFA
function potentialPts(m: any) {
  const hFifa = m.home_fifa_points as number | null
  const aFifa = m.away_fifa_points as number | null
  if (!hFifa || !aFifa) return { exact: 3, winner: 1, bonus: 0 }
  const diff = Math.abs(hFifa - aFifa)
  const avg = (hFifa + aFifa) / 2
  const upsetBonus = Math.min(5, Math.floor(diff / 100))
  const weakBonus = avg < 1550 ? 1 : 0
  const bonus = upsetBonus + weakBonus
  return { exact: 3 + bonus, winner: 1 + bonus, bonus }
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
        <p class="text-gray-400 text-base">Fase de grupos · {{ predicted }}/{{ total }} guardadas</p>
      </div>

      <!-- Progress -->
      <div class="sm:w-48">
        <div class="flex justify-between text-sm text-gray-400 mb-1.5">
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
            <span class="font-display font-black text-sm uppercase tracking-widest
                         bg-dark-600 text-gray-300 px-2 py-0.5 rounded-sm">
              Grupo {{ m.group?.name }}
            </span>
            <span v-if="m.status === 'live'" class="flex items-center gap-1 text-sm text-wc-red font-bold uppercase">
              <span class="w-1.5 h-1.5 rounded-full bg-wc-red animate-pulse inline-block" />
              En vivo
            </span>
            <span v-else-if="m.status === 'finished'" class="text-sm text-gray-400">Finalizado</span>
            <span v-else-if="isLocked(m)" class="flex items-center gap-1 text-sm text-amber-400 font-bold uppercase">
              <svg class="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd"/>
              </svg>
              Cerrado
            </span>
          </div>
          <span class="text-sm text-gray-400 font-medium">
            {{ fmtDate(m.match_date) }} · {{ fmtTime(m.match_date) }}
          </span>
        </div>

        <!-- Teams + scores -->
        <div class="px-4 py-4">
          <div class="flex items-center gap-3">

            <!-- Home team -->
            <div class="flex-1 flex items-center gap-2 min-w-0">
              <CountryFlag :code="m.home_country?.code" :name="m.home_country?.name" :size="28" />
              <span class="font-display font-bold uppercase text-base tracking-wide truncate">
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
                  v-model.number="getInput(m.id).home"
                  type="number" min="0" max="20"
                  :disabled="isLocked(m)"
                  class="score-input"
                  placeholder="—"
                  @input="onInput(m.id)"
                >
                <span class="text-gray-400 font-bold">—</span>
                <input
                  v-model.number="getInput(m.id).away"
                  type="number" min="0" max="20"
                  :disabled="isLocked(m)"
                  class="score-input"
                  placeholder="—"
                  @input="onInput(m.id)"
                >
              </template>
            </div>

            <!-- Away team -->
            <div class="flex-1 flex items-center justify-end gap-2 min-w-0">
              <span class="font-display font-bold uppercase text-base tracking-wide truncate text-right">
                {{ m.away_country?.name }}
              </span>
              <CountryFlag :code="m.away_country?.code" :name="m.away_country?.name" :size="28" />
            </div>
          </div>

          <!-- Prediction row -->
          <div
            v-if="m.status !== 'finished' || predFor(m.id)"
            class="flex items-center justify-between mt-3 pt-3 border-t border-dark-500/50"
          >
            <!-- Left: save button / recap / locked -->
            <div class="flex items-center gap-3">
              <template v-if="m.status === 'finished' && predFor(m.id)">
                <span class="text-sm text-gray-400">
                  Tu predicción:
                  <strong class="text-white">
                    {{ predFor(m.id)!.home_score }}–{{ predFor(m.id)!.away_score }}
                  </strong>
                </span>
              </template>
              <template v-else-if="!isLocked(m)">
                <button
                  :disabled="saving[m.id] || !isDirtyAndValid(m.id)"
                  :class="isDirtyAndValid(m.id) ? 'btn-primary' : 'btn-secondary'"
                  @click="save(m.id)"
                >
                  {{ saving[m.id] ? 'Guardando…' : predFor(m.id) ? 'Actualizar' : 'Guardar' }}
                </button>
                <span v-if="saveErr[m.id]" class="text-sm text-red-400">{{ saveErr[m.id] }}</span>
              </template>
              <template v-else-if="isLocked(m) && m.status === 'scheduled'">
                <span v-if="predFor(m.id)" class="text-sm text-gray-400">
                  Tu predicción:
                  <strong class="text-white">
                    {{ predFor(m.id)!.home_score }}–{{ predFor(m.id)!.away_score }}
                  </strong>
                </span>
                <span v-else class="text-sm text-gray-400">Sin predicción guardada</span>
              </template>
            </div>

            <!-- Right: points earned / potential / status -->
            <div class="text-right">
              <!-- Partido terminado: puntos reales -->
              <template v-if="m.status === 'finished' && predFor(m.id)">
                <span :class="['font-display font-black text-xl', resultClass(predFor(m.id)!.points_earned ?? 0)]">
                  +{{ predFor(m.id)!.points_earned ?? 0 }} pts
                </span>
                <p :class="['text-sm mt-0.5 font-medium', resultClass(predFor(m.id)!.points_earned ?? 0)]">
                  {{ resultLabel(predFor(m.id)!.points_earned ?? 0) }}
                </p>
              </template>
              <!-- Partido abierto: puntos potenciales -->
              <template v-else-if="!isLocked(m)">
                <div class="flex items-center gap-2 text-sm text-gray-400">
                  <span class="flex items-center gap-1">
                    <span class="font-display font-bold text-wc-green">+{{ potentialPts(m).exact }}</span>
                    <span>exacto</span>
                  </span>
                  <span class="text-gray-600">·</span>
                  <span class="flex items-center gap-1">
                    <span class="font-display font-bold text-blue-400">+{{ potentialPts(m).winner }}</span>
                    <span>ganador</span>
                  </span>
                </div>
                <p v-if="potentialPts(m).bonus > 0" class="text-sm text-wc-gold mt-0.5">
                  +{{ potentialPts(m).bonus }} bonus posible
                </p>
              </template>
              <!-- Cerrado con predicción guardada -->
              <template v-else-if="predFor(m.id)">
                <span class="text-sm text-gray-400 flex items-center gap-1.5 justify-end">
                  <span class="w-2 h-2 rounded-full bg-wc-green inline-block" />
                  Guardado
                </span>
              </template>
              <template v-else>
                <span class="text-sm text-gray-400">Sin predicción</span>
              </template>
            </div>
          </div>

          <!-- Predicciones de todos (solo partidos finalizados) -->
          <MatchPredictions
            v-if="m.status === 'finished'"
            :match-id="m.id"
            :home-score="m.home_score"
            :away-score="m.away_score"
            :home-code="m.home_country?.code"
            :away-code="m.away_country?.code"
          />
        </div>
      </AppCard>

      <!-- Empty state -->
      <AppCard v-if="roundMatches.length === 0" pad="xl" class="text-center">
        <p class="text-3xl mb-3">📅</p>
        <p class="font-display font-bold text-xl uppercase tracking-wide text-gray-300">
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
