<template>
  <div class="model-deploy-container" v-loading="loading">
    <!-- 顶部工具栏 -->
    <el-card class="toolbar-card">
      <div class="toolbar">
        <div class="toolbar-left">
          <h2>Modelica在线建模与仿真</h2>
        </div>
        <div class="toolbar-right">
          <el-button :icon="Document" @click="showProjectDialog = true">我的项目</el-button>
          <el-button type="primary" :icon="FolderOpened" @click="handleNewProject">新建项目</el-button>
          <el-button :icon="DocumentAdd" @click="handleSaveProject" :loading="saving">保存项目</el-button>
        </div>
      </div>
    </el-card>

    <!-- 主工作区 -->
    <div class="main-workspace">
      <!-- 左侧：组件库面板 -->
      <el-card class="component-panel" shadow="never">
        <template #header>
          <div class="panel-header">
            <span>组件库</span>
            <el-input
              v-model="componentSearchKeyword"
              placeholder="搜索组件"
              size="small"
              clearable
              style="width: 150px"
              @input="handleComponentSearch"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </div>
        </template>
        <div class="component-list">
          <div
            v-for="component in filteredComponents"
            :key="component.id"
            class="component-item"
            draggable="true"
            @dragstart="handleDragStart($event, component)"
          >
            <el-image
              :src="component.coverImage || defaultCover"
              class="component-icon"
              fit="cover"
              :preview-src-list="[]"
              :initial-index="0"
            >
              <template #error>
                <el-icon class="component-icon-fallback"><Box /></el-icon>
              </template>
            </el-image>
            <div class="component-info">
              <div class="component-name">{{ component.name }}</div>
              <div class="component-desc">{{ component.description || '无描述' }}</div>
            </div>
          </div>
          <el-empty v-if="filteredComponents.length === 0" description="暂无组件" :image-size="80" />
        </div>
      </el-card>

      <!-- 中间：建模画布 -->
      <div class="canvas-area">
        <el-card class="canvas-card" shadow="never">
          <template #header>
            <div class="panel-header">
              <span>建模画布</span>
              <div>
                <el-button size="small" :icon="Delete" @click="handleClearCanvas">清空</el-button>
                <el-button size="small" :icon="View" @click="handlePreviewCode">预览代码</el-button>
              </div>
            </div>
          </template>
          <div class="vue-flow-container" ref="flowContainer">
            <VueFlow
              v-model:nodes="nodes"
              v-model:edges="edges"
              :default-edge-options="{ type: 'smoothstep' }"
              :node-types="nodeTypes"
              @node-click="handleNodeClick"
              @edge-click="handleEdgeClick"
              @pane-click="handlePaneClick"
              @connect="handleConnect"
              class="vue-flow"
            />
          </div>
        </el-card>
      </div>

      <!-- 右侧：属性面板 -->
      <el-card class="property-panel" shadow="never">
        <template #header>
          <span>属性编辑</span>
        </template>
        <div v-if="selectedNode" class="property-content">
          <el-form :model="selectedNodeProperties" label-width="100px" size="small">
            <el-form-item label="组件名称">
              <el-input v-model="selectedNode.data.label" disabled />
            </el-form-item>
            <el-form-item label="组件类型">
              <el-input v-model="selectedNode.data.componentType" disabled />
            </el-form-item>
            <div v-if="selectedNodeProperties && Object.keys(selectedNodeProperties).length > 0">
              <el-divider>组件参数</el-divider>
              <el-form-item
                v-for="(value, key) in selectedNodeProperties"
                :key="key"
                :label="key"
              >
                <el-input-number
                  v-if="typeof value === 'number'"
                  v-model="selectedNodeProperties[key]"
                  :precision="3"
                  @change="handlePropertyChange"
                />
                <el-input
                  v-else
                  v-model="selectedNodeProperties[key]"
                  @change="handlePropertyChange"
                />
              </el-form-item>
            </div>
            <el-form-item>
              <el-button type="danger" size="small" @click="handleDeleteNode">删除组件</el-button>
            </el-form-item>
          </el-form>
        </div>
        <el-empty v-else description="请选择组件进行编辑" :image-size="80" />
      </el-card>
    </div>

    <!-- 底部：仿真控制面板 -->
    <el-card class="simulation-panel" shadow="never">
      <template #header>
        <div class="panel-header">
          <span>仿真控制</span>
          <div>
            <el-button
              type="primary"
              :icon="CaretRight"
              :loading="simulating"
              @click="handleStartSimulation"
              :disabled="nodes.length === 0"
            >
              {{ simulating ? '仿真中...' : '开始仿真' }}
            </el-button>
            <el-button
              type="warning"
              :icon="VideoPause"
              :disabled="!simulating"
              @click="handlePauseSimulation"
            >
              暂停
            </el-button>
            <el-button
              type="danger"
              :icon="Close"
              :disabled="!simulating"
              @click="handleStopSimulation"
            >
              停止
            </el-button>
          </div>
        </div>
      </template>
      <el-form :model="simulationParams" label-width="120px" size="small" inline>
        <el-form-item label="仿真时长 (s)">
          <el-input-number
            v-model="simulationParams.stopTime"
            :min="0.1"
            :max="1000"
            :step="0.1"
            :precision="2"
          />
        </el-form-item>
        <el-form-item label="步长 (s)">
          <el-input-number
            v-model="simulationParams.stepSize"
            :min="0.001"
            :max="1"
            :step="0.001"
            :precision="3"
          />
        </el-form-item>
        <el-form-item label="求解器">
          <el-select v-model="simulationParams.solver" style="width: 150px">
            <el-option label="DASSL" value="dassl" />
            <el-option label="Euler" value="euler" />
            <el-option label="Runge-Kutta" value="rk4" />
            <el-option label="CVode" value="cvode" />
          </el-select>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 仿真结果对话框 -->
    <el-dialog
      v-model="resultDialogVisible"
      title="仿真结果"
      width="80%"
      :close-on-click-modal="false"
    >
      <el-tabs v-model="resultTab">
        <el-tab-pane label="结果图表" name="chart">
          <div ref="chartContainer" style="width: 100%; height: 500px"></div>
        </el-tab-pane>
        <el-tab-pane label="运行日志" name="logs">
          <div class="simulation-logs">
            <div
              v-for="(log, index) in simulationLogs"
              :key="index"
              class="log-item"
              :class="log.type"
            >
              <span class="log-time">{{ log.time }}</span>
              <span class="log-content">{{ log.message }}</span>
            </div>
            <el-empty v-if="simulationLogs.length === 0" description="暂无日志" />
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-dialog>

    <!-- 代码预览对话框 -->
    <el-dialog v-model="codePreviewVisible" title="Modelica代码预览" width="70%">
      <el-input
        v-model="generatedCode"
        type="textarea"
        :rows="20"
        readonly
        style="font-family: 'Courier New', monospace"
      />
      <template #footer>
        <el-button @click="codePreviewVisible = false">关闭</el-button>
        <el-button type="primary" @click="handleCopyCode">复制代码</el-button>
      </template>
    </el-dialog>

    <!-- 项目列表对话框 -->
    <el-dialog v-model="showProjectDialog" title="我的项目" width="60%">
      <el-table :data="projectList" style="width: 100%">
        <el-table-column prop="name" label="项目名称" />
        <el-table-column prop="description" label="描述" />
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button size="small" @click="handleLoadProject(row)">加载</el-button>
            <el-button size="small" type="danger" @click="handleDeleteProject(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed, nextTick, onUnmounted } from 'vue'
