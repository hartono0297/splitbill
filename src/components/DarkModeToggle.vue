<template>
  <button
    @click="toggleDarkMode"
    class="p-2 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-700 transition-colors"
    :title="isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'"
  >
    <svg v-if="isDarkMode" class="w-5 h-5 text-slate-600 dark:text-slate-300" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
    </svg>
    <svg v-else class="w-5 h-5 text-slate-600 dark:text-slate-300" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
    </svg>
  </button>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../supabase.js'

const props = defineProps({
  userId: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['theme-changed'])

const isDarkMode = ref(false)

const getSystemPreference = () => {
  return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
}

const applyDarkMode = (darkMode) => {
  isDarkMode.value = darkMode
  if (darkMode) {
    document.documentElement.classList.add('dark')
  } else {
    document.documentElement.classList.remove('dark')
  }
  emit('theme-changed', darkMode)
}

const toggleDarkMode = async () => {
  const newMode = !isDarkMode.value
  applyDarkMode(newMode)

  if (props.userId) {
    try {
      const { data: existing } = await supabase
        .from('user_preferences')
        .select('id, currency_format')
        .eq('user_id', props.userId)
        .maybeSingle()

      if (existing) {
        await supabase
          .from('user_preferences')
          .update({
            dark_mode: newMode,
            updated_at: new Date().toISOString()
          })
          .eq('user_id', props.userId)
      } else {
        await supabase
          .from('user_preferences')
          .insert({
            user_id: props.userId,
            currency_format: existing?.currency_format || 'IDR',
            dark_mode: newMode
          })
      }
    } catch (error) {
      console.error('Error saving dark mode preference:', error)
    }
  } else {
    localStorage.setItem('darkMode', newMode.toString())
  }
}

const initializeDarkMode = async () => {
  let darkModePreference = false

  if (props.userId) {
    try {
      const { data, error } = await supabase
        .from('user_preferences')
        .select('dark_mode')
        .eq('user_id', props.userId)
        .maybeSingle()

      if (error) throw error

      if (data && data.dark_mode !== undefined) {
        darkModePreference = data.dark_mode
      } else {
        darkModePreference = getSystemPreference()
      }
    } catch (error) {
      console.error('Error loading dark mode preference:', error)
      darkModePreference = getSystemPreference()
    }
  } else {
    const stored = localStorage.getItem('darkMode')
    if (stored !== null) {
      darkModePreference = stored === 'true'
    } else {
      darkModePreference = getSystemPreference()
    }
  }

  applyDarkMode(darkModePreference)
}

onMounted(() => {
  initializeDarkMode()

  if (window.matchMedia) {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    const handleChange = (e) => {
      if (props.userId) {
        return
      }
      const stored = localStorage.getItem('darkMode')
      if (stored === null) {
        applyDarkMode(e.matches)
      }
    }
    mediaQuery.addEventListener('change', handleChange)
  }
})

defineExpose({
  initializeDarkMode
})
</script>
