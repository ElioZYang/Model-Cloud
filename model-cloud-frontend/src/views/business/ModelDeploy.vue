<template>
  <div class="model-deploy-container">
    <el-card class="header-card">
      <template #header>
        <div class="card-header">
          <h2>模型部署与仿真</h2>
          <p class="subtitle">选择公开模型库中的模型进行仿真和运行</p>
        </div>
      </template>
    </el-card>

    <!-- 模型筛选栏 -->
    <el-card class="filter-card" style="margin-top: 20px">
      <el-row :gutter="20" align="middle">
        <el-col :span="8">
          <el-input
            v-model="queryParams.keyword"
            placeholder="搜索模型名称或描述"
            clearable
            @clear="handleQuery"
            @keyup.enter="handleQuery"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </el-col>
        <el-col :span="6">
          <el-select
            v-model="queryParams.tag"
            placeholder="选择标签"
            clearable
            @change="handleQuery"
          >
            <el-option
              v-for="tag in tagList"
              :key="tag.id"
              :label="tag.name"
              :value="tag.name"
            />
          </el-select>
        </el-col>
        <el-col :span="4">
          <el-button type="primary" :icon="Search" @click="handleQuery">搜索</el-button>
        </el-col>
        <el-col :span="4">
          <el-button :icon="Refresh" @click="resetQuery">重置</el-button>
        </el-col>
      </el-row>
    </el-card>

    <!-- 模型列表 -->
    <div class="model-grid" style="margin-top: 20px">
      <el-row :gutter="20">
        <el-col
          v-for="model in modelList"
          :key="model.id"
          :xs="24"
          :sm="12"
          :md="8"
          :lg="6"
          :xl="4"
        >
          <el-card class="model-card" shadow="hover">
            <div class="model-cover" @click="viewModelDetail(model)">
              <el-image :src="model.coverImage || defaultCover" fit="cover">
                <template #error>
                  <div class="image-slot">
                    <el-icon><Picture /></el-icon>
                  </div>
                </template>
              </el-image>
            </div>
            <div class="model-info">
              <h3 class="model-name" @click="viewModelDetail(model)">{{ model.name }}</h3>
              <p class="model-desc">{{ model.description || '暂无描述' }}</p>
              <div class="model-tags">
                <el-tag v-for="tag in getTags(model)" :key="tag" size="small" class="tag-item">
                  {{ tag }}
                </el-tag>
              </div>
              <div class="model-actions">
                <el-button
                  type="primary"
                  :icon="CaretRight"
                  @click="openDeployDialog(model)"
                  style="width: 100%"
                >
                  部署仿真
                </el-button>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 分页 -->
    <div class="pagination-container" style="margin-top: 20px">
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

    <!-- 模型部署对话框 -->
    <el-dialog
      v-model="deployDialogVisible"
      :title="`部署模型: ${selectedModel?.name || ''}`"
      width="80%"
      :close-on-click-modal="false"
    >
      <div v-if="selectedModel" class="deploy-dialog-content">
        <!-- 模型信息 -->
        <el-card class="model-info-card" style="margin-bottom: 20px">
          <el-descriptions :column="2" border>
            <el-descriptions-item label="模型名称">{{ selectedModel.name }}</el-descriptions-item>
            <el-descriptions-item label="模型ID">{{ selectedModel.id }}</el-descriptions-item>
            <el-descriptions-item label="描述" :span="2">
              {{ selectedModel.description || '暂无描述' }}
            </el-descriptions-item>
            <el-descriptions-item label="标签">
              <el-tag
                v-for="tag in getTags(selectedModel)"
                :key="tag"
                size="small"
                style="margin-right: 5px"
              >
                {{ tag }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="创建时间">
              {{ formatDate(selectedModel.createTime) }}
            </el-descriptions-item>
          </el-descriptions>
        </el-card>

        <!-- 仿真参数配置 -->
        <el-card class="simulation-config-card" style="margin-bottom: 20px">
          <template #header>
            <div class="card-header">
              <span>仿真参数配置</span>
            </div>
          </template>
          <el-form :model="simulationParams" label-width="120px">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="仿真时长 (s)">
                  <el-input-number
                    v-model="simulationParams.duration"
                    :min="0.1"
                    :max="1000"
                    :step="0.1"
                    :precision="2"
                    style="width: 100%"
                  />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="步长 (s)">
                  <el-input-number
                    v-model="simulationParams.stepSize"
                    :min="0.001"
                    :max="1"
                    :step="0.001"
                    :precision="3"
                    style="width: 100%"
                  />
                </el-form-item>
              </el-col>
            </el-row>
            <el-form-item label="仿真方法">
              <el-select v-model="simulationParams.solver" style="width: 100%">
                <el-option label="DASSL (默认)" value="dassl" />
                <el-option label="Euler" value="euler" />
                <el-option label="Runge-Kutta" value="rk4" />
                <el-option label="CVode" value="cvode" />
              </el-select>
            </el-form-item>
            <el-form-item label="输入参数">
              <el-input
                v-model="simulationParams.inputParams"
                type="textarea"
                :rows="4"
                placeholder='请输入JSON格式的参数，例如: {"u": 12.0, "R": 1.0}'
              />
            </el-form-item>
          </el-form>
        </el-card>

        <!-- 仿真控制 -->
        <el-card class="simulation-control-card">
          <template #header>
            <div class="card-header">
              <span>仿真控制</span>
            </div>
          </template>
          <div class="control-buttons">
            <el-button
              type="primary"
              :icon="CaretRight"
              :loading="simulating"
              @click="startSimulation"
            >
              {{ simulating ? '仿真中...' : '开始仿真' }}
            </el-button>
            <el-button
              type="warning"
              :icon="CircleCheck"
              :disabled="!simulating"
              @click="pauseSimulation"
            >
              暂停
            </el-button>
            <el-button
              type="danger"
              :icon="Close"
              :disabled="!simulating"
              @click="stopSimulation"
            >
              停止
            </el-button>
            <el-button
              type="info"
              :icon="Download"
              :disabled="!simulationResult"
              @click="downloadResult"
            >
              下载结果
            </el-button>
          </div>
        </el-card>

        <!-- 仿真结果展示 -->
        <el-card
          v-if="simulationResult || simulationLogs.length > 0"
          class="simulation-result-card"
          style="margin-top: 20px"
        >
          <template #header>
            <div class="card-header">
              <span>仿真结果</span>
            </div>
          </template>
          <el-tabs v-model="activeTab">
            <el-tab-pane label="结果图表" name="chart">
              <div v-if="simulationResult" class="result-chart">
                <div class="chart-placeholder">
                  <el-icon class="chart-icon"><TrendCharts /></el-icon>
                  <p>仿真结果图表展示区域</p>
                  <p class="hint">（待后端接口实现后显示实际图表）</p>
                </div>
                <el-descriptions :column="2" border style="margin-top: 20px">
                  <el-descriptions-item label="仿真状态">
                    <el-tag type="success">完成</el-tag>
                  </el-descriptions-item>
                  <el-descriptions-item label="仿真时长">
                    {{ simulationParams.duration }}s
                  </el-descriptions-item>
                  <el-descriptions-item label="数据点数">
                    {{ Math.floor(simulationParams.duration / simulationParams.stepSize) }}
                  </el-descriptions-item>
                  <el-descriptions-item label="完成时间">
                    {{ new Date().toLocaleString() }}
                  </el-descriptions-item>
                </el-descriptions>
              </div>
              <el-empty v-else description="暂无仿真结果" />
            </el-tab-pane>
            <el-tab-pane label="运行日志" name="logs">
              <div class="simulation-logs">
                <el-scrollbar height="300px">
                  <div
                    v-for="(log, index) in simulationLogs"
                    :key="index"
                    class="log-item"
                    :class="log.type"
                  >
                    <span class="log-time">{{ log.time }}</span>
                    <span class="log-content">{{ log.message }}</span>
                  </div>
                  <div v-if="simulationLogs.length === 0" class="no-logs">
                    暂无日志
                  </div>
                </el-scrollbar>
              </div>
            </el-tab-pane>
            <el-tab-pane label="数据导出" name="export">
              <div class="export-section">
                <el-alert
                  title="数据导出功能"
                  type="info"
                  :closable="false"
                  style="margin-bottom: 20px"
                >
                  <template #default>
                    <p>支持导出以下格式：</p>
                    <ul>
                      <li>CSV 格式 - 用于 Excel 分析</li>
                      <li>MAT 格式 - 用于 MATLAB</li>
                      <li>JSON 格式 - 用于数据交换</li>
                    </ul>
                  </template>
                </el-alert>
                <el-button-group>
                  <el-button :icon="Document" @click="exportData('csv')">导出 CSV</el-button>
                  <el-button :icon="Document" @click="exportData('mat')">导出 MAT</el-button>
                  <el-button :icon="Document" @click="exportData('json')">导出 JSON</el-button>
                </el-button-group>
              </div>
            </el-tab-pane>
          </el-tabs>
        </el-card>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  Search,
  Refresh,
  Picture,
  CaretRight,
  CircleCheck,
  Close,
  Download,
  TrendCharts,
  Document
} from '@element-plus/icons-vue'
import { modelApi } from '@/api/model'
import { ElMessage } from 'element-plus'
import dayjs from 'dayjs'

