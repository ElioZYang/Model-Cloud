<template>
  <div class="login-container">
    <div class="login-box">
      <div class="login-header">
        <h2>模型管理系统</h2>
        <p class="subtitle">Model Cloud Management System</p>
      </div>
      
      <el-form 
        :model="loginForm" 
        :rules="rules" 
        ref="loginFormRef"
        label-width="0"
        size="large"
      >
        <el-form-item prop="username">
          <el-input 
            v-model="loginForm.username" 
            placeholder="请输入用户名"
            :prefix-icon="User"
            clearable
          />
        </el-form-item>
        
        <el-form-item prop="password">
          <el-input 
            v-model="loginForm.password" 
            type="password" 
            placeholder="请输入密码"
            :prefix-icon="Lock"
            show-password
            @keyup.enter="handleLogin"
          />
        </el-form-item>
        
        <el-form-item prop="captcha">
          <div class="captcha-wrapper">
            <el-input 
              v-model="loginForm.captcha" 
              placeholder="请输入验证码"
              :prefix-icon="Key"
              @keyup.enter="handleLogin"
            />
            <div class="captcha-image" @click="refreshCaptcha">
              <img 
                v-if="captchaImage" 
                :src="captchaImage" 
                alt="验证码"
                class="captcha-img"
              />
              <div v-else class="captcha-loading">
                <el-icon><Loading /></el-icon>
              </div>
            </div>
          </div>
        </el-form-item>
        
        <el-form-item>
          <el-button 
            type="primary" 
            @click="handleLogin" 
            :loading="loading" 
            style="width: 100%"
            size="large"
          >
            {{ loading ? '登录中...' : '登录' }}
          </el-button>
        </el-form-item>
        
        <div class="login-footer">
          <el-link type="primary" :underline="false" @click="goToRegister">
            还没有账号？立即注册
          </el-link>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElForm } from 'element-plus'
import { User, Lock, Key, Loading } from '@element-plus/icons-vue'
import { authApi } from '@/api/auth'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

const loginFormRef = ref<InstanceType<typeof ElForm>>()
const loading = ref(false)
const captchaImage = ref<string>('')
const captchaKey = ref<string>('')

const loginForm = reactive({
  username: '',
  password: '',
  captcha: ''
})

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度为3-20个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度为6-20个字符', trigger: 'blur' }
  ],
  captcha: [
    { required: true, message: '请输入验证码', trigger: 'blur' },
    { len: 4, message: '验证码为4位字符', trigger: 'blur' }
  ]
}

/**
 * 获取验证码
 */
const getCaptcha = async () => {
  try {
    const res = await authApi.getCaptcha()
    if (res.code === 200 && res.data) {
      captchaKey.value = res.data.key
      captchaImage.value = `data:image/png;base64,${res.data.image}`
    }
  } catch (error) {
    console.error('获取验证码失败:', error)
    ElMessage.error('获取验证码失败，请刷新页面重试')
  }
}

/**
 * 刷新验证码
 */
const refreshCaptcha = () => {
  getCaptcha()
}

/**
 * 处理登录
 */
const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  await loginFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    if (!captchaKey.value) {
      ElMessage.warning('请先获取验证码')
      await getCaptcha()
      return
    }
    
    loading.value = true
    
    try {
      const res = await authApi.login({
        username: loginForm.username,
        password: loginForm.password,
        captcha: loginForm.captcha,
        captchaKey: captchaKey.value
      })
      
      if (res.code === 200 && res.data) {
        // 保存Token和用户信息
        userStore.setToken(res.data.token)
        userStore.setUserInfo(res.data.userInfo)
        
        ElMessage.success('登录成功')
        
        // 跳转到首页
        router.push('/dashboard/home')
      }
    } catch (error: any) {
      console.error('登录失败:', error)
      ElMessage.error(error.message || '登录失败，请检查用户名和密码')
      // 登录失败后刷新验证码
      await getCaptcha()
      loginForm.captcha = ''
    } finally {
      loading.value = false
    }
  })
}

/**
 * 跳转到注册页面
 */
const goToRegister = () => {
  router.push('/register')
}

// 组件挂载时获取验证码
onMounted(() => {
  getCaptcha()
})
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-box {
  width: 100%;
  max-width: 420px;
  padding: 50px 40px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
}

.login-header {
  text-align: center;
  margin-bottom: 40px;
}

.login-header h2 {
  margin: 0 0 8px 0;
  color: #333;
  font-size: 28px;
  font-weight: 600;
}

.subtitle {
  margin: 0;
  color: #999;
  font-size: 14px;
}

.captcha-wrapper {
  display: flex;
  gap: 10px;
  width: 100%;
}

.captcha-wrapper .el-input {
  flex: 1;
}

.captcha-image {
  width: 120px;
  height: 40px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f7fa;
  transition: all 0.3s;
}

.captcha-image:hover {
  border-color: #409eff;
  background: #ecf5ff;
}

.captcha-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 4px;
}

.captcha-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #909399;
}

.login-footer {
  text-align: center;
  margin-top: 20px;
}

:deep(.el-form-item) {
  margin-bottom: 22px;
}

:deep(.el-input__wrapper) {
  padding: 12px 15px;
}
</style>

