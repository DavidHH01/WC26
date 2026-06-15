<script setup lang="ts">
const open = ref(false)

// Umbrales del factor de participación
const tiers = [
  { min: 90, factor: '×1.3', label: '90+ predicciones', color: 'text-yellow-400', bg: 'bg-yellow-400/10 border-yellow-400/30' },
  { min: 60, factor: '×1.2', label: '60+ predicciones', color: 'text-wc-green',   bg: 'bg-wc-green/10 border-wc-green/30' },
  { min: 30, factor: '×1.1', label: '30+ predicciones', color: 'text-blue-400',   bg: 'bg-blue-400/10 border-blue-400/30' },
  { min: 10, factor: '×1.0', label: '10+ predicciones', color: 'text-gray-300',   bg: 'bg-dark-600 border-dark-500' },
]
</script>

<template>
  <div class="mb-6">
    <button
      class="w-full flex items-center justify-between px-4 py-3 bg-dark-700 border border-dark-500 rounded-lg hover:border-dark-400 transition-colors"
      @click="open = !open"
    >
      <div class="flex items-center gap-2">
        <svg class="w-4 h-4 text-wc-gold" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
        <span class="text-sm font-semibold text-white">¿Cómo funciona el ranking?</span>
      </div>
      <svg
        :class="['w-4 h-4 text-gray-400 transition-transform duration-200', open ? 'rotate-180' : '']"
        fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"
      >
        <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/>
      </svg>
    </button>

    <Transition
      enter-active-class="transition-all duration-300 ease-out"
      enter-from-class="opacity-0 -translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition-all duration-200 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 -translate-y-2"
    >
      <div v-if="open" class="mt-2 bg-dark-700/60 border border-dark-500 rounded-lg p-5 space-y-5">

        <!-- Fórmula principal -->
        <div>
          <p class="section-label mb-3">Fórmula de puntuación</p>
          <div class="bg-dark-800 rounded-lg px-4 py-3 text-center font-display font-bold text-lg tracking-wide">
            <span class="text-white">Puntuación</span>
            <span class="text-gray-500 mx-2">=</span>
            <span class="text-wc-gold">(Puntos totales ÷ Predicciones hechas)</span>
            <span class="text-gray-500 mx-2">×</span>
            <span class="text-wc-green">Factor de participación</span>
          </div>
          <p class="text-sm text-gray-400 mt-2 text-center">
            Se premia tanto la <strong class="text-white">precisión</strong> como la
            <strong class="text-white">constancia</strong>.
          </p>
        </div>

        <!-- Factor de participación -->
        <div>
          <p class="section-label mb-3">Factor de participación</p>
          <div class="grid grid-cols-2 sm:grid-cols-4 gap-2">
            <div
              v-for="t in tiers"
              :key="t.min"
              :class="['border rounded-lg px-3 py-2 text-center', t.bg]"
            >
              <p :class="['font-display font-black text-xl', t.color]">{{ t.factor }}</p>
              <p class="text-xs text-gray-400 mt-0.5">{{ t.label }}</p>
            </div>
          </div>
          <p class="text-xs text-gray-500 mt-2">
            Con menos de 10 predicciones no apareces en el ranking.
          </p>
        </div>

        <!-- Ejemplos -->
        <div>
          <p class="section-label mb-3">Ejemplo real</p>
          <div class="space-y-2 text-sm">
            <div class="flex items-center gap-3 bg-dark-800 rounded px-3 py-2">
              <span class="text-gray-400 w-32 shrink-0">Desde el día 1</span>
              <span class="text-gray-300">80 pts en 70 predicciones → <strong class="text-white">1.14 PPP</strong> × 1.2 = </span>
              <span class="font-display font-black text-wc-gold ml-auto">1.37</span>
            </div>
            <div class="flex items-center gap-3 bg-dark-800 rounded px-3 py-2">
              <span class="text-gray-400 w-32 shrink-0">Entró tarde</span>
              <span class="text-gray-300">42 pts en 30 predicciones → <strong class="text-white">1.40 PPP</strong> × 1.1 = </span>
              <span class="font-display font-black text-wc-gold ml-auto">1.54 🥇</span>
            </div>
            <div class="flex items-center gap-3 bg-dark-800 rounded px-3 py-2">
              <span class="text-gray-400 w-32 shrink-0">Muy constante</span>
              <span class="text-gray-300">115 pts en 95 predicciones → <strong class="text-white">1.21 PPP</strong> × 1.3 = </span>
              <span class="font-display font-black text-wc-gold ml-auto">1.57 🥇</span>
            </div>
          </div>
          <p class="text-xs text-gray-500 mt-2">
            Un jugador tardío pero muy acertado puede ganar. Un jugador constante
            compensa con el factor alto.
          </p>
        </div>

      </div>
    </Transition>
  </div>
</template>
