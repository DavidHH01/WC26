<script setup lang="ts">
definePageMeta({ layout: 'auth' })

const supabase = useSupabaseClient()
const email    = ref('')
const password = ref('')
const showPwd  = ref(false)
const loading  = ref(false)
const error    = ref('')

// Mapea los códigos de error de Supabase a mensajes en español
function parseError(err: any): string {
  const msg = err?.message ?? ''
  if (msg.includes('Invalid login credentials') || msg.includes('invalid_credentials'))
    return 'Email o contraseña incorrectos. Comprueba tus datos e inténtalo de nuevo.'
  if (msg.includes('Email not confirmed'))
    return 'Tu cuenta no está confirmada. Revisa tu email y pulsa el enlace de verificación.'
  if (msg.includes('Too many requests') || err?.status === 429)
    return 'Demasiados intentos. Espera unos minutos antes de volver a intentarlo.'
  if (msg.includes('User not found'))
    return 'No existe ninguna cuenta con ese email.'
  if (msg.includes('network') || msg.includes('fetch'))
    return 'Error de conexión. Comprueba tu red e inténtalo de nuevo.'
  return `Error al iniciar sesión: ${msg || 'inténtalo de nuevo.'}`
}

async function login() {
  loading.value = true
  error.value = ''
  const { error: err } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value,
  })
  if (err) {
    error.value = parseError(err)
  } else {
    await navigateTo('/predictions', { replace: true })
  }
  loading.value = false
}
</script>

<template>
  <AppCard pad="lg">
    <h2 class="font-display font-black text-3xl uppercase tracking-wide mb-1">Bienvenido</h2>
    <p class="text-gray-400 text-sm mb-7">Inicia sesión para ver tus predicciones</p>

    <form class="space-y-4" @submit.prevent="login">

      <div>
        <label class="label" for="login-email">Email</label>
        <input
          id="login-email"
          v-model="email"
          type="email"
          autocomplete="email"
          required
          placeholder="tu@email.com"
          class="input-field"
        />
      </div>

      <div>
        <label class="label" for="login-password">Contraseña</label>
        <div class="relative">
          <input
            id="login-password"
            v-model="password"
            :type="showPwd ? 'text' : 'password'"
            autocomplete="current-password"
            required
            placeholder="••••••••"
            class="input-field pr-11"
          />
          <button
            type="button"
            class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white transition-colors p-0.5"
            :aria-label="showPwd ? 'Ocultar contraseña' : 'Ver contraseña'"
            @click="showPwd = !showPwd"
          >
            <!-- Ojo abierto -->
            <svg v-if="!showPwd" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7
                   -1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
            </svg>
            <!-- Ojo cerrado -->
            <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7
                   a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243
                   M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29
                   m7.532 7.532l3.29 3.29M3 3l3.59 3.59
                   m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7
                   a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
            </svg>
          </button>
        </div>
      </div>

      <!-- Error detallado -->
      <div v-if="error" class="alert-error">
        <svg class="w-4 h-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
        </svg>
        <span>{{ error }}</span>
      </div>

      <AppButton type="submit" :disabled="loading" full>
        {{ loading ? 'Entrando...' : 'Iniciar sesión' }}
      </AppButton>
    </form>

    <p class="text-center text-sm text-gray-400 mt-6">
      ¿No tienes cuenta?
      <NuxtLink to="/auth/register" class="text-wc-red hover:text-red-400 font-medium transition-colors">Regístrate</NuxtLink>
    </p>
  </AppCard>
</template>
