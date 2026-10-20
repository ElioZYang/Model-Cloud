<template>
    <el-dialog
      v-model="resultDialogVisible"
      title="计算结果"
      width="80%"
      :close-on-click-modal="false"
      @opened="handleResultDialogOpened"
      @closed="disposeArrayCharts"
    >
      <MatlabArtifactGallery
        :groups="resultArtifactGroups"
        :task-id="lastTaskId"
        :phase-label="artifactPhaseLabel"
        :reset-token="resultDialogVisible ? `batch-${resultBatchId}` : 'closed'"
        v-model:active-phase="activeArtifactPhase"
      />
      <el-tabs v-model="resultTab">
        <el-tab-pane label="结果图表" name="chart">
          <el-form inline size="small" style="margin-bottom: 12px">
            <el-form-item label="已选参数">
              <el-tag type="info">{{ selectedResultVariables.length }}</el-tag>
            </el-form-item>
            <el-form-item>
              <el-button
                @click="handleDownloadChart"
                :disabled="selectedPlotVariables.length === 0"
              >
                下载图表PNG
              </el-button>
            </el-form-item>
            <el-form-item>
              <el-button
                type="primary"
                @click="handleDownloadResultCsv"
                :disabled="selectedResultVariables.length === 0"
              >
                导出CSV
              </el-button>
            </el-form-item>
          </el-form>
          <div class="result-chart-layout">
            <div
              class="result-sidebar"
              :style="{ width: `${resultChartSidebarWidth}px`, flexBasis: `${resultChartSidebarWidth}px` }"
            >
              <el-collapse v-model="expandedResultGroups">
                <el-collapse-item
                  v-for="group in resultVariableGroups"
                  :key="group.group"
                  :name="group.group"
                >
                  <template #title>
                    <span>{{ group.group }}</span>
                    <el-tag size="small" style="margin-left: 8px">
                      {{ group.variables.length }}
                    </el-tag>
                  </template>
                  <el-checkbox-group
                    v-model="selectedResultVariables"
                    class="result-checkbox-group"
                  >
                    <el-checkbox
                      v-for="variable in group.variables"
                      :key="variable.key"
                      :label="variable.key"
                    >
                      {{ variable.label }}{{ variable.unit ? ` [${variable.unit}]` : '' }}
                    </el-checkbox>
                  </el-checkbox-group>
                </el-collapse-item>
              </el-collapse>
            </div>
            <div
              class="result-resize-handle"
              role="separator"
              aria-orientation="vertical"
              :aria-valuenow="resultChartSidebarWidth"
              title="拖动调整结果参数栏宽度，双击恢复默认宽度"
              @pointerdown="startResultResize('chart', $event)"
              @dblclick="resetResultSidebarWidth('chart')"
            ></div>
            <div class="result-chart-content">
              <div ref="chartContainer" class="result-chart-container"></div>
              <div v-if="selectedArrayVariables.length" class="array-result-list">
                <div v-for="variable in selectedArrayVariables" :key="variable.key" class="array-result-card">
                  <div class="array-result-title">
                    <strong>{{ variable.label }}</strong>
                    <span>{{ formatArrayShape(variable.shape) }}{{ variable.unit ? ` [${variable.unit}]` : '' }}</span>
                  </div>
                  <div class="array-result-source">{{ variable.group }}</div>
                  <MatlabArrayTable
                    v-if="variable.valueType === 'matrix' || variable.valueType === 'array'"
                    :value="resultValues[variable.key]"
                    :label="variable.label"
                    :unit="variable.unit"
                  />
                  <template v-else-if="variable.valueType === 'vector' || variable.valueType === 'ndarray'">
                    <div class="array-result-toolbar">
                      <span class="high-dimensional-hint">
                        {{ variable.valueType === 'ndarray' ? '按最后一维展开为多条曲线' : '完整向量曲线' }}
                      </span>
                      <el-button size="small" @click="handleDownloadArrayChart(variable)">
                        下载PNG
                      </el-button>
                    </div>
                    <div
                      class="array-result-chart"
                      :ref="(element) => setArrayChartElement(variable.key, element)"
                    ></div>
                  </template>
                  <div v-else class="high-dimensional-hint">
                    数组数据以整体表格显示。
                  </div>
                </div>
              </div>
            </div>
          </div>
        </el-tab-pane>
        <el-tab-pane label="结果数据" name="data">
          <el-tabs
            v-model="activeResultNodeId"
            class="result-node-tabs"
            @tab-change="handleResultNodeSelect"
          >
            <el-tab-pane
              v-for="node in availableResultNodes"
              :key="node.id"
              :name="node.id"
            >
              <template #label>
                <span :title="(node.originPath ? node.originPath + ' / ' : '') + node.instanceName + ' · ' + node.componentName">
                  {{ node.instanceName }}
                </span>
              </template>
            </el-tab-pane>
          </el-tabs>
          <div v-if="activeResultNode" class="result-data-layout">
            <aside
              class="result-page-navigation"
              :style="{ width: `${resultDataSidebarWidth}px`, flexBasis: `${resultDataSidebarWidth}px` }"
            >
              <div class="result-page-title">输出端口</div>
              <el-menu
                :default-active="activeResultPortKey"
                class="result-page-menu"
                @select="handleResultPortSelect"
              >
                <el-menu-item
                  v-for="port in activeResultPorts"
                  :key="port.key"
                  :index="port.key"
                >
                  <span class="result-page-label" :title="port.name">{{ port.name }}</span>
                  <el-tag v-if="!port.hasValue" size="small" type="info">未保存</el-tag>
                </el-menu-item>
              </el-menu>
            </aside>
            <div
              class="result-resize-handle"
              role="separator"
              aria-orientation="vertical"
              :aria-valuenow="resultDataSidebarWidth"
              title="拖动调整输出端口栏宽度，双击恢复默认宽度"
              @pointerdown="startResultResize('data', $event)"
              @dblclick="resetResultSidebarWidth('data')"
            ></div>
            <section class="result-page-content">
              <div class="result-page-header">
                <div>
                  <h3>{{ activeResultPort?.name || '输出端口' }}</h3>
                  <p>{{ activeResultNode.instanceName }} · {{ activeResultNode.componentName }}</p>
                  <p v-if="activeResultNode.originPath" class="result-origin-path">
                    来源路径：{{ activeResultNode.originPath }}
                  </p>
                </div>
              </div>
              <MatlabResultStructureTable
                v-if="resultDialogVisible && resultTab === 'data' && activeResultPort?.hasValue"
                :key="JSON.stringify([resultBatchId, activeResultNodeId, activeResultPortKey])"
                :value="activeResultPort.value"
                :unit-resolver="inferResultUnit"
              />
              <el-empty v-else-if="!activeResultPort?.hasValue" description="此次结果未保存该端口数据；重新运行后可查看完整输出。" :image-size="80" />
            </section>
          </div>
          <el-empty v-else description="暂无可展示的模块输出" :image-size="80" />
        </el-tab-pane>
        <el-tab-pane v-if="lastWorkflowResult" label="结构化结果" name="structured">
          <el-input
            :model-value="formattedWorkflowResult"
            type="textarea"
            :rows="22"
            readonly
            class="code-textarea"
          />
        </el-tab-pane>
        <el-tab-pane v-if="generatedJuliaCode" label="Julia代码" name="code">
          <el-input
            :model-value="generatedJuliaCode"
            type="textarea"
            :rows="22"
            readonly
            class="code-textarea"
          />
          <el-button style="margin-top: 10px" type="primary" @click="copyGeneratedJuliaCode">
            复制Julia代码
          </el-button>
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
</template>

