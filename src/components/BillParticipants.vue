<template>
  <div v-if="loading" class="text-center py-4">
    <p class="text-sm text-slate-500 dark:text-slate-400">Loading participants...</p>
  </div>

  <div v-else-if="participants.length === 0" class="text-center py-4">
    <p class="text-sm text-slate-500 dark:text-slate-400">No participants found</p>
  </div>

  <div v-else class="space-y-3">
    <div
      v-for="participant in participants"
      :key="participant.id"
      class="bg-slate-50 dark:bg-slate-700 rounded-lg transition-colors overflow-hidden"
    >
      <div class="flex items-center justify-between p-3">
        <span class="text-sm font-medium text-slate-700 dark:text-slate-300">{{ participant.name }}</span>
        <span class="text-sm font-bold text-green-600 dark:text-green-400">Rp {{ formatRupiah(participant.amount) }}</span>
      </div>

      <div v-if="bill" class="px-3 pb-3 pt-1 border-t border-slate-200 dark:border-slate-600">
        <div class="space-y-1 text-xs text-slate-600 dark:text-slate-400">
          <div class="flex justify-between">
            <span>Share of Original Amount</span>
            <span>Rp {{ formatRupiah(participant.original_amount || (participant.amount * bill.total_amount / bill.final_amount)) }}</span>
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
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '../supabase.js'

const props = defineProps({
  billId: {
    type: String,
    required: true
  }
})

const participants = ref([])
const bill = ref(null)
const fees = ref([])
const loading = ref(false)

const loadParticipants = async () => {
  loading.value = true
  try {
    const [participantsResult, billResult, feesResult] = await Promise.all([
      supabase
        .from('participants')
        .select('*')
        .eq('bill_id', props.billId)
        .order('created_at', { ascending: true }),
      supabase
        .from('bills')
        .select('*')
        .eq('id', props.billId)
        .maybeSingle(),
      supabase
        .from('fees')
        .select('*')
        .eq('bill_id', props.billId)
        .order('created_at', { ascending: true })
    ])

    if (participantsResult.error) throw participantsResult.error
    if (billResult.error) throw billResult.error
    if (feesResult.error) throw feesResult.error

    participants.value = participantsResult.data || []
    bill.value = billResult.data
    fees.value = feesResult.data || []
  } catch (error) {
    console.error('Error loading participants:', error)
  } finally {
    loading.value = false
  }
}

const formatRupiah = (amount) => {
  return new Intl.NumberFormat('id-ID').format(Math.round(amount))
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

watch(() => props.billId, () => {
  loadParticipants()
})

onMounted(() => {
  loadParticipants()
})
</script>
