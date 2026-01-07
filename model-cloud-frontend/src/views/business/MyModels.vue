<template>
  <div class="model-list-container">
    <ModelFilterBar
      v-model:keyword="queryParams.keyword"
      v-model:tag="queryParams.tag"
      v-model:isPublic="queryParams.isPublic"
      :show-public-filter="true"
      @search="handleQuery"
      @reset="resetQuery"
    />
    <div style="margin-bottom: 12px; text-align: right">
      <el-button type="success" :icon="Plus" @click="handleAdd">上传模型</el-button>
    </div>

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
              <div class="public-badge">
                <el-tag :type="model.isPublic === 1 ? 'success' : 'info'" size="small">
                  {{ model.isPublic === 1 ? '公开' : '不公开' }}
                </el-tag>
                <el-tag 
                  v-if="model.isPublic === 1" 
                  :type="getStatusTagType(model.status)" 
                  size="small" 
                  style="margin-left: 4px"
                >
                  {{ getStatusText(model.status) }}
                </el-tag>
              </div>
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
                <div class="model-actions">
                  <el-button type="primary" link @click.stop="downloadModel(model)">下载</el-button>
                  <el-button type="warning" link @click.stop="togglePublic(model)">设置公开</el-button>
                  <ModelDeleteButton
                    :model="{ id: model.id, name: model.name }"
                    link
                    type="danger"
                    @deleted="getList"
                  />
                </div>
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

    <ModelUploadDialog v-model="dialogVisible" @success="getList" />

    <!-- 设置公开状态对话框 -->
    <el-dialog v-model="publicDialogVisible" title="设置公开状态" width="400px">
      <el-form :model="publicForm" label-width="100px">
        <el-form-item label="当前状态">
          <el-tag :type="currentModel?.isPublic === 1 ? 'success' : 'info'">
            {{ currentModel?.isPublic === 1 ? '公开' : '不公开' }}
          </el-tag>
        </el-form-item>
        <el-form-item label="新状态">
          <el-radio-group v-model="publicForm.isPublic">
            <el-radio :label="0">不公开</el-radio>
            <el-radio :label="1">公开</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="publicDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="publicSubmitting" @click="submitPublicChange">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Plus, Picture } from '@element-plus/icons-vue'
import { modelApi } from '@/api/model'
import { ElMessage, ElMessageBox } from 'element-plus'
import dayjs from 'dayjs'
import ModelUploadDialog from '@/components/model/ModelUploadDialog.vue'
import ModelDeleteButton from '@/components/model/ModelDeleteButton.vue'
import ModelFilterBar from '@/components/model/ModelFilterBar.vue'

const router = useRouter()
const modelList = ref<any[]>([])
const total = ref(0)
const dialogVisible = ref(false)
const publicDialogVisible = ref(false)
const publicSubmitting = ref(false)
const defaultCover = 'https://placeholder.com/300x200'
const currentModel = ref<any>(null)

const queryParams = ref({
  pageNum: 1,
  pageSize: 12,
  keyword: '',
  isPublic: undefined as number | undefined,
  tag: '' as string | null
})

const publicForm = ref({
  isPublic: 0
})

const getList = async () => {
  try {
    const res: any = await modelApi.getMyModels(queryParams.value)
    if (res.code === 200) {
      modelList.value = res.data.records || []
      total.value = res.data.totalRow || 0
    }
  } catch (error) {
    console.error('获取列表失败', error)
  }
}

const handleQuery = () => {
  queryParams.value.pageNum = 1
  getList()
}

const resetQuery = () => {
  queryParams.value.keyword = ''
  queryParams.value.isPublic = undefined
  queryParams.value.tag = ''
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

const getStatusText = (status: number) => {
  const statusMap: Record<number, string> = {
    0: '初始状态',
    10: '待审核',
    20: '审核通过',
    30: '审核不通过'
  }
  return statusMap[status] || '未知'
}

const getStatusTagType = (status: number) => {
  if (status === 20) return 'success'
  if (status === 30) return 'danger'
  if (status === 10) return 'warning'
  return 'info'
}

const togglePublic = (model: any) => {
  currentModel.value = model
  publicForm.value.isPublic = model.isPublic
  publicDialogVisible.value = true
}

const submitPublicChange = async () => {
  if (!currentModel.value) return
  
  if (publicForm.value.isPublic === currentModel.value.isPublic) {
    publicDialogVisible.value = false
    return
  }

  publicSubmitting.value = true
  try {
    const res: any = await modelApi.updateModelPublic(currentModel.value.id, publicForm.value.isPublic)
    if (res.code === 200) {
      ElMessage.success('设置成功')
      publicDialogVisible.value = false
      getList()
    } else {
      ElMessage.error(res.message || '设置失败')
    }
  } catch (error) {
    console.error('设置失败', error)
    ElMessage.error('设置失败')
  } finally {
    publicSubmitting.value = false
  }
}

const handleDelete = async (model: any) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除模型"${model.name}"吗？此操作将删除数据库记录和Gitea仓库，且无法恢复！`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    const res: any = await modelApi.deleteModel(model.id)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      getList()
    } else {
      ElMessage.error(res.message || '删除失败')
    }
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('删除失败', error)
      ElMessage.error('删除失败')
    }
  }
}

onMounted(() => {
  getList()
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
  position: relative;
}

.public-badge {
  position: absolute;
  top: 8px;
  right: 8px;
  display: flex;
  flex-direction: column;
  gap: 4px;
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

.model-actions {
  display: flex;
  gap: 8px;
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