<script setup lang="ts">
import { nextTick, onUnmounted, ref, watch } from 'vue'
import * as echarts from 'echarts'
import dayjs from 'dayjs'
import { ElMessage } from 'element-plus'
import MatlabResultStructureTable from '@/components/model/MatlabResultStructureTable.vue'
import MatlabArrayTable from '@/components/model/MatlabArrayTable.vue'
import MatlabArtifactGallery from '@/features/matlab-modeling/components/MatlabArtifactGallery.vue'
import { flattenArrayForCsv, toCsvCell, formatArrayShape, highDimensionalRows, inferResultUnit, toPlotValue } from '@/utils/matlabResultData'
import type { MatlabResultsDialogBindings, ResultVariable } from '@/utils/matlabResultData'



const props = defineProps<{ bindings: MatlabResultsDialogBindings }>()
const { resultArtifactGroups, artifactPhaseLabel, activeArtifactPhase, resultDialogVisible, resultTab, selectedResultVariables, selectedPlotVariables, resultVariableGroups, expandedResultGroups, selectedLineArrayVariables, resultValues, selectedArrayVariables, resultVariables, activeResultNodeId, handleResultNodeSelect, availableResultNodes, activeResultPorts, activeResultPortKey, handleResultPortSelect, activeResultNode, activeResultPort, resultBatchId, lastWorkflowResult, formattedWorkflowResult, generatedJuliaCode, copyGeneratedJuliaCode, simulationLogs, lastTaskId } = props.bindings

