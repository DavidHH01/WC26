<script setup lang="ts">
definePageMeta({ layout: 'auth' })

const supabase = useSupabaseClient()
const username = ref('')
const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')
const success = ref(false)

async function register() {
  loading.value = true
  error.value = ''
  const { error: err } = await supabase.auth.signUp({
    email: email.value,
    password: password.value,
    options: { data: { username: username.value } },
  })
  if (err) {
    error.value = err.message === 'User already registered'
      ? 'Ya existe una cuenta con ese email.'
      : 'Error al crear la cuenta. Inténtalo de nuevo.'
  } else {
    success.value = true
  }
  loading.value = false
}
</script>

<template>
  <AppCard pad="lg">
    <template v-if="!success">
      <h2 class="font-display font-black text-3xl uppercase tracking-wide mb-1">Únete</h2>
      <p class="text-gray-500 text-sm mb-7">Crea tu cuenta y empieza a predecir el Mundial 2026</p>

      <form class="space-y-4" @submit.prevent="register">
        <div>
          <label class="label" for="reg-username">Nombre de usuario</label>
          <input id="reg-username" v-model="username" type="text" required placeholder="ElMejorPronosticador" minlength="3" maxlength="30" class="input-field" />
        </div>
        <div>
          <label class="label" for="reg-email">Email</label>
          <input id="reg-email" v-model="email" type="email" autocomplete="email" required placeholder="tu@email.com" class="input-field" />
        </div>
        <div>
          <label class="label" for="reg-password">Contraseña</label>
          <input id="reg-password" v-model="password" type="password" autocomplete="new-password" required placeholder="••••••••" minlength="6" class="input-field" />
          <p class="text-xs text-gray-600 mt-1.5">Mínimo 6 caracteres</p>
        </div>

        <div v-if="error" class="alert-error">
          <span>⚠</span> {{ error }}
        </div>

        <AppButton type="submit" :disabled="loading" full>
          {{ loading ? 'Creando cuenta...' : 'Crear cuenta' }}
        </AppButton>
      </form>

      <p class="text-center text-sm text-gray-500 mt-6">
        ¿Ya tienes cuenta?
        <NuxtLink to="/auth/login" class="text-wc-red hover:text-red-400 font-medium transition-colors">Inicia sesión</NuxtLink>
      </p>
    </template>

    <template v-else>
      <div class="text-center py-4">
        <div class="text-5xl mb-5">✉️</div>
        <h2 class="font-display font-black text-3xl uppercase tracking-wide mb-3">Revisa tu email</h2>
        <p class="text-gray-400 text-sm leading-relaxed">
          Enviamos un enlace de confirmación a<br>
          <strong class="text-white">{{ email }}</strong>
        </p>
        <NuxtLink to="/auth/login" class="inline-block mt-7 text-wc-red hover:text-red-400 text-sm font-medium transition-colors">
          Volver al login
        </NuxtLink>
      </div>
    </template>
  </AppCard>
</template>
