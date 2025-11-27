<template>
  <div class="bg-white dark:bg-slate-800 rounded-xl shadow-lg p-4 sm:p-6 transition-colors">
    <h3 class="text-lg font-semibold text-slate-800 dark:text-white mb-4">Payment Status</h3>

    <div v-if="loading" class="text-center py-4">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
      <p class="text-sm text-slate-600 dark:text-slate-400 mt-2">Loading...</p>
    </div>

    <div v-else class="space-y-3">
      <div
        v-for="participant in participants"
        :key="participant.id"
        class="flex items-center justify-between p-3 sm:p-4 bg-slate-50 dark:bg-slate-700 rounded-lg transition-colors"
      >
        <div class="flex items-center gap-3 flex-1">
          <button
            @click="togglePayment(participant)"
            class="flex-shrink-0 w-6 h-6 rounded border-2 transition-all flex items-center justify-center"
            :class="participant.paid ? 'bg-green-500 border-green-500' : 'border-slate-300 dark:border-slate-500 hover:border-green-500'"
          >
            <svg
              v-if="participant.paid"
              class="w-4 h-4 text-white"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
            </svg>
          </button>
          <div class="flex-1 min-w-0">
            <p class="font-medium text-slate-800 dark:text-white truncate">{{ participant.name }}</p>
            <p class="text-xs text-slate-500 dark:text-slate-400">
              {{ getCurrencySymbol() }} {{ formatAmount(participant.amount) }}
            </p>
          </div>
        </div>
        <div v-if="participant.paid" class="flex-shrink-0 ml-2">
          <span class="text-xs text-green-600 dark:text-green-400 font-medium">Paid</span>
        </div>
      </div>

      <div class="pt-3 border-t border-slate-200 dark:border-slate-600">
        <div class="flex justify-between items-center text-sm">
          <span class="text-slate-600 dark:text-slate-400">Payment Progress</span>
          <span class="font-semibold text-slate-800 dark:text-white">{{ paidCount }} / {{ participants.length }}</span>
        </div>
        <div class="w-full bg-slate-200 dark:bg-slate-600 rounded-full h-2 mt-2">
          <div
            class="bg-green-500 h-2 rounded-full transition-all duration-300"
            :style="{ width: progressPercentage + '%' }"
          ></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../supabase.js'

const props = defineProps({
  billId: {
    type: String,
    required: true
  },
  currencyFormat: {
    type: String,
    default: 'IDR'
  }
})

const emit = defineEmits(['payment-updated'])

const participants = ref([])
const loading = ref(false)

const paidCount = computed(() => {
  return participants.value.filter(p => p.paid).length
})

const progressPercentage = computed(() => {
  if (participants.value.length === 0) return 0
  return (paidCount.value / participants.value.length) * 100
})

const getCurrencySymbol = () => {
  return props.currencyFormat === 'USD' ? '$' : 'Rp'
}

const formatAmount = (amount) => {
  if (props.currencyFormat === 'USD') {
    return new Intl.NumberFormat('en-US').format(Math.round(amount))
  }
  return new Intl.NumberFormat('id-ID').format(Math.round(amount))
}

const loadParticipants = async () => {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('participants')
      .select('*')
      .eq('bill_id', props.billId)
      .order('created_at', { ascending: true })

    if (error) throw error

    participants.value = (data || []).map(p => ({
      ...p,
      paid: false
    }))

    try {
      const { data: paymentsData } = await supabase
        .from('participant_payments')
        .select('*')
        .eq('bill_id', props.billId)

      if (paymentsData) {
        const paymentMap = new Map(paymentsData.map(p => [p.participant_id, p.paid]))
        participants.value = participants.value.map(p => ({
          ...p,
          paid: paymentMap.get(p.id) || false
        }))
      }
    } catch (err) {
      console.log('Payment tracking not available yet')
    }
  } catch (error) {
    console.error('Error loading participants:', error)
  } finally {
    loading.value = false
  }
}

const togglePayment = async (participant) => {
  const newPaidStatus = !participant.paid

  try {
    const { data: existing, error: selectError } = await supabase
      .from('participant_payments')
      .select('id')
      .eq('participant_id', participant.id)
      .maybeSingle()

    if (selectError) {
      console.error('Error checking existing payment:', selectError)
      return
    }

    let result
    if (existing) {
      result = await supabase
        .from('participant_payments')
        .update({
          paid: newPaidStatus,
          paid_at: newPaidStatus ? new Date().toISOString() : null,
          updated_at: new Date().toISOString()
        })
        .eq('participant_id', participant.id)
    } else {
      result = await supabase
        .from('participant_payments')
        .insert({
          participant_id: participant.id,
          bill_id: props.billId,
          paid: newPaidStatus,
          paid_at: newPaidStatus ? new Date().toISOString() : null
        })
    }

    if (result.error) {
      console.error('Error saving payment status:', result.error)
      alert('Failed to save payment status. Please try again.')
      return
    }

    participant.paid = newPaidStatus

    emit('payment-updated')
  } catch (error) {
    console.error('Error updating payment status:', error)
    alert('Failed to save payment status. Please try again.')
  }
}

onMounted(() => {
  loadParticipants()
})
</script>
