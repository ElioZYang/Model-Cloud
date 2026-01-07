<template>
  <div class="model-detail-container" v-if="model">
    <el-page-header @back="goBack" :title="model.name">
      <template #extra>
        <div class="header-extra">
          <el-button type="primary" :icon="Download" @click="downloadModel">下载模型</el-button>
          <el-button type="info" :icon="View" @click="viewSourceCode">查看源码</el-button>
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
      <!-- 左侧：封面图片和描述 -->
      <el-col :span="14">
        <el-card class="left-card">
          <!-- 封面图片 -->
          <div class="cover-section">
            <div class="model-cover-small">
              <el-image :src="model.coverImage || defaultCover" fit="contain">
                <template #error>
                  <div class="image-slot">
                    <el-icon><Picture /></el-icon>
                  </div>
                </template>
              </el-image>
            </div>
            <div class="cover-actions" v-if="canEdit">
              <el-button type="primary" size="small" :icon="Edit" @click="startEditCover">修改封面</el-button>
            </div>
          </div>

          <!-- 模型描述 -->
          <div class="description-section">
            <div class="section-header">
              <h3 class="section-title">模型描述</h3>
              <el-button 
                v-if="canEdit && !isEditingDescription" 
                type="text" 
                size="small" 
                :icon="Edit" 
                @click="startEditDescription"
              >
                编辑
              </el-button>
            </div>
            <div v-if="!isEditingDescription" class="description-content">
              <p class="description">{{ model.description || '暂无描述' }}</p>
            </div>
            <div v-else class="description-edit">
              <el-input
                v-model="editDescription"
                type="textarea"
                :rows="6"
                placeholder="请输入模型描述"
              />
              <div class="edit-actions">
                <el-button type="primary" size="small" @click="saveDescription" :loading="savingDescription">保存</el-button>
                <el-button size="small" @click="cancelEditDescription">取消</el-button>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 右侧：基本信息 -->
      <el-col :span="10">
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
          <div class="section">
            <h3 class="section-title">使用说明</h3>
            <p class="use-description">{{ model.useDescription || '暂无使用说明' }}</p>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 源码查看/编辑对话框 -->
    <el-dialog 
      v-model="sourceCodeDialogVisible" 
      title="模型源码" 
      width="80%"
      :close-on-click-modal="false"
    >
      <div v-if="loadingSourceCode" class="loading-container">
        <el-skeleton :rows="10" animated />
      </div>
      <div v-else>
        <div class="source-header">
          <span class="source-file-name">{{ sourceFileName || '模型文件' }}</span>
          <el-button 
            v-if="canEdit && !isEditingSourceCode" 
            type="primary" 
            size="small" 
            :icon="Edit" 
            @click="startEditSourceCode"
          >
            编辑
          </el-button>
        </div>
        <div v-if="!isEditingSourceCode" class="source-viewer">
          <pre><code>{{ sourceCode }}</code></pre>
        </div>
        <div v-else class="source-editor">
          <el-input
            v-model="editSourceCode"
            type="textarea"
            :rows="20"
            placeholder="请输入源码"
          />
          <div class="edit-actions">
            <el-button type="primary" @click="saveSourceCode" :loading="savingSourceCode">保存</el-button>
            <el-button @click="cancelEditSourceCode">取消</el-button>
          </div>
        </div>
      </div>
    </el-dialog>

    <!-- 修改封面对话框 -->
    <el-dialog
      v-model="coverDialogVisible"
      title="修改封面"
      width="500px"
      @close="onCoverDialogClose"
    >
      <div class="cover-upload">
        <el-upload
          :auto-upload="false"
          :on-change="handleCoverChange"
          :show-file-list="false"
          accept="image/*"
        >
          <el-button type="primary" size="small">选择图片</el-button>
        </el-upload>
        <div v-if="coverPreview" class="cover-preview">
          <el-image :src="coverPreview" fit="contain" style="max-width: 100%; max-height: 260px;" />
        </div>
        <div class="edit-actions">
          <el-button type="primary" size="small" @click="saveCover" :loading="savingCover">保存</el-button>
          <el-button size="small" @click="coverDialogVisible = false">取消</el-button>
        </div>
      </div>
    </el-dialog>
  </div>
  <div v-else-if="loading" class="loading-container">
    <el-skeleton :rows="10" animated />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Download, Star, StarFilled, Picture, Edit, View } from '@element-plus/icons-vue'
