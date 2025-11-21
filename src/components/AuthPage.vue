<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 to-slate-100 dark:from-slate-900 dark:to-slate-800 flex items-center justify-center px-4 transition-colors">
    <div class="bg-white dark:bg-slate-800 rounded-2xl shadow-xl p-8 w-full max-w-md transition-colors">
      <div class="text-center mb-8">
        <h1 class="text-4xl font-bold text-slate-800 dark:text-white mb-2">Split Bill</h1>
        <p class="text-slate-600 dark:text-slate-400">{{ isLogin ? 'Welcome back!' : 'Create your account' }}</p>
      </div>

      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
            Email
          </label>
          <input
            v-model="email"
            type="email"
            required
            placeholder="your@email.com"
            class="w-full px-4 py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-slate-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
            Password
          </label>
          <input
            v-model="password"
            type="password"
            required
            placeholder="••••••••"
            minlength="6"
            class="w-full px-4 py-3 bg-slate-50 dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-slate-500"
          />
        </div>

        <button
          type="submit"
          :disabled="isLoading"
          class="w-full py-3 bg-blue-500 hover:bg-blue-600 text-white font-semibold rounded-xl transition disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ isLoading ? 'Please wait...' : (isLogin ? 'Sign In' : 'Sign Up') }}
        </button>
      </form>

      <div class="mt-6 text-center">
        <button
          @click="isLogin = !isLogin"
          class="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 font-medium transition"
        >
          {{ isLogin ? "Don't have an account? Sign Up" : 'Already have an account? Sign In' }}
        </button>
      </div>

      <div v-if="errorMessage" class="mt-4 p-4 bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-700 rounded-xl transition-colors">
        <p class="text-red-800 dark:text-red-400 text-center text-sm">{{ errorMessage }}</p>
      </div>

      <div v-if="successMessage" class="mt-4 p-4 bg-green-50 dark:bg-green-900/30 border border-green-200 dark:border-green-700 rounded-xl transition-colors">
        <p class="text-green-800 dark:text-green-400 text-center text-sm">{{ successMessage }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { supabase } from '../supabase.js'

const emit = defineEmits(['authenticated'])

const isLogin = ref(true)
const email = ref('')
const password = ref('')
const isLoading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

const handleSubmit = async () => {
  isLoading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    if (isLogin.value) {
      const { data, error } = await supabase.auth.signInWithPassword({
        email: email.value,
        password: password.value,
      })

      if (error) throw error

      emit('authenticated', data.user)
    } else {
      const { data, error } = await supabase.auth.signUp({
        email: email.value,
        password: password.value,
      })

      if (error) throw error

      successMessage.value = 'Account created successfully! Signing you in...'

      setTimeout(() => {
        emit('authenticated', data.user)
      }, 1000)
    }
  } catch (error) {
    if (error.message.includes('Invalid login credentials')) {
      errorMessage.value = 'Invalid email or password'
    } else if (error.message.includes('User already registered')) {
      errorMessage.value = 'This email is already registered. Please sign in instead.'
      isLogin.value = true
    } else {
      errorMessage.value = error.message
    }
  } finally {
    isLoading.value = false
  }
}
</script>
