<script setup lang="ts">
/**
 * UserPredictionsModal — muestra TODAS las predicciones de un usuario en
 * partidos ya finalizados. Se abre al pulsar sobre alguien en la clasificación.
 *
 * La política RLS "Predicciones visibles en partidos finalizados" garantiza
 * que solo se pueden leer predicciones de partidos 'finished'.
 */
const props = defineProps<{
  userId: string | null
  username: string
}>()
const emit = defineEmits<{ close: [] }>()

const supabase = useSupabaseClient()

// Forma normalizada y plana para que el template sea simple
interface Row {
  id: number
  predHome: number | null
  predAway: number | null
  points: number
  actualHome: number | null
  actualAway: number | null
  homeName: string
  homeCode: string
  awayName: string
  awayCode: string
  group: string
  date: string
  exact: boolean
}

const loading = ref(false)
const rows = ref<Row[]>([])

const one = (v: any): any => (Array.isArray(v) ? v[0] : v) ?? null

async function load(id: string) {
  loading.value = true
  rows.value = []
  const { data } = await supabase
    .from('predictions')
    .select(`
      id, home_score, away_score, points_earned,
      match:matches!inner(
        match_date, status, home_score, away_score,
        home_country:countries!home_country_id(name, code, flag),
        away_country:countries!away_country_id(name, code, flag),
        group:groups(name)
      )
    `)
    .eq('user_id', id)
    .eq('match.status', 'finished')

  const mapped: Row[] = (data ?? []).map((r: any) => {
    const m = one(r.match) ?? {}
    const h = one(m.home_country) ?? {}
    const a = one(m.away_country) ?? {}
    const g = one(m.group) ?? {}
    return {
      id: r.id,
      predHome: r.home_score,
      predAway: r.away_score,
      points: r.points_earned ?? 0,
      actualHome: m.home_score ?? null,
      actualAway: m.away_score ?? null,
      homeName: h.name ?? '', homeCode: h.code ?? '',
      awayName: a.name ?? '', awayCode: a.code ?? '',
      group: g.name ?? '',
      date: m.match_date ?? '',
      exact: r.home_score === m.home_score && r.away_score === m.away_score,
    }
  })
  // Orden cronológico (más reciente primero)
  mapped.sort((x, y) => y.date.localeCompare(x.date))
  rows.value = mapped
  loading.value = false
}

watch(() => props.userId, (id) => {
  if (id) load(id)
  if (import.meta.client) document.body.style.overflow = id ? 'hidden' : ''
}, { immediate: true })

onUnmounted(() => {
  if (import.meta.client) document.body.style.overflow = ''
})

const totalPts = computed(() => rows.value.reduce((s, r) => s + r.points, 0))
const exacts = computed(() => rows.value.filter(r => r.points >= 3).length)

function fmtDate(s: string) {
  if (!s) return ''
  return new Intl.DateTimeFormat('es-ES', {
    day: 'numeric', month: 'short', timeZone: 'Europe/Madrid',
  }).format(new Date(s))
}
function ptsClass(p: number): string {
  if (p >= 3) return 'text-wc-green'
  if (p >= 1) return 'text-blue-400'
  return 'text-gray-500'
}
function rowBg(p: number): string {
  if (p >= 3) return 'bg-wc-green/10 border-wc-green/20'
  if (p >= 1) return 'bg-blue-500/10 border-blue-500/20'
  return 'bg-dark-700 border-dark-500'
}
</script>

<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div
        v-if="userId"
        class="fixed inset-0 z-[100] flex items-end sm:items-center justify-center p-0 sm:p-4"
        @click.self="emit('close')"
      >
        <!-- Backdrop -->
        <div class="absolute inset-0 bg-black/70 backdrop-blur-sm" @click="emit('close')" />

        <!-- Panel -->
        <div
          class="relative w-full sm:max-w-2xl bg-dark-800 border border-dark-500 sm:rounded-lg
                 max-h-[90vh] sm:max-h-[85vh] flex flex-col rounded-t-2xl shadow-2xl"
        >
          <!-- Header -->
          <div class="flex items-center justify-between px-5 py-4 border-b border-dark-500 shrink-0">
            <div class="min-w-0">
              <p class="text-xs text-gray-500 uppercase tracking-widest font-bold">Predicciones de</p>
              <h2 class="font-display font-black text-2xl uppercase tracking-wide truncate">
                {{ username }}
              </h2>
            </div>
            <button
              class="shrink-0 w-9 h-9 flex items-center justify-center rounded-full
                     text-gray-400 hover:text-white hover:bg-dark-600 transition-colors text-xl"
              @click="emit('close')"
            >
              ✕
            </button>
          </div>

          <!-- Resumen -->
          <div v-if="!loading && rows.length" class="flex gap-6 px-5 py-3 border-b border-dark-500/60 shrink-0 text-sm">
            <span><strong class="font-display font-black text-wc-gold text-base">{{ totalPts }}</strong> <span class="text-gray-400">pts</span></span>
            <span><strong class="font-display font-black text-wc-green text-base">{{ exacts }}</strong> <span class="text-gray-400">exactos</span></span>
            <span><strong class="font-display font-black text-white text-base">{{ rows.length }}</strong> <span class="text-gray-400">partidos</span></span>
          </div>

          <!-- Contenido -->
          <div class="overflow-y-auto p-4 space-y-2">
            <!-- Loading -->
            <div v-if="loading" class="space-y-2">
              <div v-for="i in 5" :key="i" class="h-14 bg-dark-600/50 rounded animate-pulse" />
            </div>

            <!-- Vacío -->
            <div v-else-if="!rows.length" class="text-center py-12 text-gray-400">
              <p class="text-3xl mb-3">📋</p>
              <p class="font-display font-bold uppercase tracking-wide">Sin predicciones en partidos finalizados</p>
            </div>

            <!-- Lista -->
            <div
              v-for="r in rows"
              :key="r.id"
              :class="['card px-3 py-2.5 flex items-center gap-3', rowBg(r.points)]"
            >
              <!-- Fecha + grupo -->
              <div class="hidden sm:block text-center w-14 shrink-0">
                <p class="font-display font-black text-xs uppercase text-gray-400">Gr. {{ r.group }}</p>
                <p class="text-xs text-gray-500">{{ fmtDate(r.date) }}</p>
              </div>

              <!-- Partido -->
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-1.5 text-sm font-medium">
                  <CountryFlag :code="r.homeCode" :name="r.homeName" :size="16" />
                  <span class="truncate">{{ r.homeName }}</span>
                  <span class="text-gray-400 px-1 font-bold shrink-0">{{ r.actualHome }}–{{ r.actualAway }}</span>
                  <span class="truncate">{{ r.awayName }}</span>
                  <CountryFlag :code="r.awayCode" :name="r.awayName" :size="16" />
                </div>
                <p class="text-xs text-gray-400 mt-0.5">
                  Predijo:
                  <strong :class="r.exact ? 'text-wc-green' : 'text-white'">
                    {{ r.predHome }}–{{ r.predAway }}
                  </strong>
                </p>
              </div>

              <!-- Puntos -->
              <div class="shrink-0 text-right w-12">
                <p :class="['font-display font-black text-lg', ptsClass(r.points)]">+{{ r.points }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.modal-fade-enter-active,
.modal-fade-leave-active { transition: opacity 0.2s ease; }
.modal-fade-enter-from,
.modal-fade-leave-to { opacity: 0; }
</style>