import { modelApi } from '@/api/model'
import { ElMessage } from 'element-plus'
import dayjs from 'dayjs'
import { useUserStore } from '@/stores/user'
import ModelDeleteButton from '@/components/model/ModelDeleteButton.vue'
import type { UploadFile } from 'element-plus'
import { refreshHomeStats } from '@/utils/stats'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const model = ref<any>(null)
const loading = ref(true)
const isCollected = ref(false)
const defaultCover = 'https://placeholder.com/300x200'

// 编辑状态
const coverDialogVisible = ref(false)
const isEditingDescription = ref(false)
const isEditingSourceCode = ref(false)
const coverPreview = ref<string | null>(null)
const coverFile = ref<File | null>(null)
const editDescription = ref('')
const editSourceCode = ref('')
const savingCover = ref(false)
const savingDescription = ref(false)
const savingSourceCode = ref(false)

// 源码相关
const sourceCodeDialogVisible = ref(false)
const sourceCode = ref('')
const sourceFileName = ref('')
const loadingSourceCode = ref(false)

const canEdit = computed(() => {
  if (!model.value || !userStore.userInfo) return false
  return model.value.userId === userStore.userInfo.id
})

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
      editDescription.value = res.data.description || ''
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
      const res: any = await modelApi.uncollectModel(modelId)
      if (res.code === 200) {
        isCollected.value = false
        ElMessage.success('已取消收藏')
        await refreshHomeStats()
      } else {
        ElMessage.error(res.message || '取消收藏失败')
      }
    } else {
      const res: any = await modelApi.collectModel(modelId)
      if (res.code === 200) {
        isCollected.value = true
        ElMessage.success('已收藏')
        await refreshHomeStats()
      } else {
        ElMessage.error(res.message || '收藏失败')
      }
    }
  } catch (error) {
    console.error('收藏操作失败', error)
    ElMessage.error('操作失败')
  }
}

// 封面编辑
const startEditCover = () => {
  coverDialogVisible.value = true
  coverPreview.value = null
  coverFile.value = null
}

const handleCoverChange = (file: UploadFile) => {
  if (file.raw) {
    coverFile.value = file.raw
    const reader = new FileReader()
    reader.onload = (e) => {
      coverPreview.value = e.target?.result as string
    }
    reader.readAsDataURL(file.raw)
  }
}

const saveCover = async () => {
  if (!coverFile.value) {
    ElMessage.warning('请选择封面图片')
    return
  }

  savingCover.value = true
  try {
    const res: any = await modelApi.updateModelCover(model.value.id, coverFile.value)
    if (res.code === 200) {
      ElMessage.success('更新封面成功')
      coverDialogVisible.value = false
      await getDetail() // 重新获取详情以更新封面URL
    } else {
      ElMessage.error(res.message || '更新失败')
    }
  } catch (error: any) {
    console.error('更新封面失败', error)
    ElMessage.error(error.message || '更新失败')
  } finally {
    savingCover.value = false
  }
}

const onCoverDialogClose = () => {
  coverPreview.value = null
  coverFile.value = null
}

// 描述编辑
const startEditDescription = () => {
  isEditingDescription.value = true
  editDescription.value = model.value.description || ''
}

