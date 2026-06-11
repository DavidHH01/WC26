<script setup lang="ts">
const props = withDefaults(defineProps<{
  accent?: 'red' | 'green' | 'gold' | 'navy' | null
  pad?: 'none' | 'sm' | 'md' | 'lg' | 'xl'
  hover?: boolean
}>(), {
  accent: null,
  pad: 'md',
  hover: false,
})

const accentColor: Record<string, string> = {
  red:   '#E61D25',
  green: '#3CAC3B',
  gold:  '#C9A84C',
  navy:  '#2A398D',
}

const padClass: Record<string, string> = {
  none: '',
  sm:   'p-4',
  md:   'p-6',
  lg:   'p-8',
  xl:   'p-10 sm:p-12',
}

const accentStyle = computed(() =>
  props.accent
    ? { borderTopColor: accentColor[props.accent], borderTopWidth: '3px' }
    : {}
)
</script>

<template>
  <div
    :class="['card', hover && 'card-hover', padClass[pad]]"
    :style="accentStyle"
  >
    <slot />
  </div>
</template>
