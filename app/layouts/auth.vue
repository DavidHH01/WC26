<template>
  <div class="min-h-screen bg-dark-900 text-white font-sans flex items-center justify-center px-4 py-12 relative overflow-hidden">

    <!-- Ambient blobs -->
    <div class="fixed inset-0 pointer-events-none z-0" aria-hidden="true">
      <div class="absolute -top-24 left-1/4 w-[450px] h-[450px] rounded-full bg-wc-red/[0.09] blur-[130px]" />
      <div class="absolute bottom-0 -right-20 w-[500px] h-[500px] rounded-full bg-wc-navy/[0.25] blur-[150px]" />
    </div>

    <div class="w-full max-w-md relative z-10">
      <!-- Logo badge -->
      <div class="text-center mb-8">
        <NuxtLink to="/" class="inline-flex flex-col items-center gap-3">
          <div class="bg-white rounded-3xl px-7 py-5 shadow-2xl shadow-black/60">
            <img
              src="~/assets/images/wc_logo.png"
              alt="FIFA World Cup 26"
              class="h-16 w-auto"
            />
          </div>
          <span class="section-tag">USA · Canadá · México 2026</span>
        </NuxtLink>
      </div>

      <slot />
    </div>
  </div>
</template>
