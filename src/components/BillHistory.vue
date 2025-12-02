<template>
  <div class="bg-white dark:bg-slate-800 rounded-2xl shadow-lg p-6 transition-colors">
    <div class="flex items-center justify-between mb-6">
      <h2 class="text-2xl font-semibold text-slate-800 dark:text-white">Bill History</h2>
      <button
        @click="$emit('refresh')"
        class="p-2 text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700 rounded-lg transition"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        </svg>
      </button>
    </div>

    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      <p class="text-slate-600 mt-4">Loading bills...</p>
    </div>

    <div v-else-if="bills.length === 0" class="text-center py-12">
      <svg class="w-16 h-16 mx-auto text-slate-300 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
      </svg>
      <p class="text-slate-600 dark:text-slate-300 font-medium">No bills yet</p>
      <p class="text-slate-500 dark:text-slate-400 text-sm mt-2">Create your first bill to get started</p>
    </div>

    <div v-else class="space-y-4">
      <div
        v-for="bill in bills"
        :key="bill.id"
        class="bill-card border border-slate-200 dark:border-slate-700 rounded-xl p-5 hover:border-blue-300 dark:hover:border-blue-600 hover:shadow-md transition bg-white dark:bg-slate-700/50 relative"
      >
        <div class="flex flex-col sm:flex-row items-start sm:justify-between mb-3 gap-2">
          <div @click="toggleBill(bill)" class="cursor-pointer flex-1">
            <h3 class="text-lg font-semibold text-slate-800 dark:text-white">{{ bill.title }}</h3>
            <p class="text-sm text-slate-500 dark:text-slate-400">{{ formatDate(bill.created_at) }}</p>
            <div v-if="bill.payment_status" class="mt-1 text-xs text-slate-600 dark:text-slate-400">
              <span :class="bill.payment_status.all_paid ? 'text-green-600 dark:text-green-400 font-medium' : ''">
                {{ bill.payment_status.paid_count }} / {{ bill.payment_status.total_count }} paid
              </span>
            </div>
          </div>
          <div class="text-left sm:text-right">
            <p class="text-sm text-slate-600 dark:text-slate-400">Final Total</p>
            <p class="text-xl font-bold text-green-600">{{ getCurrencySymbol(bill.currency) }} {{ formatRupiah(bill.final_amount, bill.currency) }}</p>
            <div v-if="bill.payment_status?.all_paid" class="mt-2 transform rotate-3">
              <div class="inline-block border-4 border-green-600 rounded-lg px-4 py-1.5 bg-green-50 dark:bg-green-900/30 shadow-md">
                <span class="text-lg font-black text-green-600 tracking-widest">PAID</span>
              </div>
            </div>
          </div>
        </div>

        <div class="space-y-2 mb-3">
          <div class="flex gap-4 text-sm flex-wrap">
            <div>
              <span class="text-slate-500 dark:text-slate-400">Original:</span>
              <span class="font-medium text-slate-700 dark:text-slate-300 ml-1">{{ getCurrencySymbol(bill.currency) }} {{ formatRupiah(bill.total_amount, bill.currency) }}</span>
            </div>
            <div v-if="bill.discount_percent > 0">
              <span class="text-slate-500 dark:text-slate-400">Discount:</span>
              <span class="font-medium text-red-600 ml-1">{{ bill.discount_percent }}%</span>
            </div>
            <div v-if="bill.max_discount > 0">
              <span class="text-slate-500 dark:text-slate-400">Max:</span>
              <span class="font-medium text-slate-700 dark:text-slate-300 ml-1">{{ getCurrencySymbol(bill.currency) }} {{ formatRupiah(bill.max_discount, bill.currency) }}</span>
            </div>
          </div>
          <div v-if="bill.fees && bill.fees.length > 0" class="flex gap-4 text-sm flex-wrap">
            <div v-for="fee in bill.fees" :key="fee.id">
              <span class="text-slate-500 dark:text-slate-400">{{ fee.name }}:</span>
              <span class="font-medium text-green-600 ml-1">{{ getCurrencySymbol(bill.currency) }} {{ formatRupiah(fee.amount, bill.currency) }}</span>
            </div>
          </div>
        </div>

        <div class="flex flex-col sm:flex-row gap-2">
          <button
            @click="viewPDF(bill.id)"
            class="flex-1 py-2 px-4 bg-blue-500 hover:bg-blue-600 text-white font-medium rounded-lg transition flex items-center justify-center gap-2"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <span class="hidden sm:inline">View PDF</span>
            <span class="sm:hidden">View</span>
          </button>
          <button
            @click="toggleShareLink(bill)"
            class="flex-1 py-2 px-4 bg-green-500 hover:bg-green-600 text-white font-medium rounded-lg transition flex items-center justify-center gap-2"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
            </svg>
            <span class="hidden sm:inline">Share</span>
            <span class="sm:hidden">Share</span>
          </button>
          <button
            @click="confirmDelete(bill)"
            class="sm:flex-none py-2 px-4 bg-red-500 hover:bg-red-600 text-white font-medium rounded-lg transition flex items-center justify-center gap-2"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
            <span class="sm:hidden">Delete</span>
          </button>
        </div>

        <div v-if="bill.shareLink" class="mt-3 p-3 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg">
          <p class="text-xs text-green-800 dark:text-green-300 font-medium mb-2">Shareable Link (Anyone with this link can view)</p>
          <div class="flex gap-2">
            <input
              :value="bill.shareLink"
              readonly
              class="flex-1 px-3 py-2 text-xs bg-white dark:bg-slate-800 border border-green-300 dark:border-green-700 rounded text-slate-700 dark:text-slate-300"
            />
            <button
              @click="copyShareLink(bill.shareLink)"
              class="px-3 py-2 bg-green-600 hover:bg-green-700 text-white rounded transition text-xs font-medium"
            >
              Copy
            </button>
            <button
              @click="disableShareLink(bill)"
              class="px-3 py-2 bg-red-600 hover:bg-red-700 text-white rounded transition text-xs font-medium"
            >
              Disable
            </button>
          </div>
        </div>

        <div v-if="selectedBill?.id === bill.id" class="mt-4 pt-4 border-t border-slate-200 dark:border-slate-600 space-y-4">
          <div>
            <p class="text-sm font-medium text-slate-700 dark:text-slate-300 mb-3">Participants:</p>
            <div class="space-y-2">
              <BillParticipants :bill-id="bill.id" />
            </div>
          </div>

          <div v-if="bill.transfer_method" class="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-3 sm:p-4">
            <p class="text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">Transfer Details:</p>
            <div class="text-sm text-slate-600 dark:text-slate-400 space-y-1">
              <p><span class="font-medium">Method:</span> {{ formatTransferMethod(bill.transfer_method) }}</p>
              <p v-if="bill.bank_name"><span class="font-medium">Bank:</span> {{ bill.bank_name }}</p>
              <p v-if="bill.transfer_account"><span class="font-medium">Account:</span> {{ bill.transfer_account }}</p>
              <p v-if="bill.transfer_description"><span class="font-medium">Description:</span> {{ bill.transfer_description }}</p>
            </div>
          </div>

          <PaymentVerification :bill-id="bill.id" :currency-format="bill.currency || currencyFormat" />
        </div>
      </div>
    </div>

    <div
      v-if="showDeleteModal"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click.self="cancelDelete"
    >
      <div class="bg-white dark:bg-slate-800 rounded-2xl shadow-2xl max-w-md w-full p-6 transition-colors">
        <div class="flex items-center gap-3 mb-4">
          <div class="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center">
            <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
          </div>
          <div>
            <h3 class="text-xl font-bold text-slate-800 dark:text-white">Delete Bill?</h3>
            <p class="text-sm text-slate-600 dark:text-slate-400">This action cannot be undone</p>
          </div>
        </div>

        <div class="bg-slate-50 dark:bg-slate-700 rounded-lg p-4 mb-6 transition-colors">
          <p class="text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">{{ billToDelete?.title }}</p>
          <p class="text-xs text-slate-500 dark:text-slate-400">{{ formatDate(billToDelete?.created_at) }}</p>
          <p class="text-sm font-semibold text-green-600 mt-2">{{ getCurrencySymbol(billToDelete?.currency) }} {{ formatRupiah(billToDelete?.final_amount, billToDelete?.currency) }}</p>
        </div>

        <div class="flex gap-3">
          <button
            @click="cancelDelete"
            :disabled="isDeleting"
            class="flex-1 py-2.5 px-4 bg-slate-200 dark:bg-slate-700 hover:bg-slate-300 dark:hover:bg-slate-600 text-slate-700 dark:text-slate-300 font-medium rounded-lg transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Cancel
          </button>
          <button
            @click="deleteBill"
            :disabled="isDeleting"
            class="flex-1 py-2.5 px-4 bg-red-500 hover:bg-red-600 text-white font-medium rounded-lg transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            <span v-if="isDeleting" class="inline-block animate-spin rounded-full h-4 w-4 border-b-2 border-white"></span>
            {{ isDeleting ? 'Deleting...' : 'Delete' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../supabase.js'
import BillParticipants from './BillParticipants.vue'
import PaymentVerification from './PaymentVerification.vue'

const router = useRouter()

const props = defineProps({
  bills: {
    type: Array,
    required: true
  },
  loading: {
    type: Boolean,
    default: false
  },
  currencyFormat: {
    type: String,
    default: 'IDR'
  }
})

const emit = defineEmits(['refresh'])

const selectedBill = ref(null)
const billToDelete = ref(null)
const showDeleteModal = ref(false)
const isDeleting = ref(false)
const billRefs = ref([])

const getCurrencySymbol = (currency) => {
  if (currency) {
    return currency === 'USD' ? '$' : 'Rp'
  }
  return props.currencyFormat === 'USD' ? '$' : 'Rp'
}

const formatRupiah = (amount, currency) => {
  if (currency) {
    if (currency === 'USD') {
      return new Intl.NumberFormat('en-US').format(Math.round(amount))
    }
    return new Intl.NumberFormat('id-ID').format(Math.round(amount))
  }

  if (props.currencyFormat === 'USD') {
    return new Intl.NumberFormat('en-US').format(Math.round(amount))
  }
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

const toggleBill = (bill) => {
  if (selectedBill.value?.id === bill.id) {
    selectedBill.value = null
    emit('refresh')
  } else {
    selectedBill.value = bill
  }
}

const handleClickOutside = (event) => {
  if (!selectedBill.value) return

  const clickedElement = event.target
  const isClickOnBillCard = clickedElement.closest('.bill-card')

  if (!isClickOnBillCard && !showDeleteModal.value) {
    selectedBill.value = null
    emit('refresh')
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})

const viewPDF = (billId) => {
  router.push(`/bill/${billId}`)
}

const confirmDelete = (bill) => {
  billToDelete.value = bill
  showDeleteModal.value = true
}

const cancelDelete = () => {
  billToDelete.value = null
  showDeleteModal.value = false
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

const generateShareToken = () => {
  return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15)
}

const toggleShareLink = async (bill) => {
  if (bill.shareLink) {
    return
  }

  try {
    const shareToken = generateShareToken()
    const { error } = await supabase
      .from('bills')
      .update({
        is_public: true,
        share_token: shareToken
      })
      .eq('id', bill.id)

    if (error) throw error

    const shareLink = `${window.location.origin}/share/${shareToken}`
    bill.shareLink = shareLink
    bill.is_public = true
    bill.share_token = shareToken
  } catch (error) {
    console.error('Error generating share link:', error)
    alert('Failed to generate share link')
  }
}

const copyShareLink = async (link) => {
  try {
    await navigator.clipboard.writeText(link)
    alert('Link copied to clipboard!')
  } catch (error) {
    console.error('Error copying link:', error)
    alert('Failed to copy link')
  }
}

const disableShareLink = async (bill) => {
  try {
    const { error } = await supabase
      .from('bills')
      .update({
        is_public: false,
        share_token: null
      })
      .eq('id', bill.id)

    if (error) throw error

    bill.shareLink = null
    bill.is_public = false
    bill.share_token = null
  } catch (error) {
    console.error('Error disabling share link:', error)
    alert('Failed to disable share link')
  }
}

const deleteBill = async () => {
  if (!billToDelete.value) return

  isDeleting.value = true
  try {
    const { error } = await supabase
      .from('bills')
      .delete()
      .eq('id', billToDelete.value.id)

    if (error) throw error

    showDeleteModal.value = false
    billToDelete.value = null
    emit('refresh')
  } catch (error) {
    console.error('Error deleting bill:', error)
    alert('Failed to delete bill. Please try again.')
  } finally {
    isDeleting.value = false
  }
}
</script>
