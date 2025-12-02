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
        <h3 class="text-lg font-semibold text-slate-800 dark:text-white mb-4">Preferences</h3>

        <div v-if="preferencesMessage" :class="[
          'p-4 rounded-lg mb-4',
          preferencesError ? 'bg-red-50 dark:bg-red-900/30 text-red-700 dark:text-red-400' : 'bg-green-50 dark:bg-green-900/30 text-green-700 dark:text-green-400'
        ]">
          {{ preferencesMessage }}
        </div>

        <h4 class="text-md font-semibold text-slate-800 dark:text-white mb-3">Currency Format</h4>

        <div class="space-y-3 mb-6">
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
        </div>

        <h4 class="text-md font-semibold text-slate-800 dark:text-white mb-3">Default Payment Method</h4>
        <p class="text-sm text-slate-600 dark:text-slate-400 mb-3">This will be shown in PDFs when no payment method is specified for a bill.</p>

        <div class="space-y-3">
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">Transfer Method</label>
            <select
              v-model="defaultTransferMethod"
              class="w-full px-4 py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-slate-800 dark:text-white"
            >
              <option value="">None</option>
              <option value="bank">Bank Account</option>
              <option value="ovo">OVO</option>
              <option value="dana">DANA</option>
              <option value="gopay">GoPay</option>
              <option value="other">Other</option>
            </select>
          </div>

          <div v-if="defaultTransferMethod === 'bank'">
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">Bank Name</label>
            <input
              v-model="defaultBankName"
              type="text"
              placeholder="e.g., BCA, Mandiri"
              class="w-full px-4 py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-slate-800 dark:text-white"
            />
          </div>

          <div v-if="defaultTransferMethod">
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">Account Number/ID</label>
            <input
              v-model="defaultTransferAccount"
              type="text"
              placeholder="Enter account number"
              class="w-full px-4 py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-slate-800 dark:text-white"
            />
          </div>

          <div v-if="defaultTransferMethod">
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">Description (Optional)</label>
            <input
              v-model="defaultTransferDescription"
              type="text"
              placeholder="e.g., Account holder name"
              class="w-full px-4 py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-slate-800 dark:text-white"
            />
          </div>

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
const defaultTransferMethod = ref('')
const defaultBankName = ref('')
const defaultTransferAccount = ref('')
const defaultTransferDescription = ref('')
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
      defaultTransferMethod.value = data.default_transfer_method || ''
      defaultBankName.value = data.default_bank_name || ''
      defaultTransferAccount.value = data.default_transfer_account || ''
      defaultTransferDescription.value = data.default_transfer_description || ''
      emit('preferences-updated', currencyFormat.value)
    }
  } catch (error) {
    console.error('Error loading preferences:', error)
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
          default_transfer_method: defaultTransferMethod.value || null,
          default_bank_name: defaultBankName.value || null,
          default_transfer_account: defaultTransferAccount.value || null,
          default_transfer_description: defaultTransferDescription.value || null,
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
          default_transfer_method: defaultTransferMethod.value || null,
          default_bank_name: defaultBankName.value || null,
          default_transfer_account: defaultTransferAccount.value || null,
          default_transfer_description: defaultTransferDescription.value || null
        })

      if (error) throw error
    }

    preferencesError.value = false
    preferencesMessage.value = 'Preferences saved successfully!'
    emit('preferences-updated', currencyFormat.value)
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
