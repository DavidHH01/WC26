// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },

  modules: [
    '@nuxtjs/tailwindcss',
    '@nuxtjs/supabase',
  ],

  tailwindcss: {
    cssPath: '~/assets/css/main.css',
  },

  supabase: {
    redirectOptions: {
      login: '/auth/login',
      callback: '/auth/confirm',
      exclude: ['/', '/auth/login', '/auth/register'],
    },
  },

  app: {
    head: {
      title: 'WC26 — Predicciones del Mundial',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Predice los partidos del Mundial de Fútbol 2026, gana puntos y compite con tus amigos.' },
        { name: 'theme-color', content: '#080C1A' },
      ],
      link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,800&family=Outfit:wght@300;400;500;600&display=swap',
        },
      ],
    },
  },
})
