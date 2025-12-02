<template>
  <div class="bg-white dark:bg-slate-800 rounded-lg sm:rounded-2xl shadow-lg p-3 sm:p-6 mb-3 sm:mb-6 transition-colors">
    <div class="mb-4 sm:mb-6">
      <div class="flex items-center justify-between mb-3">
        <h3 class="text-sm sm:text-base font-semibold text-slate-800 dark:text-white">Scan Bill</h3>
        <button
          @click="triggerFileInput"
          class="flex items-center gap-2 px-3 py-1.5 sm:px-4 sm:py-2 bg-blue-500 hover:bg-blue-600 text-white text-xs sm:text-sm font-medium rounded-lg transition"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          Scan Receipt
        </button>
      </div>
      <input
        ref="fileInput"
        type="file"
        accept="image/*"
        capture="environment"
        @change="handleImageUpload"
        class="hidden"
      />
      <div v-if="isProcessing" class="flex items-center justify-center gap-2 py-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
        <div class="animate-spin rounded-full h-5 w-5 border-b-2 border-blue-500"></div>
        <span class="text-xs sm:text-sm text-blue-700 dark:text-blue-300">Processing image...</span>
      </div>
      <div v-if="ocrError" class="py-2 px-3 bg-red-50 dark:bg-red-900/20 rounded-lg text-xs sm:text-sm text-red-700 dark:text-red-300">
        {{ ocrError }}
      </div>
    </div>

    <div class="space-y-3 sm:space-y-4 mb-4 sm:mb-6">
      <div>
        <label class="block text-xs sm:text-sm font-medium text-slate-700 dark:text-slate-300 mb-1 sm:mb-2">
          Bill Name
        </label>
        <input
          v-model="billTitle"
          type="text"
          placeholder="e.g., Dinner at Pizza Place"
          class="w-full px-3 py-2 sm:px-4 sm:py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-lg sm:rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-sm sm:text-base text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-slate-500"
        />
      </div>

      <div v-if="!useIndividualAmounts">
        <label class="block text-xs sm:text-sm font-medium text-slate-700 dark:text-slate-300 mb-1 sm:mb-2">
          Total Amount ({{ getCurrencySymbol() }})
        </label>
        <input
          :value="formatNumberInput(totalAmount)"
          @input="handleTotalAmountInput"
          type="text"
          placeholder="0"
          class="w-full px-3 py-2 sm:px-4 sm:py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-lg sm:rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-sm sm:text-base text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-slate-500"
        />
      </div>

      <div>
        <label class="flex items-center gap-2 cursor-pointer">
          <input
            v-model="useIndividualAmounts"
            type="checkbox"
            class="w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
          />
          <span class="text-xs sm:text-sm font-medium text-slate-700 dark:text-slate-300">Each person has different amount</span>
        </label>
      </div>

      <div class="pt-3 sm:pt-4 border-t border-slate-200 dark:border-slate-600">
        <label class="block text-xs sm:text-sm font-medium text-slate-700 dark:text-slate-300 mb-2 sm:mb-3">
          Transfer To (Optional)
        </label>
        <div class="space-y-2 sm:space-y-3">
          <select
            v-model="transferMethod"
            class="w-full px-3 py-2 sm:px-4 sm:py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-lg sm:rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-sm sm:text-base text-slate-800 dark:text-white"
          >
            <option value="">Select payment method</option>
            <option value="bank">Bank Account</option>
            <option value="ovo">OVO</option>
            <option value="dana">DANA</option>
            <option value="gopay">GoPay</option>
            <option value="other">Other</option>
          </select>

          <input
            v-if="transferMethod === 'bank'"
            v-model="bankName"
            type="text"
            placeholder="Bank Name (e.g., BCA, Mandiri, BNI)"
            class="w-full px-3 py-2 sm:px-4 sm:py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-lg sm:rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-sm sm:text-base text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-slate-500"
          />

          <input
            v-if="transferMethod"
            v-model="transferAccount"
            type="text"
            :placeholder="transferMethod === 'bank' ? 'Account Number' : `${transferMethod.toUpperCase()} Number`"
            class="w-full px-3 py-2 sm:px-4 sm:py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-lg sm:rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-sm sm:text-base text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-slate-500"
          />

          <input
            v-if="transferMethod === 'other'"
            v-model="transferDescription"
            type="text"
            placeholder="Description (e.g., Cash, PayPal)"
            class="w-full px-3 py-2 sm:px-4 sm:py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-lg sm:rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-sm sm:text-base text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-slate-500"
          />
        </div>
      </div>

      <div>
        <label class="block text-xs sm:text-sm font-medium text-slate-700 dark:text-slate-300 mb-1 sm:mb-2">
          Discount Voucher
        </label>
        <div class="flex gap-2 sm:gap-3">
          <div class="flex-1">
            <input
              v-model.number="discountPercent"
              type="number"
              min="0"
              max="100"
              placeholder="Discount %"
              class="w-full px-3 py-2 sm:px-4 sm:py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-lg sm:rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-sm sm:text-base text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-slate-500"
            />
          </div>
          <div class="flex-1">
            <input
              :value="formatNumberInput(maxDiscount)"
              @input="handleMaxDiscountInput"
              type="text"
