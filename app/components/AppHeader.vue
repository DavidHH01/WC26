<script setup lang="ts">
const user = useSupabaseUser()
const supabase = useSupabaseClient()
const menuOpen = ref(false)

async function logout() {
  await supabase.auth.signOut()
  navigateTo('/')
}
</script>

<template>
  <header class="sticky top-0 z-50 bg-dark-900/75 backdrop-blur-md border-b border-dark-500/50">
    <div class="container mx-auto px-4 max-w-5xl h-16 flex items-center justify-between">

      <!-- Logo -->
      <NuxtLink to="/" class="group flex items-center">
        <span class="font-display font-black text-[1.6rem] uppercase tracking-widest leading-none select-none">
          <span class="text-wc-red">WC</span><span class="text-dark-400 group-hover:text-dark-300 transition-colors">·</span><span class="text-white">26</span>
        </span>
      </NuxtLink>

      <!-- Desktop nav -->
      <nav class="hidden sm:flex items-center gap-1">
        <template v-if="user">
          <NuxtLink
            to="/predictions"
            class="font-display font-bold text-base uppercase tracking-wide text-gray-400 hover:text-white px-3 py-2 rounded hover:bg-dark-700 transition-colors"
            active-class="!text-white bg-dark-700"
          >
            Predicciones
          </NuxtLink>
          <NuxtLink
            to="/standings"
            class="font-display font-bold text-base uppercase tracking-wide text-gray-400 hover:text-white px-3 py-2 rounded hover:bg-dark-700 transition-colors"
            active-class="!text-white bg-dark-700"
          >
            Clasificación
          </NuxtLink>
          <NuxtLink
            to="/profile"
            class="font-display font-bold text-base uppercase tracking-wide text-gray-400 hover:text-white px-3 py-2 rounded hover:bg-dark-700 transition-colors ml-1"
            active-class="!text-white bg-dark-700"
          >
            Mi perfil
          </NuxtLink>
          <button
            class="font-display font-bold text-base uppercase tracking-wide text-gray-500 hover:text-wc-red px-3 py-2 transition-colors ml-1"
            @click="logout"
          >
            Salir
          </button>
        </template>
        <template v-else>
          <NuxtLink
            to="/auth/login"
            class="font-display font-bold text-base uppercase tracking-wide text-gray-400 hover:text-white px-3 py-2 rounded hover:bg-dark-700 transition-colors"
            active-class="!text-white bg-dark-700"
          >
            Entrar
          </NuxtLink>
          <AppButton to="/auth/register" size="sm">Registrarse</AppButton>
        </template>
      </nav>

      <!-- Mobile menu toggle -->
      <button
        class="sm:hidden p-2 text-gray-400 hover:text-white transition-colors"
        :aria-label="menuOpen ? 'Cerrar menú' : 'Abrir menú'"
        @click="menuOpen = !menuOpen"
      >
        <svg v-if="!menuOpen" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
        <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>

    <!-- Mobile dropdown -->
    <Transition
      enter-active-class="transition-all duration-200 ease-out"
      enter-from-class="opacity-0 -translate-y-1"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition-all duration-150 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 -translate-y-1"
    >
      <div
        v-if="menuOpen"
        class="sm:hidden border-t border-dark-500/50 bg-dark-900/95 backdrop-blur-md px-4 py-3 space-y-1"
      >
        <template v-if="user">
          <NuxtLink to="/predictions" class="block px-3 py-2.5 text-sm text-gray-300 hover:text-white hover:bg-dark-700 transition-colors" @click="menuOpen = false">Predicciones</NuxtLink>
          <NuxtLink to="/standings" class="block px-3 py-2.5 text-sm text-gray-300 hover:text-white hover:bg-dark-700 transition-colors" @click="menuOpen = false">Clasificación</NuxtLink>
          <NuxtLink to="/profile" class="block px-3 py-2.5 text-sm text-gray-300 hover:text-white hover:bg-dark-700 transition-colors" @click="menuOpen = false">Mi perfil</NuxtLink>
          <button class="block w-full text-left px-3 py-2.5 text-sm text-wc-red hover:bg-dark-700 transition-colors" @click="logout">Salir</button>
        </template>
        <template v-else>
          <NuxtLink to="/auth/login" class="block px-3 py-2.5 text-sm text-gray-300 hover:text-white hover:bg-dark-700 transition-colors" @click="menuOpen = false">Entrar</NuxtLink>
          <div class="pt-1">
            <AppButton to="/auth/register" full @click="menuOpen = false">Registrarse</AppButton>
          </div>
        </template>
      </div>
    </Transition>
  </header>
</template>