const router = useRouter()

// 数据
const modelList = ref<any[]>([])
const total = ref(0)
const tagList = ref<any[]>([])
const defaultCover = 'https://via.placeholder.com/300x200?text=No+Image'

// 查询参数
const queryParams = ref({
  pageNum: 1,
  pageSize: 12,
  keyword: '',
  tag: '' as string | null
})

// 部署对话框
const deployDialogVisible = ref(false)
const selectedModel = ref<any>(null)

// 仿真参数
const simulationParams = ref({
  duration: 10.0,
  stepSize: 0.01,
  solver: 'dassl',
  inputParams: '{}'
})

// 仿真状态
const simulating = ref(false)
const simulationResult = ref<any>(null)
const simulationLogs = ref<Array<{ time: string; type: string; message: string }>>([])
const activeTab = ref('chart')

// 获取模型列表
const getList = async () => {
  try {
    const res: any = await modelApi.getModelList(queryParams.value)
    if (res.code === 200) {
      modelList.value = res.data.records || []
      total.value = res.data.total || 0
    }
  } catch (error) {
    console.error('获取模型列表失败:', error)
    ElMessage.error('获取模型列表失败')
  }
}

// 获取标签列表
const getTagList = async () => {
  try {
    const res: any = await modelApi.getLabelList()
    if (res.code === 200) {
      tagList.value = res.data || []
    }
  } catch (error) {
    console.error('获取标签列表失败:', error)
  }
}

