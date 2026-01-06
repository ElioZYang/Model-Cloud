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
              <div class="stat-value">{{ statistics.totalCount || 0 }}</div>
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
              <div class="stat-value">{{ statistics.myCollectCount || 0 }}</div>
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
              <div class="stat-value">{{ statistics.myUploadCount || 0 }}</div>
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
              <div class="stat-value">{{ statistics.viewCount || 0 }}</div>
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
    <el-dialog v-model="dialogVisible" title="上传模型" width="600px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="模型名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入模型名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入模型描述" :rows="3" />
        </el-form-item>
        <el-form-item label="是否公开" prop="isPublic">
          <el-radio-group v-model="form.isPublic">
            <el-radio :label="0">不公开</el-radio>
            <el-radio :label="1">公开</el-radio>
          </el-radio-group>
          <el-text type="info" size="small" style="display: block; margin-top: 5px">
            普通用户公开模型需要管理员审核通过后才能在公开模型列表中展示
          </el-text>
        </el-form-item>
        <el-form-item label="标签" prop="tags">
          <el-select v-model="form.tags" multiple placeholder="请选择相关标签" style="width: 100%">
            <el-option v-for="label in labelList" :key="label.id" :label="label.name" :value="label.name" />
          </el-select>
        </el-form-item>
        <el-form-item label="封面图片" prop="coverImage">
          <el-upload
            class="avatar-uploader"
            action="#"
            :show-file-list="false"
            :auto-upload="false"
            :on-change="handleCoverChange"
          >
            <img v-if="coverPreview" :src="coverPreview" class="avatar" />
            <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
          </el-upload>
        </el-form-item>
        <el-form-item label="模型文件" prop="modelFile">
          <el-upload
            class="upload-demo"
            action="#"
            :auto-upload="false"
            :on-change="handleFileChange"
            :limit="1"
          >
            <template #trigger>
              <el-button type="primary">选择文件</el-button>
            </template>
            <template #tip>
              <div class="el-upload__tip">文件大小不超过 500MB</div>
            </template>
          </el-upload>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="submitLoading" @click="submitForm">确定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { User, Box, Star, Upload, View, Plus, Search, Setting } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { modelApi } from '@/api/model'
import { ElMessage, type FormInstance, type UploadFile } from 'element-plus'
import dayjs from 'dayjs'

const userStore = useUserStore()
const router = useRouter()

const statistics = ref({
  totalCount: 0,
  myUploadCount: 0,
  myCollectCount: 0,
  viewCount: 0
})

const activities = ref<any[]>([])

const dialogVisible = ref(false)
const submitLoading = ref(false)
const formRef = ref<FormInstance>()
const coverPreview = ref('')
const labelList = ref<any[]>([])

const form = ref({
  name: '',
  description: '',
  isPublic: 0, // 默认不公开
  tags: [] as string[],
  coverImage: null as File | null,
  modelFile: null as File | null
})

const rules = {
  name: [{ required: true, message: '请输入模型名称', trigger: 'blur' }],
  description: [{ required: true, message: '请输入模型描述', trigger: 'blur' }],
  modelFile: [{ required: true, message: '请上传模型文件', trigger: 'change' }]
}

const getStatistics = async () => {
  try {
    const res: any = await modelApi.getStatistics()
    if (res.code === 200) {
      statistics.value = res.data || statistics.value
    }
  } catch (error) {
    console.error('获取统计信息失败', error)
  }
}

const getLabelList = async () => {
  try {
    const res: any = await modelApi.getLabelList()
    if (res.code === 200) {
      labelList.value = res.data || []
    }
  } catch (error) {
    console.error('获取标签列表失败', error)
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
  if (labelList.value.length === 0) {
    getLabelList()
  }
}

const handleSearch = () => {
  router.push('/dashboard/model/list')
}

const handleCoverChange = (file: UploadFile) => {
  if (file.raw) {
    form.value.coverImage = file.raw
    coverPreview.value = URL.createObjectURL(file.raw)
  }
}

const handleFileChange = (file: UploadFile) => {
  if (file.raw) {
    form.value.modelFile = file.raw
  }
}

const submitForm = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitLoading.value = true
      try {
        const formData = new FormData()
        formData.append('name', form.value.name)
        formData.append('description', form.value.description)
        formData.append('isPublic', form.value.isPublic.toString())
        form.value.tags.forEach(tag => formData.append('tags', tag))
        if (form.value.coverImage) {
          formData.append('coverImage', form.value.coverImage)
        }
        if (form.value.modelFile) {
          formData.append('modelFile', form.value.modelFile)
        }

        const res: any = await modelApi.createModel(formData)
        if (res.code === 200) {
          ElMessage.success('上传成功')
          dialogVisible.value = false
          // 刷新统计数据
          getStatistics()
        } else {
          ElMessage.error(res.message || '上传失败')
        }
      } catch (error) {
        console.error('上传失败', error)
        ElMessage.error('上传失败')
      } finally {
        submitLoading.value = false
      }
    }
  })
}

const resetForm = () => {
  form.value = {
    name: '',
    description: '',
    isPublic: 0,
    tags: [],
    coverImage: null,
    modelFile: null
  }
  coverPreview.value = ''
  formRef.value?.resetFields()
}

const formatDate = (date: string) => {
  return date ? dayjs(date).format('YYYY-MM-DD HH:mm') : '-'
}

onMounted(() => {
  getStatistics()
  getActivities()
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


