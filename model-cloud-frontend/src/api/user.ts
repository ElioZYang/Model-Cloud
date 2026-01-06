import request from './request'

/**
 * 用户管理相关API
 */

export interface UserVO {
  id: number
  username: string
  nickname: string
  email?: string
  phone?: string
  avatar?: string
  status: number
  statusText: string
  createTime: string
  updateTime: string
  roles?: RoleVO[]
  highestRoleCode?: string
}

export interface RoleVO {
  id: number
  roleName: string
  roleCode: string
  description?: string
  status: number
}

export interface UserQueryRequest {
  username?: string
  nickname?: string
  email?: string
  status?: number
  pageNum?: number
  pageSize?: number
}

export interface UserCreateRequest {
  username: string
  password: string
  nickname?: string
  email?: string
  phone?: string
  roleIds?: string
  status?: number
}

export interface UserUpdateRequest {
  id: number
  nickname?: string
  email?: string
  phone?: string
  avatar?: string
  roleIds?: string
  status?: number
}

export interface ResetPasswordRequest {
  id: number
  newPassword: string
}

export const userApi = {
  /**
   * 分页查询用户列表
   */
  getUserList(params: UserQueryRequest) {
    return request.get('/sys/user/page', { params })
  },
  
  /**
   * 获取用户详情
   */
  getUserDetail(id: number) {
    return request.get(`/sys/user/${id}`)
  },
  
  /**
   * 创建用户
   */
  createUser(data: UserCreateRequest) {
    return request.post('/sys/user', data)
  },
  
  /**
   * 更新用户
   */
  updateUser(data: UserUpdateRequest) {
    return request.put('/sys/user', data)
  },
  
  /**
   * 删除用户
   */
  deleteUser(id: number) {
    return request.delete(`/sys/user/${id}`)
  },
  
  /**
   * 批量删除用户
   */
  batchDeleteUsers(ids: number[]) {
    return request.delete('/sys/user/batch', { data: ids })
  },
  
  /**
   * 启用用户
   */
  enableUser(id: number) {
    return request.put(`/sys/user/${id}/enable`)
  },
  
  /**
   * 禁用用户
   */
  disableUser(id: number) {
    return request.put(`/sys/user/${id}/disable`)
  },
  
  /**
   * 重置密码
   */
  resetPassword(data: ResetPasswordRequest) {
    return request.put('/sys/user/reset-password', data)
  },
  
  /**
   * 获取角色列表
   */
  getRoleList() {
    return request.get('/sys/user/roles')
  }
}

