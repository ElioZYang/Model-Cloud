<template>
  <div class="model-list-container">
    <el-card class="filter-card">
      <el-form :inline="true" :model="queryParams" class="demo-form-inline">
        <el-form-item label="模型名称">
          <el-input v-model="queryParams.keyword" placeholder="搜索模型名称或描述" clearable @keyup.enter="handleQuery" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="handleQuery">查询</el-button>
          <el-button :icon="Refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
        <el-form-item style="float: right">
          <el-button type="success" :icon="Plus" @click="handleAdd">上传模型</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <div class="model-grid">
      <el-row :gutter="20">
        <el-col v-for="model in modelList" :key="model.id" :xs="24" :sm="12" :md="8" :lg="6" :xl="4">
          <el-card class="model-card" :body-style="{ padding: '0px' }" @click="viewDetail(model)">
            <div class="model-cover">
              <el-image :src="model.coverImage || defaultCover" fit="cover">
                <template #error>
                  <div class="image-slot">
                    <el-icon><Picture /></el-icon>
                  </div>
                </template>
              </el-image>
            </div>
            <div class="model-info">
              <h3 class="model-name">{{ model.name }}</h3>
              <p class="model-desc">{{ model.description }}</p>
              <div class="model-tags">
                <el-tag v-for="tag in getTags(model)" :key="tag" size="small" class="tag-item">
                  {{ tag }}
                </el-tag>
              </div>
              <div class="model-footer">
                <span class="model-time">{{ formatDate(model.createTime) }}</span>
                <el-button type="primary" link @click.stop="downloadModel(model)">下载</el-button>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <div class="pagination-container">
      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :page-sizes="[12, 24, 48, 96]"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </div>

    <!-- 上传模型对话框 -->
    <el-dialog v-model="dialogVisible" title="上传模型" width="600px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="模型名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入模型名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入模型描述" :rows="3" />
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
import { Search, Refresh, Plus, Picture } from '@element-plus/icons-vue'
import { modelApi } from '@/api/model'
import { ElMessage, type FormInstance, type UploadFile } from 'element-plus'
import dayjs from 'dayjs'

const router = useRouter()
const modelList = ref<any[]>([])
const total = ref(0)
const dialogVisible = ref(false)
const submitLoading = ref(false)
const formRef = ref<FormInstance>()
const defaultCover = 'https://placeholder.com/300x200'
const coverPreview = ref('')
const labelList = ref<any[]>([])

const queryParams = ref({
  pageNum: 1,
  pageSize: 12,
  keyword: ''
})

const form = ref({
  name: '',
  description: '',
  tags: [] as string[],
  coverImage: null as File | null,
  modelFile: null as File | null
})

const rules = {
  name: [{ required: true, message: '请输入模型名称', trigger: 'blur' }],
  description: [{ required: true, message: '请输入模型描述', trigger: 'blur' }],
  modelFile: [{ required: true, message: '请上传模型文件', trigger: 'change' }]
}

const getList = async () => {
  try {
    const res: any = await modelApi.getModelList(queryParams.value)
    if (res.code === 200) {
      modelList.value = res.data.records || []
      total.value = res.data.totalRow || 0
    }
  } catch (error) {
    console.error('获取列表失败', error)
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

const handleQuery = () => {
  queryParams.value.pageNum = 1
  getList()
}

const resetQuery = () => {
  queryParams.value.keyword = ''
  handleQuery()
}

const handleAdd = () => {
  dialogVisible.value = true
}

const handleSizeChange = (val: number) => {
  queryParams.value.pageSize = val
  getList()
}

const handleCurrentChange = (val: number) => {
  queryParams.value.pageNum = val
  getList()
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
          getList()
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
    tags: [],
    coverImage: null,
    modelFile: null
  }
  coverPreview.value = ''
  formRef.value?.resetFields()
}

const viewDetail = (model: any) => {
  router.push(`/dashboard/model/detail/${model.id}`)
}

const downloadModel = (model: any) => {
  if (model.repoUrl) {
    window.open(model.repoUrl, '_blank')
  } else {
    ElMessage.warning('暂无下载链接')
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
  getList()
  getLabelList()
})
</script>

<style scoped>
.model-list-container {
  padding: 0;
}

.filter-card {
  margin-bottom: 20px;
}

.model-grid {
  margin-bottom: 20px;
}

.model-card {
  margin-bottom: 20px;
  cursor: pointer;
  transition: transform 0.3s;
}

.model-card:hover {
  transform: translateY(-5px);
}

.model-cover {
  height: 180px;
  background-color: #f5f7fa;
  display: flex;
  justify-content: center;
  align-items: center;
  overflow: hidden;
}

.image-slot {
  font-size: 30px;
  color: #909399;
}

.model-info {
  padding: 14px;
}

.model-name {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: bold;
  color: #303133;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.model-desc {
  margin: 0 0 12px 0;
  font-size: 14px;
  color: #606266;
  height: 40px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.model-tags {
  margin-bottom: 12px;
  height: 24px;
  overflow: hidden;
}

.tag-item {
  margin-right: 5px;
}

.model-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.model-time {
  font-size: 12px;
  color: #909399;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
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
</style>