const chartContainer = ref<HTMLElement>()

type ResultResizeTarget = 'chart' | 'data'
type ResultResizeState = { target: ResultResizeTarget; startX: number; startWidth: number; containerWidth: number; previousCursor: string; previousUserSelect: string }

let chartInstance: echarts.ECharts | null = null

const arrayChartElements = new Map<string, HTMLElement>()

const arrayChartInstances = new Map<string, echarts.ECharts>()

const resultChartSidebarWidth = ref(300)

const resultDataSidebarWidth = ref(190)

let resultResizeState: ResultResizeState | null = null

function disposeArrayChart(key: string) {
  const chart = arrayChartInstances.get(key)
  if (chart) {
    chart.dispose()
    arrayChartInstances.delete(key)
  }
}

function disposeArrayCharts(clearElements = false) {
  Array.from(arrayChartInstances.keys()).forEach((key) => disposeArrayChart(key))
  if (clearElements) arrayChartElements.clear()
}

function setArrayChartElement(key: string, element: unknown) {
  const chartElement = element instanceof HTMLElement ? element : null
  if (!chartElement) {
    disposeArrayChart(key)
    arrayChartElements.delete(key)
    return
  }
  arrayChartElements.set(key, chartElement)
  nextTick(renderArrayCharts)
}

function renderArrayCharts() {
  const shouldRender = resultDialogVisible.value && resultTab.value === 'chart'
  const desiredKeys = new Set(shouldRender ? selectedLineArrayVariables.value.map((variable) => variable.key) : [])
  Array.from(arrayChartInstances.keys()).forEach((key) => {
    if (!desiredKeys.has(key)) disposeArrayChart(key)
  })
  if (!shouldRender) return

  selectedLineArrayVariables.value.forEach((variable) => {
    const element = arrayChartElements.get(variable.key)
    if (!element) return
    let chart = arrayChartInstances.get(variable.key)
    if (chart && chart.getDom() !== element) {
      chart.dispose()
      arrayChartInstances.delete(variable.key)
      chart = undefined
    }
    if (!chart) {
      chart = echarts.init(element)
      arrayChartInstances.set(variable.key, chart)
    }
    const value = resultValues.value[variable.key]
    const rows = variable.valueType === 'ndarray'
      ? highDimensionalRows(value)
      : [{ indices: [], data: Array.isArray(value) ? value.map(toPlotValue) : [] }]
    const maxLength = Math.max(1, ...rows.map((row) => row.data.length))
    const unit = variable.unit || '无量纲'
    chart.setOption({
      title: {
        text: variable.label,
        subtext: `${formatArrayShape(variable.shape)}${variable.unit ? ` [${variable.unit}]` : ''}`,
        left: 8,
        top: 4,
        textStyle: { fontSize: 12 },
        subtextStyle: { fontSize: 11 }
      },
      tooltip: { trigger: 'axis' },
      legend: { type: 'scroll', top: 42, data: rows.map((row) => (
        row.indices.length ? `${variable.label}[${row.indices.join(',')}]` : variable.label
      )) },
      grid: { top: 82, left: 52, right: 18, bottom: 32, containLabel: true },
      xAxis: {
        type: 'category',
        boundaryGap: false,
        data: Array.from({ length: maxLength }, (_, index) => String(index))
      },
      yAxis: { type: 'value', name: unit },
      series: rows.map((row) => ({
        type: 'line' as const,
        name: row.indices.length ? `${variable.label}[${row.indices.join(',')}]` : variable.label,
        data: row.data,
        showSymbol: true,
        symbol: 'circle',
        symbolSize: 5,
        connectNulls: false
      }))
    }, { notMerge: true })
    chart.resize()
  })
}

