<template>
  <div v-if="loading" class="text-center py-4">
    <p class="text-sm text-slate-500 dark:text-slate-400">Loading participants...</p>
  </div>

  <div v-else-if="participants.length === 0" class="text-center py-4">
    <p class="text-sm text-slate-500 dark:text-slate-400">No participants found</p>
  </div>

  <div v-else class="space-y-2">
    <div
      v-for="participant in participants"
      :key="participant.id"
      class="flex items-center justify-between p-3 bg-slate-50 dark:bg-slate-700 rounded-lg transition-colors"
    >
      <span class="text-sm font-medium text-slate-700 dark:text-slate-300">{{ participant.name }}</span>
      <span class="text-sm font-bold text-green-600 dark:text-green-400">Rp {{ formatRupiah(participant.amount) }}</span>
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
const loading = ref(false)

const loadParticipants = async () => {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('participants')
      .select('*')
      .eq('bill_id', props.billId)
      .order('created_at', { ascending: true })

    if (error) throw error
    participants.value = data || []
  } catch (error) {
    console.error('Error loading participants:', error)
  } finally {
    loading.value = false
  }
}

const formatRupiah = (amount) => {
  return new Intl.NumberFormat('id-ID').format(Math.round(amount))
}

watch(() => props.billId, () => {
  loadParticipants()
})

onMounted(() => {
  loadParticipants()
})
</script>