import { VueFlow, useVueFlow } from '@vue-flow/core'
import '@vue-flow/core/dist/style.css'
import '@vue-flow/core/dist/theme-default.css'
import type { Node, Edge, Connection } from '@vue-flow/core'
import ModelicaComponentNode from '@/components/model/ModelicaComponentNode.vue'
import {
  Search,
  Document,
  FolderOpened,
  DocumentAdd,
  Delete,
  View,
  Box,
  CaretRight,
  VideoPause,
  Close
} from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { modelDeployApi, type Component, type ModelingProject } from '@/api/model-deploy'
import * as echarts from 'echarts'
import dayjs from 'dayjs'

// Vue Flow
const nodes = ref<Node[]>([])
const edges = ref<Edge[]>([])
const { getViewport, screenToFlowCoordinate } = useVueFlow()

// 自定义节点类型
const nodeTypes = {
  modelicaComponent: ModelicaComponentNode
}

// 数据
const components = ref<Component[]>([])
const componentSearchKeyword = ref('')
const defaultCover = 'https://via.placeholder.com/300x200?text=No+Image'
const selectedNode = ref<Node | null>(null)
const selectedNodeProperties = ref<Record<string, any>>({})
const saving = ref(false)
const simulating = ref(false)
const resultDialogVisible = ref(false)
const resultTab = ref('chart')
const codePreviewVisible = ref(false)
const generatedCode = ref('')
const showProjectDialog = ref(false)
const projectList = ref<ModelingProject[]>([])
const simulationLogs = ref<Array<{ time: string; type: string; message: string }>>([])
const chartContainer = ref<HTMLElement>()
const flowContainer = ref<HTMLElement>()
const loading = ref(false)

