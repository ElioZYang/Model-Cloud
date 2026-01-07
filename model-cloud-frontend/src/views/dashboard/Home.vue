<template>
  <div class="home-container">
    <el-card class="welcome-card">
      <template #header>
        <div class="card-header">
          <span>欢迎使用模型管理系统</span>
        </div>
      </template>
      <div class="welcome-content">
        <el-icon class="welcome-icon"><User /></el-icon>
        <h2>您好，{{ userStore.nickname }}！</h2>
        <p class="welcome-text">欢迎来到模型管理系统，您可以在这里管理您的模型资源。</p>
      </div>
    </el-card>
    
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card class="stat-card" @click="goToModelList">
          <div class="stat-content">
            <div class="stat-icon" style="background: #409eff;">
              <el-icon><Box /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ statsLoaded ? statistics.totalCount : '...' }}</div>
              <div class="stat-label">模型总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card" @click="goToMyCollects">
          <div class="stat-content">
            <div class="stat-icon" style="background: #67c23a;">
              <el-icon><Star /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ statsLoaded ? statistics.myCollectCount : '...' }}</div>
              <div class="stat-label">我的收藏</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card" @click="goToMyModels">
          <div class="stat-content">
            <div class="stat-icon" style="background: #e6a23c;">
              <el-icon><Upload /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ statsLoaded ? statistics.myUploadCount : '...' }}</div>
              <div class="stat-label">我的模型</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #f56c6c;">
              <el-icon><View /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ statsLoaded ? statistics.viewCount : '...' }}</div>
              <div class="stat-label">浏览量</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    
    <el-row :gutter="20" class="quick-actions-row">
      <el-col :span="12">
        <el-card>
          <template #header>
            <span>快速操作</span>
          </template>
          <div class="quick-actions">
            <el-button type="primary" :icon="Plus" @click="handleUpload">上传模型</el-button>
            <el-button type="success" :icon="Search" @click="handleSearch">搜索模型</el-button>
            <el-button type="info" :icon="Setting">系统设置</el-button>
          </div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <template #header>
            <span>最近活动</span>
          </template>
          <div v-if="activities.length === 0">
            <el-empty description="暂无活动记录" :image-size="80" />
          </div>
          <div v-else class="activity-list">
            <el-timeline>
              <el-timeline-item
                v-for="item in activities"
                :key="item.id"
                :timestamp="formatDate(item.updateTime || item.createTime)"
                :color="item.status === 30 ? '#f56c6c' : '#409eff'"
              >
                <span :class="{ failed: item.status === 30 }">
                  模型《{{ item.name }}》{{ item.status === 30 ? '审核失败' : '状态更新' }}
                </span>
              </el-timeline-item>
            </el-timeline>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 上传模型对话框 -->
    <ModelUploadDialog v-model="dialogVisible" @success="handleUploadSuccess" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { User, Box, Star, Upload, View, Plus, Search, Setting } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { modelApi } from '@/api/model'
import dayjs from 'dayjs'
import ModelUploadDialog from '@/components/model/ModelUploadDialog.vue'

const userStore = useUserStore()
const router = useRouter()

const statistics = ref({
  totalCount: 0,
  myUploadCount: 0,
  myCollectCount: 0,
  viewCount: 0
})
const statsLoaded = ref(false)

const initStatsFromSession = () => {
  const saved = sessionStorage.getItem('modelStats')
  if (saved) {
    try {
      const parsed = JSON.parse(saved)
      statistics.value = { ...statistics.value, ...parsed }
      statsLoaded.value = true
    } catch (e) {
      console.error('恢复统计信息失败', e)
      sessionStorage.removeItem('modelStats')
    }
  }
}

const activities = ref<any[]>([])

const dialogVisible = ref(false)

const getStatistics = async () => {
  try {
    const res: any = await modelApi.getStatistics()
    if (res.code === 200) {
      statistics.value = res.data || statistics.value
      statsLoaded.value = true
      sessionStorage.setItem('modelStats', JSON.stringify(statistics.value))
    }
  } catch (error) {
    console.error('获取统计信息失败', error)
  }
}

const getActivities = async () => {
  try {
    const res: any = await modelApi.getMyActivities(10)
    if (res.code === 200) {
      activities.value = res.data || []
    }
  } catch (error) {
    console.error('获取活动失败', error)
  }
}

const goToModelList = () => {
  router.push('/dashboard/model/list')
}