// 搜索
const handleQuery = () => {
  queryParams.value.pageNum = 1
  getList()
}

// 重置
const resetQuery = () => {
  queryParams.value = {
    pageNum: 1,
    pageSize: 12,
    keyword: '',
    tag: null
  }
  getList()
}

// 分页
const handleSizeChange = (size: number) => {
  queryParams.value.pageSize = size
  getList()
}

const handleCurrentChange = (page: number) => {
  queryParams.value.pageNum = page
  getList()
}

// 获取标签
const getTags = (model: any) => {
  if (!model.attrLabelNames) return []
  return model.attrLabelNames.split(',').filter((tag: string) => tag.trim())
}

// 格式化日期
const formatDate = (date: string) => {
  return dayjs(date).format('YYYY-MM-DD HH:mm')
}

// 查看模型详情
const viewModelDetail = (model: any) => {
  router.push(`/dashboard/model/detail/${model.id}`)
}

// 打开部署对话框
const openDeployDialog = (model: any) => {
  selectedModel.value = model
  deployDialogVisible.value = true
  // 重置仿真状态
  simulating.value = false
  simulationResult.value = null
  simulationLogs.value = []
  activeTab.value = 'chart'
  // 重置仿真参数
  simulationParams.value = {
    duration: 10.0,
    stepSize: 0.01,
    solver: 'dassl',
    inputParams: '{}'
  }
}

// 开始仿真
const startSimulation = () => {
  if (!selectedModel.value) return

  // 验证输入参数
  try {
    JSON.parse(simulationParams.value.inputParams)
  } catch (error) {
    ElMessage.error('输入参数格式错误，请输入有效的JSON格式')
    return
  }

  simulating.value = true
  simulationResult.value = null
  simulationLogs.value = []

  // 添加日志
  addLog('info', '开始仿真...')
  addLog('info', `模型: ${selectedModel.value.name}`)
  addLog('info', `仿真时长: ${simulationParams.value.duration}s`)
  addLog('info', `步长: ${simulationParams.value.stepSize}s`)
  addLog('info', `求解器: ${simulationParams.value.solver}`)

  // 模拟仿真过程（待后端接口实现）
  setTimeout(() => {
    addLog('success', '模型加载成功')
    addLog('info', '初始化参数...')
    setTimeout(() => {
      addLog('info', '开始计算...')
      setTimeout(() => {
        addLog('success', '仿真完成')
        simulating.value = false
        simulationResult.value = {
          status: 'success',
          dataPoints: Math.floor(simulationParams.value.duration / simulationParams.value.stepSize),
          duration: simulationParams.value.duration
        }
        ElMessage.success('仿真完成')
      }, 2000)
    }, 1000)
  }, 1000)
}

