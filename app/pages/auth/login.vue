<script setup lang="ts">
definePageMeta({ layout: 'auth' })

const supabase = useSupabaseClient()
const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

async function login() {
  loading.value = true
  error.value = ''
  const { error: err } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value,
  })
  if (err) {
    error.value = 'Email o contraseña incorrectos.'
  } else {
    await navigateTo('/predictions', { replace: true })
  }
  loading.value = false
}
</script>

<template>
  <AppCard pad="lg">
    <h2 class="font-display font-black text-3xl uppercase tracking-wide mb-1">Bienvenido</h2>
    <p class="text-gray-500 text-sm mb-7">Inicia sesión para ver tus predicciones</p>

    <form class="space-y-4" @submit.prevent="login">
      <div>
        <label class="label" for="login-email">Email</label>
        <input id="login-email" v-model="email" type="email" autocomplete="email" required placeholder="tu@email.com" class="input-field" />
      </div>
      <div>
        <label class="label" for="login-password">Contraseña</label>
        <input id="login-password" v-model="password" type="password" autocomplete="current-password" required placeholder="••••••••" class="input-field" />
      </div>

      <div v-if="error" class="alert-error">
        <span>⚠</span> {{ error }}
      </div>

      <AppButton type="submit" :disabled="loading" full>
        {{ loading ? 'Entrando...' : 'Iniciar sesión' }}
      </AppButton>
    </form>

    <p class="text-center text-sm text-gray-500 mt-6">
      ¿No tienes cuenta?
      <NuxtLink to="/auth/register" class="text-wc-red hover:text-red-400 font-medium transition-colors">Regístrate</NuxtLink>
    </p>
  </AppCard>
</template>
