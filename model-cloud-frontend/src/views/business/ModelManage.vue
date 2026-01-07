<template>
  <div class="model-manage-container">
    <el-card class="filter-card">
      <el-form :inline="true" :model="queryParams" class="demo-form-inline">
        <el-form-item label="模型名称">
          <el-input v-model="queryParams.keyword" placeholder="搜索模型名称或描述" clearable @keyup.enter="handleQuery" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="handleQuery">查询</el-button>
          <el-button :icon="Refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <div class="model-grid">
      <el-row :gutter="20">
        <el-col v-for="model in modelList" :key="model.id" :xs="24" :sm="12" :md="8" :lg="6" :xl="4">
          <el-card class="model-card" :body-style="{ padding: '0px' }">
            <div class="model-cover">
              <el-image :src="model.coverImage || defaultCover" fit="cover">
                <template #error>
                  <div class="image-slot">
                    <el-icon><Picture /></el-icon>
                  </div>
                </template>
              </el-image>
              <div class="status-badge">
                <el-tag type="warning" size="small">待审核</el-tag>
              </div>
            </div>
            <div class="model-info">
              <h3 class="model-name">{{ model.name }}</h3>
              <p class="model-desc">{{ model.description }}</p>
              <p class="model-author">上传者：{{ model.authorName || '未知' }}</p>
              <div class="model-footer">
                <span class="model-time">{{ formatDate(model.createTime) }}</span>
                <div class="model-actions">
                  <el-button type="success" link :icon="Check" @click="handleAudit(model, true)">通过</el-button>
                  <el-button type="danger" link :icon="Close" @click="handleAudit(model, false)">驳回</el-button>
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
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Search, Refresh, Picture, Check, Close } from '@element-plus/icons-vue'
import { modelApi } from '@/api/model'
import { ElMessage, ElMessageBox } from 'element-plus'
import dayjs from 'dayjs'

const modelList = ref<any[]>([])
const total = ref(0)
const defaultCover = 'https://placeholder.com/300x200'

const queryParams = ref({
  pageNum: 1,
  pageSize: 12,
  keyword: ''
})

const getList = async () => {
  try {
    const res: any = await modelApi.getPendingModels(queryParams.value)
    if (res.code === 200) {
      modelList.value = res.data.records || []
      total.value = res.data.totalRow || 0
    }
  } catch (error) {
    console.error('获取待审核模型失败', error)
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

const handleSizeChange = (val: number) => {
  queryParams.value.pageSize = val
  getList()
}

const handleCurrentChange = (val: number) => {
  queryParams.value.pageNum = val
  getList()
}

const formatDate = (date: string) => {
  return date ? dayjs(date).format('YYYY-MM-DD HH:mm') : '-'
}

const handleAudit = async (model: any, approved: boolean) => {
  const actionText = approved ? '通过' : '驳回'
  try {
    await ElMessageBox.confirm(`确认要${actionText}模型「${model.name}」吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: approved ? 'success' : 'warning'
    })
    const res: any = await modelApi.auditModel(model.id, approved)
    if (res.code === 200) {
      ElMessage.success(`${actionText}成功`)
      getList()
    } else {
      ElMessage.error(res.message || `${actionText}失败`)
    }
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error(`${actionText}失败`, error)
      ElMessage.error(`${actionText}失败`)
    }
  }
}

onMounted(() => {
  getList()
})
</script>

<style scoped>
.model-manage-container {
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

.status-badge {
  position: absolute;
  top: 8px;
  right: 8px;
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
  margin: 0 0 8px 0;
  font-size: 14px;
  color: #606266;
  height: 40px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.model-author {
  margin: 0 0 8px 0;
  font-size: 13px;
  color: #606266;
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
</style>


