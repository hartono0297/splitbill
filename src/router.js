import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from './components/Dashboard.vue'
import BillPDF from './components/BillPDF.vue'

const routes = [
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: Dashboard
  },
  {
    path: '/bill/:id',
    name: 'BillPDF',
    component: BillPDF
  },
  {
    path: '/share/:token',
    name: 'SharedBillPDF',
    component: BillPDF
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
