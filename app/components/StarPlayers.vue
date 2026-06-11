<script setup lang="ts">
import { playerImages, starPlayers } from '~/utils/players'
</script>

<template>
  <section class="mb-10">
    <p class="section-label mb-4">Estrellas del torneo</p>

    <div class="flex gap-3 overflow-x-auto pb-2 -mx-4 px-4 snap-x sm:mx-0 sm:px-0 sm:grid sm:grid-cols-5 sm:overflow-visible">
      <div
        v-for="p in starPlayers"
        :key="p.slug"
        class="star-card group snap-start"
      >
        <!-- Glow del color del equipo -->
        <div
          class="star-glow"
          :style="{ background: `radial-gradient(circle at 50% 30%, ${p.accent}66, transparent 70%)` }"
        />

        <!-- Foto -->
        <img
          :src="playerImages[p.slug]"
          :alt="p.name"
          class="star-img"
          loading="lazy"
        />

        <!-- Degradado inferior + texto -->
        <div class="star-overlay">
          <span
            class="block h-0.5 w-6 mb-1.5 transition-all duration-300 group-hover:w-10"
            :style="{ background: p.accent }"
          />
          <p class="font-display font-black uppercase text-sm leading-none tracking-wide text-white truncate">
            {{ p.name }}
          </p>
          <p class="text-xs text-gray-400 mt-0.5 flex items-center gap-1.5">
            <CountryFlag :code="p.code" :name="p.team" :size="12" />
            {{ p.team }}
          </p>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.star-card {
  position: relative;
  flex: 0 0 9.5rem;
  width: 9.5rem;
  height: 13rem;
  border-radius: 6px;
  overflow: hidden;
  background: #0E1428;
  border: 1px solid #1F2D52;
  transition: transform 0.25s ease, border-color 0.25s ease;
}
@media (min-width: 640px) {
  .star-card { width: auto; flex: 1; height: 14rem; }
}
.star-card:hover {
  transform: translateY(-4px);
  border-color: #2A3D6E;
}

.star-glow {
  position: absolute;
  inset: 0;
  opacity: 0.7;
  transition: opacity 0.25s ease;
}
.star-card:hover .star-glow { opacity: 1; }

.star-img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: top center;
  filter: grayscale(0.15) contrast(1.05);
  transition: transform 0.35s ease, filter 0.25s ease;
}
.star-card:hover .star-img {
  transform: scale(1.06);
  filter: grayscale(0) contrast(1.1);
}

.star-overlay {
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  padding: 0.75rem;
  background: linear-gradient(to top, #080C1A 8%, rgba(8, 12, 26, 0.6) 55%, transparent);
}
</style>