:placeholder="`Max Discount (${getCurrencySymbol()})`"
              class="w-full px-3 py-2 sm:px-4 sm:py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-lg sm:rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-sm sm:text-base text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-slate-500"
            />
          </div>
        </div>
      </div>

      <div>
        <div class="flex items-center justify-between mb-1 sm:mb-2">
          <label class="block text-xs sm:text-sm font-medium text-slate-700 dark:text-slate-300">
            Additional Fees (Optional)
          </label>
          <span class="text-xs text-slate-500 dark:text-slate-400">{{ fees.length }} fee{{ fees.length !== 1 ? 's' : '' }}</span>
        </div>
        <div class="space-y-2 sm:space-y-3 mb-2 sm:mb-3">
          <div
            v-for="(fee, index) in fees"
            :key="index"
            class="flex gap-2 sm:gap-3 p-2 sm:p-3 bg-slate-50 dark:bg-slate-700 rounded-lg sm:rounded-xl transition-colors"
          >
            <input
              v-model="fee.name"
              type="text"
              placeholder="Fee Name (e.g., Delivery, Tax)"
              class="flex-1 px-2 py-1.5 sm:px-4 sm:py-2 bg-white dark:bg-slate-600 border border-slate-200 dark:border-slate-500 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-sm sm:text-base text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-slate-400"
            />
            <input
              :value="formatNumberInput(fee.amount)"
              @input="(e) => handleFeeAmountInput(e, index)"
              type="text"
              :placeholder="`Amount (${getCurrencySymbol()})`"
              class="w-24 sm:w-32 px-2 py-1.5 sm:px-4 sm:py-2 bg-white dark:bg-slate-600 border border-slate-200 dark:border-slate-500 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-sm sm:text-base text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-slate-400"
            />
            <button
              @click="removeFee(index)"
              class="p-2 text-red-500 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/30 rounded-lg transition"
              :disabled="fees.length <= 1"
              :class="{ 'opacity-40 cursor-not-allowed': fees.length <= 1 }"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </button>
          </div>
        </div>
        <button
          @click="addFee"
          class="w-full py-1.5 sm:py-2 px-3 sm:px-4 bg-slate-100 dark:bg-slate-700 hover:bg-slate-200 dark:hover:bg-slate-600 text-slate-700 dark:text-slate-300 font-medium rounded-lg transition flex items-center justify-center gap-2 text-xs sm:text-sm"
        >
          <svg class="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
          </svg>
          Add Fee
        </button>
      </div>
    </div>

    <div class="mb-4 sm:mb-6">
      <div class="flex items-center justify-between mb-3 sm:mb-4">
        <h2 class="text-base sm:text-xl font-semibold text-slate-800 dark:text-white">People</h2>
        <span class="text-xs sm:text-sm text-slate-600 dark:text-slate-400">{{ participants.length }} person{{ participants.length !== 1 ? 's' : '' }}</span>
      </div>

      <div class="space-y-2 sm:space-y-3 mb-3 sm:mb-4">
        <div
          v-for="(participant, index) in participants"
          :key="index"
          class="flex items-center gap-2 sm:gap-3 p-2 sm:p-4 bg-slate-50 dark:bg-slate-700 rounded-lg sm:rounded-xl transition hover:bg-slate-100 dark:hover:bg-slate-600"
        >
          <div class="flex-1">
            <input
              v-model="participant.name"
              type="text"
              :placeholder="`Person ${index + 1}`"
              class="w-full px-2 py-1.5 sm:px-3 sm:py-2 bg-white dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-xs sm:text-sm text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-slate-500 mb-1.5 sm:mb-2"
            />
            <input
              v-if="useIndividualAmounts"
              :value="formatNumberInput(participant.amount)"
              @input="(e) => handleParticipantAmountInput(e, index)"
              type="text"
              :placeholder="`Amount (${getCurrencySymbol()})`"
              class="w-full px-2 py-1.5 sm:px-3 sm:py-2 bg-white dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-xs sm:text-sm text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-slate-500"
            />
          </div>
          <button
            @click="removeParticipant(index)"
            class="p-1.5 sm:p-2 text-red-500 hover:bg-red-50 rounded-lg transition"
            :disabled="participants.length <= 1"
            :class="{ 'opacity-40 cursor-not-allowed': participants.length <= 1 }"
          >
            <svg class="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
          </button>
        </div>
      </div>

      <button
        @click="addParticipant"
        class="w-full py-2 sm:py-3 bg-blue-500 hover:bg-blue-600 text-white font-medium rounded-lg sm:rounded-xl transition flex items-center justify-center gap-2 text-xs sm:text-sm"
      >
        <svg class="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
        </svg>
        Add Person
      </button>
    </div>

    <div class="mb-4 sm:mb-6">
      <h2 class="text-base sm:text-xl font-semibold text-slate-800 dark:text-white mb-3 sm:mb-4">Split Result</h2>

      <div v-if="participants.length > 0 && calculatedTotalAmount > 0" class="space-y-2 sm:space-y-3">
        <div
          v-for="(participant, index) in participants"
          :key="index"
          class="flex items-center justify-between p-2.5 sm:p-4 bg-gradient-to-r from-green-50 to-emerald-50 dark:from-green-900/20 dark:to-emerald-900/20 rounded-lg sm:rounded-xl transition-colors"
        >
          <div>
            <p class="text-sm sm:text-base font-medium text-slate-800 dark:text-white">
              {{ participant.name || `Person ${index + 1}` }}
            </p>
            <p class="text-xs text-slate-600 dark:text-slate-400">owes</p>
          </div>
          <div class="text-right">
            <p class="text-lg sm:text-2xl font-bold text-green-600 dark:text-green-400">
              {{ getCurrencySymbol() }} {{ formatRupiah(getPersonFinalAmount(participant, index)) }}
            </p>
            <p v-if="useIndividualAmounts && actualDiscount > 0" class="text-xs text-slate-500 dark:text-slate-400 mt-1">
              ({{ formatRupiah(participant.amount || 0) }} - {{ formatRupiah(getPersonDiscount(participant)) }})
            </p>
          </div>
        </div>

        <div class="pt-3 sm:pt-4 border-t border-slate-200 dark:border-slate-700">
          <div class="flex justify-between items-center">
            <span class="text-xs sm:text-sm text-slate-600 dark:text-slate-400 font-medium">Original Amount</span>
            <span class="text-base sm:text-xl font-bold text-slate-800 dark:text-white">{{ getCurrencySymbol() }} {{ formatRupiah(calculatedTotalAmount) }}</span>
          </div>
          <div v-if="actualDiscount > 0" class="flex justify-between items-center mt-1.5 sm:mt-2">
            <span class="text-xs sm:text-sm text-slate-500 dark:text-slate-400">Discount ({{ discountPercent }}% max {{ getCurrencySymbol() }} {{ formatRupiah(maxDiscount) }})</span>
            <span class="text-xs sm:text-sm font-medium text-red-600 dark:text-red-400">- {{ getCurrencySymbol() }} {{ formatRupiah(actualDiscount) }}</span>
          </div>
          <template v-for="(fee, index) in fees" :key="index">
            <div
              v-if="fee.name && fee.amount > 0"
              class="flex justify-between items-center mt-1.5 sm:mt-2"
            >
              <span class="text-xs sm:text-sm text-slate-500 dark:text-slate-400">{{ fee.name }}</span>
              <span class="text-xs sm:text-sm font-medium text-green-600 dark:text-green-400">+ {{ getCurrencySymbol() }} {{ formatRupiah(fee.amount) }}</span>
            </div>
          </template>
          <div class="flex justify-between items-center mt-2 sm:mt-3 pt-2 sm:pt-3 border-t border-slate-200 dark:border-slate-700">
            <span class="text-xs sm:text-sm text-slate-600 dark:text-slate-400 font-medium">Final Total</span>
            <span class="text-base sm:text-2xl font-bold text-green-600 dark:text-green-400">{{ getCurrencySymbol() }} {{ formatRupiah(finalAmount) }}</span>
          </div>
        </div>
      </div>

      <div v-else class="text-center py-8">
        <svg class="w-16 h-16 mx-auto text-slate-300 dark:text-slate-600 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <p class="text-slate-500 dark:text-slate-400">Enter an amount to see the split</p>
      </div>
    </div>

    <div class="flex gap-2 sm:gap-3">
      <button
        @click="saveBill"
        :disabled="!billTitle || calculatedTotalAmount <= 0 || participants.length === 0 || isSaving"
        class="flex-1 py-2.5 sm:py-4 bg-green-500 hover:bg-green-600 text-white text-sm sm:text-base font-semibold rounded-lg sm:rounded-xl transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
      >
        <svg v-if="!isSaving" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4" />
        </svg>
        <span v-if="isSaving">Saving...</span>
        <span v-else>Save Bill</span>
      </button>

      <button
        @click="resetBill"
        class="flex-1 py-2.5 sm:py-4 bg-slate-200 dark:bg-slate-700 hover:bg-slate-300 dark:hover:bg-slate-600 text-slate-700 dark:text-slate-300 text-sm sm:text-base font-semibold rounded-lg sm:rounded-xl transition flex items-center justify-center gap-2"
      >
        <svg class="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        </svg>
        Reset
      </button>
    </div>

    <div v-if="savedMessage" class="mt-4 p-4 bg-green-50 dark:bg-green-900/30 border border-green-200 dark:border-green-700 rounded-xl">
      <p class="text-green-800 dark:text-green-400 text-center font-medium">{{ savedMessage }}</p>
    </div>

    <div v-if="errorMessage" class="mt-4 p-4 bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-700 rounded-xl">
      <p class="text-red-800 dark:text-red-400 text-center font-medium">{{ errorMessage }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../supabase.js'
import { createWorker } from 'tesseract.js'

const router = useRouter()
const emit = defineEmits(['bill-saved'])

const props = defineProps({
  currencyFormat: {
    type: String,
    default: 'IDR'
  }
})

const billTitle = ref('')
const totalAmount = ref(0)
const discountPercent = ref(0)
const maxDiscount = ref(0)
const fees = ref([{ name: '', amount: 0 }])
const useIndividualAmounts = ref(false)
const participants = ref([{ name: '', amount: 0 }, { name: '', amount: 0 }])
const transferMethod = ref('')
const bankName = ref('')
const transferAccount = ref('')
const transferDescription = ref('')
const isSaving = ref(false)
const savedMessage = ref('')
const errorMessage = ref('')
const isProcessing = ref(false)
const ocrError = ref('')
const fileInput = ref(null)

const calculatedTotalAmount = computed(() => {
  if (useIndividualAmounts.value) {
    return participants.value.reduce((sum, p) => sum + (p.amount || 0), 0)
  }
  return totalAmount.value
})

const actualDiscount = computed(() => {
  if (calculatedTotalAmount.value <= 0) return 0

  if (maxDiscount.value > 0 && discountPercent.value > 0) {
    const calculatedDiscount = (calculatedTotalAmount.value * discountPercent.value) / 100
    return Math.min(calculatedDiscount, maxDiscount.value)
  }

  if (maxDiscount.value > 0) {
    return maxDiscount.value
  }

  if (discountPercent.value > 0) {
    return (calculatedTotalAmount.value * discountPercent.value) / 100
  }

  return 0
})

const totalFees = computed(() => {
  return fees.value.reduce((sum, fee) => sum + (fee.amount || 0), 0)
})

const finalAmount = computed(() => {
  const amountAfterDiscount = Math.max(0, calculatedTotalAmount.value - actualDiscount.value)
  return amountAfterDiscount + totalFees.value
})

const amountPerPerson = computed(() => {
  if (participants.value.length === 0 || finalAmount.value <= 0) return 0
  return finalAmount.value / participants.value.length
})

const getPersonDiscount = (participant) => {
  if (!useIndividualAmounts.value || !actualDiscount.value) return 0
  const personAmount = participant.amount || 0
  const proportion = personAmount / calculatedTotalAmount.value
  return proportion * actualDiscount.value
}

const getPersonFees = () => {
  if (!totalFees.value) return 0
  return totalFees.value / participants.value.length
}

const getPersonFinalAmount = (participant, index) => {
  if (useIndividualAmounts.value) {
    const personAmount = participant.amount || 0
    const personDiscount = getPersonDiscount(participant)
    const personFees = getPersonFees()
    return Math.max(0, personAmount - personDiscount + personFees)
  }
  return amountPerPerson.value
}

const getPersonOriginalAmount = (participant, index) => {
  if (useIndividualAmounts.value) {
    return participant.amount || 0
  }
  return calculatedTotalAmount.value / participants.value.length
}

const getCurrencySymbol = () => {
  return props.currencyFormat === 'USD' ? '$' : 'Rp'
}

const formatRupiah = (amount) => {
  if (props.currencyFormat === 'USD') {
    return new Intl.NumberFormat('en-US').format(Math.round(amount))
  }
  return new Intl.NumberFormat('id-ID').format(Math.round(amount))
}

const formatNumberInput = (value) => {
  if (!value || value === 0) return ''
  if (props.currencyFormat === 'USD') {
    return new Intl.NumberFormat('en-US').format(value)
  }
  return new Intl.NumberFormat('id-ID').format(value)
}

const parseFormattedNumber = (formatted) => {
  if (!formatted) return 0
  if (props.currencyFormat === 'USD') {
    const cleaned = formatted.toString().replace(/,/g, '')
    const num = parseFloat(cleaned)
    return isNaN(num) ? 0 : num
  }
  const cleaned = formatted.toString().replace(/\./g, '')
  const num = parseFloat(cleaned)
  return isNaN(num) ? 0 : num
}

const handleTotalAmountInput = (event) => {
  const cleaned = event.target.value.replace(/[^\d]/g, '')
  totalAmount.value = cleaned === '' ? 0 : parseFloat(cleaned)
  event.target.value = formatNumberInput(totalAmount.value)
}

const handleMaxDiscountInput = (event) => {
  const cleaned = event.target.value.replace(/[^\d]/g, '')
  maxDiscount.value = cleaned === '' ? 0 : parseFloat(cleaned)
  event.target.value = formatNumberInput(maxDiscount.value)
}

const handleParticipantAmountInput = (event, index) => {
  const cleaned = event.target.value.replace(/[^\d]/g, '')
  participants.value[index].amount = cleaned === '' ? 0 : parseFloat(cleaned)
  event.target.value = formatNumberInput(participants.value[index].amount)
}

const handleFeeAmountInput = (event, index) => {
  const cleaned = event.target.value.replace(/[^\d]/g, '')
  fees.value[index].amount = cleaned === '' ? 0 : parseFloat(cleaned)
  event.target.value = formatNumberInput(fees.value[index].amount)
}

const triggerFileInput = () => {
  fileInput.value.click()
}

const handleImageUpload = async (event) => {
  const file = event.target.files[0]
  if (!file) return

  isProcessing.value = true
  ocrError.value = ''

  try {
    const worker = await createWorker('eng+ind', 1, {
      logger: m => console.log(m)
    })

    await worker.setParameters({
      tessedit_char_whitelist: '0123456789.,ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz%$Rp ',
      tessedit_pageseg_mode: '6'
    })

    const { data: { text } } = await worker.recognize(file)
    await worker.terminate()

    console.log('OCR Result:', text)
    parseReceiptText(text)
  } catch (error) {
    console.error('OCR Error:', error)
    ocrError.value = 'Failed to process image. Please try again.'
  } finally {
    isProcessing.value = false
    event.target.value = ''
  }
}

const parseReceiptText = (text) => {
  const lines = text.split('\n').map(line => line.trim()).filter(line => line.length > 0)

  console.log('Parsed Lines:', lines)

  const pricePattern = /(?:-\s*)?(?:Rp\.?\s*|IDR\s*|USD\s*|\$\s*)?([0-9]{1,3}(?:[.,\s][0-9]{3})*(?:[.,][0-9]{2})?)/gi

  const extractedData = {
    merchantName: '',
    prices: [],
    totalAmount: 0,
    discountPercent: 0,
    maxDiscount: 0,
    fees: [],
    subtotal: 0
  }

  const totalKeywords = ['total', 'grand total', 'amount', 'jumlah', 'bayar', 'pay']
  const subtotalKeywords = ['subtotal', 'sub total', 'sub-total']
  const discountKeywords = ['discount', 'diskon', 'potongan', 'promo', 'voucher']
  const taxKeywords = ['tax', 'pajak', 'ppn', 'pb1', 'vat']
  const serviceKeywords = ['service', 'layanan', 'servis']
  const deliveryKeywords = ['delivery', 'ongkir', 'pengiriman', 'ongkos kirim']
  const feeKeywords = ['fee', 'biaya', 'charge']

  const normalizePrice = (priceStr) => {
    let cleaned = priceStr.replace(/\s/g, '')

    const dotCount = (cleaned.match(/\./g) || []).length
    const commaCount = (cleaned.match(/,/g) || []).length

    if (props.currencyFormat === 'IDR') {
      if (dotCount > 0 && commaCount > 0) {
        cleaned = cleaned.replace(/\./g, '').replace(/,/g, '.')
      } else if (dotCount >= 1) {
        const parts = cleaned.split('.')
        if (parts.length === 2 && parts[1].length === 2) {
          cleaned = cleaned.replace(/\./g, '.')
        } else {
          cleaned = cleaned.replace(/\./g, '')
        }
      } else if (commaCount >= 1) {
        const parts = cleaned.split(',')
        if (parts.length === 2 && parts[1].length === 2) {
          cleaned = cleaned.replace(/,/g, '.')
        } else {
          cleaned = cleaned.replace(/,/g, '')
        }
      }
    } else {
      if (dotCount > 0 && commaCount > 0) {
        if (cleaned.lastIndexOf('.') > cleaned.lastIndexOf(',')) {
          cleaned = cleaned.replace(/,/g, '')
        } else {
          cleaned = cleaned.replace(/\./g, '').replace(/,/g, '.')
        }
      } else if (commaCount > 1) {
        cleaned = cleaned.replace(/,/g, '')
      } else if (commaCount === 1) {
        const parts = cleaned.split(',')
        if (parts[1].length === 2) {
          cleaned = cleaned.replace(/,/g, '.')
        } else {
          cleaned = cleaned.replace(/,/g, '')
        }
      }
    }

    const num = parseFloat(cleaned)
    return isNaN(num) ? 0 : num
  }

  lines.forEach((line, index) => {
    const lowerLine = line.toLowerCase()

    if (index < 3 && !extractedData.merchantName && !pricePattern.test(line)) {
      const hasNumbers = /\d/.test(line)
      const hasAddress = /(jl\.|jalan|street|address|alamat)/i.test(line)
      if (!hasNumbers || hasAddress) {
        if (line.length >= 3 && line.length <= 50) {
          extractedData.merchantName = line
        }
      }
    }

    const isTotalLine = totalKeywords.some(kw => lowerLine.includes(kw))
    const isSubtotalLine = subtotalKeywords.some(kw => lowerLine.includes(kw))
    const isDiscountLine = discountKeywords.some(kw => lowerLine.includes(kw))
    const isTaxLine = taxKeywords.some(kw => lowerLine.includes(kw))
    const isServiceLine = serviceKeywords.some(kw => lowerLine.includes(kw))
    const isDeliveryLine = deliveryKeywords.some(kw => lowerLine.includes(kw))
    const isFeeLine = feeKeywords.some(kw => lowerLine.includes(kw))

    const percentMatch = line.match(/(\d+)\s*%/)

    const matches = Array.from(line.matchAll(pricePattern))

    matches.forEach(match => {
      const price = normalizePrice(match[1])
      console.log(`Line: "${line}" | Raw: "${match[1]}" | Parsed: ${price}`)

      if (price > 0) {
        extractedData.prices.push({ line, price, lineIndex: index })

        if (isTotalLine && price > extractedData.totalAmount) {
          extractedData.totalAmount = price
        }

        if (isSubtotalLine && price > extractedData.subtotal) {
          extractedData.subtotal = price
        }

        if (isDiscountLine) {
          if (percentMatch) {
            extractedData.discountPercent = parseInt(percentMatch[1])
          }
          if (price > extractedData.maxDiscount) {
            extractedData.maxDiscount = price
          }
        }

        if (isTaxLine) {
          const feeName = line.split(/[0-9]/)[0].trim() || 'Tax'
          extractedData.fees.push({ name: feeName, amount: price, type: 'tax' })
        } else if (isServiceLine) {
          const feeName = line.split(/[0-9]/)[0].trim() || 'Service Charge'
          extractedData.fees.push({ name: feeName, amount: price, type: 'service' })
        } else if (isDeliveryLine) {
          const feeName = line.split(/[0-9]/)[0].trim() || 'Delivery Fee'
          extractedData.fees.push({ name: feeName, amount: price, type: 'delivery' })
        } else if (isFeeLine && !isTotalLine && !isSubtotalLine) {
          const feeName = line.split(/[0-9]/)[0].trim() || 'Fee'
          extractedData.fees.push({ name: feeName, amount: price, type: 'other' })
        }
      }
    })

    if (isDiscountLine && percentMatch && !extractedData.discountPercent) {
      extractedData.discountPercent = parseInt(percentMatch[1])
    }
  })

  if (extractedData.subtotal > 0) {
    extractedData.totalAmount = extractedData.subtotal
  } else if (!extractedData.totalAmount && extractedData.prices.length > 0) {
    const feeAmounts = new Set(extractedData.fees.map(f => f.amount))
    const nonFeePrices = extractedData.prices
      .filter(p => p.price >= 1000 && !feeAmounts.has(p.price))
      .sort((a, b) => b.price - a.price)

    if (nonFeePrices.length > 0) {
      extractedData.totalAmount = nonFeePrices[0].price
    }
  }

  if (!billTitle.value && extractedData.merchantName) {
    billTitle.value = extractedData.merchantName
  }

  if (extractedData.totalAmount > 0) {
    totalAmount.value = extractedData.totalAmount
  }

  if (extractedData.discountPercent > 0) {
    discountPercent.value = extractedData.discountPercent
  }

  if (extractedData.maxDiscount > 0) {
    maxDiscount.value = extractedData.maxDiscount
  }

  if (extractedData.fees.length > 0) {
    const uniqueFees = []
    const seenTypes = new Set()

    extractedData.fees.forEach(fee => {
      const key = `${fee.type}_${fee.amount}`
      if (!seenTypes.has(key)) {
        seenTypes.add(key)
        uniqueFees.push(fee)
      }
    })

    if (uniqueFees.length > 0) {
      if (fees.value[0].name === '' && fees.value[0].amount === 0) {
        fees.value = uniqueFees.map(f => ({ name: f.name, amount: f.amount }))
      } else {
        uniqueFees.forEach(fee => {
          fees.value.push({ name: fee.name, amount: fee.amount })
        })
      }
    }
  }

  console.log('Extracted Data:', extractedData)
}

const addParticipant = () => {
  participants.value.push({ name: '', amount: 0 })
}

const removeParticipant = (index) => {
  if (participants.value.length > 1) {
    participants.value.splice(index, 1)
  }
}

const addFee = () => {
  fees.value.push({ name: '', amount: 0 })
}

const removeFee = (index) => {
  if (fees.value.length > 1) {
    fees.value.splice(index, 1)
  }
}

const saveBill = async () => {
  if (!billTitle.value || calculatedTotalAmount.value <= 0 || participants.value.length === 0) {
    return
  }

  isSaving.value = true
  errorMessage.value = ''
  savedMessage.value = ''

  try {
    const { data: { user } } = await supabase.auth.getUser()

    if (!user) {
      throw new Error('Not authenticated')
    }

    const billInsertData = {
      user_id: user.id,
      title: billTitle.value,
      total_amount: calculatedTotalAmount.value,
      discount_percent: discountPercent.value || 0,
      max_discount: maxDiscount.value || 0,
      final_amount: finalAmount.value,
      currency: props.currencyFormat
    }

    if (transferMethod.value) {
      billInsertData.transfer_method = transferMethod.value
      billInsertData.transfer_account = transferAccount.value
      if (transferMethod.value === 'bank') {
        billInsertData.bank_name = bankName.value
      }
      if (transferMethod.value === 'other') {
        billInsertData.transfer_description = transferDescription.value
      }
    }

    const { data: billData, error: billError } = await supabase
      .from('bills')
      .insert(billInsertData)
      .select()
      .maybeSingle()

    if (billError) throw billError

    const participantsData = participants.value.map((p, index) => ({
      bill_id: billData.id,
      name: p.name || 'Anonymous',
      amount: useIndividualAmounts.value ? getPersonFinalAmount(p, index) : amountPerPerson.value,
      original_amount: getPersonOriginalAmount(p, index)
    }))

    const { error: participantsError } = await supabase
      .from('participants')
      .insert(participantsData)

    if (participantsError) throw participantsError

    const feesData = fees.value
      .filter(f => f.name && f.amount > 0)
      .map(f => ({
        bill_id: billData.id,
        name: f.name,
        amount: f.amount
      }))

    if (feesData.length > 0) {
      const { error: feesError } = await supabase
        .from('fees')
        .insert(feesData)

      if (feesError) throw feesError
    }

    savedMessage.value = 'Bill saved successfully! Redirecting to PDF...'

    setTimeout(() => {
      savedMessage.value = ''
      resetBill()
      emit('bill-saved')
      router.push(`/bill/${billData.id}`)
    }, 1000)

  } catch (error) {
    console.error('Error saving bill:', error)
    errorMessage.value = error.message || 'Failed to save bill. Please try again.'
    setTimeout(() => {
      errorMessage.value = ''
    }, 3000)
  } finally {
    isSaving.value = false
  }
}

const resetBill = () => {
  billTitle.value = ''
  totalAmount.value = 0
  discountPercent.value = 0
  maxDiscount.value = 0
  fees.value = [{ name: '', amount: 0 }]
  useIndividualAmounts.value = false
  participants.value = [{ name: '', amount: 0 }, { name: '', amount: 0 }]
  transferMethod.value = ''
  bankName.value = ''
  transferAccount.value = ''
  transferDescription.value = ''
}
</script>
