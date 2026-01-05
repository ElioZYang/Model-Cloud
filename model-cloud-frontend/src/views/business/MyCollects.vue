<template>
  <div class="collect-list-container">
    <el-card class="header-card">
      <h2>我的收藏</h2>
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

    <div v-if="modelList.length === 0 && !loading" class="empty-container">
      <el-empty description="暂无收藏的模型" :image-size="120" />
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
import { useRouter } from 'vue-router'
import { Picture } from '@element-plus/icons-vue'
import { modelApi } from '@/api/model'
import { ElMessage } from 'element-plus'
import dayjs from 'dayjs'

const router = useRouter()
const modelList = ref<any[]>([])
const total = ref(0)
const loading = ref(false)
const defaultCover = 'https://placeholder.com/300x200'

const queryParams = ref({
  pageNum: 1,
  pageSize: 12
})

const getList = async () => {
  loading.value = true
  try {
    const res: any = await modelApi.getMyCollects(queryParams.value)
    if (res.code === 200) {
      modelList.value = res.data.records || []
      total.value = res.data.totalRow || 0
    }
  } catch (error) {
    console.error('获取收藏列表失败', error)
    ElMessage.error('获取收藏列表失败')
  } finally {
    loading.value = false
  }
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

onMounted(() => {
  getList()
})
</script>

<style scoped>
.collect-list-container {
  padding: 0;
}

.header-card {
  margin-bottom: 20px;
}

.header-card h2 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #303133;
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

.empty-container {
  padding: 60px 0;
  text-align: center;
}
</style>

