import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

/**
 * 用户信息接口
 */
export interface UserInfo {
  id: number
  username: string
  nickname: string
  email: string
  phone?: string
  avatar?: string
  roles?: string[]
}

export const useUserStore = defineStore('user', () => {
  // 从localStorage恢复token
  const token = ref<string>(localStorage.getItem('token') || '')
  const userInfo = ref<UserInfo | null>(null)
  
  // 计算属性：是否已登录
  const isLoggedIn = computed(() => !!token.value)
  
  // 计算属性：用户名
  const username = computed(() => userInfo.value?.username || '')
  
  // 计算属性：昵称
  const nickname = computed(() => userInfo.value?.nickname || userInfo.value?.username || '')
  
  /**
   * 设置Token
   */
  function setToken(newToken: string) {
    token.value = newToken
    if (newToken) {
      localStorage.setItem('token', newToken)
    } else {
      localStorage.removeItem('token')
    }
  }
  
  /**
   * 设置用户信息
   */
  function setUserInfo(info: UserInfo | null) {
    userInfo.value = info
    if (info) {
      localStorage.setItem('userInfo', JSON.stringify(info))
    } else {
      localStorage.removeItem('userInfo')
    }
  }
  
  /**
   * 清除用户信息
   */
  function clearUserInfo() {
    token.value = ''
    userInfo.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
  }
  
  /**
   * 初始化用户信息（从localStorage恢复）
   */
  function initUserInfo() {
    const savedUserInfo = localStorage.getItem('userInfo')
    if (savedUserInfo) {
      try {
        userInfo.value = JSON.parse(savedUserInfo)
      } catch (error) {
        console.error('恢复用户信息失败:', error)
        localStorage.removeItem('userInfo')
      }
    }
  }
  
  // 初始化时恢复用户信息
  initUserInfo()
  
  return {
    token,
    userInfo,
    isLoggedIn,
    username,
    nickname,
    setToken,
    setUserInfo,
    clearUserInfo,
    initUserInfo
  }
})

