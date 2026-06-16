<script setup lang="ts">
/**
 * MatchPredictions — muestra las predicciones de TODOS los usuarios para un
 * partido ya finalizado, ordenadas por puntos conseguidos.
 *
 * Solo funciona con partidos 'finished' (la política RLS lo garantiza:
 * para partidos no finalizados la consulta devuelve únicamente la del propio
 * usuario, así que no se filtra información antes de tiempo).
 */
const props = defineProps<{
  matchId: number
  homeScore: number | null
  awayScore: number | null
  homeCode?: string | null
  awayCode?: string | null
}>()

const supabase = useSupabaseClient()
const user = useSupabaseUser()

interface RowPred {
  id: number
  user_id: string
  home_score: number | null
  away_score: number | null
  points_earned: number | null
  profile: { username: string | null } | { username: string | null }[] | null
}

const open = ref(false)
const loaded = ref(false)
const loading = ref(false)
const preds = ref<RowPred[]>([])

function usernameOf(r: RowPred): string {
  const p = Array.isArray(r.profile) ? r.profile[0] : r.profile
  return p?.username ?? 'Anónimo'
}

async function load() {
  loading.value = true
  const { data } = await supabase
    .from('predictions')
    .select('id, user_id, home_score, away_score, points_earned, profile:profiles!user_id(username)')
    .eq('match_id', props.matchId)
    .order('points_earned', { ascending: false })
  preds.value = (data ?? []) as RowPred[]
  loaded.value = true
  loading.value = false
}

async function toggle() {
  open.value = !open.value
  if (open.value && !loaded.value) await load()
}

// Marca si la predicción clavó el resultado exacto
function isExact(r: RowPred): boolean {
  return r.home_score === props.homeScore && r.away_score === props.awayScore
}

function ptsClass(pts: number | null): string {
  const p = pts ?? 0
  if (p >= 3) return 'text-wc-green'
  if (p >= 1) return 'text-blue-400'
  return 'text-gray-500'
}
</script>

<template>
  <div class="mt-3 pt-3 border-t border-dark-500/50">
    <button
      class="flex items-center gap-1.5 text-sm font-display font-bold uppercase tracking-wide
             text-gray-400 hover:text-white transition-colors"
      @click="toggle"
    >
      <svg
        class="w-3.5 h-3.5 transition-transform"
        :class="open ? 'rotate-90' : ''"
        fill="none" stroke="currentColor" viewBox="0 0 24 24"
      >
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7" />
      </svg>
      Predicciones de todos
      <span v-if="loaded" class="text-gray-600 font-normal normal-case">({{ preds.length }})</span>
    </button>

    <div v-if="open" class="mt-3">
      <!-- Cargando -->
      <div v-if="loading" class="space-y-1.5">
        <div v-for="i in 3" :key="i" class="h-8 bg-dark-600/50 rounded animate-pulse" />
      </div>

      <!-- Vacío -->
      <p v-else-if="!preds.length" class="text-sm text-gray-500 py-2">
        Nadie predijo este partido.
      </p>

      <!-- Lista -->
      <ul v-else class="divide-y divide-dark-500/40">
        <li
          v-for="r in preds"
          :key="r.id"
          class="flex items-center gap-3 py-1.5"
          :class="r.user_id === user?.id ? 'text-white' : 'text-gray-300'"
        >
          <!-- Usuario -->
          <span class="flex-1 min-w-0 truncate text-sm font-medium">
            {{ usernameOf(r) }}
            <span v-if="r.user_id === user?.id" class="text-xs text-wc-gold ml-1">(tú)</span>
          </span>

          <!-- Predicción -->
          <span
            class="font-display font-bold text-base tabular-nums shrink-0 px-2 py-0.5 rounded-sm"
            :class="isExact(r) ? 'bg-wc-green/15 text-wc-green' : 'bg-dark-600/60 text-gray-200'"
          >
            {{ r.home_score }}–{{ r.away_score }}
          </span>

          <!-- Puntos -->
          <span :class="['font-display font-black text-sm w-12 text-right shrink-0', ptsClass(r.points_earned)]">
            +{{ r.points_earned ?? 0 }}
          </span>
        </li>
      </ul>
    </div>
  </div>
</template>
