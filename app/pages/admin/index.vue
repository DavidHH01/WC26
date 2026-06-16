<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const supabase = useSupabaseClient()

// ── FIFA Sync ──────────────────────────────────────────────────
const syncing    = ref(false)
const syncResult = ref<any>(null)

async function runSync(opts = { matches: true, scorers: true }) {
  syncing.value = true
  syncResult.value = null
  try {
    const { data: { session } } = await supabase.auth.getSession()
    const res = await $fetch('/api/admin/sync', {
      method: 'POST',
      headers: { Authorization: `Bearer ${session?.access_token}` },
      body: opts,
    })
    syncResult.value = res
    if ((res as any).matchesUpdated > 0) await refresh()
  } catch (e: any) {
    syncResult.value = { success: false, errors: [e?.data?.message ?? e.message], timestamp: new Date().toISOString() }
  }
  syncing.value = false
}

// ── Types ─────────────────────────────────────────────────────
interface AdminMatch {
  id: number
  match_round: number
  match_date: string
  status: string
  home_score: number | null
  away_score: number | null
  home_fifa_points: number | null
  away_fifa_points: number | null
  home_country: { id: number; name: string; code: string; flag: string } | null
  away_country: { id: number; name: string; code: string; flag: string } | null
  group: { name: string } | null
}

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
  return (data ?? []) as AdminMatch[]
})

// ── Editable state ────────────────────────────────────────────
type Edit = { home: number | null; away: number | null; status: string }
const edits = reactive({} as Record<number, Edit>)

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

// Helper: ensures edits[id] always exists (for v-model binding in template)
function getEdit(id: number): Edit {
  if (!edits[id]) edits[id] = { home: null, away: null, status: 'scheduled' }
  return edits[id]
}

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
const matchErrors = reactive<Record<number, string>>({})