const handleResultDialogOpened = () => {
  nextTick(() => {
    renderChart()
    renderArrayCharts()
  })
}

const renderChart = () => {
  if (!chartContainer.value) return
  if (!chartInstance) chartInstance = echarts.init(chartContainer.value)
  const selected = resultVariables.value.filter((item) => {
    return selectedResultVariables.value.includes(item.key)
  })
  if (selected.length === 0) {
    chartInstance.setOption({
      title: { text: '请选择结果参数' },
      tooltip: { trigger: 'axis' },
      legend: { data: [] },
      xAxis: { type: 'category', data: [] },
      yAxis: { type: 'value' },
      series: []
    }, { notMerge: true })
    return
  }
  const plotVariables = selected.filter((variable) => variable.valueType === 'scalar')
  const units = Array.from(new Set(plotVariables.map((variable) => variable.unit || '无量纲')))
  if (units.length === 0) units.push('无量纲')
  const yAxes = units.map((unit, index) => ({
    type: 'value' as const,
    name: unit,
    position: index % 2 === 0 ? 'left' : 'right',
    offset: Math.floor(index / 2) * 54,
    axisLine: { show: true }
  }))
  chartInstance.setOption({
    title: {
      text: plotVariables.length === 0
        ? '已选择矩阵或非数值数组，请查看下方整体数据'
        : plotVariables.length === 1 ? `变量: ${plotVariables[0].label}` : `变量数量: ${plotVariables.length}`
    },
    tooltip: { trigger: 'axis' },
    legend: { type: 'scroll' },
    xAxis: {
      type: 'category',
      boundaryGap: true,
      data: ['0']
    },
    grid: {
      left: 55 + Math.max(0, Math.ceil(units.length / 2) - 1) * 54,
      right: 35 + Math.max(0, Math.floor(units.length / 2)) * 54,
      containLabel: true
    },
    yAxis: yAxes,
    series: plotVariables.flatMap((variable) => {
      const value = resultValues.value[variable.key]
      const base = {
        type: 'line' as const,
        showSymbol: true,
        symbol: 'circle',
        symbolSize: 7,
        yAxisIndex: units.indexOf(variable.unit || '无量纲'),
        connectNulls: false,
        label: { show: false }
      }
      return [{ ...base, name: `${variable.label}${variable.unit ? ` [${variable.unit}]` : ''}`, data: [toPlotValue(value)] }]
    })
  }, { notMerge: true })
  chartInstance.resize()
}

watch(selectedResultVariables, () => {
  nextTick(() => {
    renderChart()
    renderArrayCharts()
  })
}, { deep: true })

watch([resultDialogVisible, resultTab, resultBatchId], () => {
  nextTick(() => {
    renderChart()
    renderArrayCharts()
  })
})

const handleDownloadChart = () => {
  if (!chartInstance || selectedPlotVariables.value.length === 0) {
    ElMessage.warning('暂无可下载图表')
    return
  }
  const anchor = document.createElement('a')
  anchor.href = chartInstance.getDataURL({
    type: 'png',
    pixelRatio: 2,
    backgroundColor: '#ffffff'
  })
  anchor.download = `matlab-result-chart-${dayjs().format('YYYYMMDD-HHmmss')}.png`
  anchor.click()
}

