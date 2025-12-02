<template>
  <div class="bg-white dark:bg-slate-800 rounded-2xl shadow-lg p-6 transition-colors">
    <h2 class="text-2xl font-semibold text-slate-800 dark:text-white mb-8">Profile Settings</h2>

    <div class="space-y-8">
      <div class="bg-slate-50 dark:bg-slate-700/50 rounded-xl p-4 border border-slate-200 dark:border-slate-600">
        <label class="block text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">Email Address</label>
        <p class="text-base font-medium text-slate-800 dark:text-white">{{ user.email }}</p>
      </div>

      <div class="space-y-6">
        <div class="flex items-center gap-3">
          <div class="flex-shrink-0 w-8 h-8 bg-blue-100 dark:bg-blue-900/30 rounded-lg flex items-center justify-center">
            <svg class="w-4 h-4 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
            </svg>
          </div>
          <h3 class="text-lg font-semibold text-slate-800 dark:text-white">Change Password</h3>
        </div>

        <div class="space-y-4 pl-11">
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">New Password</label>
            <input
              v-model="newPassword"
              type="password"
              placeholder="Enter new password"
              class="w-full px-4 py-2.5 bg-white dark:bg-slate-700 border border-slate-300 dark:border-slate-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-slate-800 dark:text-white placeholder-slate-400"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">Confirm New Password</label>
            <input
              v-model="confirmPassword"
              type="password"
              placeholder="Confirm new password"
              class="w-full px-4 py-2.5 bg-white dark:bg-slate-700 border border-slate-300 dark:border-slate-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-slate-800 dark:text-white placeholder-slate-400"
            />
          </div>

          <button
            @click="changePassword"
            :disabled="isChangingPassword || !newPassword || !confirmPassword"
            class="w-full py-2.5 px-4 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            <span v-if="isChangingPassword" class="inline-block animate-spin rounded-full h-4 w-4 border-b-2 border-white"></span>
            {{ isChangingPassword ? 'Changing Password...' : 'Change Password' }}
          </button>
        </div>
      </div>

      <div class="h-px bg-slate-200 dark:bg-slate-700"></div>

      <div class="space-y-6">
        <div class="flex items-center gap-3">
          <div class="flex-shrink-0 w-8 h-8 bg-emerald-100 dark:bg-emerald-900/30 rounded-lg flex items-center justify-center">
            <svg class="w-4 h-4 text-emerald-600 dark:text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h3 class="text-lg font-semibold text-slate-800 dark:text-white">Currency Format</h3>
        </div>

        <div class="space-y-3 pl-11">
          <label class="flex items-center p-3 border-2 rounded-lg cursor-pointer transition hover:bg-slate-50 dark:hover:bg-slate-700/50"
            :class="currencyFormat === 'IDR' ? 'border-blue-500 bg-blue-50/50 dark:bg-blue-900/20' : 'border-slate-200 dark:border-slate-600'"
          >
            <input
              type="radio"
              v-model="currencyFormat"
              value="IDR"
              class="w-4 h-4 text-blue-600 focus:ring-blue-500"
            />
            <div class="ml-3 flex-1">
              <p class="font-medium text-slate-800 dark:text-white text-sm">Indonesian Rupiah (IDR)</p>
              <p class="text-xs text-slate-500 dark:text-slate-400">Format: Rp 50,000</p>
            </div>
          </label>

          <label class="flex items-center p-3 border-2 rounded-lg cursor-pointer transition hover:bg-slate-50 dark:hover:bg-slate-700/50"
            :class="currencyFormat === 'USD' ? 'border-blue-500 bg-blue-50/50 dark:bg-blue-900/20' : 'border-slate-200 dark:border-slate-600'"
          >
            <input
              type="radio"
              v-model="currencyFormat"
              value="USD"
              class="w-4 h-4 text-blue-600 focus:ring-blue-500"
            />
            <div class="ml-3 flex-1">
              <p class="font-medium text-slate-800 dark:text-white text-sm">US Dollar (USD)</p>
              <p class="text-xs text-slate-500 dark:text-slate-400">Format: $50,000</p>
            </div>
          </label>
        </div>
      </div>

      <div class="h-px bg-slate-200 dark:bg-slate-700"></div>

      <div class="space-y-6">
        <div class="flex items-start gap-3">
          <div class="flex-shrink-0 w-8 h-8 bg-violet-100 dark:bg-violet-900/30 rounded-lg flex items-center justify-center mt-0.5">
            <svg class="w-4 h-4 text-violet-600 dark:text-violet-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
            </svg>
          </div>
          <div class="flex-1">
            <h3 class="text-lg font-semibold text-slate-800 dark:text-white">Default Payment Method</h3>
            <p class="text-sm text-slate-500 dark:text-slate-400 mt-1">Used in PDFs when no payment method is specified</p>
          </div>
        </div>

        <div class="space-y-4 pl-11">
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">Transfer Method</label>
            <select
              v-model="defaultTransferMethod"
              class="w-full px-4 py-2.5 bg-white dark:bg-slate-700 border border-slate-300 dark:border-slate-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-slate-800 dark:text-white"
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
              placeholder="e.g., BCA"
              class="w-full px-4 py-2.5 bg-white dark:bg-slate-700 border border-slate-300 dark:border-slate-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-slate-800 dark:text-white placeholder-slate-400"
            />
          </div>

          <div v-if="defaultTransferMethod">
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">Account Number/ID</label>
            <input
              v-model="defaultTransferAccount"
              type="text"
              placeholder="6041047558"
              class="w-full px-4 py-2.5 bg-white dark:bg-slate-700 border border-slate-300 dark:border-slate-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-slate-800 dark:text-white placeholder-slate-400"
            />
          </div>

          <div v-if="defaultTransferMethod">
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">Description (Optional)</label>
            <input
              v-model="defaultTransferDescription"
              type="text"
              placeholder="Hartono"
              class="w-full px-4 py-2.5 bg-white dark:bg-slate-700 border border-slate-300 dark:border-slate-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-slate-800 dark:text-white placeholder-slate-400"
            />
          </div>

          <button
            @click="savePreferences"
            :disabled="isSavingPreferences"
            class="w-full py-2.5 px-4 bg-emerald-600 hover:bg-emerald-700 text-white font-medium rounded-lg transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            <span v-if="isSavingPreferences" class="inline-block animate-spin rounded-full h-4 w-4 border-b-2 border-white"></span>
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
import { useToast } from '../composables/useToast.js'

