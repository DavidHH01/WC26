<script setup lang="ts">
const user = useSupabaseUser()
</script>

<template>
  <div>

    <!-- ─── HERO: official banner fades into the dark UI ─── -->
    <section class="relative min-h-[88vh] flex items-end overflow-hidden">

      <!-- Banner background -->
      <div class="absolute inset-0" aria-hidden="true">
        <img
          src="~/assets/images/wc_banner.jpg"
          alt=""
          class="w-full h-full object-cover object-center scale-[1.02]"
          fetchpriority="high"
        />
        <!-- Gradients: dramatic fade to dark at bottom + vignette on sides -->
        <div class="absolute inset-0 bg-gradient-to-b from-black/10 via-dark-900/50 to-dark-900" />
        <div class="absolute inset-0 bg-gradient-to-r from-dark-900/30 via-transparent to-dark-900/30" />
        <!-- Extra darkening strip at very bottom so text is readable -->
        <div class="absolute bottom-0 left-0 right-0 h-40 bg-gradient-to-t from-dark-900 to-transparent" />
      </div>

      <!-- Hero content — anchored bottom-left -->
      <div class="relative z-10 w-full">
        <div class="container mx-auto px-4 max-w-5xl pb-14 sm:pb-20">

          <span class="section-tag mb-6 inline-flex">
            <span class="w-1.5 h-1.5 rounded-full bg-wc-green animate-pulse" />
            USA · Canadá · México 2026
          </span>

          <h1 class="font-display font-black text-[clamp(3.5rem,12vw,7rem)] leading-[0.88] tracking-tight uppercase text-white mb-6 drop-shadow-lg">
            Predice.<br>
            Compite.<br>
            <span class="text-wc-red">Gana.</span>
          </h1>

          <p class="text-gray-300 text-base sm:text-lg max-w-md mb-8 font-light leading-relaxed">
            Haz tus predicciones para el Mundial 2026, acumula puntos y escala en la clasificación global. Sin apuestas reales.
          </p>

          <div class="flex flex-col sm:flex-row gap-3">
            <template v-if="user">
              <AppButton to="/predictions" size="lg">
                Ver partidos
                <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"/></svg>
              </AppButton>
              <AppButton to="/standings" variant="secondary" size="lg">Clasificación</AppButton>
            </template>
            <template v-else>
              <AppButton to="/auth/register" size="lg">
                Empezar gratis
                <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"/></svg>
              </AppButton>
              <AppButton to="/auth/login" variant="secondary" size="lg">Ya tengo cuenta</AppButton>
            </template>
          </div>
        </div>
      </div>
    </section>

    <!-- ─── HOW IT WORKS ─── -->
    <section class="container mx-auto px-4 max-w-5xl pt-16 pb-6">
      <p class="section-label mb-10">Cómo funciona</p>

      <div class="grid sm:grid-cols-3 gap-4">
        <AppCard accent="red" hover>
          <p class="text-2xl mb-3">⚽</p>
          <h3 class="font-display font-black text-xl uppercase tracking-wide mb-2">Predice</h3>
          <p class="text-gray-400 text-sm leading-relaxed">Elige el resultado de cada partido antes de que empiece. Marcador exacto, ganador, o diferencia de goles.</p>
        </AppCard>

        <AppCard accent="green" hover>
          <p class="text-2xl mb-3">🎯</p>
          <h3 class="font-display font-black text-xl uppercase tracking-wide mb-2">Puntúa</h3>
          <p class="text-gray-400 text-sm leading-relaxed">Gana más puntos cuanto más aciertes. El marcador exacto vale más que solo acertar el ganador.</p>
        </AppCard>

        <AppCard accent="gold" hover>
          <p class="text-2xl mb-3">🏅</p>
          <h3 class="font-display font-black text-xl uppercase tracking-wide mb-2">Compite</h3>
          <p class="text-gray-400 text-sm leading-relaxed">Escala el ranking global y demuestra que eres el mejor pronosticador de tu grupo.</p>
        </AppCard>
      </div>
    </section>

    <!-- ─── BOTTOM CTA (guests only) ─── -->
    <section v-if="!user" class="container mx-auto px-4 max-w-5xl py-12">
      <AppCard pad="xl" class="relative overflow-hidden">
        <div class="absolute inset-0 bg-gradient-to-br from-wc-red/[0.06] via-transparent to-wc-navy/[0.12] pointer-events-none" aria-hidden="true" />
        <div class="relative text-center">
          <h2 class="font-display font-black text-4xl sm:text-5xl uppercase tracking-tight mb-3">
            ¿Listo para el <span class="text-wc-red">Mundial?</span>
          </h2>
          <p class="text-gray-400 mb-8 max-w-sm mx-auto text-sm leading-relaxed">
            Regístrate gratis y empieza a predecir el torneo más grande del mundo.
          </p>
          <AppButton to="/auth/register" size="lg">
            Crear cuenta gratis
            <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"/></svg>
          </AppButton>
        </div>
      </AppCard>
    </section>

  </div>
</template>