const handleDownloadArrayChart = (variable: ResultVariable) => {
  const chart = arrayChartInstances.get(variable.key)
  if (!chart) {
    ElMessage.warning('数组图表尚未生成')
    return
  }
  const anchor = document.createElement('a')
  anchor.href = chart.getDataURL({
    type: 'png',
    pixelRatio: 2,
    backgroundColor: '#ffffff'
  })
  const filePart = variable.label.replace(/[^\w.-]+/g, '_').slice(0, 80) || 'array'
  anchor.download = `matlab-array-${filePart}-${dayjs().format('YYYYMMDD-HHmmss')}.png`
  anchor.click()
}

const stopResultResize = () => {
  if (!resultResizeState) return
  document.body.style.cursor = resultResizeState.previousCursor
  document.body.style.userSelect = resultResizeState.previousUserSelect
  resultResizeState = null
  window.removeEventListener('pointermove', handleResultResizeMove)
  window.removeEventListener('pointerup', stopResultResize)
  window.removeEventListener('pointercancel', stopResultResize)
}

const handleResultResizeMove = (event: PointerEvent) => {
  if (!resultResizeState) return
  const minimumWidth = resultResizeState.target === 'chart' ? 220 : 150
  const minimumContentWidth = resultResizeState.target === 'chart' ? 420 : 480
  const maximumWidth = Math.max(minimumWidth, resultResizeState.containerWidth - minimumContentWidth - 8)
  const width = Math.min(maximumWidth, Math.max(minimumWidth,
    resultResizeState.startWidth + event.clientX - resultResizeState.startX))
  if (resultResizeState.target === 'chart') {
    resultChartSidebarWidth.value = width
    requestAnimationFrame(() => chartInstance?.resize())
  } else {
    resultDataSidebarWidth.value = width
  }
}

const startResultResize = (target: ResultResizeTarget, event: PointerEvent) => {
  if (event.button !== 0) return
  const handle = event.currentTarget as HTMLElement | null
  const containerWidth = handle?.parentElement?.getBoundingClientRect().width || 0
  if (!containerWidth) return
  stopResultResize()
  resultResizeState = {
    target,
    startX: event.clientX,
    startWidth: target === 'chart' ? resultChartSidebarWidth.value : resultDataSidebarWidth.value,
    containerWidth,
    previousCursor: document.body.style.cursor,
    previousUserSelect: document.body.style.userSelect
  }
  document.body.style.cursor = 'col-resize'
  document.body.style.userSelect = 'none'
  window.addEventListener('pointermove', handleResultResizeMove)
  window.addEventListener('pointerup', stopResultResize)
  window.addEventListener('pointercancel', stopResultResize)
  event.preventDefault()
}

const resetResultSidebarWidth = (target: ResultResizeTarget) => {
  if (target === 'chart') {
    resultChartSidebarWidth.value = 300
    nextTick(() => chartInstance?.resize())
  } else {
    resultDataSidebarWidth.value = 190
  }
}

