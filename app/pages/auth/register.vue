<script setup lang="ts">
definePageMeta({ layout: 'auth' })

const supabase  = useSupabaseClient()
const username  = ref('')
const email     = ref('')
const password  = ref('')
const showPwd   = ref(false)
const loading   = ref(false)
const error     = ref('')
const success   = ref(false)

// Validación client-side antes de llamar a Supabase
function validate(): string {
  if (username.value.trim().length < 3)
    return 'El nombre de usuario debe tener al menos 3 caracteres.'
  if (!/^[a-zA-Z0-9_\-\.]+$/.test(username.value))
    return 'El nombre de usuario solo puede tener letras, números, guiones (_) y puntos. No se permiten espacios ni símbolos.'
  if (!email.value.includes('@'))
    return 'Introduce un email válido.'
  if (password.value.length < 6)
    return 'La contraseña debe tener al menos 6 caracteres.'
  return ''
}

function parseError(err: any): string {
  const msg = err?.message ?? ''
  if (msg.includes('User already registered') || msg.includes('already been registered'))
    return 'Ya existe una cuenta con ese email. ¿Quieres iniciar sesión?'
  if (msg.includes('Password should be at least'))
    return 'La contraseña debe tener al menos 6 caracteres.'
  if (msg.includes('Unable to validate email'))
    return 'El formato del email no es válido.'
  if (msg.includes('Signup is disabled'))
    return 'El registro está desactivado temporalmente. Inténtalo más tarde.'
  if (msg.includes('Too many requests') || err?.status === 429)
    return 'Demasiados intentos. Espera unos minutos antes de volver a intentarlo.'
  if (msg.includes('network') || msg.includes('fetch'))
    return 'Error de conexión. Comprueba tu red e inténtalo de nuevo.'
  return `Error al crear la cuenta: ${msg || 'inténtalo de nuevo.'}`
}

async function register() {
  error.value = validate()
  if (error.value) return

  loading.value = true
  const { error: err } = await supabase.auth.signUp({
    email: email.value,
    password: password.value,
    options: { data: { username: username.value.trim() } },
  })
  if (err) {
    error.value = parseError(err)
  } else {
    success.value = true
  }
  loading.value = false
}
</script>

<template>
  <AppCard pad="lg">

    <!-- Success state -->
    <template v-if="success">
      <div class="text-center py-4">
        <div class="text-5xl mb-5">✉️</div>
        <h2 class="font-display font-black text-3xl uppercase tracking-wide mb-3">Revisa tu email</h2>
        <p class="text-gray-400 text-sm leading-relaxed">
          Enviamos un enlace de confirmación a<br>
          <strong class="text-white">{{ email }}</strong>
        </p>
        <p class="text-gray-500 text-xs mt-3">Si no lo ves, revisa la carpeta de spam.</p>
        <NuxtLink
          to="/auth/login"
          class="inline-block mt-7 text-wc-red hover:text-red-400 text-sm font-medium transition-colors"
        >
          Volver al login
        </NuxtLink>
      </div>
    </template>

    <!-- Register form -->
    <template v-else>
      <h2 class="font-display font-black text-3xl uppercase tracking-wide mb-1">Únete</h2>
      <p class="text-gray-400 text-sm mb-7">Crea tu cuenta y empieza a predecir el Mundial 2026</p>

      <form class="space-y-4" @submit.prevent="register">

        <div>
          <label class="label" for="reg-username">Nombre de usuario</label>
          <input
            id="reg-username"
            v-model="username"
            type="text"
            required
            placeholder="ElMejorPronosticador"
            minlength="3"
            maxlength="30"
            class="input-field"
            :class="{ 'border-red-500': error && error.includes('usuario') }"
          />
        </div>

        <div>
          <label class="label" for="reg-email">Email</label>
          <input
            id="reg-email"
            v-model="email"
            type="email"
            autocomplete="email"
            required
            placeholder="tu@email.com"
            class="input-field"
            :class="{ 'border-red-500': error && error.includes('email') }"
          />
        </div>

        <div>
          <label class="label" for="reg-password">Contraseña</label>
          <div class="relative">
            <input
              id="reg-password"
              v-model="password"
              :type="showPwd ? 'text' : 'password'"
              autocomplete="new-password"
              required
              placeholder="••••••••"
              minlength="6"
              class="input-field pr-11"
              :class="{ 'border-red-500': error && error.includes('contraseña') }"
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
          <p class="text-sm text-gray-500 mt-1.5">Mínimo 6 caracteres · letras, números y símbolos permitidos</p>
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
          {{ loading ? 'Creando cuenta...' : 'Crear cuenta' }}
        </AppButton>
      </form>

      <p class="text-center text-sm text-gray-400 mt-6">
        ¿Ya tienes cuenta?
        <NuxtLink to="/auth/login" class="text-wc-red hover:text-red-400 font-medium transition-colors">Inicia sesión</NuxtLink>
      </p>
    </template>

  </AppCard>
</template>
