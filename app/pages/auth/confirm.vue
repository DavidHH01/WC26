<script setup lang="ts">
definePageMeta({ layout: 'auth' })
</script>

<template>
  <AppCard pad="lg" class="text-center">
    <div class="text-5xl mb-5">✅</div>
    <h2 class="font-display font-black text-3xl uppercase tracking-wide mb-2">¡Activado!</h2>
    <p class="text-gray-400 text-sm mb-8">Tu cuenta ha sido confirmada correctamente.</p>
    <AppButton to="/predictions">
      Ver predicciones
      <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"/></svg>
    </AppButton>
  </AppCard>
</template>
