<template>
  <div
    class="model-deploy-container"
    v-loading="loading"
    :element-loading-text="loadingText"
    element-loading-background="rgba(255, 255, 255, 0.65)"
  >
    <!-- 顶部工具栏 -->
    <el-card class="toolbar-card">
      <div class="toolbar">
        <div class="toolbar-left">
          <h2>Modelica在线建模与仿真</h2>
        </div>
        <div class="toolbar-right">
          <el-button
            type="primary"
            :icon="CaretRight"
            :loading="simulating"
            :disabled="nodes.length === 0 && !importedModelCode"
            @click="handleOpenSimulationDialog"
          >
            {{ simulating ? '仿真中...' : '仿真' }}
          </el-button>
          <el-button :icon="Document" @click="handleOpenProjectDialog">我的项目</el-button>
          <el-button :icon="FolderOpened" @click="handleOpenModelImportDialog">导入模型</el-button>
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
            <el-tag size="small" type="info">共 {{ components.length }} 个</el-tag>
          </div>
        </template>
        <div class="component-search">
          <el-input
            v-model="componentKeyword"
            clearable
            placeholder="搜索组件名/类名/描述"
            :prefix-icon="Search"
          />
        </div>
        <div class="component-list">
          <el-tree
            v-if="componentTreeData.length > 0"
            class="component-tree"
            :data="componentTreeData"
            node-key="key"
            :expand-on-click-node="false"
            :default-expand-all="false"
            :props="{ label: 'label', children: 'children' }"
          >
            <template #default="{ data }">
              <div
                v-if="data.type === 'component'"
                class="component-item tree-component-item"
                :class="{ 'component-item-disabled': !data.component?.draggable }"
                :draggable="Boolean(data.component?.draggable)"
                @dragstart.capture="handleComponentItemDragStart($event, data.component)"
              >
                <el-image
                  :src="resolveComponentCover(data.component)"
                  class="component-icon"
                  lazy
                  fit="cover"
                  :preview-src-list="[]"
                  :initial-index="0"
                >
                  <template #error>
                    <el-icon class="component-icon-fallback"><Box /></el-icon>
                  </template>
                </el-image>
                <div class="component-info">
                  <div class="component-name">{{ data.component.name }}</div>
                </div>
              </div>
              <div v-else class="component-folder">{{ data.label }}</div>
            </template>
          </el-tree>
          <el-empty v-else description="暂无组件" :image-size="80" />
        </div>
      </el-card>

      <!-- 中间：建模画布 -->
      <div class="canvas-area" @drop.prevent.stop="handleDrop" @dragover.prevent.stop="handleDragOver">
        <el-card class="canvas-card" shadow="never">
          <template #header>
            <div class="panel-header">
              <span>建模画布</span>
              <div>
                <el-tag size="small" style="margin-right: 8px">节点: {{ nodes.length }}</el-tag>
                <el-button size="small" :icon="Delete" @click="handleClearCanvas">清空</el-button>
                <el-button size="small" :icon="View" @click="handlePreviewCode">预览代码</el-button>
              </div>
            </div>
          </template>
          <div
            class="vue-flow-container"
            ref="flowContainer"
            @drop.prevent.stop="handleDrop"
            @dragover.prevent.stop="handleDragOver"
          >
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
            <el-form-item label="组件实例名">
              <el-input
                v-model="selectedNodeInstanceName"
                placeholder="请输入组件实例名"
                @change="handleNodeNameChange"
              />
            </el-form-item>
            <el-form-item label="组件类型">
              <el-input v-model="selectedNode.data.componentType" disabled />
            </el-form-item>
            <el-form-item label="元数据来源" v-if="selectedNodeMetaSource">
              <el-tag size="small" type="info">{{ selectedNodeMetaSource }}</el-tag>
            </el-form-item>
            <el-form-item label="组件描述" v-if="selectedNodeDescription">
              <el-input :model-value="selectedNodeDescription" type="textarea" :rows="3" disabled />
            </el-form-item>
            <div v-if="selectedNodeProperties && Object.keys(selectedNodeProperties).length > 0">
              <el-divider>组件参数</el-divider>
              <el-form-item
                v-for="(value, key) in selectedNodeProperties"
                :key="key"
                :label="formatParameterLabel(key)"
              >
                <el-input-number
                  v-if="typeof value === 'number'"
                  v-model="selectedNodeProperties[key]"
                  :precision="3"
                  :controls="false"
                  @change="handlePropertyChange"
                />
                <el-input
                  v-else
                  v-model="selectedNodeProperties[key]"
                  @change="handlePropertyChange"
                />
                <div v-if="getParameterHint(key)" class="param-hint">{{ getParameterHint(key) }}</div>
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

    <el-dialog v-model="simulationDialogVisible" title="仿真设置" width="540px" :close-on-click-modal="false">
      <el-form :model="simulationParams" label-width="120px" size="default">
        <el-form-item label="当前仿真源">
          <el-tag :type="importedModelCode ? 'warning' : 'success'">
            {{ importedModelCode ? `导入模型：${importedModelName}` : '画布模型' }}
          </el-tag>
        </el-form-item>
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
          <el-select v-model="simulationParams.solver" style="width: 180px">
            <el-option label="DASSL" value="dassl" />
            <el-option label="Euler" value="euler" />
            <el-option label="Runge-Kutta" value="rk4" />
            <el-option label="CVode" value="cvode" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="simulationDialogVisible = false">取消</el-button>
        <el-button :icon="View" :disabled="!hasCachedResult" @click="handleOpenLatestResult">查看结果</el-button>
        <el-button
          v-if="simulating"
          type="danger"
          :icon="Close"
          @click="handleStopSimulation"
        >
          停止
        </el-button>
        <el-button
          type="primary"
          :icon="CaretRight"
          :loading="simulating"
          :disabled="nodes.length === 0 && !importedModelCode"
          @click="handleStartSimulation"
        >
          {{ simulating ? '仿真中...' : '开始仿真' }}
        </el-button>
      </template>
    </el-dialog>

    <!-- 仿真结果对话框 -->
    <el-dialog
      v-model="resultDialogVisible"
      title="仿真结果"
      width="80%"
      :close-on-click-modal="false"
    >
      <el-tabs v-model="resultTab">
        <el-tab-pane label="结果图表" name="chart">
          <el-form inline size="small" style="margin-bottom: 12px">
            <el-form-item label="已选参数">
              <el-tag type="info">{{ selectedResultVariables.length }}</el-tag>
            </el-form-item>
            <el-form-item>
              <el-button @click="handleDownloadChart" :disabled="selectedResultVariables.length === 0">
                下载图表PNG
              </el-button>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleDownloadResultCsv" :disabled="selectedResultVariables.length === 0">
                导出CSV
              </el-button>
            </el-form-item>
          </el-form>
          <div class="result-chart-layout">
            <div class="result-sidebar">
              <el-collapse v-model="expandedResultGroups">
                <el-collapse-item
                  v-for="group in resultVariableGroups"
                  :key="group.group"
                  :name="group.group"
                >
                  <template #title>
                    <span>{{ group.group }}</span>
                    <el-tag size="small" style="margin-left: 8px">{{ group.variables.length }}</el-tag>
                  </template>
                  <el-checkbox-group v-model="selectedResultVariables" class="result-checkbox-group">
                    <el-checkbox
                      v-for="variable in group.variables"
                      :key="variable"
                      :label="variable"
                    >
                      {{ getDisplayVariableName(variable, group.group) }}
                    </el-checkbox>
                  </el-checkbox-group>
                </el-collapse-item>
              </el-collapse>
            </div>
            <div ref="chartContainer" class="result-chart-container"></div>
          </div>
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
        style="font-family: 'Courier New', monospace"
      />
      <template #footer>
        <el-button @click="codePreviewVisible = false">关闭</el-button>
        <el-button type="warning" @click="handleApplyCodeToCanvas">同步到画布</el-button>
        <el-button type="primary" @click="handleCopyCode">复制代码</el-button>
      </template>
    </el-dialog>

    <!-- 项目列表对话框 -->
    <el-dialog v-model="showProjectDialogComputed" title="我的项目" width="60%">
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

    <el-dialog v-model="showModelImportDialog" title="导入模型源码仿真" width="70%">
      <el-tabs v-model="modelImportTab">
        <el-tab-pane label="公开模型" name="public">
          <el-table :data="publicModels" style="width: 100%" max-height="420">
            <el-table-column prop="name" label="模型名称" min-width="180" />
            <el-table-column prop="description" label="描述" min-width="220" />
            <el-table-column label="操作" width="120">
              <template #default="{ row }">
                <el-button size="small" type="primary" @click="handleImportModelCode(row)">导入</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="dialog-pagination">
            <el-pagination
              v-model:current-page="publicModelQuery.pageNum"
              v-model:page-size="publicModelQuery.pageSize"
              :total="publicModelTotal"
              :page-sizes="[20, 50, 100]"
              layout="total, sizes, prev, pager, next"
              @size-change="loadPublicModelsForImport"
              @current-change="loadPublicModelsForImport"
            />
          </div>
        </el-tab-pane>
        <el-tab-pane label="我的模型" name="mine">
          <el-table :data="myModelsForImport" style="width: 100%" max-height="420">
            <el-table-column prop="name" label="模型名称" min-width="180" />
            <el-table-column prop="description" label="描述" min-width="220" />
            <el-table-column label="操作" width="120">
              <template #default="{ row }">
                <el-button size="small" type="primary" @click="handleImportModelCode(row)">导入</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="dialog-pagination">
            <el-pagination
              v-model:current-page="myModelQuery.pageNum"
              v-model:page-size="myModelQuery.pageSize"
              :total="myModelTotal"
              :page-sizes="[20, 50, 100]"
              layout="total, sizes, prev, pager, next"
              @size-change="loadMyModelsForImport"
              @current-change="loadMyModelsForImport"
            />
          </div>
        </el-tab-pane>
      </el-tabs>
      <template #footer>
        <el-button @click="showModelImportDialog = false">关闭</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="showSaveProjectDialog" title="保存项目" width="420px" :close-on-click-modal="false">
      <el-form :model="saveProjectForm" label-width="90px">
        <el-form-item label="项目名称" required>
          <el-input v-model="saveProjectForm.name" maxlength="120" show-word-limit placeholder="请输入项目名称" />
        </el-form-item>
        <el-form-item label="项目描述">
          <el-input
            v-model="saveProjectForm.description"
            type="textarea"
            :rows="3"
            maxlength="500"
            show-word-limit
            placeholder="请输入项目描述（可选）"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showSaveProjectDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleConfirmSaveProject">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed, nextTick, onUnmounted, watch } from 'vue'
