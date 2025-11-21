import { ref, watch } from 'vue'

export function useCurrencyInput(initialValue = 0) {
  const numericValue = ref(initialValue)
  const displayValue = ref(formatNumber(initialValue))

  function formatNumber(value) {
    if (!value) return ''
    const numValue = typeof value === 'string' ? parseFloat(value.replace(/\./g, '')) : value
    if (isNaN(numValue)) return ''
    return new Intl.NumberFormat('id-ID').format(numValue)
  }

  function parseFormattedNumber(formatted) {
    if (!formatted) return 0
    const cleaned = formatted.toString().replace(/\./g, '')
    const num = parseFloat(cleaned)
    return isNaN(num) ? 0 : num
  }

  function handleInput(event) {
    const input = event.target.value
    const cleaned = input.replace(/[^\d]/g, '')

    if (cleaned === '') {
      numericValue.value = 0
      displayValue.value = ''
      return
    }

    const num = parseFloat(cleaned)
    numericValue.value = num
    displayValue.value = formatNumber(num)

    event.target.value = displayValue.value
  }

  function setValue(value) {
    numericValue.value = value
    displayValue.value = formatNumber(value)
  }

  watch(numericValue, (newVal) => {
    displayValue.value = formatNumber(newVal)
  })

  return {
    numericValue,
    displayValue,
    handleInput,
    setValue,
    formatNumber
  }
}