const saveDescription = async () => {
  savingDescription.value = true
  try {
    const res: any = await modelApi.updateModelDescription(model.value.id, editDescription.value)
    if (res.code === 200) {
      ElMessage.success('更新描述成功')
      model.value.description = editDescription.value
      model.value.updateTime = new Date().toISOString()
      isEditingDescription.value = false
    } else {
      ElMessage.error(res.message || '更新失败')
    }
  } catch (error: any) {
    console.error('更新描述失败', error)
    ElMessage.error(error.message || '更新失败')
  } finally {
    savingDescription.value = false
  }
}

const cancelEditDescription = () => {
  isEditingDescription.value = false
  editDescription.value = model.value.description || ''
}

// 源码查看/编辑
const viewSourceCode = async () => {
  sourceCodeDialogVisible.value = true
  loadingSourceCode.value = true
  try {
    const res: any = await modelApi.getModelSourceCode(model.value.id)
    if (res.code === 200) {
      sourceCode.value = res.data.content || ''
      sourceFileName.value = res.data.fileName || 'model文件'
    } else {
      ElMessage.error(res.message || '获取源码失败')
    }
  } catch (error: any) {
    console.error('获取源码失败', error)
    ElMessage.error(error.message || '获取源码失败')
  } finally {
    loadingSourceCode.value = false
  }
}

const startEditSourceCode = () => {
  isEditingSourceCode.value = true
  editSourceCode.value = sourceCode.value
}

const saveSourceCode = async () => {
  savingSourceCode.value = true
  try {
    const res: any = await modelApi.updateModelSourceCode(
      model.value.id, 
      editSourceCode.value, 
      sourceFileName.value || 'model文件'
    )
    if (res.code === 200) {
      ElMessage.success('更新源码成功')
      sourceCode.value = editSourceCode.value
      model.value.updateTime = new Date().toISOString()
      isEditingSourceCode.value = false
    } else {
      ElMessage.error(res.message || '更新失败')
    }
  } catch (error: any) {
    console.error('更新源码失败', error)
    ElMessage.error(error.message || '更新失败')
  } finally {
    savingSourceCode.value = false
  }
}

const cancelEditSourceCode = () => {
  isEditingSourceCode.value = false
  editSourceCode.value = sourceCode.value
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

.left-card {
  margin-bottom: 20px;
}

.cover-section {
  margin-bottom: 24px;
}

.model-cover-small {
  width: 100%;
  height: 320px;
  background-color: #f5f7fa;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  border-radius: 6px;
  overflow: hidden;
  position: relative;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.model-cover-small .el-image {
  width: 100%;
  height: 100%;
}

.cover-actions {
  margin-top: 12px;
}

.cover-upload {
  text-align: center;
}

.cover-preview {
  margin-top: 12px;
}

.description-section {
  margin-top: 24px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin: 0;
  padding-left: 10px;
  border-left: 4px solid #409eff;
}

.description-content {
  min-height: 100px;
}

.description {
  font-size: 14px;
  color: #606266;
  line-height: 1.6;
  white-space: pre-wrap;
  margin: 0;
}

.description-edit {
  margin-top: 12px;
}

.edit-actions {
  margin-top: 12px;
  text-align: right;
}

.info-card {
  margin-bottom: 20px;
}

.info-card .info-item {
  display: flex;
  margin-bottom: 16px;
  font-size: 14px;
}

.info-card .label {
  width: 100px;
  color: #909399;
  flex-shrink: 0;
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

.section {
  margin-top: 24px;
}

.use-description {
  font-size: 14px;
  color: #606266;
  line-height: 1.6;
  white-space: pre-wrap;
  margin: 0;
}

.loading-container {
  padding: 20px;
  background-color: #fff;
}

.image-slot {
  font-size: 48px;
  color: #909399;
}

.source-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.source-file-name {
  font-weight: 600;
  color: #303133;
}

.source-viewer {
  background-color: #f5f7fa;
  padding: 16px;
  border-radius: 4px;
  max-height: 600px;
  overflow: auto;
}

.source-viewer pre {
  margin: 0;
  font-family: 'Courier New', monospace;
  font-size: 14px;
  line-height: 1.5;
}

.source-editor {
  margin-top: 12px;
}
</style>
