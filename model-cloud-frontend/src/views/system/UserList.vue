<template>
  <div class="user-list-container">
    <el-card class="filter-card">
      <el-form :inline="true" :model="queryParams" class="demo-form-inline">
        <el-form-item label="用户名">
          <el-input v-model="queryParams.username" placeholder="搜索用户名" clearable @keyup.enter="handleQuery" />
        </el-form-item>
        <el-form-item label="昵称">
          <el-input v-model="queryParams.nickname" placeholder="搜索昵称" clearable @keyup.enter="handleQuery" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="请选择状态" clearable style="width: 150px">
            <el-option label="启用" :value="1" />
            <el-option label="禁用" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="handleQuery">查询</el-button>
          <el-button :icon="Refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
        <el-form-item style="float: right">
          <el-button type="success" :icon="Plus" @click="handleAdd">新增用户</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card class="table-card">
      <el-table :data="userList" v-loading="loading" stripe border>
        <el-table-column type="selection" width="55" />
        <el-table-column label="序号" width="80" type="index" :index="indexMethod" />
        <el-table-column prop="username" label="用户名" width="150" />
        <el-table-column prop="nickname" label="昵称" width="150" />
        <el-table-column prop="email" label="邮箱" width="200" />
        <el-table-column prop="phone" label="手机号" width="150" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'">
              {{ row.statusText }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="roles" label="角色" width="200">
          <template #default="{ row }">
            <el-tag v-for="role in row.roles" :key="role.id" size="small" style="margin-right: 5px">
              {{ role.roleName }}
            </el-tag>
            <span v-if="!row.roles || row.roles.length === 0">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180">
          <template #default="{ row }">
            {{ formatDate(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="350" fixed="right">
          <template #default="{ row }">
            <!-- 重置密码：超级管理员可以重置管理员和普通用户，管理员只能重置普通用户 -->
            <el-button 
              v-if="canResetPassword(row)" 
              type="warning" 
              link 
              size="small" 
              @click="handleResetPassword(row)"
            >
              重置密码
            </el-button>
            <!-- 启用/禁用：超级管理员可以管理管理员和普通用户，管理员只能管理普通用户 -->
            <el-button 
              v-if="row.status === 1 && canManageUser(row)" 
              type="warning" 
              link 
              size="small" 
              @click="handleDisable(row)"
            >
              禁用
            </el-button>
            <el-button 
              v-if="row.status === 0 && canManageUser(row)" 
              type="success" 
              link 
              size="small" 
              @click="handleEnable(row)"
            >
              启用
            </el-button>
            <!-- 删除：只有超级管理员可以删除管理员和普通用户 -->
            <el-button 
              v-if="canDeleteUser(row)" 
              type="danger" 
              link 
              size="small" 
              @click="handleDelete(row)"
            >
              删除
            </el-button>
            <!-- 修改角色：只有超级管理员可以修改管理员和普通用户的角色 -->
            <el-button 
              v-if="canModifyRole(row)" 
              type="primary" 
              link 
              size="small" 
              @click="handleEditRole(row)"
            >
              修改角色
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 新增用户对话框 -->
    <el-dialog 
      v-model="dialogVisible" 
      title="新增用户" 
      width="600px" 
      @close="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="form.password" type="password" placeholder="请输入密码" show-password />
        </el-form-item>
        <el-form-item label="昵称" prop="nickname">
          <el-input v-model="form.nickname" placeholder="请输入昵称" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="form.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="form.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="角色" prop="roleIds" v-if="userStore.isSuperAdmin">
          <el-select v-model="form.roleIdsArray" placeholder="请选择角色" style="width: 100%" clearable>
            <el-option 
              v-for="role in filteredRoleList" 
              :key="role.id" 
              :label="role.roleName" 
              :value="role.id.toString()" 
            />
          </el-select>
          <el-text type="info" size="small" style="margin-left: 10px">
            只能选择管理员或普通用户，不允许多角色
          </el-text>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :label="1">启用</el-radio>
            <el-radio :label="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>

    <!-- 修改角色对话框 -->
    <el-dialog 
      v-model="roleDialogVisible" 
      title="修改角色" 
      width="500px" 
      @close="resetRoleForm"
    >
      <el-form ref="roleFormRef" :model="roleForm" :rules="roleRules" label-width="100px">
        <el-form-item label="用户名">
          <el-input v-model="roleForm.username" disabled />
        </el-form-item>
        <el-form-item label="当前角色">
          <el-input :value="getCurrentRoleName(roleForm.userId)" disabled />
        </el-form-item>
        <el-form-item label="新角色" prop="roleId">
          <el-select v-model="roleForm.roleId" placeholder="请选择角色" style="width: 100%" clearable>
            <el-option 
              v-for="role in filteredRoleList" 
              :key="role.id" 
              :label="role.roleName" 
              :value="role.id.toString()" 
            />
          </el-select>
          <el-text type="info" size="small" style="margin-left: 10px">
            只能选择管理员或普通用户，不允许多角色
          </el-text>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="roleDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleRoleSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>

    <!-- 重置密码对话框 -->
    <el-dialog v-model="passwordDialogVisible" title="重置密码" width="400px">
      <el-form ref="passwordFormRef" :model="passwordForm" :rules="passwordRules" label-width="100px">
        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="passwordForm.newPassword" type="password" placeholder="请输入新密码" show-password />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="passwordDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handlePasswordSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus } from '@element-plus/icons-vue'
import { userApi, type UserVO, type UserQueryRequest, type UserCreateRequest, type UserUpdateRequest, type RoleVO } from '@/api/user'
import { useUserStore } from '@/stores/user'

// 查询参数
const queryParams = reactive<UserQueryRequest>({
  username: '',
  nickname: '',
  email: '',
  status: undefined,
  pageNum: 1,
  pageSize: 10
})

// 数据
const userList = ref<UserVO[]>([])
const total = ref(0)
const loading = ref(false)

// 对话框
const dialogVisible = ref(false)
const passwordDialogVisible = ref(false)
const roleDialogVisible = ref(false)
const submitting = ref(false)

// 表单
const formRef = ref()
const passwordFormRef = ref()
const form = reactive<UserCreateRequest & { id?: number; roleIdsArray?: string }>({
  username: '',
  password: '',
  nickname: '',
  email: '',
  phone: '',
  roleIds: '',
  roleIdsArray: '',
  status: 1
})

const passwordForm = reactive({
  id: 0,
  newPassword: ''
})

const roleForm = reactive({
  userId: 0,
  username: '',
  roleId: ''
})

const roleFormRef = ref()

// 角色列表
const roleList = ref<RoleVO[]>([])

// 用户store
const userStore = useUserStore()

// 过滤后的角色列表（只包含 admin 和 user，不包含 super_admin）
const filteredRoleList = computed(() => {
  return roleList.value.filter(role => 
    role.roleCode === 'admin' || role.roleCode === 'user'
  )
})

// 表单验证规则
const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 50, message: '用户名长度为3-50个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度为6-20个字符', trigger: 'blur' }
  ],
  nickname: [
    { max: 50, message: '昵称长度不能超过50个字符', trigger: 'blur' }
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ]
}

const roleRules = {
  roleId: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ]
}

