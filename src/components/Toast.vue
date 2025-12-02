<template>
  <Teleport to="body">
    <Transition name="toast">
      <div
        v-if="show"
        class="fixed top-6 left-1/2 -translate-x-1/2 z-[9999] pointer-events-none"
        style="position: fixed !important; z-index: 9999 !important;"
      >
        <div class="bg-slate-800 dark:bg-slate-700 text-white px-6 py-3 rounded-xl shadow-2xl flex items-center gap-3 min-w-[280px] border border-slate-700 dark:border-slate-600 pointer-events-auto">
          <div class="flex-shrink-0">
            <svg
              v-if="type === 'success'"
              class="w-5 h-5 text-emerald-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M5 13l4 4L19 7"
              />
            </svg>
            <svg
              v-else-if="type === 'error'"
              class="w-5 h-5 text-red-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
            <svg
              v-else
              class="w-5 h-5 text-blue-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
          <p class="text-sm font-medium">{{ message }}</p>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  message: {
    type: String,
    required: true
  },
  type: {
    type: String,
    default: 'success',
    validator: (value) => ['success', 'error', 'info'].includes(value)
  },
  duration: {
    type: Number,
    default: 2500
  },
  modelValue: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue'])

const show = ref(props.modelValue)
let timeoutId = null

watch(() => props.modelValue, (newValue) => {
  show.value = newValue
  if (newValue) {
    if (timeoutId) clearTimeout(timeoutId)
    timeoutId = setTimeout(() => {
      show.value = false
      emit('update:modelValue', false)
    }, props.duration)
  }
})

watch(show, (newValue) => {
  if (!newValue) {
    emit('update:modelValue', false)
  }
})
</script>

<style scoped>
.toast-enter-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.toast-leave-active {
  transition: all 0.2s cubic-bezier(0.4, 0, 1, 1);
}

.toast-enter-from {
  opacity: 0;
  transform: translateX(-50%) translateY(-1rem) scale(0.95);
}

.toast-leave-to {
  opacity: 0;
  transform: translateX(-50%) translateY(-0.5rem) scale(0.98);
}
</style>
