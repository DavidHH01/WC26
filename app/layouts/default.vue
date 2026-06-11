<template>
  <div class="min-h-screen bg-dark-900 text-white font-sans relative">

    <!-- Ambient glow blobs — fixed, behind everything -->
    <div class="fixed inset-0 pointer-events-none overflow-hidden z-0" aria-hidden="true">
      <div class="absolute -top-40 -right-40 w-[500px] h-[500px] rounded-full bg-wc-red/[0.07] blur-[130px]" />
      <div class="absolute top-1/2 -left-60 w-[600px] h-[600px] rounded-full bg-wc-navy/[0.22] blur-[150px]" />
      <div class="absolute bottom-0 right-1/3 w-96 h-96 rounded-full bg-wc-green/[0.05] blur-[110px]" />
    </div>

    <AppHeader />

    <main class="relative z-10">
      <slot />
    </main>

    <AppFooter />
  </div>
</template>