const goToMyCollects = () => {
  router.push('/dashboard/model/collects')
}

const goToMyModels = () => {
  router.push('/dashboard/model/my')
}

const handleUpload = () => {
  dialogVisible.value = true
}

const handleUploadSuccess = () => {
  dialogVisible.value = false
  getStatistics()
}

const handleSearch = () => {
  router.push('/dashboard/model/list')
}

const formatDate = (date: string) => {
  return date ? dayjs(date).format('YYYY-MM-DD HH:mm') : '-'
}

// SSE连接相关
let eventSource: EventSource | null = null
let reconnectTimer: number | null = null

// 建立SSE连接，实时接收浏览量更新
const connectSSE = () => {
  // 如果已经存在连接，先关闭
  if (eventSource) {
    disconnectSSE()
  }

  // 如果浏览器不支持EventSource，则不建立连接
  if (typeof EventSource === 'undefined') {
    console.warn('浏览器不支持EventSource，无法建立SSE连接')
    return
  }

  try {
    // 获取baseURL（从axios配置中获取）
    const baseURL = '/api'
    const sseUrl = `${baseURL}/sse/visit-count`
    
    eventSource = new EventSource(sseUrl)
    
    // 监听连接成功事件
    eventSource.addEventListener('connected', (event: any) => {
      console.log('SSE连接成功:', event.data)
      // 清除重连定时器
      if (reconnectTimer) {
        clearTimeout(reconnectTimer)
        reconnectTimer = null
      }
    })
    
    // 监听浏览量更新事件
    eventSource.addEventListener('visitCountUpdate', (event: any) => {
      const newCount = parseInt(event.data, 10)
      if (!isNaN(newCount)) {
        console.log('收到浏览量更新:', newCount)
        statistics.value.viewCount = newCount
        // 同步更新sessionStorage
        const saved = sessionStorage.getItem('modelStats')
        if (saved) {
          try {
            const parsed = JSON.parse(saved)
            parsed.viewCount = newCount
            sessionStorage.setItem('modelStats', JSON.stringify(parsed))
          } catch (e) {
            console.error('更新sessionStorage失败', e)
          }
        }
      }
    })
    
    // 监听错误事件
    eventSource.onerror = (error) => {
      console.error('SSE连接错误:', error)
      // EventSource会自动重连，但如果连接完全关闭，我们手动重连
      if (eventSource?.readyState === EventSource.CLOSED) {
        // 清除之前的重连定时器
        if (reconnectTimer) {
          clearTimeout(reconnectTimer)
        }
        // 5秒后尝试重连
        reconnectTimer = window.setTimeout(() => {
          console.log('尝试重新连接SSE...')
          connectSSE()
        }, 5000)
      }
    }
  } catch (error) {
    console.error('建立SSE连接失败:', error)
  }
}

// 关闭SSE连接
const disconnectSSE = () => {
  if (reconnectTimer) {
    clearTimeout(reconnectTimer)
    reconnectTimer = null
  }
  if (eventSource) {
    eventSource.close()
    eventSource = null
    console.log('SSE连接已关闭')
  }
}

onMounted(() => {
  initStatsFromSession()
  if (!statsLoaded.value) {
    getStatistics()
  }
  getActivities()
  // 建立SSE连接
  connectSSE()
})

onUnmounted(() => {
  // 组件销毁时关闭SSE连接
  disconnectSSE()
})
</script>

<style scoped>
.home-container {
  padding: 0;
}

.welcome-card {
  margin-bottom: 20px;
}

.card-header {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.welcome-content {
  text-align: center;
  padding: 40px 20px;
}

.welcome-icon {
  font-size: 64px;
  color: #409eff;
  margin-bottom: 20px;
}

.welcome-content h2 {
  margin: 20px 0 10px 0;
  color: #303133;
  font-size: 24px;
}

.welcome-text {
  color: #909399;
  font-size: 14px;
  margin: 0;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  cursor: pointer;
  transition: all 0.3s;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 20px;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 28px;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 32px;
  font-weight: bold;
  color: #303133;
  line-height: 1;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.quick-actions-row {
  margin-bottom: 20px;
}

.quick-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.avatar-uploader .avatar {
  width: 178px;
  height: 178px;
  display: block;
  object-fit: cover;
}

.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 178px;
  height: 178px;
  text-align: center;
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  line-height: 178px;
}

.activity-list {
  max-height: 260px;
  overflow-y: auto;
}

.failed {
  color: #f56c6c;
}
</style>


