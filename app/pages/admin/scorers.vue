<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const supabase = useSupabaseClient()

// ── Types ──────────────────────────────────────────────────────
interface AdminCountry {
  id: number
  name: string
  code: string
  flag: string
}
interface AdminScorer {
  id: number
  player_name: string
  position: string | null
  goals: number
  assists: number
  matches: number
  country: AdminCountry | null
}

// ── Countries for select ──────────────────────────────────────
const { data: countries } = await useAsyncData('admin-countries', async () => {
  const { data } = await supabase
    .from('countries')
    .select('id, name, code, flag')
    .order('name')
  return (data ?? []) as AdminCountry[]
})

// ── Fetch scorers ─────────────────────────────────────────────
const { data: scorers, refresh } = await useAsyncData('admin-scorers', async () => {
  const { data } = await supabase
    .from('top_scorers')
    .select(`id, player_name, position, goals, assists, matches, country:countries(id, name, code, flag)`)
    .order('goals', { ascending: false })
    .order('assists', { ascending: false })
  return (data ?? []) as AdminScorer[]
})

// ── New scorer form ───────────────────────────────────────────
const blankForm = () => ({
  player_name: '',
  country_id: null as number | null,
  position: 'FW' as string,
  goals: 0,
  assists: 0,
  matches: 0,
})
const form = reactive(blankForm())
const saving = ref(false)
const formErr = ref('')

async function addScorer() {
  if (!form.player_name.trim() || !form.country_id) {
    formErr.value = 'Nombre y país son obligatorios'
    return
  }
  saving.value = true
  formErr.value = ''
  const { error } = await (supabase.from('top_scorers') as any).insert({
    player_name: form.player_name.trim(),
    country_id: form.country_id,
    position: form.position,
    goals: form.goals,
    assists: form.assists,
    matches: form.matches,
  })
  if (error) {
    formErr.value = error.message
  } else {
    Object.assign(form, blankForm())
    await refresh()
  }
  saving.value = false
}

// ── Inline edit ───────────────────────────────────────────────
type ScorerRow = { goals: number; assists: number; matches: number }
const edits     = reactive({} as Record<number, ScorerRow>)
const savingRow = reactive<Record<number, boolean>>({})
const savedRow  = reactive<Record<number, boolean>>({})

function getEdit(id: number): ScorerRow {
  if (!edits[id]) edits[id] = { goals: 0, assists: 0, matches: 0 }
  return edits[id]
}

function startEdit(s: AdminScorer) {
  edits[s.id] = { goals: s.goals, assists: s.assists, matches: s.matches }
}

watch(scorers, (ss) => {
  ss?.forEach(s => startEdit(s))
}, { immediate: true })

async function saveRow(id: number) {
  savingRow[id] = true
  delete savedRow[id]
  const { error } = await (supabase
    .from('top_scorers') as any)
    .update({ ...edits[id], updated_at: new Date().toISOString() })
    .eq('id', id)
  if (!error) {
    savedRow[id] = true
    await refresh()
    setTimeout(() => delete savedRow[id], 2000)
  }
  savingRow[id] = false
}

async function deleteScorer(id: number) {
  if (!confirm('¿Eliminar este goleador?')) return
  await (supabase.from('top_scorers') as any).delete().eq('id', id)
  await refresh()
}

// ── Player image helper ────────────────────────────────────────
import { playerImageByName } from '~/utils/players'
</script>