// 仿真参数
const simulationParams = reactive({
  stopTime: 10.0,
  stepSize: 0.01,
  solver: 'dassl',
  inputParams: {} as Record<string, any>
})

// 当前项目
const currentProject = ref<{
  id?: number
  name: string
  description?: string
}>({
  name: '未命名项目'
})

// 计算属性：过滤后的组件列表
const filteredComponents = computed(() => {
  if (!componentSearchKeyword.value) {
    return components.value
  }
  const keyword = componentSearchKeyword.value.toLowerCase()
  return components.value.filter(
    (c) =>
      c.name.toLowerCase().includes(keyword) ||
      (c.description && c.description.toLowerCase().includes(keyword))
  )
})

// 初始化
onMounted(async () => {
  await loadComponents()
  
  // 等待 Vue Flow 初始化后，绑定拖拽事件到 pane
  await nextTick()
  const vueFlowEl = document.querySelector('.vue-flow')
  if (vueFlowEl) {
    const paneEl = vueFlowEl.querySelector('.vue-flow__pane') as HTMLElement
    if (paneEl) {
      paneEl.addEventListener('drop', handleDrop)
      paneEl.addEventListener('dragover', handleDragOver)
    }
  }
})

// 清理事件监听
onUnmounted(() => {
  const vueFlowEl = document.querySelector('.vue-flow')
  if (vueFlowEl) {
    const paneEl = vueFlowEl.querySelector('.vue-flow__pane') as HTMLElement
    if (paneEl) {
      paneEl.removeEventListener('drop', handleDrop)
      paneEl.removeEventListener('dragover', handleDragOver)
    }
  }
})

// 加载组件列表
const loadComponents = async () => {
  try {
    loading.value = true
    const res = await modelDeployApi.getComponents()
    if (res.code === 200) {
      components.value = res.data || []
      if (components.value.length === 0) {
        ElMessage.info('暂无可用组件，请先上传Modelica模型')
      }
    } else {
      ElMessage.warning('获取组件列表失败: ' + (res.message || '未知错误'))
    }
  } catch (error: any) {
    console.error('加载组件列表失败:', error)
    ElMessage.error('加载组件列表失败: ' + (error.message || '网络错误'))
  } finally {
    loading.value = false
  }
}

// 组件搜索（不需要，computed会自动更新）
const handleComponentSearch = () => {
  // computed会自动响应componentSearchKeyword的变化
}

// 拖拽开始
const handleDragStart = (event: DragEvent, component: Component) => {
  if (event.dataTransfer) {
    event.dataTransfer.setData('application/json', JSON.stringify(component))
    event.dataTransfer.effectAllowed = 'copy'
  }
}

