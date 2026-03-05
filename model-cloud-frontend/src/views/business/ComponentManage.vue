<template>
  <div class="component-manage-container">
    <el-card class="filter-card">
      <el-form :inline="true" :model="queryParams">
        <el-form-item label="关键词">
          <el-input
            v-model="queryParams.keyword"
            placeholder="搜索名称或描述"
            clearable
            @keyup.enter="reloadActiveTab"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="reloadActiveTab">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card>
      <el-tabs v-model="activeTab" @tab-change="handleTabChange">
        <el-tab-pane label="基础组件库" name="component">
          <div class="toolbar">
            <el-button
              type="primary"
              :disabled="selectedComponentIds.length === 0"
              :loading="generatingIcons"
              @click="handleBatchGenerateIcons"
            >
              批量生成图标（{{ selectedComponentIds.length }}）
            </el-button>
          </div>
          <el-table :data="componentRows" stripe style="width: 100%" @selection-change="handleComponentSelectionChange">
            <el-table-column type="selection" width="55" />
            <el-table-column prop="id" label="ID" width="90" />
            <el-table-column prop="name" label="名称" min-width="220" />
            <el-table-column prop="description" label="描述" min-width="280" />
            <el-table-column prop="authorName" label="上传者" width="140" />
            <el-table-column label="类型" width="100">
              <template #default>
                <el-tag type="success">component</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="240">
              <template #default="{ row }">
                <el-button size="small" type="warning" @click="handleSingleRevert(row)">
                  转回模型
                </el-button>
                <el-button size="small" type="primary" @click="handleOpenDetail(row)">详情</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-container">
            <el-pagination
              v-model:current-page="queryParams.pageNum"
              v-model:page-size="queryParams.pageSize"
              :total="total"
              :page-sizes="[10, 20, 50, 100]"
              layout="total, sizes, prev, pager, next, jumper"
              @size-change="reloadActiveTab"
              @current-change="reloadActiveTab"
            />
          </div>
        </el-tab-pane>

        <el-tab-pane label="模型批量转组件" name="model">
          <div class="toolbar">
            <el-button
              type="success"
              :disabled="selectedModelIds.length === 0"
              :loading="converting"
              @click="handleBatchConvert"
            >
              批量转为基础组件（{{ selectedModelIds.length }}）
            </el-button>
          </div>
          <el-table
            :data="modelRows"
            stripe
            style="width: 100%"
            @selection-change="handleSelectionChange"
          >
            <el-table-column type="selection" width="55" />
            <el-table-column prop="id" label="ID" width="90" />
            <el-table-column prop="name" label="名称" min-width="220" />
            <el-table-column prop="description" label="描述" min-width="280" />
            <el-table-column prop="authorName" label="上传者" width="140" />
            <el-table-column label="公开状态" width="120">
              <template #default="{ row }">
                <el-tag :type="row.isPublic === 1 ? 'success' : 'info'">
                  {{ row.isPublic === 1 ? '公开' : '不公开' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="180">
              <template #default="{ row }">
                <el-button size="small" type="success" @click="handleSingleConvert(row)">
                  转为组件
                </el-button>
                <el-button size="small" type="primary" @click="handleOpenDetail(row)">详情</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-container">
            <el-pagination
              v-model:current-page="queryParams.pageNum"
              v-model:page-size="queryParams.pageSize"
              :total="total"
              :page-sizes="[10, 20, 50, 100]"
              layout="total, sizes, prev, pager, next, jumper"
              @size-change="reloadActiveTab"
              @current-change="reloadActiveTab"
            />
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { modelApi } from '@/api/model'

const router = useRouter()

const activeTab = ref<'component' | 'model'>('component')
const converting = ref(false)
const generatingIcons = ref(false)
const total = ref(0)
const componentRows = ref<any[]>([])
const modelRows = ref<any[]>([])
const selectedModelIds = ref<number[]>([])
const selectedComponentIds = ref<number[]>([])

const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  keyword: ''
})

