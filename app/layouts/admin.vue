<script setup lang="ts">
const supabase = useSupabaseClient()
const route = useRoute()

async function logout() {
  await supabase.auth.signOut()
  navigateTo('/auth/login')
}

const tabs = [
  { label: 'Partidos', path: '/admin' },
  { label: 'Goleadores', path: '/admin/scorers' },
]
</script>

<template>
  <div class="min-h-screen bg-dark-900 text-white font-sans">

    <!-- Admin header -->
    <header class="sticky top-0 z-50 bg-dark-800 border-b-2 border-wc-red">
      <div class="container mx-auto px-4 max-w-6xl h-14 flex items-center justify-between">
        <div class="flex items-center gap-4">
          <NuxtLink to="/" class="font-display font-black text-xl uppercase tracking-widest">
            <span class="text-wc-red">WC</span><span class="text-gray-500">·</span><span class="text-white">26</span>
          </NuxtLink>
          <span class="bg-wc-red text-white font-display font-black text-xs uppercase tracking-widest px-2 py-0.5 rounded-sm">
            Admin
          </span>
          <nav class="hidden sm:flex items-center gap-1 ml-2">
            <NuxtLink
              v-for="tab in tabs"
              :key="tab.path"
              :to="tab.path"
              class="font-display font-bold text-sm uppercase tracking-wide px-3 py-1.5 rounded transition-colors"
              :class="route.path === tab.path
                ? 'bg-dark-600 text-white'
                : 'text-gray-400 hover:text-white hover:bg-dark-700'"
            >
              {{ tab.label }}
            </NuxtLink>
          </nav>
        </div>
        <button
          class="text-sm text-gray-400 hover:text-wc-red transition-colors font-display font-bold uppercase tracking-wide"
          @click="logout"
        >
          Salir
        </button>
      </div>
    </header>

    <main class="container mx-auto px-4 max-w-6xl py-8">
      <slot />
    </main>
  </div>
</template>
