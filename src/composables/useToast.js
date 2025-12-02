import { ref } from 'vue'

const toastMessage = ref('')
const toastType = ref('success')
const toastKey = ref(0)

export const useToast = () => {
  const showToast = (message, type = 'success') => {
    toastMessage.value = message
    toastType.value = type
    toastKey.value++
  }

  return {
    toastMessage,
    toastType,
    toastKey,
    showToast
  }
}
