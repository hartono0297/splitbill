<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100">
    <AuthPage v-if="!user && !loading" @authenticated="handleAuthenticated" />
    <router-view v-else-if="user" :user="user" @signout="handleSignOut" />
    <div v-else-if="loading" class="min-h-screen flex items-center justify-center">
      <div class="text-center">
        <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mb-4"></div>
        <p class="text-slate-600 font-medium">Loading...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from './supabase.js'
import AuthPage from './components/AuthPage.vue'

const user = ref(null)
const loading = ref(true)

const checkAuth = async () => {
  try {
    const { data: { session } } = await supabase.auth.getSession()
    user.value = session?.user || null
  } catch (error) {
    console.error('Auth check error:', error)
  } finally {
    loading.value = false
  }
}

const handleAuthenticated = (authenticatedUser) => {
  user.value = authenticatedUser
}

const handleSignOut = () => {
  user.value = null
}

onMounted(() => {
  checkAuth()

  const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
    (async () => {
      user.value = session?.user || null
    })()
  })
})
</script>
