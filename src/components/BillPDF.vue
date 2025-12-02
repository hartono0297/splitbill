<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800 py-8 px-4 transition-colors">
    <div class="max-w-4xl mx-auto">
      <div class="mb-6 flex items-center justify-between">
        <button
          @click="goBack"
          class="flex items-center gap-2 px-4 py-2 text-slate-600 dark:text-slate-300 hover:text-slate-800 dark:hover:text-white hover:bg-white dark:hover:bg-slate-700 rounded-lg transition"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
          Back
        </button>

        <div class="flex items-center gap-3">
          <button
            @click="showParticipantDetails = !showParticipantDetails"
            class="px-3 py-1.5 text-xs font-medium text-slate-600 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-700 rounded-md transition border border-slate-300 dark:border-slate-600"
          >
            {{ showParticipantDetails ? 'Hide' : 'Show' }} Breakdown
          </button>
          <DarkModeToggle />
          <button
            @click="printPDF"
            class="flex items-center gap-2 px-4 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-lg transition"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
            </svg>
            Print / Save PDF
          </button>
        </div>
      </div>

      <div v-if="loading" class="bg-white dark:bg-slate-800 rounded-2xl shadow-lg p-12 text-center transition-colors">
        <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mb-4"></div>
        <p class="text-slate-600 dark:text-slate-400">Loading bill...</p>
      </div>

      <div v-else-if="error" class="bg-white dark:bg-slate-800 rounded-2xl shadow-lg p-12 text-center transition-colors">
        <svg class="w-16 h-16 mx-auto text-red-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <p class="text-red-600 dark:text-red-400 font-medium">{{ error }}</p>
      </div>

      <div v-else-if="bill" id="pdf-content" class="bg-white dark:bg-slate-800 rounded-2xl shadow-lg p-8 transition-colors">
        <div class="border-b border-slate-200 dark:border-slate-700 pb-6 mb-6">
          <h1 class="text-3xl font-bold text-slate-800 dark:text-white mb-2">Bill Receipt</h1>
          <p class="text-slate-500 dark:text-slate-400">{{ formatDate(bill.created_at) }}</p>
        </div>

        <div class="mb-8">
          <h2 class="text-2xl font-semibold text-slate-800 dark:text-white mb-4">{{ bill.title }}</h2>
        </div>

        <div class="mb-8">
          <h3 class="text-lg font-semibold text-slate-700 dark:text-slate-300 mb-4">Participants</h3>
          <div class="space-y-3">
            <div
              v-for="participant in participants"
              :key="participant.id"
              class="bg-slate-50 dark:bg-slate-700 rounded-lg border border-slate-200 dark:border-slate-600 transition-colors overflow-hidden"
            >
              <div class="flex items-center justify-between p-4">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-full bg-blue-500 dark:bg-blue-600 flex items-center justify-center text-white font-semibold">
                    {{ participant.name.charAt(0).toUpperCase() }}
                  </div>
                  <span class="font-medium text-slate-800 dark:text-slate-200">{{ participant.name }}</span>
                </div>
                <span class="text-lg font-bold text-green-600 dark:text-green-400">Rp {{ formatRupiah(participant.amount) }}</span>
              </div>

              <div v-if="showParticipantDetails" class="px-4 pb-4 pt-2 border-t border-slate-200 dark:border-slate-600">
                <div class="space-y-1.5 text-xs text-slate-600 dark:text-slate-400">
                  <div class="flex justify-between">
                    <span>Share of Original Amount</span>
                    <span>Rp {{ formatRupiah(participant.amount * bill.total_amount / bill.final_amount) }}</span>
                  </div>

                  <div v-if="bill.discount_percent > 0" class="flex justify-between text-red-600 dark:text-red-400">
                    <span>Discount ({{ bill.discount_percent }}%)</span>
                    <span>- Rp {{ formatRupiah(calculateParticipantDiscount(participant.amount)) }}</span>
                  </div>

                  <div v-if="fees.length > 0" v-for="fee in fees" :key="fee.id" class="flex justify-between text-green-600 dark:text-green-400">
                    <span>{{ fee.name }}</span>
                    <span>+ Rp {{ formatRupiah(calculateParticipantFee(participant.amount, fee.amount)) }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-if="bill.transfer_method || (userPreferences && userPreferences.default_transfer_method)" class="mb-6 p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg border border-blue-200 dark:border-blue-800 transition-colors">
          <h3 class="text-md font-semibold text-slate-700 dark:text-slate-300 mb-2">Transfer To:</h3>
          <div class="text-sm text-slate-600 dark:text-slate-400 space-y-1">
            <p><span class="font-medium">Method:</span> {{ formatTransferMethod(bill.transfer_method || userPreferences?.default_transfer_method) }}</p>
            <p v-if="bill.bank_name || userPreferences?.default_bank_name"><span class="font-medium">Bank:</span> {{ bill.bank_name || userPreferences?.default_bank_name }}</p>
            <p v-if="bill.transfer_account || userPreferences?.default_transfer_account"><span class="font-medium">Account:</span> {{ bill.transfer_account || userPreferences?.default_transfer_account }}</p>
            <p v-if="bill.transfer_description || userPreferences?.default_transfer_description"><span class="font-medium">Description:</span> {{ bill.transfer_description || userPreferences?.default_transfer_description }}</p>
          </div>
        </div>

        <div class="border-t border-slate-200 dark:border-slate-700 pt-6">
          <div class="space-y-3">
            <div class="flex justify-between items-center text-slate-700 dark:text-slate-300">
              <span class="font-medium">Original Amount</span>
              <span class="text-xl font-semibold">Rp {{ formatRupiah(bill.total_amount) }}</span>
            </div>

            <div v-if="bill.discount_percent > 0" class="flex justify-between items-center text-slate-600 dark:text-slate-400">
              <span class="text-sm">
                Discount ({{ bill.discount_percent }}%
                <span v-if="bill.max_discount > 0">max Rp {{ formatRupiah(bill.max_discount) }}</span>)
              </span>
              <span class="text-sm font-medium text-red-600 dark:text-red-400">
                - Rp {{ formatRupiah(calculateDiscount()) }}
              </span>
            </div>

            <div
              v-for="fee in fees"
              :key="fee.id"
              class="flex justify-between items-center text-slate-600 dark:text-slate-400"
            >
              <span class="text-sm">{{ fee.name }}</span>
              <span class="text-sm font-medium text-green-600 dark:text-green-400">+ Rp {{ formatRupiah(fee.amount) }}</span>
            </div>

            <div class="flex justify-between items-center pt-4 border-t border-slate-200 dark:border-slate-700">
              <span class="text-lg font-bold text-slate-800 dark:text-slate-200">Final Total</span>
              <span class="text-2xl font-bold text-green-600 dark:text-green-400">Rp {{ formatRupiah(bill.final_amount) }}</span>
            </div>
          </div>
        </div>

        <div class="mt-8 pt-6 border-t border-slate-200 dark:border-slate-700 text-center text-sm text-slate-500 dark:text-slate-400">
          <p>Thank you for using Split Bill App</p>
          <p class="mt-1">Generated on {{ formatDate(new Date()) }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../supabase.js'
import DarkModeToggle from './DarkModeToggle.vue'

const router = useRouter()
const route = useRoute()

const bill = ref(null)
const participants = ref([])
const fees = ref([])
const loading = ref(true)
const error = ref('')
const showParticipantDetails = ref(true)
const userPreferences = ref(null)

const loadBill = async () => {
  loading.value = true
  error.value = ''

  try {
    const billId = route.params.id
    const shareToken = route.params.token

    let billData, billError

    if (shareToken) {
      const result = await supabase
        .from('bills')
        .select('*')
        .eq('share_token', shareToken)
        .eq('is_public', true)
        .maybeSingle()

      billData = result.data
      billError = result.error
    } else {
      const result = await supabase
        .from('bills')
        .select('*')
        .eq('id', billId)
        .maybeSingle()

      billData = result.data
      billError = result.error
    }

    if (billError) throw billError
    if (!billData) throw new Error('Bill not found')

    bill.value = billData

    const { data: participantsData, error: participantsError } = await supabase
      .from('participants')
      .select('*')
      .eq('bill_id', billData.id)
      .order('created_at', { ascending: true })

    if (participantsError) throw participantsError
    participants.value = participantsData || []

    const { data: feesData, error: feesError } = await supabase
      .from('fees')
      .select('*')
      .eq('bill_id', billData.id)
      .order('created_at', { ascending: true })

    if (feesError) throw feesError
    fees.value = feesData || []

    if (!shareToken) {
      const { data: { user } } = await supabase.auth.getUser()
      if (user) {
        const { data: prefsData } = await supabase
          .from('user_preferences')
          .select('*')
          .eq('user_id', user.id)
          .maybeSingle()

        userPreferences.value = prefsData
      }
    } else {
      const { data: prefsData } = await supabase
        .from('user_preferences')
        .select('*')
        .eq('user_id', billData.user_id)
        .maybeSingle()

      userPreferences.value = prefsData
    }
  } catch (err) {
    console.error('Error loading bill:', err)
    error.value = err.message || 'Failed to load bill'
  } finally {
    loading.value = false
  }
}

const formatRupiah = (amount) => {
  return new Intl.NumberFormat('id-ID').format(Math.round(amount))
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('id-ID', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const calculateDiscount = () => {
  if (!bill.value) return 0
  const discount = (bill.value.total_amount * bill.value.discount_percent) / 100
  if (bill.value.max_discount > 0) {
    return Math.min(discount, bill.value.max_discount)
  }
  return discount
}

const formatTransferMethod = (method) => {
  const methods = {
    bank: 'Bank Account',
    ovo: 'OVO',
    dana: 'DANA',
    gopay: 'GoPay',
    other: 'Other'
  }
  return methods[method] || method
}

const calculateParticipantDiscount = (participantAmount) => {
  if (!bill.value) return 0
  const totalDiscount = (bill.value.total_amount * bill.value.discount_percent) / 100
  const cappedDiscount = bill.value.max_discount > 0 ? Math.min(totalDiscount, bill.value.max_discount) : totalDiscount
  return (participantAmount / bill.value.final_amount) * cappedDiscount
}

const calculateParticipantFee = (participantAmount, feeAmount) => {
  if (!bill.value) return 0
  return (participantAmount / bill.value.final_amount) * feeAmount
}

const goBack = () => {
  router.push('/dashboard')
}

const printPDF = () => {
  window.print()
}

onMounted(() => {
  loadBill()
})
</script>

<style scoped>
@media print {
  .min-h-screen {
    min-height: auto;
  }

  button {
    display: none !important;
  }

  #pdf-content {
    box-shadow: none;
    border-radius: 0;
  }

  @media (prefers-color-scheme: dark) {
    .dark\:bg-slate-800 {
      background-color: rgb(30 41 59) !important;
    }
    .dark\:bg-slate-700 {
      background-color: rgb(51 65 85) !important;
    }
    .dark\:text-white {
      color: rgb(255 255 255) !important;
    }
    .dark\:text-slate-200 {
      color: rgb(226 232 240) !important;
    }
    .dark\:text-slate-300 {
      color: rgb(203 213 225) !important;
    }
    .dark\:text-slate-400 {
      color: rgb(148 163 184) !important;
    }
    .dark\:border-slate-700 {
      border-color: rgb(51 65 85) !important;
    }
    .dark\:border-slate-600 {
      border-color: rgb(71 85 105) !important;
    }
    .dark\:bg-blue-600 {
      background-color: rgb(37 99 235) !important;
    }
    .dark\:bg-blue-900\/20 {
      background-color: rgba(30 58 138 / 0.2) !important;
    }
    .dark\:border-blue-800 {
      border-color: rgb(30 64 175) !important;
    }
    .dark\:text-green-400 {
      color: rgb(74 222 128) !important;
    }
    .dark\:text-red-400 {
      color: rgb(248 113 113) !important;
    }
    body {
      background-color: rgb(30 41 59) !important;
    }
  }
}
</style>
