<template>
  <div class="bg-white dark:bg-slate-800 rounded-2xl shadow-lg p-6 transition-colors">
    <h2 class="text-2xl font-semibold text-slate-800 dark:text-white mb-6">User Profile</h2>

    <div class="space-y-6">
      <div>
        <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">Email</label>
        <input
          type="email"
          :value="user.email"
          disabled
          class="w-full px-4 py-3 bg-slate-100 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-xl text-slate-600 dark:text-slate-300 cursor-not-allowed transition-colors"
        />
      </div>

      <div class="pt-6 border-t border-slate-200 dark:border-slate-700">
        <h3 class="text-lg font-semibold text-slate-800 dark:text-white mb-4">Change Password</h3>

        <div v-if="passwordMessage" :class="[
          'p-4 rounded-lg mb-4',
          passwordError ? 'bg-red-50 dark:bg-red-900/30 text-red-700 dark:text-red-400' : 'bg-green-50 dark:bg-green-900/30 text-green-700 dark:text-green-400'
        ]">
          {{ passwordMessage }}
        </div>

        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">New Password</label>
            <input
              v-model="newPassword"
              type="password"
              placeholder="Enter new password"
              class="w-full px-4 py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-slate-800 dark:text-white"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">Confirm New Password</label>
            <input
              v-model="confirmPassword"
              type="password"
              placeholder="Confirm new password"
              class="w-full px-4 py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-slate-800 dark:text-white"
            />
          </div>

          <button
            @click="changePassword"
            :disabled="isChangingPassword || !newPassword || !confirmPassword"
            class="w-full py-3 px-4 bg-blue-500 hover:bg-blue-600 text-white font-medium rounded-xl transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            <span v-if="isChangingPassword" class="inline-block animate-spin rounded-full h-5 w-5 border-b-2 border-white"></span>
            {{ isChangingPassword ? 'Changing Password...' : 'Change Password' }}
          </button>
        </div>
      </div>

      <div class="pt-6 border-t border-slate-200 dark:border-slate-700">
        <h3 class="text-lg font-semibold text-slate-800 dark:text-white mb-4">Appearance</h3>

        <div v-if="preferencesMessage" :class="[
          'p-4 rounded-lg mb-4',
          preferencesError ? 'bg-red-50 dark:bg-red-900/30 text-red-700 dark:text-red-400' : 'bg-green-50 dark:bg-green-900/30 text-green-700 dark:text-green-400'
        ]">
          {{ preferencesMessage }}
        </div>

        <div class="mb-6">
          <label class="flex items-center justify-between p-4 border-2 rounded-xl cursor-pointer transition hover:bg-slate-50 dark:hover:bg-slate-700"
            :class="darkMode ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/30' : 'border-slate-200 dark:border-slate-600'"
            @click="toggleDarkMode"
          >
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-full flex items-center justify-center transition-colors"
                :class="darkMode ? 'bg-slate-700' : 'bg-amber-100'">
                <svg v-if="darkMode" class="w-5 h-5 text-slate-300" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                </svg>
                <svg v-else class="w-5 h-5 text-amber-500" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
              </div>
              <div>
                <p class="font-medium text-slate-800 dark:text-white">Dark Mode</p>
                <p class="text-sm text-slate-600 dark:text-slate-400">{{ darkMode ? 'Enabled' : 'Disabled' }}</p>
              </div>
            </div>
            <div class="relative w-12 h-6 rounded-full transition"
              :class="darkMode ? 'bg-blue-500' : 'bg-slate-300'"
            >
              <div class="absolute top-1 left-1 w-4 h-4 bg-white rounded-full transition-transform"
                :class="darkMode ? 'transform translate-x-6' : ''"
              ></div>
            </div>
          </label>
        </div>

        <h4 class="text-md font-semibold text-slate-800 dark:text-white mb-3">Currency Format</h4>

        <div class="space-y-3">
          <label class="flex items-center p-4 border-2 rounded-xl cursor-pointer transition hover:bg-slate-50 dark:hover:bg-slate-700"
            :class="currencyFormat === 'IDR' ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/30' : 'border-slate-200 dark:border-slate-600'"
          >
            <input
              type="radio"
              v-model="currencyFormat"
              value="IDR"
              class="w-4 h-4 text-blue-500"
            />
            <div class="ml-3">
              <p class="font-medium text-slate-800 dark:text-white">Indonesian Rupiah (IDR)</p>
              <p class="text-sm text-slate-600 dark:text-slate-400">Format: Rp 50.000</p>
            </div>
          </label>

          <label class="flex items-center p-4 border-2 rounded-xl cursor-pointer transition hover:bg-slate-50 dark:hover:bg-slate-700"
            :class="currencyFormat === 'USD' ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/30' : 'border-slate-200 dark:border-slate-600'"
          >
            <input
              type="radio"
              v-model="currencyFormat"
              value="USD"
              class="w-4 h-4 text-blue-500"
            />
            <div class="ml-3">
              <p class="font-medium text-slate-800 dark:text-white">US Dollar (USD)</p>
              <p class="text-sm text-slate-600 dark:text-slate-400">Format: $50,000</p>
            </div>
          </label>

          <button
            @click="savePreferences"
            :disabled="isSavingPreferences"
            class="w-full py-3 px-4 bg-green-500 hover:bg-green-600 text-white font-medium rounded-xl transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            <span v-if="isSavingPreferences" class="inline-block animate-spin rounded-full h-5 w-5 border-b-2 border-white"></span>
            {{ isSavingPreferences ? 'Saving...' : 'Save Preferences' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../supabase.js'

const props = defineProps({
  user: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['preferences-updated'])

const newPassword = ref('')
const confirmPassword = ref('')
const isChangingPassword = ref(false)
const passwordMessage = ref('')
const passwordError = ref(false)

const currencyFormat = ref('IDR')
const darkMode = ref(false)
const isSavingPreferences = ref(false)
const preferencesMessage = ref('')
const preferencesError = ref(false)

const loadPreferences = async () => {
  try {
    const { data, error } = await supabase
      .from('user_preferences')
      .select('*')
      .eq('user_id', props.user.id)
      .maybeSingle()

    if (error) throw error

    if (data) {
      currencyFormat.value = data.currency_format || 'IDR'
      darkMode.value = data.dark_mode || false
      emit('preferences-updated', currencyFormat.value, darkMode.value)
    }
  } catch (error) {
    console.error('Error loading preferences:', error)
  }
}

const toggleDarkMode = async () => {
  darkMode.value = !darkMode.value
  emit('preferences-updated', currencyFormat.value, darkMode.value)

  try {
    const { data: existing } = await supabase
      .from('user_preferences')
      .select('id')
      .eq('user_id', props.user.id)
      .maybeSingle()

    if (existing) {
      await supabase
        .from('user_preferences')
        .update({
          dark_mode: darkMode.value,
          updated_at: new Date().toISOString()
        })
        .eq('user_id', props.user.id)
    } else {
      await supabase
        .from('user_preferences')
        .insert({
          user_id: props.user.id,
          currency_format: currencyFormat.value,
          dark_mode: darkMode.value
        })
    }
  } catch (error) {
    console.error('Error saving dark mode:', error)
  }
}

const changePassword = async () => {
  if (newPassword.value !== confirmPassword.value) {
    passwordError.value = true
    passwordMessage.value = 'Passwords do not match'
    return
  }

  if (newPassword.value.length < 6) {
    passwordError.value = true
    passwordMessage.value = 'Password must be at least 6 characters'
    return
  }

  isChangingPassword.value = true
  passwordMessage.value = ''
  passwordError.value = false

  try {
    const { error } = await supabase.auth.updateUser({
      password: newPassword.value
    })

    if (error) throw error

    passwordError.value = false
    passwordMessage.value = 'Password changed successfully!'
    newPassword.value = ''
    confirmPassword.value = ''
  } catch (error) {
    console.error('Error changing password:', error)
    passwordError.value = true
    passwordMessage.value = error.message || 'Failed to change password'
  } finally {
    isChangingPassword.value = false
  }
}

const savePreferences = async () => {
  isSavingPreferences.value = true
  preferencesMessage.value = ''
  preferencesError.value = false

  try {
    const { data: existing } = await supabase
      .from('user_preferences')
      .select('id')
      .eq('user_id', props.user.id)
      .maybeSingle()

    if (existing) {
      const { error } = await supabase
        .from('user_preferences')
        .update({
          currency_format: currencyFormat.value,
          dark_mode: darkMode.value,
          updated_at: new Date().toISOString()
        })
        .eq('user_id', props.user.id)

      if (error) throw error
    } else {
      const { error } = await supabase
        .from('user_preferences')
        .insert({
          user_id: props.user.id,
          currency_format: currencyFormat.value,
          dark_mode: darkMode.value
        })

      if (error) throw error
    }

    preferencesError.value = false
    preferencesMessage.value = 'Preferences saved successfully!'
    emit('preferences-updated', currencyFormat.value, darkMode.value)
  } catch (error) {
    console.error('Error saving preferences:', error)
    preferencesError.value = true
    preferencesMessage.value = error.message || 'Failed to save preferences'
  } finally {
    isSavingPreferences.value = false
  }
}

onMounted(() => {
  loadPreferences()
})
</script>
