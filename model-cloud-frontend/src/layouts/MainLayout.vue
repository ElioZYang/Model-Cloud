<template>
  <el-container class="main-layout">
    <el-aside width="200px" class="sidebar">
      <div class="logo">
        <h3>模型管理系统</h3>
      </div>
      <el-menu
        :default-active="activeMenu"
        class="sidebar-menu"
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409eff"
        router
      >
        <el-menu-item index="/dashboard/home">
          <el-icon><HomeFilled /></el-icon>
          <span>首页</span>
        </el-menu-item>
        <el-menu-item index="/dashboard/model/list">
          <el-icon><Box /></el-icon>
          <span>模型列表</span>
        </el-menu-item>
        <el-menu-item index="/dashboard/model/collects">
          <el-icon><Star /></el-icon>
          <span>我的收藏</span>
        </el-menu-item>
        <el-menu-item v-if="userStore.isAdmin" index="/dashboard/system/user">
          <el-icon><User /></el-icon>
          <span>用户管理</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    <el-container>
      <el-header class="header">
        <div class="header-left">
          <el-icon class="collapse-icon" @click="toggleCollapse">
            <Expand v-if="isCollapse" />
            <Fold v-else />
          </el-icon>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="32" :src="userStore.userInfo?.avatar">
                {{ userStore.nickname ? userStore.nickname.charAt(0).toUpperCase() : 'U' }}
              </el-avatar>
              <span class="username">{{ userStore.nickname || '用户' }}</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">个人中心</el-dropdown-item>
                <el-dropdown-item command="settings">设置</el-dropdown-item>
                <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      <el-main class="main-content">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { HomeFilled, Box, Star, User, Expand, Fold, ArrowDown } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { authApi } from '@/api/auth'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const isCollapse = ref(false)

// 当前激活的菜单
const activeMenu = computed(() => route.path)

/**
 * 切换侧边栏折叠
 */
const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
  // TODO: 实现侧边栏折叠动画
}

/**
 * 处理下拉菜单命令
 */
const handleCommand = async (command: string) => {
  switch (command) {
    case 'profile':
      // TODO: 跳转到个人中心
      ElMessage.info('个人中心功能开发中')
      break
    case 'settings':
      // TODO: 跳转到设置页面
      ElMessage.info('设置功能开发中')
      break
    case 'logout':
      try {
        await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })
        
        // 调用登出接口
        try {
          await authApi.logout()
        } catch (error) {
          console.error('登出接口调用失败:', error)
        }
        
        // 清除用户信息
        userStore.clearUserInfo()
        ElMessage.success('已退出登录')
        
        // 跳转到登录页
        router.push('/login')
      } catch (error) {
        // 用户取消
      }
      break
  }
}
</script>

<style scoped>
.main-layout {
  height: 100vh;
}

.sidebar {
  background-color: #304156;
  overflow: hidden;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #2b3a4a;
  border-bottom: 1px solid #1f2d3d;
}

.logo h3 {
  margin: 0;
  color: #fff;
  font-size: 18px;
  font-weight: 600;
}

.sidebar-menu {
  border: none;
  height: calc(100vh - 60px);
  overflow-y: auto;
}

.header {
  background-color: #fff;
  border-bottom: 1px solid #e4e7ed;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
}

.header-left {
  display: flex;
  align-items: center;
}

.collapse-icon {
  font-size: 20px;
  cursor: pointer;
  color: #606266;
  transition: color 0.3s;
}

.collapse-icon:hover {
  color: #409eff;
}

.header-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.user-info:hover {
  background-color: #f5f7fa;
}

.username {
  font-size: 14px;
  color: #303133;
}

.main-content {
  background-color: #f0f2f5;
  padding: 20px;
  overflow-y: auto;
}

/* 滚动条样式 */
.sidebar-menu::-webkit-scrollbar,
.main-content::-webkit-scrollbar {
  width: 6px;
}

.sidebar-menu::-webkit-scrollbar-track,
.main-content::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.sidebar-menu::-webkit-scrollbar-thumb,
.main-content::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.sidebar-menu::-webkit-scrollbar-thumb:hover,
.main-content::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>