<template>
  <div>
    <div class="mb-6">
      <h1 class="font-display font-black text-3xl uppercase tracking-wide">Goleadores</h1>
      <p class="text-gray-400 text-sm mt-0.5">Añade y actualiza los máximos goleadores del torneo</p>
    </div>

    <!-- Add scorer form -->
    <AppCard pad="md" accent="red" class="mb-8">
      <p class="section-label mb-4">Añadir goleador</p>
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div class="sm:col-span-2 lg:col-span-1">
          <label class="label">Nombre del jugador</label>
          <input
            v-model="form.player_name"
            type="text"
            placeholder="Ej: Kylian Mbappé"
            class="input-field"
          />
        </div>
        <div>
          <label class="label">País</label>
          <select v-model="form.country_id" class="input-field">
            <option :value="null" disabled>Selecciona país…</option>
            <option
              v-for="c in countries"
              :key="c.id"
              :value="c.id"
            >
              {{ c.flag }} {{ c.name }}
            </option>
          </select>
        </div>
        <div>
          <label class="label">Posición</label>
          <select v-model="form.position" class="input-field">
            <option value="GK">Portero (GK)</option>
            <option value="DF">Defensa (DF)</option>
            <option value="MF">Centrocampista (MF)</option>
            <option value="FW">Delantero (FW)</option>
          </select>
        </div>
        <div>
          <label class="label">Goles</label>
          <input v-model.number="form.goals" type="number" min="0" class="input-field" />
        </div>
        <div>
          <label class="label">Asistencias</label>
          <input v-model.number="form.assists" type="number" min="0" class="input-field" />
        </div>
        <div>
          <label class="label">Partidos jugados</label>
          <input v-model.number="form.matches" type="number" min="0" class="input-field" />
        </div>
      </div>
      <div v-if="formErr" class="alert-error mt-3">{{ formErr }}</div>
      <div class="mt-4">
        <button :disabled="saving" class="btn-primary" @click="addScorer">
          {{ saving ? 'Añadiendo…' : '+ Añadir goleador' }}
        </button>
      </div>
    </AppCard>

    <!-- Scorers table -->
    <AppCard pad="none">
      <p v-if="!scorers?.length" class="text-center py-12 text-gray-500">
        No hay goleadores aún. Añade el primero arriba.
      </p>

      <table v-else class="w-full text-sm">
        <thead>
          <tr class="border-b border-dark-500 text-gray-400 text-xs uppercase tracking-wider">
            <th class="text-left px-4 py-3 font-bold">Jugador</th>
            <th class="text-center px-3 py-3 font-bold">Pos</th>
            <th class="text-center px-3 py-3 font-bold">PJ</th>
            <th class="text-center px-3 py-3 font-bold">Asist.</th>
            <th class="text-center px-3 py-3 font-bold text-wc-gold">Goles</th>
            <th class="text-right px-4 py-3 font-bold">Acción</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="s in scorers"
            :key="s.id"
            class="border-b border-dark-500/40 hover:bg-dark-700/30 transition-colors"
          >
            <!-- Player -->
            <td class="px-4 py-3">
              <div class="flex items-center gap-3">
                <img
                  v-if="playerImageByName(s.player_name)"
                  :src="playerImageByName(s.player_name)"
                  :alt="s.player_name"
                  class="w-8 h-8 rounded-full object-cover object-top border border-dark-400 bg-dark-700 shrink-0"
                />
                <CountryFlag v-else :code="s.country?.code" :name="s.country?.name" :size="20" />
                <div>
                  <p class="font-semibold text-white">{{ s.player_name }}</p>
                  <p class="text-xs text-gray-500 flex items-center gap-1">
                    <CountryFlag :code="s.country?.code" :name="s.country?.name" :size="12" />
                    {{ s.country?.name }}
                  </p>
                </div>
              </div>
            </td>

            <!-- Position -->
            <td class="px-3 py-3 text-center text-gray-400 font-display font-bold">{{ s.position ?? '—' }}</td>

            <!-- Matches (editable) -->
            <td class="px-3 py-3 text-center">
              <input
                v-model.number="getEdit(s.id).matches"
                type="number" min="0" max="20"
                class="admin-num-input"
              >
            </td>

            <!-- Assists (editable) -->
            <td class="px-3 py-3 text-center">
              <input
                v-model.number="getEdit(s.id).assists"
                type="number" min="0" max="99"
                class="admin-num-input"
              >
            </td>

            <!-- Goals (editable) -->
            <td class="px-3 py-3 text-center">
              <input
                v-model.number="getEdit(s.id).goals"
                type="number" min="0" max="99"
                class="admin-num-input text-wc-gold font-display font-black text-lg"
              >
            </td>

            <!-- Actions -->
            <td class="px-4 py-3 text-right">
              <div class="flex items-center justify-end gap-2">
                <span v-if="savedRow[s.id]" class="text-xs text-wc-green font-bold">✓</span>
                <button
                  :disabled="savingRow[s.id]"
                  class="btn-primary btn-sm"
                  @click="saveRow(s.id)"
                >
                  {{ savingRow[s.id] ? '…' : 'Guardar' }}
                </button>
                <button
                  class="btn-danger btn-sm"
                  @click="deleteScorer(s.id)"
                >
                  ✕
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </AppCard>
  </div>
</template>

<style scoped>
.admin-num-input {
  width: 3.5rem;
  height: 2.2rem;
  text-align: center;
  font-family: 'Barlow Condensed', sans-serif;
  font-weight: 700;
  font-size: 1rem;
  background: #141C35;
  border: 1px solid #2A3D6E;
  border-radius: 4px;
  color: white;
  outline: none;
  transition: border-color 0.15s;
}
.admin-num-input:focus { border-color: #E61D25; }
.admin-num-input::-webkit-outer-spin-button,
.admin-num-input::-webkit-inner-spin-button { -webkit-appearance: none; }
.admin-num-input[type=number] { -moz-appearance: textfield; }
</style>
