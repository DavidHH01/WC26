<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const supabase = useSupabaseClient()

// ── Fetch all matches ─────────────────────────────────────────
const { data: matches, refresh } = await useAsyncData('admin-matches', async () => {
  const { data } = await supabase
    .from('matches')
    .select(`
      id, match_round, match_date, status, home_score, away_score, home_fifa_points, away_fifa_points,
      home_country:countries!home_country_id(id, name, code, flag),
      away_country:countries!away_country_id(id, name, code, flag),
      group:groups(name)
    `)
    .eq('stage', 'group')
    .order('match_date')
  return data ?? []
})

// ── Editable state ────────────────────────────────────────────
type Edit = { home: number | null; away: number | null; status: string }
const edits = reactive<Record<number, Edit>>({})

watch(matches, (ms) => {
  ms?.forEach(m => {
    if (!edits[m.id]) {
      edits[m.id] = {
        home: m.home_score ?? null,
        away: m.away_score ?? null,
        status: m.status,
      }
    }
  })
}, { immediate: true })

// ── Filter ────────────────────────────────────────────────────
const filter = ref<'all' | 'scheduled' | 'live' | 'finished'>('all')
const filtered = computed(() => {
  const ms = matches.value ?? []
  if (filter.value === 'all') return ms
  return ms.filter(m => m.status === filter.value)
})

// ── Counts ────────────────────────────────────────────────────
const counts = computed(() => ({
  all: matches.value?.length ?? 0,
  scheduled: matches.value?.filter(m => m.status === 'scheduled').length ?? 0,
  live: matches.value?.filter(m => m.status === 'live').length ?? 0,
  finished: matches.value?.filter(m => m.status === 'finished').length ?? 0,
}))

// ── Save ─────────────────────────────────────────────────────
const saving = reactive<Record<number, boolean>>({})
const saved  = reactive<Record<number, boolean>>({})
const errors = reactive<Record<number, string>>({})

async function saveMatch(id: number) {
  const e = edits[id]
  if (!e) return
  saving[id] = true
  delete errors[id]
  delete saved[id]

  const payload: Record<string, any> = { status: e.status }

  // Only include scores if finishing or already has them
  if (e.home !== null && e.away !== null) {
    payload.home_score = e.home
    payload.away_score = e.away
  }

  const { error } = await supabase
    .from('matches')
    .update(payload)
    .eq('id', id)

  if (error) {
    errors[id] = error.message
  } else {
    saved[id] = true
    await refresh()
    setTimeout(() => { delete saved[id] }, 2000)
  }
  saving[id] = false
}

// ── Helpers ───────────────────────────────────────────────────
function fmtDate(s: string) {
  return new Intl.DateTimeFormat('es-ES', {
    weekday: 'short', day: 'numeric', month: 'short',
    hour: '2-digit', minute: '2-digit',
    timeZone: 'Europe/Madrid',
  }).format(new Date(s))
}