import { VueFlow, useVueFlow } from '@vue-flow/core'
import '@vue-flow/core/dist/style.css'
import '@vue-flow/core/dist/theme-default.css'
import type { Node, Edge, Connection } from '@vue-flow/core'
import ModelicaComponentNode from '@/components/model/ModelicaComponentNode.vue'
import {
  Document,
  FolderOpened,
  DocumentAdd,
  Delete,
  View,
  Box,
  CaretRight,
  Close,
  Search
} from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { modelDeployApi, type Component, type ModelingProject, type ParameterDetail } from '@/api/model-deploy'
import { modelApi } from '@/api/model'
import * as echarts from 'echarts'
import dayjs from 'dayjs'

// Vue Flow
const nodes = ref<Node[]>([])
const edges = ref<Edge[]>([])
const { setCenter, fitView } = useVueFlow()
const nodeTypes = {
  modelicaComponent: ModelicaComponentNode
} as any

// 数据
const components = ref<Component[]>([])
const componentKeyword = ref('')
const defaultCover = 'https://via.placeholder.com/300x200?text=No+Image'
const selectedNode = ref<Node | null>(null)
const selectedNodeProperties = ref<Record<string, any>>({})
const selectedNodeDescription = ref('')
const selectedNodeParamDetails = ref<ParameterDetail[]>([])
const selectedNodeMetaSource = ref('')
const selectedNodeInstanceName = ref('')
const saving = ref(false)
const simulating = ref(false)
const resultDialogVisible = ref(false)
const simulationDialogVisible = ref(false)
const resultTab = ref('chart')
const codePreviewVisible = ref(false)
const generatedCode = ref('')
const showProjectDialog = ref(false)
const showSaveProjectDialog = ref(false)
const showModelImportDialog = ref(false)
const modelImportTab = ref<'public' | 'mine'>('public')
const projectList = ref<ModelingProject[]>([])
const publicModels = ref<any[]>([])
const myModelsForImport = ref<any[]>([])
const publicModelTotal = ref(0)
const myModelTotal = ref(0)
const publicModelQuery = reactive({ pageNum: 1, pageSize: 20 })
const myModelQuery = reactive({ pageNum: 1, pageSize: 20 })
const importedModelCode = ref('')
const importedModelName = ref('')
const simulationLogs = ref<Array<{ time: string; type: string; message: string }>>([])
const chartContainer = ref<HTMLElement>()
const flowContainer = ref<HTMLElement>()
const loading = ref(false)
const loadingText = ref('加载中...')
const simulationTaskId = ref<number | null>(null)
const pollingTimer = ref<number | null>(null)
const availableVariables = ref<string[]>([])
const selectedResultVariables = ref<string[]>([])
const expandedResultGroups = ref<string[]>([])
const resultSeriesData = ref<Record<string, number[]>>({})
const resultTimeData = ref<number[]>([])
const hasCachedResult = ref(false)
const componentDetailCache = ref<Record<string, any>>({})
let chartInstance: echarts.ECharts | null = null

const formatParameterLabel = (name: string) => {
  const detail = selectedNodeParamDetails.value.find((item) => item.name === name)
  if (!detail) return name
  const unit = detail.unit ? ` [${detail.unit}]` : ''
  return `${name}${unit}`
}

const getParameterHint = (name: string) => {
  const detail = selectedNodeParamDetails.value.find((item) => item.name === name)
  if (!detail) return ''
  const typeText = detail.type ? `类型: ${detail.type}` : ''
  const descText = detail.description ? detail.description : ''
  if (typeText && descText) return `${typeText} | ${descText}`
  return typeText || descText
}

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
const saveProjectForm = reactive({
  name: '',
  description: ''
})

type ComponentTreeNode = {
  key: string
  label: string
  type: 'folder' | 'component'
  component?: Component
  children?: ComponentTreeNode[]
}

