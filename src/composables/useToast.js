import { ref } from 'vue'

const toastState = ref({
  show: false,
  message: '',
  type: 'success'
})

export const useToast = () => {
  const showToast = (message, type = 'success') => {
    toastState.value = {
      show: true,
      message,
      type
    }
  }

  const hideToast = () => {
    toastState.value.show = false
  }

  return {
    toastState,
    showToast,
    hideToast
  }
}