const loadRows = async (modelKind: 'component' | 'model') => {
  const res: any = await modelApi.getAdminModels({
    pageNum: queryParams.pageNum,
    pageSize: queryParams.pageSize,
    keyword: queryParams.keyword,
    modelKind
  })
  if (res.code !== 200) {
    throw new Error(res.message || '加载失败')
  }
  total.value = res.data?.totalRow || 0
  const rows = res.data?.records || []
  if (modelKind === 'component') {
    componentRows.value = rows
  } else {
    modelRows.value = rows
  }
}

const reloadActiveTab = async () => {
  try {
    await loadRows(activeTab.value)
  } catch (error: any) {
    ElMessage.error(error.message || '加载失败')
  }
}

const handleTabChange = async () => {
  queryParams.pageNum = 1
  selectedModelIds.value = []
  selectedComponentIds.value = []
  await reloadActiveTab()
}

const resetQuery = async () => {
  queryParams.keyword = ''
  queryParams.pageNum = 1
  await reloadActiveTab()
}

const handleSelectionChange = (rows: any[]) => {
  selectedModelIds.value = rows.map((r) => Number(r.id))
}

const handleComponentSelectionChange = (rows: any[]) => {
  selectedComponentIds.value = rows.map((r) => Number(r.id))
}

const doBatchUpdate = async (ids: number[], modelKind: 'model' | 'component', successText: string) => {
  if (ids.length === 0) {
    ElMessage.warning('请先选择至少一条记录')
    return
  }
  converting.value = true
  try {
    const res: any = await modelApi.batchUpdateModelKind(ids, modelKind)
    if (res.code === 200) {
      ElMessage.success(successText)
      selectedModelIds.value = []
      await reloadActiveTab()
    } else {
      ElMessage.error(res.message || '操作失败')
    }
  } catch (error: any) {
    ElMessage.error(error.message || '操作失败')
  } finally {
    converting.value = false
  }
}

const handleBatchConvert = async () => {
  try {
    await ElMessageBox.confirm(
      `确认将选中的 ${selectedModelIds.value.length} 个模型转为基础组件吗？`,
      '确认操作',
      { type: 'warning' }
    )
    await doBatchUpdate(selectedModelIds.value, 'component', '批量转换成功')
  } catch {
    // 用户取消
  }
}

const handleSingleConvert = async (row: any) => {
  try {
    await ElMessageBox.confirm(`确认将模型「${row.name}」转为基础组件吗？`, '确认操作', { type: 'warning' })
    await doBatchUpdate([Number(row.id)], 'component', '转换成功')
  } catch {
    // 用户取消
  }
}

const handleSingleRevert = async (row: any) => {
  try {
    await ElMessageBox.confirm(`确认将组件「${row.name}」转回模型吗？`, '确认操作', { type: 'warning' })
    await doBatchUpdate([Number(row.id)], 'model', '已转回模型')
  } catch {
    // 用户取消
  }
}

const handleBatchGenerateIcons = async () => {
  if (selectedComponentIds.value.length === 0) {
    ElMessage.warning('请先选择至少一个组件')
    return
  }
  generatingIcons.value = true
  try {
    const res: any = await modelApi.batchGenerateIcons(selectedComponentIds.value)
    if (res.code !== 200) {
      ElMessage.error(res.message || '生成图标失败')
      return
    }
    const data = res.data || {}
    const success = Object.values(data).filter((v) => String(v || '').length > 0).length
    const fail = selectedComponentIds.value.length - success
    ElMessage.success(`图标生成完成：成功 ${success}，失败 ${fail}`)
    await reloadActiveTab()
  } catch (error: any) {
    ElMessage.error(error.message || '生成图标失败')
  } finally {
    generatingIcons.value = false
  }
}

const handleOpenDetail = (row: any) => {
  router.push(`/dashboard/model/detail/${row.id}`)
}

onMounted(async () => {
  await reloadActiveTab()
})
</script>

<style scoped>
.component-manage-container {
  padding: 0;
}

.filter-card {
  margin-bottom: 16px;
}

.toolbar {
  margin-bottom: 12px;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 16px;
}
</style>
