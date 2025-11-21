<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800 transition-colors">
    <nav class="bg-white dark:bg-slate-800 shadow-sm border-b border-slate-200 dark:border-slate-700 transition-colors">
      <div class="max-w-7xl mx-auto px-4 py-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <h1 class="text-2xl font-bold text-slate-800 dark:text-white">Split Bill</h1>
            <span class="text-sm text-slate-500 dark:text-slate-400">{{ userEmail }}</span>
          </div>
          <button
            @click="handleSignOut"
            class="px-4 py-2 text-slate-600 dark:text-slate-300 hover:text-slate-800 dark:hover:text-white hover:bg-slate-100 dark:hover:bg-slate-700 rounded-lg transition font-medium"
          >
            Sign Out
          </button>
        </div>
      </div>
    </nav>

    <div class="max-w-7xl mx-auto px-4 py-8">
      <div class="grid lg:grid-cols-3 gap-6">
        <div class="lg:col-span-2">
          <div class="flex gap-4 mb-6">
            <button
              @click="activeTab = 'create'"
              :class="[
                'flex-1 py-3 px-6 rounded-xl font-semibold transition',
                activeTab === 'create'
                  ? 'bg-blue-500 text-white shadow-lg'
                  : 'bg-white dark:bg-slate-800 text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-700'
              ]"
            >
              Create New Bill
            </button>
            <button
              @click="activeTab = 'history'"
              :class="[
                'flex-1 py-3 px-6 rounded-xl font-semibold transition',
                activeTab === 'history'
                  ? 'bg-blue-500 text-white shadow-lg'
                  : 'bg-white dark:bg-slate-800 text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-700'
              ]"
            >
              Bill History
            </button>
            <button
              @click="activeTab = 'profile'"
              :class="[
                'flex-1 py-3 px-6 rounded-xl font-semibold transition',
                activeTab === 'profile'
                  ? 'bg-blue-500 text-white shadow-lg'
                  : 'bg-white dark:bg-slate-800 text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-700'
              ]"
            >
              Profile
            </button>
          </div>

          <div v-if="activeTab === 'create'">
            <SplitBillForm :currency-format="currencyFormat" @bill-saved="handleBillSaved" />
          </div>

          <div v-else-if="activeTab === 'history'">
            <BillHistory :bills="bills" :loading="loadingBills" :currency-format="currencyFormat" @refresh="loadBills" />
          </div>

          <div v-else>
            <UserProfile :user="user" @preferences-updated="handlePreferencesUpdated" />
          </div>
        </div>

        <div class="lg:col-span-1">
          <div class="bg-white dark:bg-slate-800 rounded-2xl shadow-lg p-6 sticky top-8 transition-colors">
            <h3 class="text-lg font-semibold text-slate-800 dark:text-white mb-4">Quick Stats</h3>
            <div class="space-y-4">
              <div class="p-4 bg-blue-50 dark:bg-blue-900/30 rounded-xl transition-colors">
                <p class="text-sm text-slate-600 dark:text-slate-400 mb-1">Total Bills</p>
                <p class="text-3xl font-bold text-blue-600 dark:text-blue-400">{{ bills.length }}</p>
              </div>
              <div class="p-4 bg-green-50 dark:bg-green-900/30 rounded-xl transition-colors">
                <p class="text-sm text-slate-600 dark:text-slate-400 mb-1">Total Spent</p>
                <p class="text-2xl font-bold text-green-600 dark:text-green-400">{{ currencyFormat === 'USD' ? '$' : 'Rp' }} {{ formatRupiah(totalSpent) }}</p>
              </div>
              <div class="p-4 bg-amber-50 dark:bg-amber-900/30 rounded-xl transition-colors">
                <p class="text-sm text-slate-600 dark:text-slate-400 mb-1">Total Saved</p>
                <p class="text-2xl font-bold text-amber-600 dark:text-amber-400">{{ currencyFormat === 'USD' ? '$' : 'Rp' }} {{ formatRupiah(totalSaved) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../supabase.js'
import SplitBillForm from './SplitBillForm.vue'
import BillHistory from './BillHistory.vue'
import UserProfile from './UserProfile.vue'

const emit = defineEmits(['signout'])

const props = defineProps({
  user: {
    type: Object,
    required: true
  }
})

const activeTab = ref('create')
const bills = ref([])
const loadingBills = ref(false)
const currencyFormat = ref('IDR')
const isDarkMode = ref(false)

const userEmail = computed(() => props.user?.email || '')

const convertCurrency = (amount, fromCurrency) => {
  if (fromCurrency === currencyFormat.value) {
    return amount
  }

  const usdToIdrRate = 15600

  if (fromCurrency === 'USD' && currencyFormat.value === 'IDR') {
    return amount * usdToIdrRate
  } else if (fromCurrency === 'IDR' && currencyFormat.value === 'USD') {
    return amount / usdToIdrRate
  }

  return amount
}

const totalSpent = computed(() => {
  return bills.value.reduce((sum, bill) => {
    const amount = parseFloat(bill.final_amount || 0)
    const converted = convertCurrency(amount, bill.currency || 'IDR')
    return sum + converted
  }, 0)
})

const totalSaved = computed(() => {
  return bills.value.reduce((sum, bill) => {
    const original = parseFloat(bill.total_amount || 0)
    const final = parseFloat(bill.final_amount || 0)
    const saved = original - final
    const converted = convertCurrency(saved, bill.currency || 'IDR')
    return sum + converted
  }, 0)
})

const formatRupiah = (amount) => {
  if (currencyFormat.value === 'USD') {
    return new Intl.NumberFormat('en-US').format(Math.round(amount))
  }
  return new Intl.NumberFormat('id-ID').format(Math.round(amount))
}

const loadUserPreferences = async () => {
  try {
    const { data, error } = await supabase
      .from('user_preferences')
      .select('currency_format, dark_mode')
      .eq('user_id', props.user.id)
      .maybeSingle()

    if (error) throw error

    if (data) {
      currencyFormat.value = data.currency_format || 'IDR'
      isDarkMode.value = data.dark_mode || false
      applyDarkMode(isDarkMode.value)
    }
  } catch (error) {
    console.error('Error loading preferences:', error)
  }
}

const applyDarkMode = (darkMode) => {
  if (darkMode) {
    document.documentElement.classList.add('dark')
  } else {
    document.documentElement.classList.remove('dark')
  }
}

const loadBills = async () => {
  loadingBills.value = true
  try {
    const { data: billsData, error } = await supabase
      .from('bills')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error

    const billsWithFees = await Promise.all(
      (billsData || []).map(async (bill) => {
        const { data: feesData } = await supabase
          .from('fees')
          .select('*')
          .eq('bill_id', bill.id)
          .order('created_at', { ascending: true })

        return {
          ...bill,
          fees: feesData || []
        }
      })
    )

    bills.value = billsWithFees
  } catch (error) {
    console.error('Error loading bills:', error)
  } finally {
    loadingBills.value = false
  }
}

const handleBillSaved = () => {
  loadBills()
  activeTab.value = 'history'
}

const handleSignOut = async () => {
  await supabase.auth.signOut()
  emit('signout')
}

const handlePreferencesUpdated = (newCurrencyFormat, newDarkMode) => {
  currencyFormat.value = newCurrencyFormat
  isDarkMode.value = newDarkMode
  applyDarkMode(newDarkMode)
}

onMounted(() => {
  loadUserPreferences()
  loadBills()
})
</script>
