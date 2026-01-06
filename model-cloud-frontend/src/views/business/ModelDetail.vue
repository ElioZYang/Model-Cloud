<template>
  <div class="model-detail-container" v-if="model">
    <el-page-header @back="goBack" :title="model.name">
      <template #extra>
        <div class="header-extra">
          <el-button type="primary" :icon="Download" @click="downloadModel">下载模型</el-button>
          <ModelDeleteButton
            v-if="canDelete"
            :model="{ id: model.id, name: model.name }"
            type="danger"
            :link="false"
            @deleted="handleDeleted"
          />
          <el-button type="warning" :icon="Star" v-if="!isCollected" @click="toggleCollect">收藏</el-button>
          <el-button type="info" :icon="StarFilled" v-else @click="toggleCollect">已收藏</el-button>
        </div>
      </template>
    </el-page-header>

    <el-row :gutter="20" class="detail-content">
      <el-col :span="16">
        <el-card class="main-card">
          <div class="model-cover-large">
            <el-image :src="model.coverImage || defaultCover" fit="contain">
              <template #error>
                <div class="image-slot">
                  <el-icon><Picture /></el-icon>
                </div>
              </template>
            </el-image>
          </div>
          <div class="section">
            <h3 class="section-title">模型描述</h3>
            <p class="description">{{ model.description }}</p>
          </div>
          <div class="section">
            <h3 class="section-title">使用说明</h3>
            <p class="use-description">{{ model.useDescription || '暂无使用说明' }}</p>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card class="info-card">
          <template #header>
            <div class="card-header">
              <span>基本信息</span>
            </div>
          </template>
          <div class="info-item">
            <span class="label">作者:</span>
            <span class="value">{{ model.authorName || '未知' }}</span>
          </div>
          <div class="info-item">
            <span class="label">创建时间:</span>
            <span class="value">{{ formatDate(model.createTime) }}</span>
          </div>
          <div class="info-item">
            <span class="label">更新时间:</span>
            <span class="value">{{ formatDate(model.updateTime) }}</span>
          </div>
          <div class="info-item">
            <span class="label">标签:</span>
            <div class="value tags">
              <el-tag v-for="tag in getTags(model)" :key="tag" size="small" class="tag-item">
                {{ tag }}
              </el-tag>
            </div>
          </div>
          <div class="info-item">
            <span class="label">仓库地址:</span>
            <div class="value">
              <el-link :href="model.repoUrl" target="_blank" type="primary">{{ model.repoName }}</el-link>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
  <div v-else-if="loading" class="loading-container">
    <el-skeleton :rows="10" animated />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Download, Star, StarFilled, Picture } from '@element-plus/icons-vue'
import { modelApi } from '@/api/model'
import { ElMessage } from 'element-plus'
import dayjs from 'dayjs'
import { useUserStore } from '@/stores/user'
import ModelDeleteButton from '@/components/model/ModelDeleteButton.vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const model = ref<any>(null)
const loading = ref(true)
const isCollected = ref(false)
const defaultCover = 'https://placeholder.com/600x400'
const canDelete = computed(() => {
  if (!model.value || !userStore.userInfo) return false
  if (userStore.isSuperAdmin) return true
  return model.value.userId === userStore.userInfo.id
})

const getDetail = async () => {
  const id = Number(route.params.id)
  if (isNaN(id)) {
    ElMessage.error('无效的模型ID')
    router.push('/dashboard/model/list')
    return
  }

  try {
    const res: any = await modelApi.getModelDetail(id)
    if (res.code === 200) {
      model.value = res.data
      // 检查是否已收藏
      checkCollected(id)
    } else {
      ElMessage.error(res.message || '获取详情失败')
    }
  } catch (error) {
    console.error('获取详情失败', error)
  } finally {
    loading.value = false
  }
}

const checkCollected = async (modelId: number) => {
  try {
    const res: any = await modelApi.checkCollected(modelId)
    if (res.code === 200) {
      isCollected.value = res.data || false
    }
  } catch (error) {
    console.error('检查收藏状态失败', error)
  }
}

const goBack = () => {
  router.back()
}

const downloadModel = () => {
  if (model.value?.repoUrl) {
    window.open(model.value.repoUrl, '_blank')
  } else {
    ElMessage.warning('暂无下载链接')
  }
}

const handleDeleted = () => {
  router.push('/dashboard/model/list')
}

const toggleCollect = async () => {
  if (!model.value) return
  
  const modelId = model.value.id
  try {
    if (isCollected.value) {
      // 取消收藏
      const res: any = await modelApi.uncollectModel(modelId)
      if (res.code === 200) {
        isCollected.value = false
        ElMessage.success('已取消收藏')
      } else {
        ElMessage.error(res.message || '取消收藏失败')
      }
    } else {
      // 收藏
      const res: any = await modelApi.collectModel(modelId)
      if (res.code === 200) {
        isCollected.value = true
        ElMessage.success('已收藏')
      } else {
        ElMessage.error(res.message || '收藏失败')
      }
    }
  } catch (error) {
    console.error('收藏操作失败', error)
    ElMessage.error('操作失败')
  }
}

const getTags = (model: any) => {
  if (!model.attrLabelNames) return []
  return model.attrLabelNames.split(',')
}

const formatDate = (date: string) => {
  return dayjs(date).format('YYYY-MM-DD HH:mm')
}

onMounted(() => {
  getDetail()
})
</script>

<style scoped>
.model-detail-container {
  padding: 0;
}

.header-extra {
  display: flex;
  gap: 12px;
}

.detail-content {
  margin-top: 20px;
}

.main-card {
  margin-bottom: 20px;
}

.model-cover-large {
  width: 100%;
  height: 400px;
  background-color: #f5f7fa;
  display: flex;
  justify-content: center;
  align-items: center;
  border-radius: 4px;
  margin-bottom: 24px;
  overflow: hidden;
}

.image-slot {
  font-size: 64px;
  color: #909399;
}

.section {
  margin-bottom: 24px;
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 16px;
  padding-left: 10px;
  border-left: 4px solid #409eff;
}

.description, .use-description {
  font-size: 14px;
  color: #606266;
  line-height: 1.6;
  white-space: pre-wrap;
}

.info-card .info-item {
  display: flex;
  margin-bottom: 16px;
  font-size: 14px;
}

.info-card .label {
  width: 80px;
  color: #909399;
}

.info-card .value {
  flex: 1;
  color: #303133;
}

.info-card .tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.loading-container {
  padding: 20px;
  background-color: #fff;
}
</style>