const props = defineProps({
  user: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['preferences-updated'])
const { showToast } = useToast()

const newPassword = ref('')
const confirmPassword = ref('')
const isChangingPassword = ref(false)

const currencyFormat = ref('IDR')
const darkMode = ref(false)
const defaultTransferMethod = ref('')
const defaultBankName = ref('')
const defaultTransferAccount = ref('')
const defaultTransferDescription = ref('')
const isSavingPreferences = ref(false)

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
    showToast('Passwords do not match', 'error')
    return
  }

  if (newPassword.value.length < 6) {
    showToast('Password must be at least 6 characters', 'error')
    return
  }

  isChangingPassword.value = true

  try {
    const { error } = await supabase.auth.updateUser({
      password: newPassword.value
    })

    if (error) throw error

    showToast('Password changed successfully!', 'success')
    newPassword.value = ''
    confirmPassword.value = ''
  } catch (error) {
    console.error('Error changing password:', error)
    showToast(error.message || 'Failed to change password', 'error')
  } finally {
    isChangingPassword.value = false
  }
}

const savePreferences = async () => {
  isSavingPreferences.value = true

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

    showToast('Preferences saved successfully!', 'success')
    emit('preferences-updated', currencyFormat.value)
  } catch (error) {
    console.error('Error saving preferences:', error)
    showToast(error.message || 'Failed to save preferences', 'error')
  } finally {
    isSavingPreferences.value = false
  }
}

onMounted(() => {
  loadPreferences()
})
</script>