const passwordRules = {
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度为6-20个字符', trigger: 'blur' }
  ]
}

/**
 * 查询用户列表
 */
const loadUserList = async () => {
  loading.value = true
  try {
    const res = await userApi.getUserList(queryParams)
    if (res.code === 200 && res.data) {
      userList.value = res.data.records || []
      total.value = res.data.totalRow || 0
    }
  } catch (error) {
    console.error('查询用户列表失败:', error)
  } finally {
    loading.value = false
  }
}

/**
 * 加载角色列表
 */
const loadRoleList = async () => {
  try {
    const res = await userApi.getRoleList()
    if (res.code === 200 && res.data) {
      roleList.value = res.data || []
      console.log('角色列表加载成功:', roleList.value)
      console.log('过滤后的角色列表:', filteredRoleList.value)
    }
  } catch (error) {
    console.error('加载角色列表失败:', error)
    ElMessage.error('加载角色列表失败')
  }
}

/**
 * 查询
 */
const handleQuery = () => {
  queryParams.pageNum = 1
  loadUserList()
}

/**
 * 重置查询
 */
const resetQuery = () => {
  queryParams.username = ''
  queryParams.nickname = ''
  queryParams.email = ''
  queryParams.status = undefined
  queryParams.pageNum = 1
  loadUserList()
}