const componentTreeData = computed<ComponentTreeNode[]>(() => {
  const fixedModules = ['Electrical', 'Mechanics', 'Blocks', 'Math']
  const root: ComponentTreeNode[] = fixedModules.map((module) => ({
    key: `folder:${module}`,
    label: module,
    type: 'folder',
    children: []
  }))
  const folderMap = new Map<string, ComponentTreeNode>()
  root.forEach((n) => folderMap.set(n.label, n))

  const getFolderSegments = (component: Component): string[] => {
    if (component.className) {
      const parts = component.className
        .split('.')
        .map((s) => s.trim())
        .filter(Boolean)
      const noPrefix = parts[0] === 'Modelica' ? parts.slice(1) : parts
      return noPrefix.length > 1 ? noPrefix.slice(0, -1) : ['Electrical']
    }
    return ['Electrical']
  }

  const sortTree = (nodes: ComponentTreeNode[]) => {
    nodes.sort((a, b) => {
      if (a.type !== b.type) {
        return a.type === 'folder' ? -1 : 1
      }
      return a.label.localeCompare(b.label)
    })
    nodes.forEach((node) => {
      if (node.children && node.children.length > 0) {
        sortTree(node.children)
      }
    })
  }

  const keyword = String(componentKeyword.value || '').trim().toLowerCase()
  const filteredComponents = keyword
    ? components.value.filter((component) => {
        const name = String(component.name || '').toLowerCase()
        const className = String(component.className || component.id || '').toLowerCase()
        const desc = String(component.description || '').toLowerCase()
        return name.includes(keyword) || className.includes(keyword) || desc.includes(keyword)
      })
    : components.value

  filteredComponents.forEach((component) => {
    const folders = getFolderSegments(component)
    let parentChildren = root
    let folderPath = ''
    folders.forEach((folderName) => {
      folderPath = folderPath ? `${folderPath}/${folderName}` : folderName
      let folderNode = folderMap.get(folderPath)
      if (!folderNode) {
        folderNode = {
          key: `folder:${folderPath}`,
          label: folderName,
          type: 'folder',
          children: []
        }
        folderMap.set(folderPath, folderNode)
        parentChildren.push(folderNode)
      }
      parentChildren = folderNode.children || []
    })

    if (component.draggable === false && (component.childrenCount || 0) > 0) {
      return
    }
    parentChildren.push({
      key: `component:${component.id}`,
      label: component.name,
      type: 'component',
      component
    })
  })

  sortTree(root)
  return root
})

const resultVariableGroups = computed(() => {
  const groups: Record<string, string[]> = {}
  availableVariables.value.forEach((variable) => {
    const token = String(variable || '')
    const splitIndex = token.indexOf('.')
    const group = splitIndex > 0 ? token.slice(0, splitIndex) : '系统变量'
    if (!groups[group]) {
      groups[group] = []
    }
    groups[group].push(token)
  })
  return Object.keys(groups)
    .sort()
    .map((group) => ({
      group,
      variables: groups[group].sort()
    }))
})

// 初始化
onMounted(async () => {
  await loadComponents()
})

