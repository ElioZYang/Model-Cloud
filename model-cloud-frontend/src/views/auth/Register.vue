<template>
  <div class="register-container">
    <div class="register-box">
      <div class="register-header">
        <h2>用户注册</h2>
        <p class="subtitle">创建您的账号</p>
      </div>
      
      <el-form 
        :model="registerForm" 
        :rules="rules" 
        ref="registerFormRef"
        label-width="0"
        size="large"
      >
        <el-form-item prop="username">
          <el-input 
            v-model="registerForm.username" 
            placeholder="请输入用户名（3-20个字符）"
            :prefix-icon="User"
            clearable
          />
        </el-form-item>
        
        <el-form-item prop="nickname">
          <el-input 
            v-model="registerForm.nickname" 
            placeholder="请输入昵称（可选）"
            :prefix-icon="User"
            clearable
          />
        </el-form-item>
        
        <el-form-item prop="email">
          <el-input 
            v-model="registerForm.email" 
            placeholder="请输入邮箱"
            :prefix-icon="Message"
            clearable
          />
        </el-form-item>
        
        <el-form-item prop="phone">
          <el-input 
            v-model="registerForm.phone" 
            placeholder="请输入手机号（可选）"
            :prefix-icon="Phone"
            clearable
          />
        </el-form-item>
        
        <el-form-item prop="password">
          <el-input 
            v-model="registerForm.password" 
            type="password" 
            placeholder="请输入密码（6-20个字符）"
            :prefix-icon="Lock"
            show-password
          />
        </el-form-item>
        
        <el-form-item prop="confirmPassword">
          <el-input 
            v-model="registerForm.confirmPassword" 
            type="password" 
            placeholder="请再次输入密码"
            :prefix-icon="Lock"
            show-password
            @keyup.enter="handleRegister"
          />
        </el-form-item>
        
        <el-form-item prop="captcha">
          <div class="captcha-wrapper">
            <el-input 
              v-model="registerForm.captcha" 
              placeholder="请输入验证码"
              :prefix-icon="Key"
              @keyup.enter="handleRegister"
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
            @click="handleRegister" 
            :loading="loading" 
            style="width: 100%"
            size="large"
          >
            {{ loading ? '注册中...' : '注册' }}
          </el-button>
        </el-form-item>
        
        <div class="register-footer">
          <el-link type="primary" :underline="false" @click="goToLogin">
            已有账号？立即登录
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
import { User, Lock, Key, Message, Phone, Loading } from '@element-plus/icons-vue'
import { authApi } from '@/api/auth'

const router = useRouter()

const registerFormRef = ref<InstanceType<typeof ElForm>>()
const loading = ref(false)
const captchaImage = ref<string>('')
const captchaKey = ref<string>('')

const registerForm = reactive({
  username: '',
  nickname: '',
  email: '',
  phone: '',
  password: '',
  confirmPassword: '',
  captcha: ''
})

/**
 * 验证密码确认
 */
const validateConfirmPassword = (rule: any, value: string, callback: Function) => {
  if (value !== registerForm.password) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

/**
 * 验证邮箱格式
 */
const validateEmail = (rule: any, value: string, callback: Function) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(value)) {
    callback(new Error('请输入正确的邮箱格式'))
  } else {
    callback()
  }
}

/**
 * 验证手机号格式
 */
const validatePhone = (rule: any, value: string, callback: Function) => {
  if (!value) {
    callback()
    return
  }
  const phoneRegex = /^1[3-9]\d{9}$/
  if (!phoneRegex.test(value)) {
    callback(new Error('请输入正确的手机号格式'))
  } else {
    callback()
  }
}

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度为3-20个字符', trigger: 'blur' },
    { pattern: /^[a-zA-Z0-9_]+$/, message: '用户名只能包含字母、数字和下划线', trigger: 'blur' }
  ],
  nickname: [
    { max: 20, message: '昵称长度不能超过20个字符', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { validator: validateEmail, trigger: 'blur' }
  ],
  phone: [
    { validator: validatePhone, trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度为6-20个字符', trigger: 'blur' },
    { pattern: /^(?=.*[a-zA-Z])(?=.*\d)/, message: '密码必须包含字母和数字', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
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
 * 处理注册
 */
const handleRegister = async () => {
  if (!registerFormRef.value) return
  
  await registerFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    if (!captchaKey.value) {
      ElMessage.warning('请先获取验证码')
      await getCaptcha()
      return
    }
    
    loading.value = true
    
    try {
      const res = await authApi.register({
        username: registerForm.username,
        password: registerForm.password,
        confirmPassword: registerForm.confirmPassword,
        email: registerForm.email,
        phone: registerForm.phone || undefined,
        nickname: registerForm.nickname || undefined,
        captcha: registerForm.captcha,
        captchaKey: captchaKey.value
      })
      
      if (res.code === 200) {
        ElMessage.success('注册成功，请登录')
        // 跳转到登录页
        router.push('/login')
      }
    } catch (error: any) {
      console.error('注册失败:', error)
      ElMessage.error(error.message || '注册失败，请重试')
      // 注册失败后刷新验证码
      await getCaptcha()
      registerForm.captcha = ''
    } finally {
      loading.value = false
    }
  })
}

/**
 * 跳转到登录页面
 */
const goToLogin = () => {
  router.push('/login')
}

// 组件挂载时获取验证码
onMounted(() => {
  getCaptcha()
})
</script>

<style scoped>
.register-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.register-box {
  width: 100%;
  max-width: 480px;
  padding: 50px 40px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
  max-height: 90vh;
  overflow-y: auto;
}

.register-header {
  text-align: center;
  margin-bottom: 40px;
}

.register-header h2 {
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
  flex-shrink: 0;
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

.register-footer {
  text-align: center;
  margin-top: 20px;
}

:deep(.el-form-item) {
  margin-bottom: 22px;
}

:deep(.el-input__wrapper) {
  padding: 12px 15px;
}

/* 滚动条样式 */
.register-box::-webkit-scrollbar {
  width: 6px;
}

.register-box::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.register-box::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.register-box::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>



