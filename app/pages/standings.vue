<script setup lang="ts">
const supabase = useSupabaseClient()

// ── Types ─────────────────────────────────────────────────────
interface LeaderboardRow {
  id: string
  username: string
  total_points: number
  exact_scores: number
  correct_results: number
  total_predicted: number
  rank: number
}
interface GroupStandingRow {
  id: number
  group_name: string
  position: number
  name: string
  code: string
  flag: string
  played: number
  wins: number
  draws: number
  losses: number
  goals_for: number
  goals_against: number
  goal_diff: number
  group_points: number
}
interface ScorerRow {
  id: number
  player_name: string
  position: string | null
  goals: number
  assists: number
  matches: number
  country: { name: string; code: string; flag: string } | null
}

// ── Fetch leaderboard ─────────────────────────────────────────
const { data: leaderboard, pending: loadingBoard } = await useAsyncData('leaderboard', async () => {
  const { data } = await supabase
    .from('leaderboard')
    .select('id, username, total_points, exact_scores, correct_results, total_predicted, rank')
    .limit(100)
  return (data ?? []) as LeaderboardRow[]
})

// ── Fetch group standings ─────────────────────────────────────
const { data: groupRows, pending: loadingGroups } = await useAsyncData('group-standings', async () => {
  const { data } = await supabase
    .from('group_standings')
    .select('*')
  return (data ?? []) as GroupStandingRow[]
})

// ── Fetch top scorers ─────────────────────────────────────────
const { data: scorers, pending: loadingScorers } = await useAsyncData('top-scorers', async () => {
  const { data } = await supabase
    .from('top_scorers')
    .select(`
      id, player_name, position, goals, assists, matches,
      country:countries(name, code, flag)
    `)
    .order('goals', { ascending: false })
    .order('assists', { ascending: false })
    .limit(50)
  return (data ?? []) as ScorerRow[]
})

// ── Groups tab ────────────────────────────────────────────────
const groupNames = ['A','B','C','D','E','F','G','H','I','J','K','L']
const selectedGroup = ref('A')

const groupStandings = computed(() =>
  (groupRows.value ?? [])
    .filter(r => r.group_name === selectedGroup.value)
    .sort((a, b) => a.position - b.position)
)

// ── Tabs ──────────────────────────────────────────────────────
const activeTab = ref<'users' | 'groups' | 'scorers'>('users')

import { playerImageByName } from '~/utils/players'

// ── Helpers ───────────────────────────────────────────────────
function rankColor(rank: number) {
  if (rank === 1) return 'text-yellow-400'
  if (rank === 2) return 'text-gray-300'
  if (rank === 3) return 'text-amber-600'
  return 'text-gray-500'
}
function rankBg(rank: number) {
  if (rank === 1) return 'bg-yellow-400/10 border-yellow-400/30'
  if (rank === 2) return 'bg-gray-400/10 border-gray-400/30'
  if (rank === 3) return 'bg-amber-600/10 border-amber-600/30'
  return ''
}
</script>