async function saveMatch(id: number) {
  const e = edits[id]
  if (!e) return
  saving[id] = true
  delete matchErrors[id]
  delete saved[id]

  const payload: Record<string, unknown> = { status: e.status }

  // Only include scores if finishing or already has them
  if (e.home !== null && e.away !== null) {
    payload.home_score = e.home
    payload.away_score = e.away
  }

  const { error } = await (supabase.from('matches') as any)
    .update(payload)
    .eq('id', id)

  if (error) {
    matchErrors[id] = error.message
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

    <!-- FIFA Sync panel -->
    <AppCard pad="md" class="mb-6">
      <!-- Estado auto-sync -->
      <div class="flex items-center gap-2 mb-4 pb-4 border-b border-dark-500/60">
        <span class="inline-flex items-center gap-1.5">
          <span class="w-2 h-2 rounded-full bg-wc-green animate-pulse inline-block" />
          <span class="text-sm font-semibold text-wc-green">Auto-sync activo</span>
        </span>
        <span class="text-sm text-gray-400">— los resultados, estados y goleadores se sincronizan con FIFA <strong class="text-white">automáticamente</strong> cada minuto. Normalmente no necesitas tocar nada aquí.</span>
      </div>

      <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <p class="section-label mb-1">Sync manual</p>
          <p class="text-sm text-gray-400">
            Fuerza una sincronización inmediata con FIFA.com.
          </p>
        </div>
        <div class="flex items-center gap-2 shrink-0">
          <button
            :disabled="syncing"
            class="btn-primary btn-sm"
            @click="runSync()"
          >
            <svg v-if="syncing" class="w-3.5 h-3.5 animate-spin mr-1" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
            </svg>
            {{ syncing ? 'Sincronizando…' : '↻ Sync ahora' }}
          </button>
        </div>
      </div>

      <!-- Resultado del último sync manual -->
      <div v-if="syncResult" class="mt-4 pt-4 border-t border-dark-500/60">
        <div :class="['flex items-start gap-2 text-sm rounded p-3', syncResult.success ? 'bg-wc-green/10 border border-wc-green/25' : 'bg-red-500/10 border border-red-500/25']">
          <span class="text-lg shrink-0">{{ syncResult.success ? '✓' : '✗' }}</span>
          <div class="min-w-0">
            <p :class="syncResult.success ? 'text-wc-green font-semibold' : 'text-red-400 font-semibold'">
              {{ syncResult.success
                  ? `Actualizado: ${syncResult.matchesUpdated} partidos · ${syncResult.scorersUpdated} goleadores`
                    + (syncResult.source ? ` [${syncResult.source}]` : '')
                  : 'Sync fallido' }}
            </p>
            <p v-if="syncResult.errors?.length" class="text-red-300 text-xs mt-1">
              {{ syncResult.errors.join(' · ') }}
            </p>
            <details v-if="syncResult.log?.length" class="mt-1">
              <summary class="text-xs text-gray-500 cursor-pointer hover:text-gray-300">Ver log ({{ syncResult.log.length }})</summary>
              <pre class="text-xs text-gray-400 mt-1 max-h-32 overflow-y-auto whitespace-pre-wrap">{{ syncResult.log.join('\n') }}</pre>
            </details>
            <p class="text-xs text-gray-500 mt-1">
              {{ new Date(syncResult.timestamp).toLocaleTimeString('es-ES') }}
            </p>
          </div>
        </div>
      </div>
    </AppCard>

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

    <!-- Matches list (tarjetas responsive) -->
    <AppCard pad="none">
      <ul class="divide-y divide-dark-500/40">
        <li
          v-for="m in filtered"
          :key="m.id"
          class="p-3 sm:px-4 sm:py-3 flex flex-col gap-3 sm:flex-row sm:items-center sm:gap-4"
        >
          <!-- Info del partido -->
          <div class="min-w-0 sm:flex-1">
            <div class="flex items-center gap-1.5 font-semibold">
              <CountryFlag :code="m.home_country?.code" :name="m.home_country?.name" :size="16" />
              <span class="truncate">{{ m.home_country?.name }}</span>
              <span class="text-gray-500 px-1 font-bold shrink-0">vs</span>
              <span class="truncate">{{ m.away_country?.name }}</span>
              <CountryFlag :code="m.away_country?.code" :name="m.away_country?.name" :size="16" />
            </div>
            <p class="text-xs text-gray-500 mt-0.5">
              Grupo {{ m.group?.name }} · {{ fmtDate(m.match_date) }}
            </p>
          </div>

          <!-- Controles: marcador + estado + guardar -->
          <div class="flex items-center gap-2 sm:gap-3 flex-wrap sm:flex-nowrap sm:shrink-0">
            <!-- Marcador -->
            <div class="flex items-center gap-1.5">
              <input
                v-model.number="getEdit(m.id).home"
                type="number" min="0" max="30"
                class="admin-score"
                placeholder="—"
              >
              <span class="text-gray-500 font-bold text-lg">–</span>
              <input
                v-model.number="getEdit(m.id).away"
                type="number" min="0" max="30"
                class="admin-score"
                placeholder="—"
              >
            </div>

            <!-- Estado -->
            <select
              v-model="getEdit(m.id).status"
              class="admin-select flex-1 sm:flex-none min-w-[7rem]"
              :class="statusColor[getEdit(m.id).status]"
            >
              <option value="scheduled">Programado</option>
              <option value="live">En vivo</option>
              <option value="finished">Finalizado</option>
            </select>

            <!-- Guardar -->
            <button
              :disabled="saving[m.id]"
              class="btn-primary btn-sm shrink-0"
              @click="saveMatch(m.id)"
            >
              {{ saving[m.id] ? '…' : 'Guardar' }}
            </button>

            <!-- Feedback -->
            <span v-if="saved[m.id]" class="text-xs text-wc-green font-bold shrink-0">✓</span>
            <span v-if="matchErrors[m.id]" class="text-xs text-red-400 shrink-0">Error</span>
          </div>
        </li>
      </ul>

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