// 暂停仿真
const pauseSimulation = () => {
  addLog('warning', '仿真已暂停')
  ElMessage.info('仿真已暂停')
}

// 停止仿真
const stopSimulation = () => {
  simulating.value = false
  addLog('warning', '仿真已停止')
  ElMessage.warning('仿真已停止')
}

// 添加日志
const addLog = (type: string, message: string) => {
  simulationLogs.value.push({
    time: new Date().toLocaleTimeString(),
    type,
    message
  })
}

// 下载结果
const downloadResult = () => {
  if (!simulationResult.value) {
    ElMessage.warning('暂无仿真结果')
    return
  }
  ElMessage.info('下载功能待实现')
}

// 导出数据
const exportData = (format: string) => {
  if (!simulationResult.value) {
    ElMessage.warning('暂无仿真结果')
    return
  }
  ElMessage.info(`导出 ${format.toUpperCase()} 格式功能待实现`)
}

// 初始化
onMounted(() => {
  getList()
  getTagList()
})
</script>

<style scoped>
.model-deploy-container {
  padding: 0;
}

.header-card .card-header {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.header-card .card-header h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: #303133;
}

.header-card .subtitle {
  margin: 0;
  color: #909399;
  font-size: 14px;
}

.model-grid {
  min-height: 400px;
}

.model-card {
  margin-bottom: 20px;
  cursor: pointer;
  transition: all 0.3s;
}

.model-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.model-cover {
  width: 100%;
  height: 200px;
  overflow: hidden;
  border-radius: 4px 4px 0 0;
}

.model-cover .el-image {
  width: 100%;
  height: 100%;
}

.image-slot {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
  background: #f5f7fa;
  color: #909399;
  font-size: 30px;
}

.model-info {
  padding: 15px;
}

.model-name {
  margin: 0 0 10px 0;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  cursor: pointer;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.model-name:hover {
  color: #409eff;
}

.model-desc {
  margin: 0 0 10px 0;
  font-size: 13px;
  color: #606266;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  min-height: 40px;
}

.model-tags {
  margin-bottom: 15px;
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
}

.tag-item {
  margin: 0;
}

.model-actions {
  margin-top: 10px;
}

.pagination-container {
  display: flex;
  justify-content: center;
  padding: 20px 0;
}

/* 部署对话框样式 */
.deploy-dialog-content {
  max-height: 70vh;
  overflow-y: auto;
}

.card-header {
  font-weight: 600;
  font-size: 16px;
}

.simulation-config-card,
.simulation-control-card,
.simulation-result-card {
  margin-bottom: 20px;
}

.control-buttons {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.result-chart {
  min-height: 300px;
}

.chart-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 300px;
  background: #f5f7fa;
  border-radius: 4px;
  color: #909399;
}

.chart-icon {
  font-size: 64px;
  margin-bottom: 20px;
  color: #c0c4cc;
}

.hint {
  font-size: 12px;
  color: #c0c4cc;
  margin-top: 10px;
}

.simulation-logs {
  background: #1e1e1e;
  border-radius: 4px;
  padding: 10px;
}

.log-item {
  padding: 5px 0;
  font-family: 'Courier New', monospace;
  font-size: 13px;
  line-height: 1.6;
}

.log-item .log-time {
  color: #888;
  margin-right: 10px;
}

.log-item.info .log-content {
  color: #409eff;
}

.log-item.success .log-content {
  color: #67c23a;
}

.log-item.warning .log-content {
  color: #e6a23c;
}

.log-item.error .log-content {
  color: #f56c6c;
}

.no-logs {
  text-align: center;
  color: #909399;
  padding: 20px;
}

.export-section {
  padding: 20px 0;
}
</style>

