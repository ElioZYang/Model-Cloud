import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    redirect: '/dashboard/home'
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/auth/Login.vue'),
    meta: { 
      title: '登录',
      requiresAuth: false 
    }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/auth/Register.vue'),
    meta: { 
      title: '注册',
      requiresAuth: false 
    }
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('@/layouts/MainLayout.vue'),
    redirect: '/dashboard/home',
    meta: { requiresAuth: true },
    children: [
      {
        path: 'home',
        name: 'Home',
        component: () => import('@/views/dashboard/Home.vue'),
        meta: { title: '首页' }
      },
      {
        path: 'model/list',
        name: 'ModelList',
        component: () => import('@/views/business/ModelList.vue'),
        meta: { title: '模型列表' }
      },
      {
        path: 'model/detail/:id',
        name: 'ModelDetail',
        component: () => import('@/views/business/ModelDetail.vue'),
        meta: { title: '模型详情' }
      },
      {
        path: 'model/collects',
        name: 'MyCollects',
        component: () => import('@/views/business/MyCollects.vue'),
        meta: { title: '我的收藏' }
      },
      {
        path: 'system/user',
        name: 'UserList',
        component: () => import('@/views/system/UserList.vue'),
        meta: { title: '用户管理', requiresAdmin: true }
      },
      {
        path: 'system/profile',
        name: 'Profile',
        component: () => import('@/views/system/Profile.vue'),
        meta: { title: '个人信息' }
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('@/views/error/404.vue'),
    meta: { title: '页面不存在' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  // 确保token从store获取，如果store中没有则从localStorage恢复
  const token = userStore.token || localStorage.getItem('token')
  if (token && !userStore.token) {
    userStore.setToken(token)
  }
  
  // 设置页面标题
  if (to.meta.title) {
    document.title = `${to.meta.title} - 模型管理系统`
  }
  
  // 检查是否需要认证
  if (to.meta.requiresAuth) {
    if (!token) {
      ElMessage.warning('请先登录')
      next({
        path: '/login',
        query: { redirect: to.fullPath }
      })
    } else {
      // 检查是否需要管理员权限
      if (to.meta.requiresAdmin) {
        if (!userStore.isAdmin) {
          ElMessage.warning('无权限访问，需要管理员权限')
          next('/dashboard/home')
        } else {
          next()
        }
      } else {
        // 如果有token，直接放行（用户信息会在需要时加载）
        next()
      }
    }
  } else {
    // 如果已登录，访问登录/注册页时重定向到首页
    if ((to.path === '/login' || to.path === '/register') && token) {
      next('/dashboard/home')
    } else {
      next()
    }
  }
})

export default router

