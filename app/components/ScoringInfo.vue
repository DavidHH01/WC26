<script setup lang="ts">
const open = ref(false)

const examples = [
  {
    real: '2 – 1', pred: '2 – 1',
    home: 'España', away: 'Alemania',
    pts: 3, label: 'Exacto', color: 'text-wc-green', bg: 'bg-wc-green/10 border-wc-green/25',
  },
  {
    real: '2 – 1', pred: '3 – 0',
    home: 'España', away: 'Alemania',
    pts: 1, label: 'Ganador', color: 'text-blue-400', bg: 'bg-blue-500/10 border-blue-500/20',
  },
  {
    real: '2 – 1', pred: '0 – 1',
    home: 'España', away: 'Alemania',
    pts: 0, label: 'Fallo', color: 'text-gray-400', bg: 'bg-dark-700 border-dark-500',
  },
  {
    real: '1 – 0', pred: '1 – 0',
    home: 'Cabo Verde', away: 'España',
    pts: 7, label: '¡Sorpresa! Exacto', color: 'text-wc-gold', bg: 'bg-wc-gold/10 border-wc-gold/25',
    note: '+3 exacto · +4 bonus sorpresa',
  },
  {
    real: '1 – 0', pred: '2 – 0',
    home: 'Cabo Verde', away: 'España',
    pts: 5, label: '¡Sorpresa! Ganador', color: 'text-wc-gold', bg: 'bg-wc-gold/10 border-wc-gold/25',
    note: '+1 ganador · +4 bonus sorpresa',
  },
]
</script>

<template>
  <AppCard pad="none" class="mb-8 overflow-hidden">
    <!-- Cabecera / toggle -->
    <button
      class="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-dark-700/40 transition-colors"
      :aria-expanded="open"
      @click="open = !open"
    >
      <span class="flex items-center gap-3">
        <span class="flex items-center justify-center w-7 h-7 rounded-sm bg-wc-red/15 text-wc-red font-display font-black text-base shrink-0">
          ?
        </span>
        <span class="font-display font-bold uppercase tracking-wide text-base sm:text-lg">
          ¿Cómo se puntúa?
        </span>
      </span>
      <svg
        class="w-5 h-5 text-gray-300 transition-transform duration-200 shrink-0"
        :class="open ? 'rotate-180' : ''"
        fill="none" stroke="currentColor" viewBox="0 0 24 24"
      >
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </button>

    <Transition
      enter-active-class="transition-all duration-200 ease-out"
      enter-from-class="opacity-0 max-h-0"
      enter-to-class="opacity-100 max-h-[2000px]"
      leave-active-class="transition-all duration-150 ease-in"
      leave-from-class="opacity-100 max-h-[2000px]"
      leave-to-class="opacity-0 max-h-0"
    >
      <div v-if="open" class="border-t border-dark-500/60 overflow-hidden">

        <!-- Puntos base: 3 bloques -->
        <div class="grid grid-cols-3 divide-x divide-dark-500/60">
          <div class="px-4 py-5 text-center">
            <p class="font-display font-black text-4xl text-wc-green leading-none">+3</p>
            <p class="font-display font-bold uppercase text-sm tracking-wide text-white mt-2">Exacto</p>
            <p class="text-sm text-gray-400 mt-1 leading-snug">Aciertas el marcador clavado</p>
          </div>
          <div class="px-4 py-5 text-center">
            <p class="font-display font-black text-4xl text-blue-400 leading-none">+1</p>
            <p class="font-display font-bold uppercase text-sm tracking-wide text-white mt-2">Ganador</p>
            <p class="text-sm text-gray-400 mt-1 leading-snug">Aciertas quién gana o el empate</p>
          </div>
          <div class="px-4 py-5 text-center">
            <p class="font-display font-black text-4xl text-gray-500 leading-none">0</p>
            <p class="font-display font-bold uppercase text-sm tracking-wide text-white mt-2">Fallo</p>
            <p class="text-sm text-gray-400 mt-1 leading-snug">No aciertas ni el ganador</p>
          </div>
        </div>

        <!-- Bonus -->
        <div class="px-5 pb-5 border-t border-dark-500/60">
          <p class="section-label mt-5 mb-4">Bonificaciones</p>
          <div class="space-y-3">
            <div class="flex items-start gap-4 rounded bg-dark-700/60 border border-dark-500/50 p-4">
              <span class="pts-badge bg-wc-gold/15 text-wc-gold border-wc-gold/30 mt-0.5">+1–5</span>
              <div>
                <p class="text-base font-semibold text-white">Bonus sorpresa</p>
                <p class="text-sm text-gray-300 mt-1 leading-relaxed">
                  Si el equipo peor rankeado FIFA gana y tú lo predijiste, sumas puntos extra
                  según la diferencia de ranking. Cuanto mayor la sorpresa, más bonus (hasta +5).
                </p>
              </div>
            </div>
            <div class="flex items-start gap-4 rounded bg-dark-700/60 border border-dark-500/50 p-4">
              <span class="pts-badge bg-wc-gold/15 text-wc-gold border-wc-gold/30 mt-0.5">+1</span>
              <div>
                <p class="text-base font-semibold text-white">Partido difícil</p>
                <p class="text-sm text-gray-300 mt-1">
                  Si ambos equipos tienen ranking FIFA bajo, el partido es más impredecible: +1 extra si aciertas el resultado.
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Ejemplos -->
        <div class="px-5 pb-5 border-t border-dark-500/60">
          <p class="section-label mt-5 mb-4">Ejemplos</p>

          <div class="space-y-2">
            <div
              v-for="ex in examples"
              :key="ex.pred + ex.real + ex.home"
              :class="['flex items-center gap-3 rounded border px-4 py-3', ex.bg]"
            >
              <!-- Equipos + resultado real -->
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2 text-sm sm:text-base font-semibold flex-wrap">
                  <span class="text-gray-200">{{ ex.home }}</span>
                  <span class="font-display font-black text-white bg-dark-600 px-2 py-0.5 rounded text-sm">{{ ex.real }}</span>
                  <span class="text-gray-200">{{ ex.away }}</span>
                </div>
                <div class="flex items-center gap-2 mt-1">
                  <span class="text-sm text-gray-400">Tu predicción:</span>
                  <span class="font-display font-bold text-white text-sm">{{ ex.pred }}</span>
                  <span v-if="ex.note" class="text-sm text-gray-400 hidden sm:inline">· {{ ex.note }}</span>
                </div>
              </div>
              <!-- Puntos -->
              <div class="shrink-0 text-right">
                <span :class="['font-display font-black text-2xl leading-none', ex.color]">
                  {{ ex.pts > 0 ? `+${ex.pts}` : '0' }}
                </span>
                <p :class="['text-sm mt-0.5 font-medium', ex.color]">{{ ex.label }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Máximo posible -->
        <div class="mx-5 mb-5 flex items-center gap-4 rounded bg-wc-red/10 border border-wc-red/25 px-4 py-3.5">
          <span class="font-display font-black text-3xl text-wc-red leading-none">9</span>
          <p class="text-sm text-gray-300">
            <strong class="text-white">Máximo por partido:</strong>
            exacto (+3) · sorpresa máxima (+5) · partido difícil (+1)
          </p>
        </div>

        <p class="px-5 pb-5 text-sm text-gray-400">
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
  font-size: 0.9rem;
  padding: 0.2rem 0.55rem;
  min-width: 2.5rem;
  border-radius: 4px;
  border-width: 1px;
  border-style: solid;
  flex-shrink: 0;
}
</style>