<template>
  <div class="container mx-auto px-4 max-w-4xl py-8">

    <!-- Header -->
    <h1 class="font-display font-black text-4xl sm:text-5xl uppercase tracking-wide mb-2">
      Clasificación
    </h1>
    <p class="text-gray-400 text-sm mb-8">Rankings y estadísticas del torneo</p>

    <!-- Tabs -->
    <div class="flex gap-2 mb-8">
      <button
        :class="activeTab === 'users' ? 'btn-primary btn-sm' : 'btn-secondary btn-sm'"
        @click="activeTab = 'users'"
      >
        Usuarios
      </button>
      <button
        :class="activeTab === 'groups' ? 'btn-primary btn-sm' : 'btn-secondary btn-sm'"
        @click="activeTab = 'groups'"
      >
        Grupos
      </button>
      <button
        :class="activeTab === 'scorers' ? 'btn-primary btn-sm' : 'btn-secondary btn-sm'"
        @click="activeTab = 'scorers'"
      >
        Goleadores
      </button>
    </div>

    <!-- ── USUARIOS ─────────────────────────────────────────── -->
    <div v-if="activeTab === 'users'">

      <!-- Loading skeleton -->
      <div v-if="loadingBoard" class="space-y-2">
        <AppCard v-for="i in 8" :key="i" pad="md" class="animate-pulse">
          <div class="h-8 bg-dark-600 rounded" />
        </AppCard>
      </div>

      <!-- Empty -->
      <AppCard v-else-if="!leaderboard?.length" pad="xl" class="text-center">
        <p class="text-3xl mb-3">🏅</p>
        <p class="font-display font-bold text-xl uppercase tracking-wide text-gray-500">
          Aún no hay predicciones
        </p>
        <p class="text-sm text-gray-400 mt-1">
          La clasificación se activará cuando los usuarios empiecen a predecir.
        </p>
      </AppCard>

      <!-- Leaderboard -->
      <div v-else class="space-y-2">

        <!-- Top 3 highlight -->
        <div v-if="leaderboard.length >= 1" class="grid grid-cols-1 sm:grid-cols-3 gap-3 mb-6">
          <template v-for="row in leaderboard.slice(0, 3)" :key="row.id">
            <AppCard
              pad="md"
              :class="['text-center', rankBg(row.rank)]"
            >
              <p :class="['font-display font-black text-5xl mb-1', rankColor(row.rank)]">
                {{ row.rank === 1 ? '🥇' : row.rank === 2 ? '🥈' : '🥉' }}
              </p>
              <p class="font-display font-black text-xl uppercase tracking-wide">{{ row.username }}</p>
              <p :class="['font-display font-black text-3xl mt-1', rankColor(row.rank)]">
                {{ row.total_points }} <span class="text-base font-bold">pts</span>
              </p>
              <p class="text-sm text-gray-400 mt-1">{{ row.exact_scores }} exactos · {{ row.correct_results }} acertados</p>
            </AppCard>
          </template>
        </div>

        <!-- Rest of the table -->
        <AppCard v-if="leaderboard.length > 3" pad="none">
          <table class="w-full text-sm">
            <thead>
              <tr class="border-b border-dark-500 text-gray-400 text-sm uppercase tracking-wider">
                <th class="text-left px-4 py-3 font-bold w-10">#</th>
                <th class="text-left px-4 py-3 font-bold">Usuario</th>
                <th class="text-right px-4 py-3 font-bold">Exactos</th>
                <th class="text-right px-4 py-3 font-bold hidden sm:table-cell">Acertados</th>
                <th class="text-right px-4 py-3 font-bold">Puntos</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="row in leaderboard.slice(3)"
                :key="row.id"
                class="border-b border-dark-500/40 hover:bg-dark-700/40 transition-colors"
              >
                <td class="px-4 py-3 font-display font-bold text-gray-400">{{ row.rank }}</td>
                <td class="px-4 py-3 font-semibold">{{ row.username }}</td>
                <td class="px-4 py-3 text-right text-gray-400">{{ row.exact_scores }}</td>
                <td class="px-4 py-3 text-right text-gray-400 hidden sm:table-cell">{{ row.correct_results }}</td>
                <td class="px-4 py-3 text-right font-display font-black text-wc-gold text-base">
                  {{ row.total_points }}
                </td>
              </tr>
            </tbody>
          </table>
        </AppCard>
      </div>
    </div>

    <!-- ── GRUPOS ────────────────────────────────────────────── -->
    <div v-if="activeTab === 'groups'">

      <!-- Group selector -->
      <div class="flex flex-wrap gap-1.5 mb-6">
        <button
          v-for="g in groupNames"
          :key="g"
          :class="selectedGroup === g ? 'btn-primary btn-sm' : 'btn-secondary btn-sm'"
          @click="selectedGroup = g"
        >
          {{ g }}
        </button>
      </div>

      <!-- Loading -->
      <AppCard v-if="loadingGroups" pad="md" class="animate-pulse">
        <div class="h-40 bg-dark-600 rounded" />
      </AppCard>

      <!-- Group table -->
      <AppCard v-else pad="none" :accent="'navy'">
        <div class="px-4 py-3 border-b border-dark-500">
          <p class="font-display font-black text-lg uppercase tracking-widest">
            Grupo {{ selectedGroup }}
          </p>
        </div>
        <table class="w-full text-sm">
          <thead>
            <tr class="border-b border-dark-500 text-gray-400 text-sm uppercase tracking-wider">
              <th class="text-left px-4 py-2.5 font-bold">Selección</th>
              <th class="text-center px-2 py-2.5 font-bold">PJ</th>
              <th class="text-center px-2 py-2.5 font-bold">G</th>
              <th class="text-center px-2 py-2.5 font-bold">E</th>
              <th class="text-center px-2 py-2.5 font-bold">P</th>
              <th class="text-center px-2 py-2.5 font-bold hidden sm:table-cell">GF</th>
              <th class="text-center px-2 py-2.5 font-bold hidden sm:table-cell">GC</th>
              <th class="text-center px-2 py-2.5 font-bold">DG</th>
              <th class="text-center px-3 py-2.5 font-bold text-white">Pts</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(row, i) in groupStandings"
              :key="row.id"
              :class="[
                'border-b border-dark-500/40 transition-colors',
                i < 2 ? 'bg-wc-navy/10' : '',
              ]"
            >
              <td class="px-4 py-3">
                <div class="flex items-center gap-2">
                  <span class="font-display font-black text-sm w-5 text-gray-500">{{ row.position }}</span>
                  <CountryFlag :code="row.code" :name="row.name" :size="20" />
                  <span class="font-semibold truncate max-w-[120px] sm:max-w-none">{{ row.name }}</span>
                  <span v-if="i < 2" class="hidden sm:inline text-xs text-wc-green font-bold border border-wc-green/30 bg-wc-green/10 px-1.5 py-0.5 rounded-sm">
                    CLASIF
                  </span>
                </div>
              </td>
              <td class="px-2 py-3 text-center text-gray-300">{{ row.played }}</td>
              <td class="px-2 py-3 text-center text-gray-300">{{ row.wins }}</td>
              <td class="px-2 py-3 text-center text-gray-300">{{ row.draws }}</td>
              <td class="px-2 py-3 text-center text-gray-300">{{ row.losses }}</td>
              <td class="px-2 py-3 text-center text-gray-400 hidden sm:table-cell">{{ row.goals_for }}</td>
              <td class="px-2 py-3 text-center text-gray-400 hidden sm:table-cell">{{ row.goals_against }}</td>
              <td class="px-2 py-3 text-center text-gray-300">
                {{ row.goal_diff > 0 ? `+${row.goal_diff}` : row.goal_diff }}
              </td>
              <td class="px-3 py-3 text-center font-display font-black text-lg text-white">
                {{ row.group_points }}
              </td>
            </tr>
          </tbody>
        </table>
        <p class="px-4 py-2 text-xs text-gray-400 border-t border-dark-500">
          Los dos primeros de cada grupo clasifican a octavos de final
        </p>
      </AppCard>
    </div>

    <!-- ── GOLEADORES ────────────────────────────────────────── -->
    <div v-if="activeTab === 'scorers'">

      <!-- Loading -->
      <AppCard v-if="loadingScorers" pad="md" class="animate-pulse">
        <div class="h-40 bg-dark-600 rounded" />
      </AppCard>

      <!-- Empty -->
      <AppCard v-else-if="!scorers?.length" pad="xl" class="text-center">
        <p class="text-3xl mb-3">⚽</p>
        <p class="font-display font-bold text-xl uppercase tracking-wide text-gray-400">
          Aún no hay goleadores
        </p>
        <p class="text-sm text-gray-500 mt-1">
          La tabla se actualizará cuando empiece el torneo.
        </p>
      </AppCard>

      <!-- Scorers table -->
      <AppCard v-else pad="none" accent="gold">
        <table class="w-full text-sm">
          <thead>
            <tr class="border-b border-dark-500 text-gray-400 text-xs uppercase tracking-wider">
              <th class="text-left px-4 py-3 font-bold w-10">#</th>
              <th class="text-left px-4 py-3 font-bold">Jugador</th>
              <th class="text-center px-2 py-3 font-bold hidden sm:table-cell">Pos</th>
              <th class="text-center px-2 py-3 font-bold hidden sm:table-cell">PJ</th>
              <th class="text-center px-2 py-3 font-bold">Asist.</th>
              <th class="text-center px-3 py-3 font-bold text-wc-gold">Goles</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(s, i) in scorers"
              :key="s.id"
              class="border-b border-dark-500/40 hover:bg-dark-700/40 transition-colors"
            >
              <td class="px-4 py-3 font-display font-bold text-gray-400">{{ i + 1 }}</td>
              <td class="px-4 py-3">
                <div class="flex items-center gap-3">
                  <img
                    v-if="playerImageByName(s.player_name)"
                    :src="playerImageByName(s.player_name)"
                    :alt="s.player_name"
                    class="w-9 h-9 rounded-full object-cover object-top border border-dark-400 bg-dark-700 shrink-0"
                  />
                  <CountryFlag v-else :code="s.country?.code" :name="s.country?.name" :size="22" />
                  <div class="min-w-0">
                    <p class="font-semibold truncate">{{ s.player_name }}</p>
                    <p class="text-xs text-gray-500 truncate flex items-center gap-1.5">
                      <CountryFlag :code="s.country?.code" :name="s.country?.name" :size="12" />
                      {{ s.country?.name }}
                    </p>
                  </div>
                </div>
              </td>
              <td class="px-2 py-3 text-center text-gray-400 hidden sm:table-cell">{{ s.position ?? '—' }}</td>
              <td class="px-2 py-3 text-center text-gray-400 hidden sm:table-cell">{{ s.matches }}</td>
              <td class="px-2 py-3 text-center text-gray-300">{{ s.assists }}</td>
              <td class="px-3 py-3 text-center font-display font-black text-xl text-wc-gold">
                {{ s.goals }}
              </td>
            </tr>
          </tbody>
        </table>
      </AppCard>
    </div>

  </div>
</template>