// 清理事件监听
onUnmounted(() => {
  clearPollingTimer()
  if (chartInstance) {
    chartInstance.dispose()
    chartInstance = null
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
        ElMessage.info('暂无可用基础组件，请联系超级管理员维护组件库')
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

const getComponentDetailCached = async (className: string) => {
  if (!className) {
    return null
  }
  if (componentDetailCache.value[className]) {
    return componentDetailCache.value[className]
  }
  const detailRes = await modelDeployApi.getComponentDetailByClassName(className)
  if (detailRes.code === 200 && detailRes.data) {
    componentDetailCache.value[className] = detailRes.data
    return detailRes.data
  }
  return null
}

// 拖拽开始
const handleDragStart = (event: DragEvent, component: Component) => {
  if (!component?.draggable) {
    event.preventDefault()
    return
  }
  if (event.dataTransfer) {
    const payload = JSON.stringify(component)
    event.dataTransfer.setData('application/json', payload)
    event.dataTransfer.setData('text/plain', payload)
    event.dataTransfer.effectAllowed = 'copy'
  }
}

const handleComponentItemDragStart = (event: DragEvent, component?: Component) => {
  if (!component || component.draggable === false) {
    event.preventDefault()
    return
  }
  handleDragStart(event, component)
}

// 拖拽放置
const handleDrop = async (event: DragEvent) => {
  event.preventDefault()
  event.stopPropagation()
  if (!event.dataTransfer) return

  loadingText.value = '正在加载组件元数据...'
  loading.value = true
  try {
    const rawData =
      event.dataTransfer.getData('application/json') ||
      event.dataTransfer.getData('text/plain')
    if (!rawData) {
      ElMessage.warning('未获取到拖拽组件数据')
      return
    }
    const componentData = JSON.parse(rawData) as Component
    
    // 使用容器相对坐标，确保节点一定在当前可见区域
    let position = { x: 120 + nodes.value.length * 20, y: 80 + nodes.value.length * 20 }
    if (flowContainer.value) {
      const rect = flowContainer.value.getBoundingClientRect()
      const x = event.clientX - rect.left - 80
      const y = event.clientY - rect.top - 30
      const maxX = Math.max(20, rect.width - 180)
      const maxY = Math.max(20, rect.height - 120)
      position = {
        x: Math.min(Math.max(20, x), maxX),
        y: Math.min(Math.max(20, y), maxY)
      }
    }

    // 加载组件详情（必须从后端元数据返回端口）
    let componentDetail: any = null
    try {
      const detailData = await getComponentDetailCached(componentData.id || componentData.className || '')
      if (detailData) {
        componentDetail = detailData
        try {
          const debugData = await modelDeployApi.getComponentDebugByClassName(
            String(detailData.className || componentData.className || componentData.id || '')
          )
          console.info('[ModelDeploy] backend debug endpoint', debugData)
        } catch (debugErr) {
          console.warn('[ModelDeploy] backend debug endpoint failed', debugErr)
        }
      } else {
        ElMessage.warning('组件详情加载失败，无法确定端口信息')
        return
      }
    } catch {
      ElMessage.warning('组件详情加载异常，无法确定端口信息')
      return
    }

    const connectors = componentDetail.connectors?.list || componentDetail.ports?.list || []
    if (!Array.isArray(connectors) || connectors.length === 0) {
      ElMessage.warning('组件缺少端口元数据，已阻止添加到画布')
      return
    }
    const connectorNames = connectors.map((c: any) => String(c?.name || '')).filter(Boolean)
    const metaSource = String(componentDetail?._metaSource || 'unknown')
    console.info('[ModelDeploy] component detail debug', {
      className: componentDetail.className || componentData.className || componentData.id,
      metaSource,
      connectorNames,
      connectorCount: connectorNames.length
    })

    // 创建节点
    const nodeId = `node_${Date.now()}_${Math.random().toString(36).slice(2, 11)}`
    const normalizedProperties = normalizeComponentParameters(componentDetail.parameters || {})
    const defaultProperties = getDefaultPropertiesByType(
      String(componentDetail.className || componentData.className || componentData.name),
      String(componentData.name)
    )
    const finalProperties =
      Object.keys(normalizedProperties).length > 0 ? normalizedProperties : defaultProperties
    const baseInstanceName = normalizeModelicaIdentifier(componentData.name)
    const instanceName = generateUniqueInstanceName(baseInstanceName, nodes.value)

    const componentType = resolveModelicaType(componentDetail.className || componentData.name, componentData.name)
    const nodeCover = resolveComponentCover({
      ...componentData,
      className: componentDetail.className || componentData.className || componentType,
      coverImage: componentDetail.coverImage || componentData.coverImage
    })

    const newNode: Node = {
      id: nodeId,
      type: 'modelicaComponent',
      position: position,
      data: {
        componentId: componentData.id,
        componentName: componentData.name,
        instanceName,
        componentType,
        coverImage: nodeCover,
        connectors: connectors,
        properties: finalProperties,
        description: String(componentDetail.description || ''),
        parameterDetails: Array.isArray(componentDetail.parameterDetails) ? componentDetail.parameterDetails : [],
        metaSource
      },
      label: instanceName
    }

    nodes.value = [...nodes.value, newNode]
    if (importedModelCode.value) {
      // 一旦开始画布建模，默认切回画布模型仿真源
      importedModelCode.value = ''
      importedModelName.value = ''
    }
    await nextTick()
    try {
      setCenter(position.x, position.y, { zoom: 1.2, duration: 300 })
      fitView({ padding: 0.2, duration: 300 })
    } catch {
      // ignore viewport errors
    }
    ElMessage.success(`已添加组件: ${componentData.name}（${metaSource}，端口:${connectorNames.join(', ')}）`)
  } catch (error: any) {
    console.error('添加组件失败:', error)
    ElMessage.error('添加组件失败: ' + (error.message || '未知错误'))
  } finally {
    loading.value = false
    loadingText.value = '加载中...'
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
    selectedNodeInstanceName.value = String(
      node.data?.instanceName || node.label || node.id
    )
    selectedNodeDescription.value = String(node.data?.description || '')
    selectedNodeParamDetails.value = Array.isArray(node.data?.parameterDetails)
      ? [...node.data.parameterDetails]
      : []
    selectedNodeMetaSource.value = String(node.data?.metaSource || '')
    const localProperties = (node.data?.properties || {}) as Record<string, any>
    if (Object.keys(localProperties).length > 0) {
      selectedNodeProperties.value = { ...localProperties }
      return
    }

    const componentId = node.data?.componentId
    const className = node.data?.componentType || (typeof componentId === 'string' ? componentId : null)
    if (className) {
      const detailData = await getComponentDetailCached(className)
      if (detailData) {
        const normalized = normalizeComponentParameters(detailData?.parameters || {})
        const fallback = getDefaultPropertiesByType(
          String(node.data?.componentType || ''),
          String(node.data?.componentName || '')
        )
        const merged = Object.keys(normalized).length > 0 ? normalized : fallback
        selectedNodeProperties.value = { ...merged }
        if (!node.data) {
          node.data = {}
        }
        node.data.properties = { ...merged }
        node.data.description = String(detailData?.description || '')
        node.data.parameterDetails = Array.isArray(detailData?.parameterDetails) ? detailData.parameterDetails : []
        node.data.metaSource = String(detailData?._metaSource || '')
        selectedNodeDescription.value = String(detailData?.description || '')
        selectedNodeParamDetails.value = Array.isArray(detailData?.parameterDetails) ? [...detailData.parameterDetails] : []
        selectedNodeMetaSource.value = String(detailData?._metaSource || '')
        return
      }
    }

    const fallback = getDefaultPropertiesByType(
      String(node.data?.componentType || ''),
      String(node.data?.componentName || '')
    )
    selectedNodeProperties.value = { ...fallback }
    if (!node.data) {
      node.data = {}
    }
    node.data.properties = { ...fallback }
    selectedNodeDescription.value = String(node.data?.description || '')
    selectedNodeParamDetails.value = Array.isArray(node.data?.parameterDetails)
      ? [...node.data.parameterDetails]
      : []
    selectedNodeMetaSource.value = String(node.data?.metaSource || '')
  } catch (error) {
    console.error('加载组件属性失败:', error)
    const fallback = getDefaultPropertiesByType(
      String(node.data?.componentType || ''),
      String(node.data?.componentName || '')
    )
    selectedNodeProperties.value = { ...fallback }
    selectedNodeDescription.value = ''
    selectedNodeParamDetails.value = []
    selectedNodeMetaSource.value = ''
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

const handleNodeNameChange = () => {
  if (!selectedNode.value) return
  const normalized = normalizeModelicaIdentifier(selectedNodeInstanceName.value || '')
  if (!normalized) {
    ElMessage.warning('实例名不能为空')
    return
  }
  selectedNodeInstanceName.value = normalized
  if (!selectedNode.value.data) {
    selectedNode.value.data = {}
  }
  selectedNode.value.data.instanceName = normalized
  selectedNode.value.label = normalized
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

  const nodeNameMap = buildUniqueNodeNameMap(nodes.value)

  // 组件实例声明
  const groundNodeIds: string[] = []
  nodes.value.forEach((node) => {
    const componentType = resolveModelicaType(
      String(node.data?.componentType || ''),
      String(node.data?.componentName || '')
    )
    const nodeName = String(node.data?.componentName || '').toLowerCase()
    if (componentType.includes('.Ground') || nodeName.includes('ground') || nodeName.includes('接地')) {
      groundNodeIds.push(node.id)
    }
    const nodeId = nodeNameMap[node.id]
    const properties = node.data?.properties || {}
    const parameterDetails = Array.isArray(node.data?.parameterDetails)
      ? (node.data?.parameterDetails as Array<{ name?: string }>)
      : []
    const allowedParameterNames =
      parameterDetails.length > 0
        ? new Set(
            parameterDetails
              .map((item) => String(item?.name || '').trim())
              .filter((name) => !!name)
          )
        : null
    const paramItems: string[] = []
    Object.entries(properties).forEach(([key, value]) => {
      const safeName = normalizeModelicaIdentifier(key)
      if (!safeName) {
        return
      }
      if (allowedParameterNames && !allowedParameterNames.has(key)) {
        return
      }
      if (typeof value === 'number' && Number.isFinite(value)) {
        paramItems.push(`${safeName}=${value}`)
        return
      }
      if (typeof value === 'boolean') {
        paramItems.push(`${safeName}=${value ? 'true' : 'false'}`)
        return
      }
      if (typeof value === 'string') {
        const trimmed = value.trim()
        if (!trimmed) {
          return
        }
        const numeric = Number(trimmed)
        if (!Number.isNaN(numeric)) {
          paramItems.push(`${safeName}=${numeric}`)
          return
        }
        // 仅允许简单标识符字符串，避免生成非法Modelica表达式
        if (/^[A-Za-z_][A-Za-z0-9_]*$/.test(trimmed)) {
          paramItems.push(`${safeName}=${trimmed}`)
        }
      }
    })

    if (paramItems.length > 0) {
      lines.push(`  ${componentType} ${nodeId}(${paramItems.join(', ')});`)
    } else {
      lines.push(`  ${componentType} ${nodeId};`)
    }
  })

  lines.push('')
  lines.push('equation')

  // 连接语句
  edges.value.forEach((edge) => {
    const source = nodeNameMap[edge.source]
    const target = nodeNameMap[edge.target]
    if (!source || !target) {
      return
    }
    const sourceNode = nodes.value.find((n) => n.id === edge.source)
    const targetNode = nodes.value.find((n) => n.id === edge.target)
    const sourceConnectors = (sourceNode?.data?.connectors || []) as Array<{ name: string; type?: string }>
    const targetConnectors = (targetNode?.data?.connectors || []) as Array<{ name: string; type?: string }>

    const sourceHandle =
      edge.sourceHandle ||
      pickConnectorName(sourceConnectors, ['p', 'flange_a', 'u', 'inPort']) ||
      sourceConnectors[0]?.name ||
      'p'
    const sourceType =
      sourceConnectors.find((c) => c.name === sourceHandle)?.type ||
      'Modelica.Electrical.Analog.Interfaces.Pin'
    const targetHandle =
      edge.targetHandle ||
      pickCompatibleTargetHandle(sourceType, targetConnectors, sourceHandle) ||
      pickConnectorName(targetConnectors, ['n', 'flange_b', 'y', 'outPort']) ||
      targetConnectors[0]?.name ||
      'n'
    lines.push(`  connect(${source}.${sourceHandle}, ${target}.${targetHandle});`)
  })

  // 若模型中没有接地，自动补一个Ground，避免浮地电路导致求解失败
  if (groundNodeIds.length === 0 && nodes.value.length > 0) {
    const autoGroundId = 'auto_ground'
    lines.splice(lines.indexOf('equation') - 1, 0, `  Modelica.Electrical.Analog.Basic.Ground ${autoGroundId};`)

    const refNode = nodes.value.find((node) => {
      const connectors = node.data?.connectors || []
      return connectors.some((c: any) => c.name === 'n') || connectors.some((c: any) => c.name === 'p')
    })
    if (refNode) {
      const refConnectors = refNode.data?.connectors || []
      const hasN = refConnectors.some((c: any) => c.name === 'n')
      const refHandle = hasN ? 'n' : 'p'
      const refNodeName = nodeNameMap[refNode.id]
      if (refNodeName) {
        lines.push(`  connect(${autoGroundId}.p, ${refNodeName}.${refHandle});`)
      }
    }
  }

  lines.push('end GeneratedModel;')

  return lines.join('\n')
}

const normalizeModelicaIdentifier = (name: string): string => {
  const normalized = String(name || '')
    .replace(/[^\w]/g, '_')
    .replace(/^\d+/, '')
  return normalized || 'Resistor'
}

const buildUniqueNodeNameMap = (list: Node[]): Record<string, string> => {
  const used = new Set<string>()
  const map: Record<string, string> = {}
  list.forEach((node, index) => {
    const preferred = normalizeModelicaIdentifier(
      String(node.data?.instanceName || node.label || `comp_${index + 1}`)
    )
    let name = preferred
    let i = 1
    while (used.has(name)) {
      i += 1
      name = `${preferred}_${i}`
    }
    used.add(name)
    map[node.id] = name
  })
  return map
}

const generateUniqueInstanceName = (base: string, existingNodes: Node[]): string => {
  const normalizedBase = normalizeModelicaIdentifier(base || 'component')
  const existing = new Set(
    existingNodes.map((n) =>
      String(n.data?.instanceName || n.label || '').trim().toLowerCase()
    )
  )
  if (!existing.has(normalizedBase.toLowerCase())) {
    return normalizedBase
  }
  let index = 2
  while (existing.has(`${normalizedBase}${index}`.toLowerCase())) {
    index += 1
  }
  return `${normalizedBase}${index}`
}

const normalizeComponentParameters = (rawParams: Record<string, any>): Record<string, any> => {
  const result: Record<string, any> = {}
  Object.entries(rawParams || {}).forEach(([key, value]) => {
    if (!key) return
    let v: any = value
    if (v && typeof v === 'object' && 'defaultValue' in (v as Record<string, any>)) {
      v = (v as Record<string, any>).defaultValue
    }
    if (typeof v === 'string') {
      const trimmed = v.trim()
      if (trimmed !== '') {
        const numeric = Number(trimmed)
        if (!Number.isNaN(numeric)) {
          result[key] = numeric
          return
        }
      }
      result[key] = v
      return
    }
    result[key] = v
  })
  return result
}

const getDefaultPropertiesByType = (componentType: string, componentName: string): Record<string, any> => {
  const normalizedType = String(componentType || '').trim().toLowerCase()
  const nameText = String(componentName || '').trim().toLowerCase()
  const t = `${normalizedType} ${nameText}`

  if (normalizedType === 'modelica.electrical.analog.sources.constantvoltage') {
    return { V: 12 }
  }
  if (normalizedType === 'modelica.electrical.analog.sources.sinevoltage') {
    return { V: 12, freqHz: 50 }
  }
  if (normalizedType === 'modelica.electrical.analog.sources.constantcurrent') {
    return { I: 1 }
  }

  if (t.includes('resistor') || t.includes('电阻')) {
    return { R: 10 }
  }
  if (t.includes('inductor') || t.includes('电感')) {
    return { L: 0.1 }
  }
  if (t.includes('capacitor') || t.includes('电容')) {
    return { C: 0.001 }
  }
  return {}
}

const resolveModelicaType = (candidate: string, displayName: string): string => {
  const raw = String(candidate || '').trim()
  if (/^[A-Za-z_][A-Za-z0-9_.]*$/.test(raw) && raw.includes('.')) {
    return raw
  }
  const c = `${raw} ${displayName}`.toLowerCase()
  if (c.includes('resistor') || c.includes('电阻')) return 'Modelica.Electrical.Analog.Basic.Resistor'
  if (c.includes('inductor') || c.includes('电感')) return 'Modelica.Electrical.Analog.Basic.Inductor'
  if (c.includes('capacitor') || c.includes('电容')) return 'Modelica.Electrical.Analog.Basic.Capacitor'
  if (c.includes('ground') || c.includes('接地')) return 'Modelica.Electrical.Analog.Basic.Ground'
  if (c.includes('currentsensor') || c.includes('ammeter') || c.includes('电流表')) {
    return 'Modelica.Electrical.Analog.Sensors.CurrentSensor'
  }
  if (c.includes('voltagesensor') || c.includes('电压表')) return 'Modelica.Electrical.Analog.Sensors.VoltageSensor'
  if (c.includes('sine') || c.includes('正弦')) return 'Modelica.Electrical.Analog.Sources.SineVoltage'
  if (c.includes('current') || c.includes('电流源')) return 'Modelica.Electrical.Analog.Sources.ConstantCurrent'
  if (c.includes('source') || c.includes('voltage') || c.includes('电源')) {
    return 'Modelica.Electrical.Analog.Sources.ConstantVoltage'
  }
  if (/^[A-Za-z_][A-Za-z0-9_]*$/.test(raw)) {
    return raw
  }
  return 'Modelica.Electrical.Analog.Basic.Resistor'
}

const getOpenModelicaIconUrl = (_modelicaType: string): string => {
  // 公开文档站当前未提供稳定可访问的类图标静态文件路径，先禁用远程拼接
  // 避免产生大量404请求。后续改为后端本地渲染后再返回可访问URL。
  return ''
}

const resolveComponentCover = (component: Partial<Component> & { componentType?: string }): string => {
  if (component.coverImage) {
    return component.coverImage
  }
  const classOrType = String(component.className || component.componentType || component.name || '')
  const modelicaType = resolveModelicaType(classOrType, String(component.name || ''))
  const autoIcon = getOpenModelicaIconUrl(modelicaType)
  return autoIcon || defaultCover
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

type ParsedDeclaration = {
  componentType: string
  instanceName: string
  properties: Record<string, any>
}

const parseModelicaDeclarations = (code: string): ParsedDeclaration[] => {
  const declarations: ParsedDeclaration[] = []
  const block = (code || '').split(/\bequation\b/i)[0] || ''
  const regex = /^\s*([A-Za-z_][A-Za-z0-9_.]*)\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?:\(([^;]*)\))?\s*;/gm
  let m: RegExpExecArray | null
  while ((m = regex.exec(block)) !== null) {
    const type = String(m[1] || '').trim()
    const name = String(m[2] || '').trim()
    if (!type || !name) continue
    const paramsRaw = String(m[3] || '').trim()
    const props: Record<string, any> = {}
    if (paramsRaw) {
      paramsRaw.split(',').forEach((item) => {
        const [k, v] = item.split('=').map((s) => String(s || '').trim())
        if (!k || !v) return
        if (/^(true|false)$/i.test(v)) {
          props[k] = v.toLowerCase() === 'true'
          return
        }
        const n = Number(v)
        props[k] = Number.isNaN(n) ? v : n
      })
    }
    declarations.push({ componentType: type, instanceName: name, properties: props })
  }
  return declarations
}

const parseModelicaConnects = (code: string): Array<{ source: string; sourcePort: string; target: string; targetPort: string }> => {
  const result: Array<{ source: string; sourcePort: string; target: string; targetPort: string }> = []
  const regex = /connect\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)\s*,\s*([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)\s*\)\s*;/g
  let m: RegExpExecArray | null
  while ((m = regex.exec(code || '')) !== null) {
    result.push({
      source: String(m[1]),
      sourcePort: String(m[2]),
      target: String(m[3]),
      targetPort: String(m[4])
    })
  }
  return result
}

const handleApplyCodeToCanvas = async () => {
  const code = String(generatedCode.value || '').trim()
  await applyModelicaCodeToCanvas(code, '手动编辑模型')
}

const applyModelicaCodeToCanvas = async (code: string, sourceName: string) => {
  if (!code) {
    ElMessage.warning('代码为空，无法同步到画布')
    return
  }
  const declarations = parseModelicaDeclarations(code)
  if (declarations.length === 0) {
    ElMessage.warning('未解析到组件声明，请检查代码格式')
    return
  }

  loading.value = true
  try {
    const newNodes: Node[] = []
    const instanceToNodeId: Record<string, string> = {}
    for (let i = 0; i < declarations.length; i += 1) {
      const d = declarations[i]
      const className = d.componentType
      const detail = await getComponentDetailCached(className)
      const connectors = (detail?.connectors?.list || detail?.ports?.list || []) as Array<{ name: string; type?: string }>
      const nodeId = `node_${Date.now()}_${i}_${Math.random().toString(36).slice(2, 7)}`
      instanceToNodeId[d.instanceName] = nodeId
      const col = i % 6
      const row = Math.floor(i / 6)
      newNodes.push({
        id: nodeId,
        type: 'modelicaComponent',
        position: { x: 60 + col * 220, y: 40 + row * 140 },
        data: {
          componentId: className,
          componentName: className.split('.').pop() || className,
          instanceName: d.instanceName,
          componentType: className,
          coverImage: resolveComponentCover({
            className,
            name: className.split('.').pop() || className,
            coverImage: detail?.coverImage
          }),
          connectors,
          properties: { ...(detail?.parameters || {}), ...d.properties },
          description: String(detail?.description || ''),
          parameterDetails: Array.isArray(detail?.parameterDetails) ? detail.parameterDetails : [],
          metaSource: String(detail?._metaSource || '')
        },
        label: d.instanceName
      })
    }

    const links = parseModelicaConnects(code)
    const newEdges: Edge[] = links
      .map((l, idx) => {
        const s = instanceToNodeId[l.source]
        const t = instanceToNodeId[l.target]
        if (!s || !t) return null
        return {
          id: `edge_code_${idx}_${Date.now()}`,
          source: s,
          target: t,
          sourceHandle: l.sourcePort,
          targetHandle: l.targetPort,
          type: 'smoothstep'
        } as Edge
      })
      .filter((e): e is Edge => Boolean(e))

    nodes.value = newNodes
    edges.value = newEdges
    selectedNode.value = null
    importedModelCode.value = code
    importedModelName.value = sourceName
    codePreviewVisible.value = false
    ElMessage.success(`已从代码同步到画布：组件${newNodes.length}个，连接${newEdges.length}条`)
  } catch (error: any) {
    ElMessage.error('代码同步到画布失败: ' + (error?.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

// 新建项目
const handleNewProject = () => {
  currentProject.value = { name: '未命名项目' }
  saveProjectForm.name = ''
  saveProjectForm.description = ''
  importedModelCode.value = ''
  importedModelName.value = ''
  nodes.value = []
  edges.value = []
  selectedNode.value = null
  ElMessage.success('已创建新项目')
}

const loadPublicModelsForImport = async () => {
  const res: any = await modelApi.getModelList({
    pageNum: publicModelQuery.pageNum,
    pageSize: publicModelQuery.pageSize
  })
  if (res.code === 200) {
    publicModels.value = res.data?.records || []
    publicModelTotal.value = Number(res.data?.totalRow || 0)
  } else {
    throw new Error(res.message || '获取公开模型失败')
  }
}

const loadMyModelsForImport = async () => {
  const res: any = await modelApi.getMyModels({
    pageNum: myModelQuery.pageNum,
    pageSize: myModelQuery.pageSize
  })
  if (res.code === 200) {
    myModelsForImport.value = res.data?.records || []
    myModelTotal.value = Number(res.data?.totalRow || 0)
  } else {
    throw new Error(res.message || '获取我的模型失败')
  }
}

const handleOpenModelImportDialog = async () => {
  try {
    publicModelQuery.pageNum = 1
    myModelQuery.pageNum = 1
    await Promise.all([loadPublicModelsForImport(), loadMyModelsForImport()])
    showModelImportDialog.value = true
  } catch (error: any) {
    ElMessage.error(error.message || '加载可导入模型失败')
  }
}

const handleImportModelCode = async (model: any) => {
  try {
    loadingText.value = '正在导入模型源码...'
    loading.value = true
    const res: any = await modelApi.getModelSourceCode(model.id)
    if (res.code !== 200) {
      ElMessage.error(res.message || '获取模型源码失败')
      return
    }
    importedModelCode.value = String(res.data?.content || '')
    if (!importedModelCode.value) {
      ElMessage.warning('模型源码为空，无法导入')
      return
    }
    importedModelName.value = String(model.name || '未命名模型')
    generatedCode.value = importedModelCode.value
    currentProject.value = {
      ...currentProject.value,
      name: importedModelName.value
    }
    await applyModelicaCodeToCanvas(importedModelCode.value, importedModelName.value)
    showModelImportDialog.value = false
    ElMessage.success(`已导入模型「${importedModelName.value}」，并同步到画布`)
  } catch (error: any) {
    ElMessage.error('导入模型失败: ' + (error.message || '未知错误'))
  } finally {
    loading.value = false
    loadingText.value = '加载中...'
  }
}

// 保存项目
const handleSaveProject = () => {
  if (nodes.value.length === 0) {
    ElMessage.warning('画布为空，无法保存')
    return
  }
  saveProjectForm.name = currentProject.value.name || ''
  saveProjectForm.description = currentProject.value.description || ''
  showSaveProjectDialog.value = true
}

const handleConfirmSaveProject = async () => {
  const projectName = String(saveProjectForm.name || '').trim()
  if (!projectName) {
    ElMessage.warning('请输入项目名称')
    return
  }
  try {
    let targetProjectId = currentProject.value.id
    const conflictProject = await findProjectByName(projectName)
    if (conflictProject && conflictProject.id !== currentProject.value.id) {
      try {
        await ElMessageBox.confirm(
          `已存在同名项目「${projectName}」。点击“覆盖保存”将更新该项目；点击“另存为”将创建新项目。`,
          '项目名称冲突',
          {
            type: 'warning',
            confirmButtonText: '覆盖保存',
            cancelButtonText: '另存为',
            distinguishCancelAndClose: true
          }
        )
        targetProjectId = conflictProject.id
      } catch (action: any) {
        if (action === 'cancel') {
          targetProjectId = undefined
        } else {
          return
        }
      }
    }

    saving.value = true
    const projectData = {
      nodes: nodes.value,
      edges: edges.value
    }
    const modelicaCode = generateModelicaCode()
    const payload = {
      name: projectName,
      description: String(saveProjectForm.description || '').trim(),
      projectData: JSON.stringify(projectData),
      modelicaCode
    }

    const res = targetProjectId
      ? await modelDeployApi.updateProject(targetProjectId, payload)
      : await modelDeployApi.saveProject(payload)

    if (res.code === 200) {
      if (!targetProjectId) {
        currentProject.value.id = res.data
      } else {
        currentProject.value.id = targetProjectId
      }
      currentProject.value.name = payload.name
      currentProject.value.description = payload.description
      showSaveProjectDialog.value = false
      await loadProjectList()
      ElMessage.success('项目保存成功')
    }
  } catch (error: any) {
    ElMessage.error('保存项目失败: ' + (error.message || '未知错误'))
  } finally {
    saving.value = false
  }
}

const findProjectByName = async (name: string): Promise<ModelingProject | undefined> => {
  const normalizedName = String(name || '').trim()
  if (!normalizedName) {
    return undefined
  }
  try {
    const res = await modelDeployApi.getUserProjects(1, 200)
    if (res.code !== 200) {
      return undefined
    }
    return (res.data.records || []).find(
      (project) => String(project.name || '').trim() === normalizedName
    )
  } catch {
    return undefined
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
      importedModelCode.value = ''
      importedModelName.value = ''
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
  } catch (error: any) {
    console.error('加载项目列表失败:', error)
    ElMessage.error('获取项目列表失败: ' + (error.message || '未知错误'))
  }
}

const handleOpenProjectDialog = async () => {
  await loadProjectList()
  showProjectDialog.value = true
}

const handleOpenSimulationDialog = () => {
  if (nodes.value.length === 0 && !importedModelCode.value) {
    ElMessage.warning('画布为空，无法仿真')
    return
  }
  simulationDialogVisible.value = true
}

// 开始仿真
const handleStartSimulation = async () => {
  if (nodes.value.length === 0 && !importedModelCode.value) {
    ElMessage.warning('画布为空，无法仿真')
    return
  }

  try {
    simulating.value = true
    simulationLogs.value = []
    availableVariables.value = []
    selectedResultVariables.value = []
    expandedResultGroups.value = []
    resultSeriesData.value = {}
    resultTimeData.value = []
    hasCachedResult.value = false
    addLog('info', '开始仿真...')

    const modelCode = importedModelCode.value || generateModelicaCode()
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
      simulationTaskId.value = res.data
      addLog('success', '仿真任务已提交，任务ID: ' + res.data)
      ElMessage.success('仿真任务已提交')
      await startPollingSimulationStatus(res.data)
    }
  } catch (error: any) {
    addLog('error', '仿真失败: ' + (error.message || '未知错误'))
    ElMessage.error('提交仿真任务失败: ' + (error.message || '未知错误'))
  } finally {
    simulating.value = false
  }
}

// 停止仿真
const handleStopSimulation = () => {
  simulating.value = false
  clearPollingTimer()
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

const pickConnectorName = (
  connectors: Array<{ name: string; type?: string }>,
  preferred: string[]
): string | undefined => {
  const preferredSet = new Set(preferred.map((v) => v.toLowerCase()))
  return connectors.find((c) => preferredSet.has(String(c.name || '').toLowerCase()))?.name
}

const isCompatibleConnectorType = (sourceType: string, targetType: string): boolean => {
  const s = String(sourceType || '').toLowerCase()
  const t = String(targetType || '').toLowerCase()
  if (!s || !t) return false
  if (s === t) return true

  if (s.includes('pin') && t.includes('pin')) return true
  if (s.includes('realinput') && t.includes('realoutput')) return true
  if (s.includes('realoutput') && t.includes('realinput')) return true
  if (s.includes('booleaninput') && t.includes('booleanoutput')) return true
  if (s.includes('booleanoutput') && t.includes('booleaninput')) return true

  const bothRotational = s.includes('mechanics.rotational.interfaces') && t.includes('mechanics.rotational.interfaces')
  const bothTranslational = s.includes('mechanics.translational.interfaces') && t.includes('mechanics.translational.interfaces')
  const supportFlangePair = (s.includes('support') && t.includes('flange')) || (s.includes('flange') && t.includes('support'))
  if ((bothRotational || bothTranslational) && supportFlangePair) return true

  if (s.includes('flange') && t.includes('flange')) {
    // 机械 Flange 只有在同一力学域（转动/平动）才允许直接连接
    const sRot = s.includes('mechanics.rotational.interfaces')
    const tRot = t.includes('mechanics.rotational.interfaces')
    const sTra = s.includes('mechanics.translational.interfaces')
    const tTra = t.includes('mechanics.translational.interfaces')
    if ((sRot && tRot) || (sTra && tTra)) return true
  }
  return false
}

const pickCompatibleTargetHandle = (
  sourceType: string,
  targetConnectors: Array<{ name: string; type?: string }>,
  sourceHandle?: string
): string | undefined => {
  const lowerSourceHandle = String(sourceHandle || '').toLowerCase()
  if (sourceType.includes('Pin')) {
    // 电气组件优先选对向端口，避免默认落到同名端口（例如 p->p）
    if (lowerSourceHandle === 'p') {
      const n = targetConnectors.find((c) => String(c.name || '').toLowerCase() === 'n')
      if (n) return n.name
    }
    if (lowerSourceHandle === 'n') {
      const p = targetConnectors.find((c) => String(c.name || '').toLowerCase() === 'p')
      if (p) return p.name
    }
  }
  return targetConnectors.find((c) =>
    isCompatibleConnectorType(sourceType, c.type || 'Modelica.Electrical.Analog.Interfaces.Pin')
  )?.name
}

// 连接处理
// 连线处理（验证连接是否合法）
const handleConnect = (connection: Connection) => {
  if (!connection.source || !connection.target) {
    return
  }

  // 获取源节点和目标节点
  const sourceNode = nodes.value.find(n => n.id === connection.source)
  const targetNode = nodes.value.find(n => n.id === connection.target)

  if (!sourceNode || !targetNode) {
    ElMessage.warning('无法找到连接的节点')
    return
  }

  const sourceConnectors = (sourceNode.data?.connectors || []) as Array<{ name: string; type?: string }>
  const targetConnectors = (targetNode.data?.connectors || []) as Array<{ name: string; type?: string }>

  const sourceHandle =
    connection.sourceHandle ||
    pickConnectorName(sourceConnectors, ['p', 'flange_a', 'u', 'inPort']) ||
    sourceConnectors[0]?.name ||
    'p'

  const sourceConnector = sourceConnectors.find((c) => c.name === sourceHandle) || sourceConnectors[0]
  const sourceType = sourceConnector?.type || 'Modelica.Electrical.Analog.Interfaces.Pin'

  let targetHandle =
    connection.targetHandle ||
    pickCompatibleTargetHandle(sourceType, targetConnectors, sourceHandle) ||
    pickConnectorName(targetConnectors, ['n', 'flange_b', 'y', 'outPort']) ||
    targetConnectors[0]?.name ||
    'n'
  let targetConnector = targetConnectors.find((c) => c.name === targetHandle) || targetConnectors[0]

  // 验证连接类型是否兼容（简化处理：检查类型是否匹配或兼容）
  // 实际应该调用后端API验证，这里先做简单检查
  let targetType = targetConnector?.type || 'Modelica.Electrical.Analog.Interfaces.Pin'

  let isCompatible = isCompatibleConnectorType(sourceType, targetType)
  if (!isCompatible && !connection.targetHandle) {
    const preferredAutoHandle = pickCompatibleTargetHandle(sourceType, targetConnectors, sourceHandle)
    const autoTarget = targetConnectors.find((c) => c.name === preferredAutoHandle) ||
      targetConnectors.find((c) =>
        isCompatibleConnectorType(sourceType, c.type || 'Modelica.Electrical.Analog.Interfaces.Pin')
      )
    if (autoTarget) {
      targetHandle = autoTarget.name
      targetConnector = autoTarget
      targetType = autoTarget.type || 'Modelica.Electrical.Analog.Interfaces.Pin'
      isCompatible = true
    }
  }

  if (!isCompatible) {
    ElMessage.warning(`接口类型不兼容: ${sourceType} 与 ${targetType} 无法连接`)
    // 阻止连接
    return
  }

  const duplicated = edges.value.some((edge) => {
    return (
      edge.source === connection.source &&
      edge.target === connection.target &&
      (edge.sourceHandle || 'p') === sourceHandle &&
      (edge.targetHandle || 'n') === targetHandle
    )
  })
  if (duplicated) {
    ElMessage.warning('该连线已存在')
    return
  }

  edges.value = [...edges.value, {
    id: `edge_${Date.now()}_${Math.random().toString(36).slice(2, 9)}`,
    source: connection.source,
    target: connection.target,
    sourceHandle,
    targetHandle,
    type: 'smoothstep'
  } as Edge]

  ElMessage.success('连接成功')
}

const clearPollingTimer = () => {
  if (pollingTimer.value !== null) {
    window.clearInterval(pollingTimer.value)
    pollingTimer.value = null
  }
}

const startPollingSimulationStatus = async (taskId: number) => {
  clearPollingTimer()

  const fetchStatus = async () => {
    try {
      const statusRes = await modelDeployApi.getSimulationStatus(taskId)
      if (statusRes.code !== 200 || !statusRes.data) {
        return
      }
      const task = statusRes.data
      if (task.progress != null) {
        addLog('info', `任务状态: ${task.status}, 进度: ${task.progress}%`)
      } else {
        addLog('info', `任务状态: ${task.status}`)
      }

      if (task.status === 'completed') {
        simulating.value = false
        clearPollingTimer()
        addLog('success', '仿真完成，正在展示结果')
        applyResultData(task.resultData)
        resultDialogVisible.value = true
      } else if (task.status === 'failed' || task.status === 'cancelled') {
        simulating.value = false
        clearPollingTimer()
        addLog('error', task.errorMessage || '仿真失败')
        ElMessage.error(task.errorMessage || '仿真失败')
      }
    } catch (error: any) {
      addLog('warning', `查询任务状态失败: ${error.message || '未知错误'}`)
    }
  }

  await fetchStatus()
  pollingTimer.value = window.setInterval(fetchStatus, 3000)
}

const applyResultData = (raw: any) => {
  if (!raw) {
    ElMessage.warning('仿真完成，但没有结果数据')
    return
  }
  let parsed: any = raw
  if (typeof raw === 'string') {
    try {
      parsed = JSON.parse(raw)
    } catch {
      ElMessage.warning('结果数据格式无法解析')
      return
    }
  }
  const time = Array.isArray(parsed.time) ? parsed.time : []
  const variables = parsed.variables && typeof parsed.variables === 'object' ? parsed.variables : {}
  const keys = Array.isArray(parsed.availableVariables)
    ? parsed.availableVariables
    : Object.keys(variables)

  resultTimeData.value = time
  resultSeriesData.value = variables
  availableVariables.value = keys
  selectedResultVariables.value = []
  expandedResultGroups.value = resultVariableGroups.value.map((item) => item.group)
  hasCachedResult.value = keys.length > 0

  nextTick(() => {
    renderChart()
  })
}

const renderChart = () => {
  if (!chartContainer.value) {
    return
  }
  if (!chartInstance) {
    chartInstance = echarts.init(chartContainer.value)
  }
  const selected = selectedResultVariables.value.filter((v) => !!resultSeriesData.value[v])
  if (selected.length === 0) {
    chartInstance.setOption(
      {
        title: { text: '请选择仿真参数' },
        tooltip: { trigger: 'axis' },
        legend: { data: [] },
        xAxis: { type: 'category', name: 'time', data: resultTimeData.value || [] },
        yAxis: { type: 'value' },
        series: []
      },
      { notMerge: true, lazyUpdate: true }
    )
    return
  }
  chartInstance.setOption(
    {
      title: {
        text: selected.length === 1 ? `变量: ${selected[0]}` : `变量数量: ${selected.length}`
      },
      tooltip: {
        trigger: 'axis'
      },
      xAxis: {
        type: 'category',
        name: 'time',
        data: resultTimeData.value
      },
      yAxis: {
        type: 'value'
      },
      legend: {
        type: 'scroll'
      },
      series: selected.map((variable) => ({
        name: variable,
        type: 'line',
        showSymbol: false,
        data: resultSeriesData.value[variable]
      }))
    },
    { notMerge: true, lazyUpdate: true }
  )
}

watch(selectedResultVariables, () => {
  renderChart()
}, { deep: true })

const handleDownloadChart = () => {
  if (!chartInstance) {
    ElMessage.warning('暂无可下载图表')
    return
  }
  const dataUrl = chartInstance.getDataURL({
    type: 'png',
    pixelRatio: 2,
    backgroundColor: '#ffffff'
  })
  const a = document.createElement('a')
  a.href = dataUrl
  a.download = `simulation-chart-${dayjs().format('YYYYMMDD-HHmmss')}.png`
  a.click()
}

const handleOpenLatestResult = () => {
  if (!hasCachedResult.value) {
    ElMessage.info('暂无可查看的历史仿真结果')
    return
  }
  resultDialogVisible.value = true
  nextTick(() => {
    renderChart()
  })
}

const getDisplayVariableName = (variable: string, group: string): string => {
  if (group === '系统变量') {
    return variable
  }
  const prefix = `${group}.`
  return variable.startsWith(prefix) ? variable.slice(prefix.length) : variable
}

const toCsvCell = (value: any): string => {
  const text = value == null ? '' : String(value)
  const escaped = text.replace(/"/g, '""')
  return /[",\n]/.test(escaped) ? `"${escaped}"` : escaped
}

const handleDownloadResultCsv = () => {
  if (resultTimeData.value.length === 0) {
    ElMessage.warning('暂无可导出的仿真数据')
    return
  }
  const selected = selectedResultVariables.value.filter((v) => !!resultSeriesData.value[v])
  if (selected.length === 0) {
    ElMessage.warning('请选择要导出的仿真参数')
    return
  }
  const headers = ['time', ...selected]
  const rows: string[] = [headers.map(toCsvCell).join(',')]
  for (let i = 0; i < resultTimeData.value.length; i += 1) {
    const row = [resultTimeData.value[i], ...selected.map((v) => resultSeriesData.value[v]?.[i] ?? '')]
    rows.push(row.map(toCsvCell).join(','))
  }
  const csvContent = '\uFEFF' + rows.join('\n')
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `simulation-data-${dayjs().format('YYYYMMDD-HHmmss')}.csv`
  a.click()
  URL.revokeObjectURL(url)
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
  height: 100%;
  min-height: 420px;
  background: #f8fafc;
  border: 1px solid #ebeef5;
  border-radius: 6px;
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
  padding: 6px 0;
}

.component-search {
  margin-bottom: 8px;
}

.component-tree {
  background: transparent;
}

.component-tree :deep(.el-tree-node__content) {
  height: auto;
  padding: 2px 0;
}

.component-folder {
  font-size: 13px;
  color: #606266;
  font-weight: 600;
  padding: 2px 0;
}

.component-item {
  display: flex;
  align-items: center;
  padding: 6px 8px;
  margin-bottom: 4px;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  cursor: move;
  transition: all 0.3s;
}

.tree-component-item {
  width: 100%;
  margin-bottom: 0;
  margin-left: -18px;
}

.component-item:hover {
  border-color: #409eff;
  background-color: #f5f7fa;
}

.component-item-disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

.component-item-disabled:hover {
  border-color: #e4e7ed;
  background-color: transparent;
}

.component-icon {
  width: 32px;
  height: 32px;
  min-width: 32px;
  margin-right: 8px;
  border-radius: 4px;
  object-fit: cover;
  border: 1px solid #e4e7ed;
}

.component-icon-fallback {
  width: 32px;
  height: 32px;
  min-width: 32px;
  margin-right: 8px;
  font-size: 18px;
  color: #409eff;
  display: flex;
  align-items: center;
  justify-content: center;
}

.component-info {
  flex: 1;
}

.component-name {
  font-weight: 500;
  font-size: 13px;
  line-height: 1.3;
}

.property-content {
  padding: 10px 0;
}

.param-hint {
  margin-top: 4px;
  font-size: 12px;
  color: #909399;
  line-height: 1.4;
}

.simulation-panel {
  flex-shrink: 0;
}

.result-chart-layout {
  display: flex;
  gap: 12px;
  height: 500px;
}

.result-sidebar {
  width: 300px;
  overflow-y: auto;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  padding: 8px;
  background: #fafafa;
}

.result-checkbox-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.result-chart-container {
  flex: 1;
  min-width: 0;
  height: 100%;
}

.simulation-logs {
  max-height: 400px;
  overflow-y: auto;
  background: #1e1e1e;
  padding: 10px;
  border-radius: 4px;
}

.dialog-pagination {
  display: flex;
  justify-content: center;
  margin-top: 12px;
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
