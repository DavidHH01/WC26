<script setup lang="ts">
const supabase = useSupabaseClient()
const user = useSupabaseUser()

// ── Types ─────────────────────────────────────────────────────
interface ProfileData {
  id: string
  username: string
  total_points: number
  total_predicted: number
  exact_scores: number
  correct_results: number
  avatar_url: string | null
}
interface HistoryCountry {
  name: string; code: string; flag: string
}
interface HistoryMatch {
  id: number
  match_date: string
  status: string
  home_score: number | null
  away_score: number | null
  home_country: HistoryCountry | null
  away_country: HistoryCountry | null
  group: { name: string } | null
}
interface HistoryPred {
  id: number
  home_score: number | null
  away_score: number | null
  points_earned: number | null
  created_at: string
  match: HistoryMatch | null
}

// ── Fetch profile ─────────────────────────────────────────────
const { data: profile, refresh: refreshProfile } = await useAsyncData('my-profile', async () => {
  if (!user.value) return null
  const { data } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.value.id)
    .single()
  return data as ProfileData | null
})

// ── Fetch prediction history ──────────────────────────────────
const { data: history } = await useAsyncData('pred-history', async () => {
  if (!user.value) return [] as HistoryPred[]
  const { data } = await supabase
    .from('predictions')
    .select(`
      id, home_score, away_score, points_earned, created_at,
      match:matches(
        id, match_date, status, home_score, away_score,
        home_country:countries!home_country_id(name, code, flag),
        away_country:countries!away_country_id(name, code, flag),
        group:groups(name)
      )
    `)
    .order('created_at', { ascending: false })
  return (data ?? []) as HistoryPred[]
})

// ── Logout ────────────────────────────────────────────────────
async function logout() {
  await supabase.auth.signOut()
  navigateTo('/')
}

// ── Helpers ───────────────────────────────────────────────────
function fmtDate(s: string) {
  return new Intl.DateTimeFormat('es-ES', {
    day: 'numeric', month: 'short',
    timeZone: 'Europe/Madrid',
  }).format(new Date(s))
}

function resultLabel(pts: number | null) {
  const p = pts ?? 0
  if (p >= 3) return p > 3 ? 'Exacto +bonus' : 'Exacto'
  if (p >= 1) return p > 1 ? 'Acertado +bonus' : 'Acertado'
  return 'Fallado'
}
function resultClass(pts: number | null) {
  const p = pts ?? 0
  if (p >= 3) return 'text-wc-green'
  if (p >= 1) return 'text-blue-400'
  return 'text-gray-500'
}
function resultBg(pts: number | null) {
  const p = pts ?? 0
  if (p >= 3) return 'bg-wc-green/10 border-wc-green/20'
  if (p >= 1) return 'bg-blue-500/10 border-blue-500/20'
  return 'bg-dark-700 border-dark-500'
}

// Accuracy percentage
const accuracy = computed(() => {
  const p = profile.value
  if (!p || !p.total_predicted) return 0
  return Math.round((p.correct_results / p.total_predicted) * 100)
})
</script>

<template>
  <div class="container mx-auto px-4 max-w-4xl py-8">

    <!-- Header -->
    <div class="flex items-start justify-between mb-10">
      <div>
        <h1 class="font-display font-black text-4xl sm:text-5xl uppercase tracking-wide mb-1">
          Mi perfil
        </h1>
        <p class="text-gray-400 text-sm">{{ user?.email }}</p>
      </div>
      <AppButton variant="danger" @click="logout">Salir</AppButton>
    </div>

    <!-- Stats grid -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-8">

      <AppCard pad="md" accent="gold">
        <p class="label">Puntos</p>
        <p class="stat-number">{{ profile?.total_points ?? 0 }}</p>
      </AppCard>

      <AppCard pad="md" accent="green">
        <p class="label">Exactos</p>
        <p class="font-display font-black text-3xl text-wc-green leading-none">
          {{ profile?.exact_scores ?? 0 }}
        </p>
      </AppCard>

      <AppCard pad="md" accent="navy">
        <p class="label">Acertados</p>
        <p class="font-display font-black text-3xl text-blue-400 leading-none">
          {{ profile?.correct_results ?? 0 }}
        </p>
      </AppCard>

      <AppCard pad="md">
        <p class="label">Precisión</p>
        <p class="font-display font-black text-3xl text-white leading-none">
          {{ accuracy }}<span class="text-lg">%</span>
        </p>
      </AppCard>
    </div>

    <!-- User info -->
    <AppCard pad="md" class="mb-8">
      <div class="flex items-center justify-between">
        <div>
          <p class="label">Nombre de usuario</p>
          <p class="font-display font-black text-3xl uppercase tracking-wide mt-0.5">
            {{ profile?.username ?? user?.user_metadata?.username ?? '—' }}
          </p>
        </div>
        <div class="text-right">
          <p class="label">Predicciones</p>
          <p class="font-semibold text-xl">{{ profile?.total_predicted ?? 0 }} / 72</p>
        </div>
      </div>
    </AppCard>

    <!-- Prediction history -->
    <div>
      <p class="section-label mb-5">Historial de predicciones</p>

      <div v-if="!history?.length" class="text-center py-12 text-gray-400">
        <p class="text-3xl mb-3">📋</p>
        <p class="font-display font-bold text-lg uppercase tracking-wide">Sin predicciones aún</p>
        <AppButton to="/predictions" class="mt-4">Ir a predecir</AppButton>
      </div>

      <div v-else class="space-y-2">
        <div
          v-for="p in history"
          :key="p.id"
          :class="['card px-4 py-3 flex items-center gap-4', resultBg(p.points_earned)]"
        >
          <!-- Group + date -->
          <div class="hidden sm:block text-center w-16 shrink-0">
            <p class="font-display font-black text-xs uppercase text-gray-400">
              Gr. {{ p.match?.group?.name }}
            </p>
            <p class="text-xs text-gray-400">{{ fmtDate(p.match?.match_date ?? '') }}</p>
          </div>

          <!-- Match -->
          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-1.5 text-base font-medium">
              <CountryFlag :code="p.match?.home_country?.code" :name="p.match?.home_country?.name" :size="16" />
              <span class="truncate text-sm sm:text-base">{{ p.match?.home_country?.name }}</span>
              <span class="text-gray-400 px-1">
                {{ p.match?.status === 'finished'
                    ? `${p.match.home_score}–${p.match.away_score}`
                    : '—' }}
              </span>
              <span class="truncate text-xs sm:text-sm">{{ p.match?.away_country?.name }}</span>
              <CountryFlag :code="p.match?.away_country?.code" :name="p.match?.away_country?.name" :size="16" />
            </div>
            <p class="text-sm text-gray-400 mt-0.5">
              Tu predicción: {{ p.home_score }}–{{ p.away_score }}
            </p>
          </div>

          <!-- Points -->
          <div class="shrink-0 text-right">
            <template v-if="p.match?.status === 'finished'">
              <p :class="['font-display font-black text-xl', resultClass(p.points_earned)]">
                +{{ p.points_earned }}
              </p>
              <p :class="['text-xs', resultClass(p.points_earned)]">
                {{ resultLabel(p.points_earned) }}
              </p>
            </template>
            <span v-else class="text-xs text-gray-400">Pendiente</span>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>