const handleDownloadResultCsv = () => {
  const selected = resultVariables.value.filter((item) => {
    return selectedResultVariables.value.includes(item.key)
  })
  if (selected.length === 0) {
    ElMessage.warning('请选择要导出的结果参数')
    return
  }
  const rows = [['source', 'group', 'fieldPath', 'shape', 'indices0', 'value', 'unit', 'kind']
    .map(toCsvCell).join(',')]
  selected.forEach((item) => {
    const value = resultValues.value[item.key]
    const cells = Array.isArray(value) ? flattenArrayForCsv(value) : [{ indices: [], value }]
    const separatorIndex = item.group.indexOf(' · ')
    const source = separatorIndex >= 0 ? item.group.slice(0, separatorIndex) : item.group
    cells.forEach((cell) => rows.push([
      source,
      item.group,
      item.label,
      formatArrayShape(item.shape),
      cell.indices.join('.'),
      cell.value ?? '',
      item.unit || '',
      item.kind
    ].map(toCsvCell).join(',')))
  })
  const blob = new Blob(['\uFEFF' + rows.join('\n')], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const anchor = document.createElement('a')
  anchor.href = url
  anchor.download = `matlab-result-data-${dayjs().format('YYYYMMDD-HHmmss')}.csv`
  anchor.click()
  URL.revokeObjectURL(url)
}
onUnmounted(() => {
  stopResultResize()
  if (chartInstance) { chartInstance.dispose(); chartInstance = null }
  disposeArrayCharts(true)
})

</script>

<style scoped>

.model-deploy-container {
  padding: 20px;
  height: calc(100vh - 60px);
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.toolbar-card { flex-shrink: 0; }

/* MATLAB 画布中选中的连线使用更粗的线宽，便于识别当前连接。 */
:deep(.vue-flow__edge.selected .vue-flow__edge-path),
:deep(.vue-flow__edge:focus .vue-flow__edge-path),
:deep(.vue-flow__edge:focus-visible .vue-flow__edge-path) {
  stroke-width: 3px;
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

.toolbar-left { display: flex; align-items: center; gap: 18px; min-width: 0; }
.scene-breadcrumb { cursor: pointer; }
.scene-breadcrumb-current { cursor: default; }

.main-workspace {
  flex: 1;
  display: flex;
  gap: 10px;
  min-height: 0;
}

.component-panel {
  width: 250px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
}

.property-panel {
  width: 420px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
}

.property-panel :deep(.el-card__body) {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
}

.resource-card {
  padding: 12px;
  border: 1px solid #dcdfe6;
  border-radius: 6px;
  background: #fafafa;
  margin-bottom: 16px;
}

.resource-status-row,
.resource-actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.resource-file-name {
  margin: 10px 0 6px;
  font-weight: 600;
  word-break: break-all;
}

.resource-actions {
  justify-content: flex-start;
  flex-wrap: wrap;
  margin-top: 12px;
}

.hidden-file-input { display: none; }

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
  min-height: 420px;
  height: 100%;
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

.component-search { margin-bottom: 8px; }
.component-tree { background: transparent; }

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

.component-info { flex: 1; }

.component-name {
  font-weight: 500;
  font-size: 13px;
  line-height: 1.3;
}

.property-content { padding: 10px 0; }

.param-hint {
  margin-top: 4px;
  font-size: 12px;
  color: #909399;
  line-height: 1.4;
}

.parameter-form-item :deep(.el-form-item__content) {
  display: block;
  margin-left: 0 !important;
}

.parameter-name {
  width: 100%;
  margin-bottom: 6px;
  color: #606266;
  font-size: 13px;
  line-height: 1.4;
  overflow-wrap: anywhere;
}

.connection-status,
.output-port-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 8px 0;
  border-bottom: 1px solid #ebeef5;
  font-size: 13px;
}

.connection-status > div,
.output-port-row {
  min-width: 0;
}

.connection-status strong,
.output-port-row strong {
  margin-right: 6px;
  overflow-wrap: anywhere;
}

.code-textarea :deep(textarea) {
  font-family: 'Courier New', monospace;
  line-height: 1.5;
}

.result-chart-layout {
  display: flex;
  gap: 0;
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
  min-height: 300px;
  height: 100%;
}

.result-chart-content {
  flex: 1;
  min-width: 0;
  min-height: 0;
  overflow: auto;
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding-left: 8px;
}

.result-resize-handle {
  position: relative;
  width: 10px;
  flex: 0 0 10px;
  cursor: col-resize;
  touch-action: none;
  outline: none;
}

.result-resize-handle::after {
  content: '';
  position: absolute;
  top: 0;
  bottom: 0;
  left: 4px;
  width: 2px;
  border-radius: 2px;
  background: var(--el-border-color-light);
  transition: background-color 0.15s ease;
}

.result-resize-handle:hover::after,
.result-resize-handle:active::after {
  background: var(--el-color-primary);
}

.array-result-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 12px;
  padding-right: 4px;
}

.result-artifact-panel {
  margin-bottom: 14px;
  padding: 10px;
  border: 1px solid var(--el-border-color-light);
  border-radius: 6px;
  background: var(--el-bg-color);
}

.result-artifact-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.result-artifact-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 10px;
}

