<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 py-8 px-4">
    <div class="max-w-4xl mx-auto">
      <div class="mb-6 flex items-center justify-between">
        <button
          @click="goBack"
          class="flex items-center gap-2 px-4 py-2 text-slate-600 hover:text-slate-800 hover:bg-white rounded-lg transition"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
          Back
        </button>

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

      <div v-if="loading" class="bg-white rounded-2xl shadow-lg p-12 text-center">
        <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mb-4"></div>
        <p class="text-slate-600">Loading bill...</p>
      </div>

      <div v-else-if="error" class="bg-white rounded-2xl shadow-lg p-12 text-center">
        <svg class="w-16 h-16 mx-auto text-red-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <p class="text-red-600 font-medium">{{ error }}</p>
      </div>

      <div v-else-if="bill" id="pdf-content" class="bg-white rounded-2xl shadow-lg p-8">
        <div class="border-b border-slate-200 pb-6 mb-6">
          <h1 class="text-3xl font-bold text-slate-800 mb-2">Bill Receipt</h1>
          <p class="text-slate-500">{{ formatDate(bill.created_at) }}</p>
        </div>

        <div class="mb-8">
          <h2 class="text-2xl font-semibold text-slate-800 mb-4">{{ bill.title }}</h2>
        </div>

        <div class="mb-8">
          <h3 class="text-lg font-semibold text-slate-700 mb-4">Participants</h3>
          <div class="space-y-3">
            <div
              v-for="participant in participants"
              :key="participant.id"
              class="flex items-center justify-between p-4 bg-slate-50 rounded-lg border border-slate-200"
            >
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center text-white font-semibold">
                  {{ participant.name.charAt(0).toUpperCase() }}
                </div>
                <span class="font-medium text-slate-800">{{ participant.name }}</span>
              </div>
              <span class="text-lg font-bold text-green-600">Rp {{ formatRupiah(participant.amount) }}</span>
            </div>
          </div>
        </div>

        <div v-if="bill.transfer_method" class="mb-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
          <h3 class="text-md font-semibold text-slate-700 mb-2">Transfer To:</h3>
          <div class="text-sm text-slate-600 space-y-1">
            <p><span class="font-medium">Method:</span> {{ formatTransferMethod(bill.transfer_method) }}</p>
            <p v-if="bill.bank_name"><span class="font-medium">Bank:</span> {{ bill.bank_name }}</p>
            <p v-if="bill.transfer_account"><span class="font-medium">Account:</span> {{ bill.transfer_account }}</p>
            <p v-if="bill.transfer_description"><span class="font-medium">Description:</span> {{ bill.transfer_description }}</p>
          </div>
        </div>

        <div class="border-t border-slate-200 pt-6">
          <div class="space-y-3">
            <div class="flex justify-between items-center text-slate-700">
              <span class="font-medium">Original Amount</span>
              <span class="text-xl font-semibold">Rp {{ formatRupiah(bill.total_amount) }}</span>
            </div>

            <div v-if="bill.discount_percent > 0" class="flex justify-between items-center text-slate-600">
              <span class="text-sm">
                Discount ({{ bill.discount_percent }}%
                <span v-if="bill.max_discount > 0">max Rp {{ formatRupiah(bill.max_discount) }}</span>)
              </span>
              <span class="text-sm font-medium text-red-600">
                - Rp {{ formatRupiah(calculateDiscount()) }}
              </span>
            </div>

            <div
              v-for="fee in fees"
              :key="fee.id"
              class="flex justify-between items-center text-slate-600"
            >
              <span class="text-sm">{{ fee.name }}</span>
              <span class="text-sm font-medium text-green-600">+ Rp {{ formatRupiah(fee.amount) }}</span>
            </div>

            <div class="flex justify-between items-center pt-4 border-t border-slate-200">
              <span class="text-lg font-bold text-slate-800">Final Total</span>
              <span class="text-2xl font-bold text-green-600">Rp {{ formatRupiah(bill.final_amount) }}</span>
            </div>
          </div>
        </div>

        <div class="mt-8 pt-6 border-t border-slate-200 text-center text-sm text-slate-500">
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

const router = useRouter()
const route = useRoute()

const bill = ref(null)
const participants = ref([])
const fees = ref([])
const loading = ref(true)
const error = ref('')

const loadBill = async () => {
  loading.value = true
  error.value = ''

  try {
    const billId = route.params.id

    const { data: billData, error: billError } = await supabase
      .from('bills')
      .select('*')
      .eq('id', billId)
      .maybeSingle()

    if (billError) throw billError
    if (!billData) throw new Error('Bill not found')

    bill.value = billData

    const { data: participantsData, error: participantsError } = await supabase
      .from('participants')
      .select('*')
      .eq('bill_id', billId)
      .order('created_at', { ascending: true })

    if (participantsError) throw participantsError
    participants.value = participantsData || []

    const { data: feesData, error: feesError } = await supabase
      .from('fees')
      .select('*')
      .eq('bill_id', billId)
      .order('created_at', { ascending: true })

    if (feesError) throw feesError
    fees.value = feesData || []
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
}
</style>
