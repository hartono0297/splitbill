<template>
  <Transition name="toast">
    <div
      v-if="show"
      class="fixed top-6 left-1/2 -translate-x-1/2 z-50 px-6 py-3 bg-slate-800 dark:bg-slate-700 text-white rounded-xl shadow-2xl flex items-center gap-3 backdrop-blur-sm bg-opacity-95 dark:bg-opacity-95"
      role="alert"
    >
      <svg
        v-if="type === 'success'"
        class="w-5 h-5 text-green-400"
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
      <span class="text-sm font-medium">{{ message }}</span>
    </div>
  </Transition>
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
  }
})

const show = ref(false)
let timeoutId = null

const showToast = () => {
  show.value = true

  if (timeoutId) {
    clearTimeout(timeoutId)
  }

  timeoutId = setTimeout(() => {
    show.value = false
  }, props.duration)
}

watch(() => props.message, () => {
  if (props.message) {
    showToast()
  }
}, { immediate: true })

defineExpose({
  showToast
})
</script>

<style scoped>
.toast-enter-active {
  animation: toast-in 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.toast-leave-active {
  animation: toast-out 0.25s cubic-bezier(0.4, 0, 1, 1);
}

@keyframes toast-in {
  from {
    opacity: 0;
    transform: translate(-50%, -100%) scale(0.9);
  }
  to {
    opacity: 1;
    transform: translate(-50%, 0) scale(1);
  }
}

@keyframes toast-out {
  from {
    opacity: 1;
    transform: translate(-50%, 0) scale(1);
  }
  to {
    opacity: 0;
    transform: translate(-50%, -20px) scale(0.95);
  }
}
</style>