.result-artifact-card {
  min-width: 0;
  padding: 8px;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 4px;
}

.result-artifact-name,
.result-artifact-source {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.result-artifact-name { font-size: 12px; font-weight: 600; }
.result-artifact-source { margin-top: 2px; color: var(--el-text-color-secondary); font-size: 11px; }
.result-artifact-image { display: block; width: 100%; height: 150px; margin: 6px 0; background: #f5f7fa; }
.result-artifact-actions { display: flex; justify-content: flex-end; gap: 6px; }

.array-result-card {
  border: 1px solid var(--el-border-color-light);
  border-radius: 6px;
  padding: 10px;
  background: var(--el-bg-color);
}

.array-result-title {
  display: flex;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 6px;
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.array-result-title strong {
  color: var(--el-text-color-primary);
  overflow-wrap: anywhere;
}

.array-result-source {
  margin: -2px 0 6px;
  color: var(--el-text-color-secondary);
  font-size: 11px;
  overflow-wrap: anywhere;
}

.array-result-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 6px;
}

.array-result-chart {
  width: 100%;
  min-height: 260px;
}

.high-dimensional-hint {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.result-data-layout {
  display: flex;
  min-height: 540px;
  overflow: hidden;
  border: 1px solid var(--el-border-color-light);
  border-radius: 6px;
  background: var(--el-bg-color);
}

.result-node-tabs :deep(.el-tabs__header) {
  margin: 0 0 12px;
}

.result-node-tabs :deep(.el-tabs__nav-wrap) {
  overflow-x: auto;
}

.result-node-tabs :deep(.el-tabs__nav-scroll) {
  overflow: visible;
}

.result-node-tabs :deep(.el-tabs__item) {
  max-width: 220px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.result-node-tabs :deep(.el-tabs__content) {
  display: none;
}

.result-page-navigation {
  width: 190px;
  flex: 0 0 190px;
  border-right: 1px solid var(--el-border-color-light);
  background: var(--el-fill-color-lighter);
}

.result-page-title {
  padding: 16px 18px 10px;
  color: var(--el-text-color-secondary);
  font-size: 13px;
  font-weight: 600;
}

.result-page-menu {
  border-right: 0;
  background: transparent;
}

.result-page-menu .el-menu-item {
  display: flex;
  justify-content: space-between;
  gap: 10px;
  height: 44px;
  padding: 0 16px;
}

.result-page-label {
  overflow: hidden;
  text-overflow: ellipsis;
}

.result-page-content {
  flex: 1;
  min-width: 0;
  padding: 18px 20px 20px;
}

.result-page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.result-page-header h3 {
  margin: 0 0 4px;
  color: var(--el-text-color-primary);
  font-size: 18px;
}

.result-page-header p {
  margin: 0;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

@media (max-width: 900px) {
  .result-data-layout {
    flex-direction: column;
  }

  .result-page-navigation {
    width: 100% !important;
    flex-basis: auto !important;
    border-right: 0;
    border-bottom: 1px solid var(--el-border-color-light);
  }

  .result-data-layout > .result-resize-handle {
    display: none;
  }

  .result-page-menu {
    display: flex;
    overflow-x: auto;
  }

  .result-page-menu .el-menu-item {
    flex: 0 0 auto;
  }
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

.log-item.info .log-content { color: #409eff; }
.log-item.success .log-content { color: #67c23a; }
.log-item.warning .log-content { color: #e6a23c; }
.log-item.error .log-content { color: #f56c6c; }

</style>
