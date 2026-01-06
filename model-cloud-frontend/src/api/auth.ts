import request from './request'

/**
 * 登录请求参数
 */
export interface LoginRequest {
  username: string
  password: string
  captcha: string
  captchaKey: string
}

/**
 * 注册请求参数
 */
export interface RegisterRequest {
  username: string
  password: string
  confirmPassword: string
  email: string
  phone?: string
  nickname?: string
  captcha: string
  captchaKey: string
}

/**
 * 登录响应数据
 */
export interface LoginResponse {
  token: string
  userInfo: {
    id: number
    username: string
    nickname: string
    email: string
    avatar?: string
    roles?: string[]
  }
}

/**
 * 验证码响应数据
 */
export interface CaptchaResponse {
  key: string
  image: string
}

/**
 * 认证相关API
 */
export const authApi = {
  /**
   * 用户登录
   */
  login(data: LoginRequest) {
    return request.post<LoginResponse>('/auth/login', data)
  },
  
  /**
   * 用户注册
   */
  register(data: RegisterRequest) {
    return request.post('/auth/register', data)
  },
  
  /**
   * 用户登出
   */
  logout() {
    return request.post('/auth/logout')
  },
  
  /**
   * 获取验证码
   */
  getCaptcha() {
    return request.get<CaptchaResponse>('/auth/captcha')
  },
  
  /**
   * 刷新Token
   */
  refreshToken() {
    return request.post('/auth/refresh')
  },
  
  /**
   * 获取当前用户信息
   */
  getCurrentUser() {
    return request.get('/auth/user')
  }
}