// 拖拽放置
const handleDrop = async (event: DragEvent) => {
  event.preventDefault()
  event.stopPropagation()
  if (!event.dataTransfer) return

  try {
    const componentData = JSON.parse(event.dataTransfer.getData('application/json')) as Component
    
    // 使用 Vue Flow 的坐标转换，将屏幕坐标转换为画布坐标
    const position = screenToFlowCoordinate({
      x: event.clientX,
      y: event.clientY
    })

    // 加载组件详情（包括connectors）
    const detailRes = await modelDeployApi.getComponentDetail(componentData.id)
    if (detailRes.code !== 200) {
      ElMessage.error('加载组件详情失败')
      return
    }

    const componentDetail = detailRes.data
    const connectors = componentDetail.connectors?.list || componentDetail.ports?.list || []

    // 创建节点
    const nodeId = `node_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    const newNode: Node = {
      id: nodeId,
      type: 'modelicaComponent', // 使用自定义节点类型
      position: position,
      data: {
        componentId: componentData.id,
        componentName: componentData.name,
        componentType: componentData.name,
        coverImage: componentDetail.coverImage || componentData.coverImage,
        connectors: connectors,
        properties: componentDetail.parameters || {}
      },
      label: componentData.name
    }

    nodes.value.push(newNode)
    ElMessage.success(`已添加组件: ${componentData.name}`)
  } catch (error: any) {
    console.error('添加组件失败:', error)
    ElMessage.error('添加组件失败: ' + (error.message || '未知错误'))
  }
}

// 拖拽悬停
const handleDragOver = (event: DragEvent) => {
  event.preventDefault()
  event.stopPropagation()
  if (event.dataTransfer) {
    event.dataTransfer.dropEffect = 'copy'
  }
}


// 加载节点属性
const loadNodeProperties = async (node: Node) => {
  try {
    const componentId = node.data?.componentId
    if (componentId) {
      const res = await modelDeployApi.getComponentDetail(componentId)
      if (res.code === 200 && res.data.parameters) {
        selectedNodeProperties.value = { ...res.data.parameters }
      }
    } else {
      selectedNodeProperties.value = node.data?.properties || {}
    }
  } catch (error) {
    console.error('加载组件属性失败:', error)
  }
}

// 属性变更
const handlePropertyChange = () => {
  if (selectedNode.value) {
    if (!selectedNode.value.data) {
      selectedNode.value.data = {}
    }
    selectedNode.value.data.properties = { ...selectedNodeProperties.value }
  }
}

// 删除节点
const handleDeleteNode = () => {
  if (selectedNode.value) {
    nodes.value = nodes.value.filter(n => n.id !== selectedNode.value!.id)
    edges.value = edges.value.filter(e => e.source !== selectedNode.value!.id && e.target !== selectedNode.value!.id)
    selectedNode.value = null
  }
}

// 清空画布
const handleClearCanvas = async () => {
  try {
    await ElMessageBox.confirm('确定要清空画布吗？', '提示', {
      type: 'warning'
    })
    nodes.value = []
    edges.value = []
    selectedNode.value = null
  } catch {
    // 用户取消
  }
}

// 预览代码
const handlePreviewCode = () => {
  generatedCode.value = generateModelicaCode()
  codePreviewVisible.value = true
}

// 生成Modelica代码
const generateModelicaCode = (): string => {
  if (nodes.value.length === 0) {
    return '// 画布为空，请添加组件'
  }

  const lines: string[] = []
  lines.push('model GeneratedModel')
  lines.push('  // 自动生成的Modelica模型')
  lines.push('')

  // 导入语句（简化处理，实际应该根据组件类型导入）
  lines.push('  import Modelica.Electrical.Analog.Basic.*;')
  lines.push('  import Modelica.Electrical.Analog.Sources.*;')
  lines.push('')

  // 组件实例声明
  nodes.value.forEach((node) => {
    const componentType = node.data?.componentType || 'Resistor'
    const nodeId = node.id
    const properties = node.data?.properties || {}
    const params = Object.entries(properties)
      .map(([key, value]) => `${key}=${value}`)
      .join(', ')
    lines.push(`  ${componentType} ${nodeId}(${params || ''});`)
  })

  lines.push('')
  lines.push('equation')

  // 连接语句
  edges.value.forEach((edge) => {
    const source = edge.source
    const target = edge.target
    lines.push(`  connect(${source}.p, ${target}.n);`)
  })

  lines.push('end GeneratedModel;')

  return lines.join('\n')
}

// 复制代码
const handleCopyCode = async () => {
  try {
    await navigator.clipboard.writeText(generatedCode.value)
    ElMessage.success('代码已复制到剪贴板')
  } catch (error) {
    ElMessage.error('复制失败')
  }
}

// 新建项目
const handleNewProject = () => {
  currentProject.value = { name: '未命名项目' }
  nodes.value = []
  edges.value = []
  selectedNode.value = null
  ElMessage.success('已创建新项目')
}

// 保存项目
const handleSaveProject = async () => {
  if (nodes.value.length === 0) {
    ElMessage.warning('画布为空，无法保存')
    return
  }

  try {
    saving.value = true
    const projectData = {
      nodes: getNodes.value,
      edges: getEdges.value
    }
    const modelicaCode = generateModelicaCode()

    const res = await modelDeployApi.saveProject({
      name: currentProject.value.name,
      description: currentProject.value.description,
      projectData: JSON.stringify(projectData),
      modelicaCode
    })

    if (res.code === 200) {
      currentProject.value.id = res.data
      ElMessage.success('项目保存成功')
    }
  } catch (error: any) {
    ElMessage.error('保存项目失败: ' + (error.message || '未知错误'))
  } finally {
    saving.value = false
  }
}

// 加载项目
const handleLoadProject = async (project: ModelingProject) => {
  try {
    const res = await modelDeployApi.getProject(project.id)
    if (res.code === 200) {
      const projectData = JSON.parse(res.data.projectData)
      nodes.value = projectData.nodes || []
      edges.value = projectData.edges || []
      currentProject.value = {
        id: project.id,
        name: project.name,
        description: project.description
      }
      showProjectDialog.value = false
      ElMessage.success('项目加载成功')
    }
  } catch (error: any) {
    ElMessage.error('加载项目失败: ' + (error.message || '未知错误'))
  }
}

// 删除项目
const handleDeleteProject = async (project: ModelingProject) => {
  try {
    await ElMessageBox.confirm('确定要删除此项目吗？', '提示', {
      type: 'warning'
    })
    await modelDeployApi.deleteProject(project.id)
    await loadProjectList()
    ElMessage.success('删除成功')
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败: ' + (error.message || '未知错误'))
    }
  }
}

// 加载项目列表
const loadProjectList = async () => {
  try {
    const res = await modelDeployApi.getUserProjects(1, 100)
    if (res.code === 200) {
      projectList.value = res.data.records || []
    }
  } catch (error) {
    console.error('加载项目列表失败:', error)
  }
}

// 开始仿真
const handleStartSimulation = async () => {
  if (nodes.value.length === 0) {
    ElMessage.warning('画布为空，无法仿真')
    return
  }

  try {
    simulating.value = true
    simulationLogs.value = []
    addLog('info', '开始仿真...')

    const modelCode = generateModelicaCode()
    const res = await modelDeployApi.submitSimulation({
      modelCode,
      simulationParams: {
        stopTime: simulationParams.stopTime,
        stepSize: simulationParams.stepSize,
        solver: simulationParams.solver,
        inputParams: simulationParams.inputParams
      }
    })

    if (res.code === 200) {
      addLog('success', '仿真任务已提交，任务ID: ' + res.data)
      // TODO: 轮询任务状态
      ElMessage.success('仿真任务已提交')
    }
  } catch (error: any) {
    addLog('error', '仿真失败: ' + (error.message || '未知错误'))
    ElMessage.error('提交仿真任务失败: ' + (error.message || '未知错误'))
  } finally {
    simulating.value = false
  }
}

// 暂停仿真
const handlePauseSimulation = () => {
  addLog('warning', '仿真已暂停')
  ElMessage.info('仿真已暂停')
}

// 停止仿真
const handleStopSimulation = () => {
  simulating.value = false
  addLog('warning', '仿真已停止')
  ElMessage.warning('仿真已停止')
}

// 添加日志
const addLog = (type: string, message: string) => {
  simulationLogs.value.push({
    time: dayjs().format('HH:mm:ss'),
    type,
    message
  })
}

// 显示项目对话框时加载列表
const showProjectDialogComputed = computed({
  get: () => showProjectDialog.value,
  set: (val) => {
    showProjectDialog.value = val
    if (val) {
      loadProjectList()
    }
  }
})

// 节点点击
const handleNodeClick = (event: { node: Node }) => {
  selectedNode.value = event.node
  // 加载组件属性
  loadNodeProperties(event.node)
}

// 边点击
const handleEdgeClick = () => {
  selectedNode.value = null
}

// 画布点击
const handlePaneClick = () => {
  selectedNode.value = null
}

// 连接处理
// 连线处理（验证连接是否合法）
const handleConnect = async (connection: Connection) => {
  if (!connection.source || !connection.target || !connection.sourceHandle || !connection.targetHandle) {
    return
  }

  // 获取源节点和目标节点
  const sourceNode = nodes.value.find(n => n.id === connection.source)
  const targetNode = nodes.value.find(n => n.id === connection.target)

  if (!sourceNode || !targetNode) {
    ElMessage.warning('无法找到连接的节点')
    return
  }

  // 获取源接口和目标接口
  const sourceConnector = sourceNode.data?.connectors?.find((c: any) => c.name === connection.sourceHandle)
  const targetConnector = targetNode.data?.connectors?.find((c: any) => c.name === connection.targetHandle)

  if (!sourceConnector || !targetConnector) {
    ElMessage.warning('无法找到连接的接口')
    return
  }

  // 验证连接类型是否兼容（简化处理：检查类型是否匹配或兼容）
  // 实际应该调用后端API验证，这里先做简单检查
  const sourceType = sourceConnector.type || ''
  const targetType = targetConnector.type || ''

  // 检查类型是否相同或兼容（例如PositivePin和NegativePin可以连接）
  const isCompatible = sourceType === targetType || 
                       (sourceType.includes('PositivePin') && targetType.includes('NegativePin')) ||
                       (sourceType.includes('NegativePin') && targetType.includes('PositivePin')) ||
                       sourceType.includes('Pin') && targetType.includes('Pin')

  if (!isCompatible) {
    ElMessage.warning(`接口类型不兼容: ${sourceType} 与 ${targetType} 无法连接`)
    // 阻止连接
    return
  }

  // 连接合法，允许创建边
  ElMessage.success('连接成功')
}

// 旧的handleConnect（已废弃，保留以防需要）
const handleConnectOld = (connection: Connection) => {
  edges.value.push(connection as Edge)
}

</script>

<style scoped>
.model-deploy-container {
  padding: 20px;
  height: calc(100vh - 60px);
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.toolbar-card {
  flex-shrink: 0;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.toolbar-left h2 {
  margin: 0;
  font-size: 20px;
}

.main-workspace {
  flex: 1;
  display: flex;
  gap: 10px;
  min-height: 0;
}

.component-panel,
.property-panel {
  width: 250px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
}

.canvas-area {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.canvas-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 0;
}

.vue-flow-container {
  flex: 1;
  min-height: 0;
}

.vue-flow {
  width: 100%;
  height: 100%;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.component-list {
  flex: 1;
  overflow-y: auto;
  padding: 10px 0;
}

.component-item {
  display: flex;
  align-items: center;
  padding: 10px;
  margin-bottom: 8px;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  cursor: move;
  transition: all 0.3s;
}

.component-item:hover {
  border-color: #409eff;
  background-color: #f5f7fa;
}

.component-icon {
  width: 48px;
  height: 48px;
  min-width: 48px;
  margin-right: 10px;
  border-radius: 4px;
  object-fit: cover;
  border: 1px solid #e4e7ed;
}

.component-icon-fallback {
  width: 48px;
  height: 48px;
  min-width: 48px;
  margin-right: 10px;
  font-size: 24px;
  color: #409eff;
  display: flex;
  align-items: center;
  justify-content: center;
}

.component-info {
  flex: 1;
}

.component-name {
  font-weight: 600;
  margin-bottom: 4px;
}

.component-desc {
  font-size: 12px;
  color: #909399;
}

.property-content {
  padding: 10px 0;
}

.simulation-panel {
  flex-shrink: 0;
}

.simulation-logs {
  max-height: 400px;
  overflow-y: auto;
  background: #1e1e1e;
  padding: 10px;
  border-radius: 4px;
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
</style>