/**
 * 分页大小改变
 */
const handleSizeChange = (size: number) => {
  queryParams.pageSize = size
  queryParams.pageNum = 1
  loadUserList()
}

/**
 * 当前页改变
 */
const handleCurrentChange = (page: number) => {
  queryParams.pageNum = page
  loadUserList()
}

/**
 * 新增用户
 */
const handleAdd = () => {
  resetForm()
  dialogVisible.value = true
}

/**
 * 修改角色
 */
const handleEditRole = async (row: UserVO) => {
  try {
    // 确保角色列表已加载
    if (roleList.value.length === 0) {
      await loadRoleList()
    }
    
    const res = await userApi.getUserDetail(row.id)
    if (res.code === 200 && res.data) {
      const user = res.data
      roleForm.userId = user.id
      roleForm.username = user.username
      // 只取第一个角色（单选）
      roleForm.roleId = user.roles && user.roles.length > 0 ? user.roles[0].id.toString() : ''
      roleDialogVisible.value = true
    }
  } catch (error) {
    console.error('获取用户详情失败:', error)
    ElMessage.error('获取用户详情失败')
  }
}

/**
 * 获取当前角色名称
 */
const getCurrentRoleName = (userId: number) => {
  const user = userList.value.find(u => u.id === userId)
  if (user && user.roles && user.roles.length > 0) {
    return user.roles[0].roleName
  }
  return '-'
}

/**
 * 删除用户
 */
const handleDelete = async (row: UserVO) => {
  try {
    await ElMessageBox.confirm(`确定要删除用户 "${row.username}" 吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await userApi.deleteUser(row.id)
    ElMessage.success('删除成功')
    loadUserList()
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('删除用户失败:', error)
    }
  }
}

/**
 * 启用用户
 */
const handleEnable = async (row: UserVO) => {
  try {
    await userApi.enableUser(row.id)
    ElMessage.success('启用成功')
    loadUserList()
  } catch (error) {
    console.error('启用用户失败:', error)
  }
}

/**
 * 禁用用户
 */
const handleDisable = async (row: UserVO) => {
  try {
    await ElMessageBox.confirm(`确定要禁用用户 "${row.username}" 吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await userApi.disableUser(row.id)
    ElMessage.success('禁用成功')
    loadUserList()
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('禁用用户失败:', error)
    }
  }
}

/**
 * 重置密码
 */
const handleResetPassword = (row: UserVO) => {
  passwordForm.id = row.id
  passwordForm.newPassword = ''
  passwordDialogVisible.value = true
}

/**
 * 提交表单（新增用户）
 */
const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid: boolean) => {
    if (valid) {
      submitting.value = true
      try {
        // 单选角色
        const roleIdsStr = form.roleIdsArray || ''
        const createData: UserCreateRequest = {
          username: form.username,
          password: form.password,
          nickname: form.nickname,
          email: form.email,
          phone: form.phone,
          roleIds: roleIdsStr,
          status: form.status
        }
        await userApi.createUser(createData)
        ElMessage.success('创建成功')
        dialogVisible.value = false
        loadUserList()
      } catch (error) {
        console.error('提交失败:', error)
      } finally {
        submitting.value = false
      }
    }
  })
}

/**
 * 提交角色修改
 */
const handleRoleSubmit = async () => {
  if (!roleFormRef.value) return
  
  await roleFormRef.value.validate(async (valid: boolean) => {
    if (valid) {
      submitting.value = true
      try {
        // 只发送必要的字段：id 和 roleIds
        const updateData = {
          id: roleForm.userId,
          roleIds: roleForm.roleId || ''
        } as UserUpdateRequest
        await userApi.updateUser(updateData)
        ElMessage.success('修改角色成功')
        roleDialogVisible.value = false
        loadUserList()
      } catch (error) {
        console.error('修改角色失败:', error)
      } finally {
        submitting.value = false
      }
    }
  })
}

