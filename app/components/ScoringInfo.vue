<script setup lang="ts">
const open = ref(false)
</script>

<template>
  <AppCard pad="none" class="mb-8 overflow-hidden">
    <!-- Cabecera / toggle -->
    <button
      class="w-full flex items-center justify-between px-4 py-3.5 text-left hover:bg-dark-700/40 transition-colors"
      :aria-expanded="open"
      @click="open = !open"
    >
      <span class="flex items-center gap-2.5">
        <span class="flex items-center justify-center w-6 h-6 rounded-sm bg-wc-red/15 text-wc-red font-display font-black text-sm shrink-0">
          ?
        </span>
        <span class="font-display font-bold uppercase tracking-wide text-sm sm:text-base">
          ¿Cómo se puntúa?
        </span>
      </span>
      <svg
        class="w-4 h-4 text-gray-400 transition-transform duration-200 shrink-0"
        :class="open ? 'rotate-180' : ''"
        fill="none" stroke="currentColor" viewBox="0 0 24 24"
      >
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </button>

    <!-- Contenido -->
    <Transition
      enter-active-class="transition-all duration-200 ease-out"
      enter-from-class="opacity-0 max-h-0"
      enter-to-class="opacity-100 max-h-[1200px]"
      leave-active-class="transition-all duration-150 ease-in"
      leave-from-class="opacity-100 max-h-[1200px]"
      leave-to-class="opacity-0 max-h-0"
    >
      <div v-if="open" class="px-4 pb-5 border-t border-dark-500/60 overflow-hidden">

        <!-- Puntos base -->
        <p class="section-label mt-5 mb-3">Puntos base</p>
        <div class="space-y-2">
          <div class="flex items-center gap-3">
            <span class="pts-badge bg-wc-green/15 text-wc-green border-wc-green/30">+3</span>
            <p class="text-sm text-gray-300">
              <strong class="text-white">Resultado exacto.</strong>
              Aciertas el marcador clavado.
              <span class="text-gray-500">Ej: predices 2–1 y queda 2–1.</span>
            </p>
          </div>
          <div class="flex items-center gap-3">
            <span class="pts-badge bg-blue-500/15 text-blue-400 border-blue-500/30">+1</span>
            <p class="text-sm text-gray-300">
              <strong class="text-white">Resultado acertado.</strong>
              Aciertas quién gana (o el empate), pero no el marcador.
              <span class="text-gray-500">Ej: predices 2–0 y queda 3–1.</span>
            </p>
          </div>
          <div class="flex items-center gap-3">
            <span class="pts-badge bg-dark-600 text-gray-500 border-dark-500">0</span>
            <p class="text-sm text-gray-300">
              <strong class="text-white">Fallo.</strong>
              No aciertas ni el ganador.
              <span class="text-gray-500">Ej: predices que gana el local y gana el visitante.</span>
            </p>
          </div>
        </div>

        <!-- Bonus -->
        <p class="section-label mt-6 mb-3">Bonificaciones</p>
        <div class="space-y-3">

          <!-- Sorpresa -->
          <div class="rounded bg-dark-700/60 border border-dark-500/60 p-3.5">
            <div class="flex items-center gap-2 mb-1.5">
              <span class="pts-badge bg-wc-gold/15 text-wc-gold border-wc-gold/30">+1 a +5</span>
              <span class="font-display font-bold uppercase text-sm tracking-wide text-wc-gold">Bonus sorpresa</span>
            </div>
            <p class="text-sm text-gray-300 leading-relaxed">
              Si aciertas una <strong class="text-white">sorpresa</strong> —que gane el equipo peor clasificado
              en el ranking FIFA— sumas puntos extra según la diferencia de ranking
              (cuanto mayor la sorpresa, más bonus, hasta +5).
            </p>
            <div class="mt-2.5 flex items-start gap-2 text-xs text-gray-400 bg-dark-800/70 rounded px-3 py-2">
              <span class="text-wc-gold font-bold shrink-0">Ej</span>
              <span>
                <strong class="text-gray-200">Cabo Verde</strong> (peor rankeada) gana a <strong class="text-gray-200">España</strong>
                y lo predijiste. La diferencia de ranking da <strong class="text-wc-gold">+4</strong>:
                acertar el ganador (+1) → <strong class="text-white">5 pts</strong>; clavar el marcador (+3) → <strong class="text-white">7 pts</strong>.
              </span>
            </div>
          </div>

          <!-- Partido débil -->
          <div class="rounded bg-dark-700/60 border border-dark-500/60 p-3.5">
            <div class="flex items-center gap-2 mb-1.5">
              <span class="pts-badge bg-wc-gold/15 text-wc-gold border-wc-gold/30">+1</span>
              <span class="font-display font-bold uppercase text-sm tracking-wide text-wc-gold">Partido difícil de leer</span>
            </div>
            <p class="text-sm text-gray-300 leading-relaxed">
              Si ambos equipos están bajos en el ranking FIFA, es un partido más impredecible:
              <strong class="text-white">+1 punto extra</strong> por acertar el resultado.
            </p>
            <div class="mt-2.5 flex items-start gap-2 text-xs text-gray-400 bg-dark-800/70 rounded px-3 py-2">
              <span class="text-wc-gold font-bold shrink-0">Ej</span>
              <span>
                <strong class="text-gray-200">Jordania</strong> vs <strong class="text-gray-200">Irak</strong>: aciertas el resultado →
                <strong class="text-white">+1</strong> sobre lo que ya sumes.
              </span>
            </div>
          </div>
        </div>

        <!-- Máximo -->
        <div class="mt-5 flex items-center gap-3 rounded bg-wc-red/10 border border-wc-red/25 px-4 py-3">
          <span class="font-display font-black text-2xl text-wc-red leading-none">9</span>
          <p class="text-sm text-gray-300">
            <strong class="text-white">Máximo por partido:</strong>
            marcador exacto (3) + sorpresa máxima (5) + partido difícil (1) = <strong class="text-white">9 puntos</strong>.
          </p>
        </div>

        <p class="text-xs text-gray-500 mt-4">
          Las predicciones se bloquean al empezar cada partido. Los puntos se calculan automáticamente al finalizar.
        </p>
      </div>
    </Transition>
  </AppCard>
</template>

<style scoped>
.pts-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-family: 'Barlow Condensed', sans-serif;
  font-weight: 800;
  font-size: 0.85rem;
  letter-spacing: 0.02em;
  padding: 0.15rem 0.5rem;
  min-width: 2.25rem;
  border-radius: 4px;
  border-width: 1px;
  border-style: solid;
  flex-shrink: 0;
}
</style>
