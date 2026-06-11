<script setup lang="ts">
import { flagByCode } from '~/utils/countries'

const props = withDefaults(defineProps<{
  code?: string | null
  name?: string | null
  size?: number          // alto en px (el ancho se calcula 1.4:1)
  rounded?: boolean
}>(), { size: 18, rounded: true })

const src = computed(() => flagByCode(props.code))
const w = computed(() => Math.round(props.size * 1.4))
</script>

<template>
  <img
    v-if="src"
    :src="src"
    :alt="name || code || ''"
    class="inline-block object-cover align-middle shrink-0 border border-dark-500/60"
    :style="{
      height: `${size}px`,
      width: `${w}px`,
      borderRadius: rounded ? '3px' : '0',
    }"
    loading="lazy"
  />
  <span
    v-else
    class="inline-block align-middle text-gray-500 font-display font-bold"
    :style="{ fontSize: `${Math.round(size * 0.6)}px` }"
  >
    {{ code }}
  </span>
</template>
