<script setup lang="ts">
const props = withDefaults(defineProps<{
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  to?: string
  type?: 'button' | 'submit' | 'reset'
  disabled?: boolean
  full?: boolean
}>(), {
  variant: 'primary',
  size: 'md',
  type: 'button',
  disabled: false,
  full: false,
})

const router = useRouter()

const classes = computed(() => [
  `btn-${props.variant}`,
  props.size !== 'md' && `btn-${props.size}`,
  props.full && 'w-full',
])

function navigate(e: MouseEvent) {
  if (!props.to) return
  if (e.metaKey || e.ctrlKey || e.shiftKey) return
  e.preventDefault()
  router.push(props.to)
}
</script>

<template>
  <a
    v-if="to"
    :href="to"
    :class="classes"
    @click="navigate"
  >
    <slot />
  </a>
  <button
    v-else
    :type="type"
    :disabled="disabled"
    :class="classes"
  >
    <slot />
  </button>
</template>