/**
 * 提交密码重置
 */
const handlePasswordSubmit = async () => {
  if (!passwordFormRef.value) return
  
  await passwordFormRef.value.validate(async (valid: boolean) => {
    if (valid) {
      submitting.value = true
      try {
        await userApi.resetPassword({
          id: passwordForm.id,
          newPassword: passwordForm.newPassword
        })
        ElMessage.success('重置密码成功')
        passwordDialogVisible.value = false
      } catch (error) {
        console.error('重置密码失败:', error)
      } finally {
        submitting.value = false
      }
    }
  })
}

/**
 * 重置表单
 */
const resetForm = () => {
  form.username = ''
  form.password = ''
  form.nickname = ''
  form.email = ''
  form.phone = ''
  form.roleIds = ''
  form.roleIdsArray = ''
  form.status = 1
  formRef.value?.resetFields()
}

/**
 * 重置角色表单
 */
const resetRoleForm = () => {
  roleForm.userId = 0
  roleForm.username = ''
  roleForm.roleId = ''
  roleFormRef.value?.resetFields()
}

/**
 * 格式化日期
 */
const formatDate = (dateStr: string) => {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return date.toLocaleString('zh-CN')
}

/**
 * 序号计算方法
 */
const indexMethod = (index: number) => {
  return (queryParams.pageNum - 1) * queryParams.pageSize + index + 1
}

/**
 * 检查是否是超级管理员
 */
const isSuperAdmin = (row: UserVO) => {
  return row.highestRoleCode === 'super_admin' || row.roles?.some(r => r.roleCode === 'super_admin')
}

/**
 * 检查是否是管理员（非超级管理员）
 */
const isAdmin = (row: UserVO) => {
  return row.highestRoleCode === 'admin' || row.roles?.some(r => r.roleCode === 'admin')
}

/**
 * 检查是否可以管理该用户（启用/禁用）
 */
const canManageUser = (row: UserVO) => {
  if (userStore.isSuperAdmin) {
    // 超级管理员可以管理所有用户（除了自己）
    return row.id !== userStore.userInfo?.id
  } else if (userStore.isAdmin) {
    // 管理员只能管理普通用户
    return !isSuperAdmin(row) && !isAdmin(row)
  }
  return false
}

/**
 * 检查是否可以重置密码
 */
const canResetPassword = (row: UserVO) => {
  if (userStore.isSuperAdmin) {
    // 超级管理员可以重置所有用户密码（除了自己和超级管理员）
    return row.id !== userStore.userInfo?.id && !isSuperAdmin(row)
  } else if (userStore.isAdmin) {
    // 管理员只能重置普通用户密码
    return !isSuperAdmin(row) && !isAdmin(row)
  }
  return false
}

/**
 * 检查是否可以删除用户
 */
const canDeleteUser = (row: UserVO) => {
  if (userStore.isSuperAdmin) {
    // 超级管理员可以删除所有用户（除了自己和超级管理员）
    return row.id !== userStore.userInfo?.id && !isSuperAdmin(row)
  }
  return false
}

/**
 * 检查是否可以修改角色
 */
const canModifyRole = (row: UserVO) => {
  if (userStore.isSuperAdmin) {
    // 超级管理员可以修改所有用户的角色（除了自己和超级管理员）
    return row.id !== userStore.userInfo?.id && !isSuperAdmin(row)
  }
  return false
}

/**
 * 获取角色显示名称
 */
const getRoleDisplayName = () => {
  if (form.roleIdsArray) {
    const role = roleList.value.find(r => r.id.toString() === form.roleIdsArray)
    return role ? role.roleName : '-'
  }
  return '-'
}

// 初始化
onMounted(() => {
  loadUserList()
  loadRoleList()
})
</script>

<style scoped>
.user-list-container {
  padding: 0;
}

.filter-card {
  margin-bottom: 20px;
}

.table-card {
  margin-bottom: 20px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>