const statusLabel: Record<string, string> = {
  scheduled: 'Programado',
  live: 'En vivo',
  finished: 'Finalizado',
}
const statusColor: Record<string, string> = {
  scheduled: 'text-gray-400',
  live: 'text-wc-red',
  finished: 'text-wc-green',
}
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <div>
        <h1 class="font-display font-black text-3xl uppercase tracking-wide">Partidos</h1>
        <p class="text-gray-400 text-sm mt-0.5">Gestiona resultados y estado de los partidos</p>
      </div>
    </div>

    <!-- Filter tabs -->
    <div class="flex gap-2 mb-6 flex-wrap">
      <button
        v-for="f in ['all', 'scheduled', 'live', 'finished'] as const"
        :key="f"
        :class="filter === f ? 'btn-primary btn-sm' : 'btn-secondary btn-sm'"
        @click="filter = f"
      >
        {{ f === 'all' ? 'Todos' : statusLabel[f] }}
        <span class="ml-1 font-normal opacity-70">({{ counts[f] }})</span>
      </button>
    </div>

    <!-- Matches table -->
    <AppCard pad="none">
      <table class="w-full text-sm">
        <thead>
          <tr class="border-b border-dark-500 text-gray-400 text-xs uppercase tracking-wider">
            <th class="text-left px-4 py-3 font-bold">Partido</th>
            <th class="text-center px-3 py-3 font-bold">Resultado</th>
            <th class="text-center px-3 py-3 font-bold hidden sm:table-cell">Estado</th>
            <th class="text-right px-4 py-3 font-bold">Acción</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="m in filtered"
            :key="m.id"
            class="border-b border-dark-500/40"
          >
            <!-- Match info -->
            <td class="px-4 py-3">
              <div class="flex items-center gap-1.5 font-semibold">
                <CountryFlag :code="m.home_country?.code" :name="m.home_country?.name" :size="16" />
                <span class="truncate max-w-[70px] sm:max-w-none">{{ m.home_country?.name }}</span>
                <span class="text-gray-500 px-1 font-bold">vs</span>
                <span class="truncate max-w-[70px] sm:max-w-none">{{ m.away_country?.name }}</span>
                <CountryFlag :code="m.away_country?.code" :name="m.away_country?.name" :size="16" />
              </div>
              <p class="text-xs text-gray-500 mt-0.5">
                Grupo {{ m.group?.name }} · {{ fmtDate(m.match_date) }}
              </p>
            </td>

            <!-- Score inputs -->
            <td class="px-3 py-3">
              <div class="flex items-center justify-center gap-1.5">
                <input
                  v-model.number="edits[m.id].home"
                  type="number" min="0" max="30"
                  class="admin-score"
                  placeholder="—"
                >
                <span class="text-gray-500 font-bold text-lg">–</span>
                <input
                  v-model.number="edits[m.id].away"
                  type="number" min="0" max="30"
                  class="admin-score"
                  placeholder="—"
                >
              </div>
            </td>

            <!-- Status select -->
            <td class="px-3 py-3 hidden sm:table-cell">
              <select
                v-model="edits[m.id].status"
                class="admin-select"
                :class="statusColor[edits[m.id].status]"
              >
                <option value="scheduled">Programado</option>
                <option value="live">En vivo</option>
                <option value="finished">Finalizado</option>
              </select>
            </td>

            <!-- Save button -->
            <td class="px-4 py-3 text-right">
              <div class="flex items-center justify-end gap-2">
                <span v-if="saved[m.id]" class="text-xs text-wc-green font-bold">✓ Guardado</span>
                <span v-if="errors[m.id]" class="text-xs text-red-400">Error</span>
                <!-- Mobile: status selector inline -->
                <select
                  v-model="edits[m.id].status"
                  class="admin-select sm:hidden"
                  :class="statusColor[edits[m.id].status]"
                >
                  <option value="scheduled">Prog.</option>
                  <option value="live">Vivo</option>
                  <option value="finished">Final.</option>
                </select>
                <button
                  :disabled="saving[m.id]"
                  class="btn-primary btn-sm"
                  @click="saveMatch(m.id)"
                >
                  {{ saving[m.id] ? '…' : 'Guardar' }}
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <p v-if="filtered.length === 0" class="text-center py-10 text-gray-500">
        No hay partidos con este filtro
      </p>
    </AppCard>
  </div>
</template>

<style scoped>
.admin-score {
  width: 3rem;
  height: 2.5rem;
  text-align: center;
  font-family: 'Barlow Condensed', sans-serif;
  font-weight: 800;
  font-size: 1.2rem;
  background: #141C35;
  border: 2px solid #2A3D6E;
  border-radius: 4px;
  color: white;
  outline: none;
  transition: border-color 0.15s;
}
.admin-score:focus { border-color: #E61D25; }
.admin-score::-webkit-outer-spin-button,
.admin-score::-webkit-inner-spin-button { -webkit-appearance: none; }
.admin-score[type=number] { -moz-appearance: textfield; }

.admin-select {
  background: #141C35;
  border: 2px solid #2A3D6E;
  border-radius: 4px;
  padding: 0.35rem 0.6rem;
  font-family: 'Barlow Condensed', sans-serif;
  font-weight: 700;
  font-size: 0.82rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  outline: none;
  cursor: pointer;
  transition: border-color 0.15s;
}
.admin-select:focus { border-color: #2A398D; }
</style>
