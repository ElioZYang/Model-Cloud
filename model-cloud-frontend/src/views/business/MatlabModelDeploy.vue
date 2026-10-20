<template>
  <div
    class="model-deploy-container"
    v-loading="loading"
    :element-loading-text="loadingText"
    element-loading-background="rgba(255, 255, 255, 0.65)"
  >
    <el-card class="toolbar-card">
      <div class="toolbar">
        <div class="toolbar-left">
          <h2>MATLAB-Julia在线建模与计算</h2>
          <MatlabBreadcrumb
            :items="sceneBreadcrumb"
            :active-scene-id="activeSceneId"
            @navigate="handleSceneBreadcrumbClick"
          />
        </div>
        <div class="toolbar-right">
          <el-button @click="handleOpenProjectDialog">我的项目</el-button>
          <el-button @click="handleNewProject">新建项目</el-button>
          <el-button @click="handleSaveProject" :disabled="nodes.length === 0">保存项目</el-button>
          <el-button
            type="primary"
            :icon="CaretRight"
            :loading="calculating"
            :disabled="nodes.length === 0"
            @click="handleOpenCalculationDialog"
          >
            {{ calculating ? '计算中...' : '计算' }}
          </el-button>
          <el-button v-if="lastExecutionFailure" @click="failureDialogVisible = true">最近失败</el-button>
        </div>
      </div>
    </el-card>

    <el-dialog v-model="projectDialogVisible" title="我的 MATLAB 项目" width="720px">
      <el-table :data="projectList" v-loading="projectLoading" empty-text="暂无 MATLAB 项目">
        <el-table-column prop="name" label="项目名称" min-width="180" />
        <el-table-column prop="description" label="描述" min-width="220" show-overflow-tooltip />
        <el-table-column prop="updateTime" label="更新时间" width="180" />
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleLoadProject(row)">加载</el-button>
            <el-button link type="danger" @click="handleDeleteProject(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button @click="projectDialogVisible = false">关闭</el-button>
        <el-button @click="loadProjectList">刷新</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="saveProjectDialogVisible" title="保存 MATLAB 项目" width="520px">
      <el-form label-width="90px">
        <el-form-item label="项目名称" required>
          <el-input v-model="saveProjectForm.name" maxlength="120" show-word-limit />
        </el-form-item>
        <el-form-item label="项目描述">
          <el-input v-model="saveProjectForm.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="saveProjectDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="projectSaving" @click="handleConfirmSaveProject">保存</el-button>
      </template>
    </el-dialog>

    <div class="main-workspace">
      <MatlabCatalogPanel
        :components="components"
        :tree-data="componentTreeData"
        :resolve-component-cover="resolveComponentCover"
        v-model:keyword="componentKeyword"
        @drag-start="(component, dragEvent) => handleComponentDragStart(dragEvent, component)"
      />

      <div class="canvas-area" @drop.prevent.stop="handleDrop" @dragover.prevent.stop>
        <el-card class="canvas-card" shadow="never">
          <template #header>
            <div class="panel-header">
              <span>建模画布</span>
              <div>
                <el-tag size="small" style="margin-right: 8px">节点: {{ nodes.length }}</el-tag>
                <el-tag size="small" type="warning" style="margin-right: 8px">
                  统一图执行：{{ nodes.length }} 个节点 / {{ edges.length }} 条连线
                </el-tag>
                <el-button size="small" :loading="elkLayoutBusy" @click="handleManualLayout">
                  重新整理
                </el-button>
                <el-button size="small" :disabled="physicalLensFocused || selectedSceneNodeIds.length === 0" @click="handleEncapsulateSelection">
                  封装选中
                </el-button>
                <el-button size="small" :disabled="physicalLensFocused || !canCreateAssemblyRelation" @click="handleCreateAssemblyRelation">
                  创建装配关系
                </el-button>
                <el-button size="small" :disabled="physicalLensFocused || !selectedCompositeNode" @click="handleUnencapsulateSelection">
                  解封装
                </el-button>
                <MatlabPhysicalLensToolbar
                  v-if="canvasHasPhysicalComponents"
                  :model-value="physicalLensMode"
                  :active-count="physicalLensActiveCount"
                  @update:model-value="setPhysicalLensMode"
                />
                <el-button size="small" :icon="Delete" :disabled="physicalLensFocused" @click="handleClearCanvas">清空</el-button>
                <el-button size="small" :icon="View" @click="handlePreviewPayload">预览负载</el-button>
              </div>
            </div>
          </template>
          <div
            ref="flowContainer"
            class="vue-flow-container"
            @drop.prevent.stop="handleDrop"
            @dragover.prevent.stop
          >
            <VueFlow
              v-model:nodes="nodes"
              v-model:edges="canvasEdges"
              :node-types="nodeTypes"
              :edge-types="edgeTypes"
              :default-edge-options="defaultEdgeOptions"
              :nodes-connectable="true"
              :connect-on-click="false"
              :multi-selection-key-code="'Shift'"
              @pointerdown.capture="captureNodeSelection"
              @connect="handleConnect"
              @node-drag-stop="scheduleElkLayout(false)"
              @node-click="handleNodeClick"
              @node-double-click="handleNodeDoubleClick"
              @edge-click="handleEdgeClick"
              @pane-click="handlePaneClick"
              @viewport-change="handleViewportChange"
              class="vue-flow"
            />
          </div>
        </el-card>
      </div>

      <el-card class="property-panel" shadow="never">
        <template #header>
          <span>属性编辑</span>
        </template>
        <MatlabPhysicalProperties
          v-if="physicalLensMode !== 'overview' && (selectedNode?.data?.physicalCapabilities || selectedEdge?.data?.physicalProjection || (!selectedNode && editorStore.activeAssembly))"
          :mode="physicalLensMode"
          :selected-node="selectedNode"
          :selected-edge="selectedEdge"
          :active-group-id="activeRelationGroupId"
          :groups="activeAssemblyGroups"
          :edges="canvasEdges"
          :assembly-defaults="activeAssemblyDefaults"
          :motor-shaft-group-id="editorStore.activeAssembly?.motorBindings?.find(binding => binding.motorNodeId === selectedNode?.id)?.shaftGroupId"
          class="property-content"
          @select-group="activeRelationGroupId = $event"
          @create-group="createSelectedRelationGroup"
          @add-node-to-group="addSelectedNodeToGroup"
          @remove-node-from-group="removeSelectedNodeFromGroup"
          @update-group="updateActiveRelationGroup"
          @delete-group="deleteActiveRelationGroup"
          @update-node-parameter="updatePhysicalNodeParameter"
          @update-scene-parameter="updatePhysicalSceneParameter"
          @update-stream-role="updateSelectedEdgeStreamRole"
          @delete-edge="handleDeleteSelectedEdge"
          @delete-node="handleDeleteNode"
        />
        <div v-else-if="selectedEdge" class="property-content">
          <el-button type="danger" size="small" @click="handleDeleteSelectedEdge">删除连线</el-button>
        </div>
        <div v-else-if="selectedNode" class="property-content">
          <template v-if="isBusNode(selectedNode)">
            <el-form label-width="100px" size="small">
              <el-form-item label="组件实例名">
                <el-input
                  v-model="selectedNodeInstanceName"
                  placeholder="请输入组件实例名"
                  @change="handleNodeNameChange"
                />
              </el-form-item>
              <el-form-item label="节点类型">
                <el-tag type="info">{{ selectedNode.data?.nodeKind }}</el-tag>
              </el-form-item>
            </el-form>
            <MatlabBusEditor
              v-if="selectedNode.data?.nodeKind === 'busCreator'"
              :node-kind="'busCreator'"
              :config="selectedBusConfig"
              @update:config="updateSelectedBusConfig"
            />
            <MatlabBusEditor
              v-else
              :node-kind="'busSelector'"
              :selector-config="selectedSelectorConfig"
              :available-fields="selectedBusAvailableFields"
              @update:selector-config="updateSelectedSelectorConfig"
            />
            <el-button type="danger" size="small" @click="handleDeleteNode">删除组件</el-button>
          </template>
          <template v-else-if="selectedNode.data?.componentKind === 'boundaryPort'">
            <el-form label-width="100px" size="small">
              <el-form-item label="接口方向"><el-tag>{{ selectedNode.data?.boundaryDirection === 'input' ? 'In · 子系统输入' : 'Out · 子系统输出' }}</el-tag></el-form-item>
              <el-form-item label="接口名称"><el-input v-model="selectedNodeInstanceName" @change="handleNodeNameChange" /></el-form-item>
              <el-form-item label="信号类型"><el-input :model-value="boundarySignalSummary(selectedNode).type" disabled /></el-form-item>
              <el-form-item label="单位"><el-input :model-value="boundarySignalSummary(selectedNode).unit || '由连接推导'" disabled /></el-form-item>
              <el-form-item label="形状"><el-input :model-value="boundarySignalSummary(selectedNode).shape || '由连接推导'" disabled /></el-form-item>
            </el-form>
            <el-button type="danger" size="small" @click="handleDeleteNode">删除接口</el-button>
          </template>
          <el-form v-else :model="selectedInputValues" label-width="100px" size="small">
            <el-form-item label="组件实例名">
              <el-input
                v-model="selectedNodeInstanceName"
                placeholder="请输入组件实例名"
                @change="handleNodeNameChange"
              />
            </el-form-item>
            <el-form-item label="组件类型">
              <el-input :model-value="selectedNode.data?.functionName" disabled />
            </el-form-item>
            <el-form-item label="元数据来源">
              <el-tag size="small" type="info">静态MATLAB组件元数据</el-tag>
            </el-form-item>
            <el-form-item label="组件描述" v-if="selectedNode.data?.description">
              <el-input
                :model-value="selectedNode.data.description"
                type="textarea"
                :rows="3"
                disabled
              />
            </el-form-item>
            <template v-if="selectedNode.data?.childSceneId && selectedNodeBoundaryPorts.length > 0">
              <el-divider>边界端口</el-divider>
              <el-form-item
                v-for="port in selectedNodeBoundaryPorts"
                :key="port.id"
                :label="port.direction === 'input' ? '输入' : '输出'"
              >
                <el-input
                  :model-value="port.name"
                  :placeholder="port.id"
                  @change="(value: string) => handleBoundaryPortNameChange(port.id, value)"
                >
                  <template #append>{{ port.id }}</template>
                </el-input>
              </el-form-item>
            </template>
            <div v-if="editableNumberPorts.length > 0">
              <el-divider>组件参数</el-divider>
              <el-form-item
                v-for="port in editableNumberPorts"
                :key="port.name"
                class="parameter-form-item"
              >
                <div class="parameter-name" :title="formatPortLabel(port)">
                  {{ formatPortLabel(port) }}
                </div>
                <template v-if="port.type === 'array'">
                  <div v-for="(row, rowIndex) in numericMatrixInput(port.name)" :key="`${port.name}-${rowIndex}`" class="numeric-vector-row">
                    <div v-for="(item, columnIndex) in row" :key="`${port.name}-${rowIndex}-${columnIndex}`" class="numeric-vector-item">
                      <span class="numeric-vector-label">{{ numericMatrixInput(port.name).length === 1 ? numericAxisLabel(columnIndex) : `[${rowIndex + 1}, ${columnIndex + 1}]` }}</span>
                      <el-input-number
                        :model-value="item"
                        :min="port.min"
                        :max="port.max"
                        :precision="6"
                        :controls="false"
                        :disabled="!!getInputConnection(port.name)"
                        style="width: 100%"
                        @change="(value: number | undefined) => handleArrayInputChange(port.name, rowIndex, columnIndex, value)"
                      />
                    </div>
                  </div>
                </template>
                <el-input-number
                  v-else
                  v-model="selectedInputValues[port.name]"
                  :min="port.min"
                  :max="port.max"
                  :precision="6"
                  :controls="false"
                  :disabled="!!getInputConnection(port.name)"
                  style="width: 100%"
                  @change="handleInputChange"
                />
                <div class="param-hint">
                  {{ arrayDimensionWarning(port) || (getInputConnection(port.name)
                    ? `由连线提供：${getInputConnectionLabel(port.name)}`
                    : `${port.description || (port.type === 'array' ? '数值数组，按轴顺序传入' : '输入必须是有限标量')}${formatInputRange(port)}`) }}
                </div>
              </el-form-item>
            </div>
            <div>
              <div v-if="selectedResourceDefinition">
                <el-divider>电机配置 Excel</el-divider>
                <div class="resource-card">
                  <div class="resource-status-row">
                    <span>当前配置</span>
                    <el-tag :type="selectedConfigRecord ? 'success' : 'info'" size="small">
                      {{ selectedConfigRecord ? '用户配置' : '系统默认配置' }}
                    </el-tag>
                  </div>
                  <div class="resource-file-name">
                    {{ selectedConfigRecord?.fileName || 'pmsm input.xlsx' }}
                  </div>
                  <div v-if="selectedConfigRecord" class="param-hint">
                    SHA-256：{{ selectedConfigRecord.sha256.slice(0, 16) }}…；
                    参数 {{ selectedConfigRecord.summary?.designParameterCount ?? '-' }} 个
                  </div>
                  <input
                    ref="configFileInput"
                    class="hidden-file-input"
                    type="file"
                    accept=".xlsx"
                    @change="handleConfigFileSelected"
                  />
                  <div class="resource-actions">
                    <el-button size="small" @click="handleDownloadConfigTemplate">
                      下载模板
                    </el-button>
                    <el-button size="small" type="primary" @click="openConfigFilePicker">
                      {{ selectedConfigRecord ? '重新上传' : '选择并上传' }}
                    </el-button>
                    <el-button
                      v-if="selectedConfigRecord"
                      size="small"
                      @click="handleViewCurrentConfig"
                    >查看配置</el-button>
                    <el-button
                      v-if="selectedConfigRecord"
                      size="small"
                      type="warning"
                      @click="handleRestoreDefaultConfig"
                    >
                      恢复默认
                    </el-button>
                  </div>
                </div>
              </div>
              <div v-if="structuredInputPorts.length > 0">
                <el-divider>结构化输入端口</el-divider>
                <div
                  v-for="port in structuredInputPorts"
                  :key="port.name"
                  class="connection-status"
                >
                  <div>
                    <strong>{{ port.name }}</strong>
                    <el-tag size="small" type="info">{{ port.type }}</el-tag>
                  </div>
                  <el-tag
                    size="small"
                    :type="getInputConnection(port.name) ? 'success' : 'danger'"
                  >
                    {{ getInputConnectionLabel(port.name) }}
                  </el-tag>
                </div>
              </div>
              <div v-if="visibleOutputPorts.length > 0">
                <el-divider>结构化输出端口</el-divider>
                <div v-for="port in visibleOutputPorts" :key="port.name" class="output-port-row">
                  <strong>{{ port.name }}</strong>
                  <el-tag size="small" type="success">{{ port.type }}</el-tag>
                </div>
              </div>
            </div>
            <el-form-item>
              <el-button type="danger" size="small" @click="handleDeleteNode">删除组件</el-button>
            </el-form-item>
          </el-form>
        </div>
        <el-empty v-else description="请选择组件或连线进行编辑" :image-size="80" />
      </el-card>
    </div>

    <el-dialog
      v-model="calculationDialogVisible"
      title="计算设置"
      width="540px"
      :close-on-click-modal="false"
    >
      <el-form label-width="120px" size="default">
        <el-form-item label="当前计算源">
          <el-tag type="success">
            当前完整MATLAB组件图
          </el-tag>
        </el-form-item>
        <el-form-item label="图规模">
          <el-input
            :model-value="`${nodes.length} 个节点 / ${edges.length} 条连线`"
            disabled
          />
        </el-form-item>
        <el-form-item label="执行链路">
          <el-select model-value="julia-matlab-graph" disabled style="width: 220px">
            <el-option label="Julia + MATLAB.jl 统一图执行" value="julia-matlab-graph" />
          </el-select>
        </el-form-item>
        <el-form-item label="输入参数">
          <el-tag type="info">
            {{ workflowRequiredInputCount }} 个必需输入端口
          </el-tag>
        </el-form-item>
        <el-form-item label="输出参数">
          <el-tag type="info">
            {{ workflowOutputCount }} 个逻辑输出端口
          </el-tag>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="calculationDialogVisible = false">取消</el-button>
        <el-button :icon="View" :disabled="!hasCachedResult" @click="handleOpenLatestResult">
          查看结果
        </el-button>
        <el-button
          type="primary"
          :icon="CaretRight"
          :loading="calculating"
          :disabled="nodes.length === 0"
          @click="handleStartCalculation"
        >
          {{ calculating ? '计算中...' : '开始计算' }}
        </el-button>
      </template>
    </el-dialog>


    <MatlabResultsDialog :bindings="resultBindings" />
    <MatlabFailureDialog v-model:visible="failureDialogVisible" :failure="lastExecutionFailure" />

    <el-dialog v-model="payloadPreviewVisible" title="MATLAB工作流与Julia代码预览" width="70%">
      <el-input
        v-model="generatedPayload"
        type="textarea"
        :rows="20"
        readonly
        style="font-family: 'Courier New', monospace"
      />
      <template #footer>
        <el-button @click="payloadPreviewVisible = false">关闭</el-button>
        <el-button type="primary" @click="handleCopyPayload">复制预览内容</el-button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="configPreviewVisible"
      title="PMSM电机配置预览"
      width="760px"
      :close-on-click-modal="false"
    >
      <el-alert
        v-if="configPreviewWarnings.length"
        :title="configPreviewWarnings.join('；')"
        type="warning"
        show-icon
        :closable="false"
        style="margin-bottom: 12px"
      />
      <el-descriptions :column="3" border size="small" style="margin-bottom: 12px">
        <el-descriptions-item label="文件名">{{ pendingConfigFile?.name }}</el-descriptions-item>
        <el-descriptions-item label="文件大小">{{ formatFileSize(pendingConfigFile?.size || 0) }}</el-descriptions-item>
        <el-descriptions-item label="设计参数">{{ configPreviewRows.length }}</el-descriptions-item>
        <el-descriptions-item label="优化参数">{{ configPreviewOptimizationCount }}</el-descriptions-item>
        <el-descriptions-item label="材料">{{ configPreviewMaterialCount }}</el-descriptions-item>
        <el-descriptions-item label="工作表校验">通过</el-descriptions-item>
      </el-descriptions>
      <el-table :data="configPreviewRows" border stripe max-height="420">
        <el-table-column prop="variables" label="变量" min-width="160" />
        <el-table-column prop="value" label="默认值" width="120" />
        <el-table-column prop="opt" label="优化" width="80" />
        <el-table-column prop="min" label="最小值" width="110" />
        <el-table-column prop="max" label="最大值" width="110" />
      </el-table>
      <template #footer>
        <el-button @click="cancelConfigPreview">取消</el-button>
        <el-button type="primary" :loading="configUploading" @click="confirmConfigUpload">
          保存为我的配置并使用
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { computed, markRaw, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import { MarkerType, VueFlow, useVueFlow } from '@vue-flow/core'
import type { Connection, Edge, EdgeMouseEvent, Node, NodeMouseEvent } from '@vue-flow/core'
import '@vue-flow/core/dist/style.css'
import '@vue-flow/core/dist/theme-default.css'
import { CaretRight, Delete, View } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import MatlabComponentNode from '@/components/model/MatlabComponentNode.vue'
import MatlabCompositeNode from '@/components/model/MatlabCompositeNode.vue'
import MatlabBusNode from '@/components/model/MatlabBusNode.vue'
import MatlabBoundaryNode from '@/components/model/MatlabBoundaryNode.vue'
import MatlabElkEdge from '@/components/model/MatlabElkEdge.vue'
import MatlabPhysicalLensToolbar from '@/components/model/MatlabPhysicalLensToolbar.vue'
import MatlabPhysicalProperties from '@/components/model/MatlabPhysicalProperties.vue'
import MatlabResultsDialog from '@/components/model/MatlabResultsDialog.vue'
import MatlabBusEditor from '@/components/model/MatlabBusEditor.vue'
import { type MatlabResultsDialogBindings } from '@/utils/matlabResultData'
import { useMatlabResults } from '@/composables/useMatlabResults'
import { useMatlabExecution } from '@/composables/useMatlabExecution'
import {
  cloneMatlabGraph,
  makeCompositePortData,
  parseMatlabProject,
  serializeMatlabProject,
  type MatlabBoundaryPort,
  type SavedMatlabProjectNode
} from '@/utils/matlabProjectData'
import { modelDeployApi, type ModelingProject } from '@/api/model-deploy'
import { useMatlabProject } from '@/composables/useMatlabProject'
import { useMatlabConfigWorkbook } from '@/composables/useMatlabConfigWorkbook'
import { useMatlabCanvasLayout } from '@/composables/useMatlabCanvasLayout'
import { useMatlabPhysicalLens } from '@/composables/useMatlabPhysicalLens'
import { useMatlabEditorStore } from '@/features/matlab-modeling/stores/useMatlabEditorStore'
import { useMatlabPhysicalAssemblyEditor } from '@/features/matlab-modeling/composables/useMatlabPhysicalAssemblyEditor'
import { useMatlabSubsystemNavigation } from '@/features/matlab-modeling/composables/useMatlabSubsystemNavigation'
import { useMatlabSubmissionValidation } from '@/features/matlab-modeling/composables/useMatlabSubmissionValidation'
import { useMatlabTemplateOperations } from '@/features/matlab-modeling/composables/useMatlabTemplateOperations'
import { compileExecutionPayload } from '@/features/matlab-modeling/infrastructure/executionPayloadCompiler'
import MatlabBreadcrumb from '@/features/matlab-modeling/components/MatlabBreadcrumb.vue'
import MatlabFailureDialog from '@/features/matlab-modeling/components/MatlabFailureDialog.vue'
import MatlabCatalogPanel from '@/features/matlab-modeling/components/MatlabCatalogPanel.vue'
import type { RuntimeSceneData } from '@/features/matlab-modeling/domain/sceneCommands'
import { physicalCapabilitiesOf } from '@/features/matlab-modeling/domain/physicalAssembly'
import { compareEngineConfigurationCatalogOrder } from '@/features/matlab-modeling/domain/componentCatalogOrdering'
import { useMatlabNodeSelection } from '@/features/matlab-modeling/composables/useMatlabNodeSelection'
import { builtinBoundaryComponents, BOUNDARY_IN_ID, BOUNDARY_OUT_ID, boundaryDirection, synchronizeProjectInterfaces } from '@/features/matlab-modeling/domain/boundaryComponents'
import { matchPortsInDeclarationOrder } from '@/features/matlab-modeling/domain/portAutoMatcher'
import {
  projectPhysicalEdges,
  selectPhysicalLayoutEdges,
  type PhysicalEdgeRoutes
} from '@/features/matlab-modeling/domain/physicalView'
import { createAssemblyRelation, removeAssemblyMembers, synchronizeAssemblyBindings } from '@/features/matlab-modeling/domain/assemblyCommands'
import { readPersistedDataEdges } from '@/features/matlab-modeling/domain/dataEdgeAdapter'
import {
  encapsulateSelection,
  unencapsulateSubsystem
} from '@/features/matlab-modeling/domain/sceneCommands'

import {
  matlabModelDeployApi,
  type MatlabComponent,
  type MatlabConfigRecord,
  type MatlabPort,
  type MatlabStructuredError
} from '@/api/matlab-model-deploy'
import {
  BUS_CREATOR_ID,
  BUS_SELECTOR_ID,
  builtinBusComponents,
  busFieldsForType,
  cloneBusFields,
  isBusComponentId,
  normalizeSignalName,
  validBusPath,
  type BusConfig,
  type BusField,
  type BusSelectorConfig
} from '@/utils/matlabBus'

type ComponentTreeNode = {
  key: string
  label: string
  type: 'folder' | 'component'
  component?: MatlabComponent
  children?: ComponentTreeNode[]
}

const nodeTypes = markRaw({
  modelicaComponent: markRaw(MatlabComponentNode),
  matlabBus: markRaw(MatlabBusNode),
  matlabBoundary: markRaw(MatlabBoundaryNode),
  matlabComposite: markRaw(MatlabCompositeNode)
}) as any
const edgeTypes = markRaw({ matlabElk: markRaw(MatlabElkEdge) }) as any
const defaultEdgeOptions = {
  type: 'matlabElk',
  zIndex: 1001,
  animated: false,
  markerEnd: MarkerType.ArrowClosed
}
const { setViewport, updateNodeInternals } = useVueFlow()

const components = ref<MatlabComponent[]>([])
const componentKeyword = ref('')
// 唯一 Scene 图状态源在 useMatlabEditorStore；nodes/edges 是对
// scenes[activeSceneId] 的可写透传，不再保存第二份图数据。
const editorStore = useMatlabEditorStore()
const nodes = computed<Node[]>({
  get: () => editorStore.activeSceneNodes,
  set: (next) => editorStore.setActiveSceneNodes(next)
})
const edges = computed<Edge[]>({
  get: () => editorStore.activeSceneEdges,
  set: (next) => editorStore.setActiveSceneEdges(next)
})
// Physical edges are a view projection, never a second persisted graph.
// Their ELK routes stay in memory and are discarded on scene changes/unmount.
const transientPhysicalRoutes = ref<PhysicalEdgeRoutes>({})
const projectedPhysicalEdges = computed<Edge[]>(() => projectPhysicalEdges(
  editorStore.scenes,
  editorStore.activeSceneId,
  editorStore.physicalAssemblies,
  transientPhysicalRoutes.value
))
const canvasEdges = computed<Edge[]>({
  get: () => [...edges.value, ...projectedPhysicalEdges.value],
  set: next => { edges.value = next.filter(edge => !edge.data?.physicalProjection) }
})
const designPointUpgradePending = ref(false)
type PhysicalRelation = 'flow' | 'shaft' | 'bleed'
const physicalRelation = ref<PhysicalRelation>('flow')
const selectedEdgeId = ref<string | null>(null)
const selectedEdge = computed(() => selectedEdgeId.value
  ? canvasEdges.value.find((edge) => edge.id === selectedEdgeId.value) || null
  : null)
const rootSceneId = 'scene_root'
const projectRootSceneId = ref(rootSceneId)
// activeSceneId 由 store 持有；页面读写通过可写 computed 透传。
const activeSceneId = computed<string>({
  get: () => editorStore.activeSceneId,
  set: (sceneId) => editorStore.setActiveScene(sceneId)
})
const sceneHydrating = ref(false)
type RuntimeScene = RuntimeSceneData
const sceneStore = computed(() => editorStore.scenes)
const sceneBreadcrumb = computed(() => {
  const result: RuntimeScene[] = []
  const visited = new Set<string>()
  let current: RuntimeScene | undefined = sceneStore.value[activeSceneId.value]
  while (current && !visited.has(current.id)) {
    result.unshift(current)
    visited.add(current.id)
    current = current.parentSceneId ? sceneStore.value[current.parentSceneId] : undefined
  }
  return result
})
const scenePathTitle = (sceneId: string) => {
  const result: string[] = []
  const visited = new Set<string>()
  let current: RuntimeScene | undefined = sceneStore.value[sceneId]
  while (current && !visited.has(current.id)) {
    result.unshift(current.title)
    visited.add(current.id)
    current = current.parentSceneId ? sceneStore.value[current.parentSceneId] : undefined
  }
  return result.join(' / ')
}
const activeScene = computed(() => sceneStore.value[activeSceneId.value])
const { mode: physicalLensMode, isNodeFocused, isEdgeFocused } = useMatlabPhysicalLens(
  activeSceneId,
  computed(() => canvasHasPhysicalComponents.value),
  canvasEdges
)
// V3：物理透视入口由部件能力与装配成员决定，不再由 Scene 类型决定。
const canvasHasPhysicalComponents = computed(() => nodes.value.some((node) => (
  Boolean(physicalCapabilitiesOf(node.data)?.flow)
)))
const canCreateAssemblyRelation = computed(() => {
  const selected = nodes.value.filter(node => isNodeSelected(node))
  // Let the domain command recursively validate pure organization subsystems;
  // rejecting them here would make nested hand-built physical groups impossible.
  return selected.length > 0
})
const physicalLayoutEdges = computed<Edge[]>(() => selectPhysicalLayoutEdges(
  edges.value,
  projectedPhysicalEdges.value,
  canvasHasPhysicalComponents.value
))
const physicalLensFocused = computed(() => canvasHasPhysicalComponents.value && physicalLensMode.value !== 'overview')
const physicalLensActiveCount = computed(() => {
  const assembly = editorStore.activeAssembly
  if (!assembly) return 0
  if (physicalLensMode.value === 'flow') return assembly.flowRelations.length
  if (physicalLensMode.value === 'shaft') return assembly.shaftGroups.length
  if (physicalLensMode.value === 'bleed') return assembly.bleedGroups.length
  return 0
})

/** 流路角色只在选中具体气路边后编辑；未指定时移除字段。 */
const updateSelectedEdgeStreamRole = (streamRole: string) => {
  const assembly = editorStore.activeAssembly
  const edge = selectedEdge.value
  if (!assembly || !edge) return
  const relationId = String(edge.data?.relationId || '')
  assembly.flowRelations = assembly.flowRelations.map((relation) => {
    if (relation.id !== relationId) return relation
    const next = { ...relation }
    if (streamRole === 'core' || streamRole === 'bypass') next.streamRole = streamRole
    else delete next.streamRole
    return next
  })
  editorStore.upsertAssembly({ ...assembly })
  resetResultData()
}
const activeAssemblyGroups = computed(() => {
  const assembly = editorStore.activeAssembly
  if (!assembly) return []
  return [...assembly.shaftGroups, ...assembly.bleedGroups]
})
const activeAssemblyDefaults = computed(() => editorStore.activeAssembly?.defaults || {})
const updatePhysicalSceneParameter = (key: string, value: any) => {
  // 构型级参数入装配 defaults（V3）
  const assembly = editorStore.activeAssembly
  if (!assembly) return
  editorStore.upsertAssembly({ ...assembly, defaults: { ...assembly.defaults, [key]: value } })
  resetResultData()
}
const selectedSceneNodeIds = computed(() => nodes.value
  .filter((node) => isNodeSelected(node))
  .map((node) => node.id))
const selectedCompositeNode = computed(() => {
  const selected = nodes.value.find((node) => isNodeSelected(node))
  return selected?.data?.childSceneId ? selected : null
})
const selectedNodeId = ref<string | null>(null)
// Ctrl 选择自动连线的临时发送节点，不写入节点数据或项目文件。
const autoConnectSourceNodeId = ref<string | null>(null)
const selectedNode = computed<Node | null>(() => {
  if (!selectedNodeId.value) return null
  return nodes.value.find((node) => node.id === selectedNodeId.value) || null
})
const selectedNodeInstanceName = ref('')
const selectedInputValues = ref<Record<string, unknown>>({})
const selectedNodeBoundaryPorts = computed<MatlabBoundaryPort[]>(() => (
  Array.isArray(selectedNode.value?.data?.boundaryPorts)
    ? selectedNode.value!.data.boundaryPorts as MatlabBoundaryPort[] : []
))









const loading = ref(false)
const loadingText = ref('加载中...')
const calculationDialogVisible = ref(false)
const resultTab = ref('chart')
const payloadPreviewVisible = ref(false)
const generatedPayload = ref('')
const flowContainer = ref<HTMLElement>()
const simulationLogs = ref<Array<{ time: string; type: string; message: string }>>([])
const lastTaskId = ref<number | null>(null)







let ignoreNextPaneClick = false






type WorkflowConnectionCandidate = {
  sourceNode: Node
  targetNode: Node
  sourcePort: MatlabPort
  targetPort: MatlabPort
  sourceHandle: string
  targetHandle: string
}

type ConnectionBatchResult = {
  addedEdges: Edge[]
  skippedCount: number
  cycle: boolean
}

const isValidPort = (value: unknown): value is MatlabPort => {
  if (!value || typeof value !== 'object') return false
  const port = value as Partial<MatlabPort>
  return typeof port.name === 'string' && port.name.trim().length > 0
    && typeof port.type === 'string' && port.type.trim().length > 0
}

const getValidPorts = (value: unknown): MatlabPort[] => {
  if (!Array.isArray(value)) return []
  const names = new Set<string>()
  return value.filter((port): port is MatlabPort => {
    if (!isValidPort(port) || names.has(port.name)) return false
    names.add(port.name)
    return true
  })
}

const selectedInputPorts = computed(() => getValidPorts(selectedNode.value?.data?.inputPorts))
const editableNumberPorts = computed(() => selectedInputPorts.value
  .filter((port) => port.type === 'number' || port.type === 'array'))
const structuredInputPorts = computed(() => selectedInputPorts.value
  .filter((port) => port.type !== 'number'))
const visibleOutputPorts = computed(() => getValidPorts(selectedNode.value?.data?.outputPorts))

const isBusNode = (node: Node | null | undefined) => (
  node?.data?.nodeKind === 'busCreator' || node?.data?.nodeKind === 'busSelector'
)

const selectedBusConfig = computed<BusConfig>(() => {
  const config = selectedNode.value?.data?.busConfig
  return {
    schemaMode: config?.schemaMode === 'named' ? 'named' : 'anonymous',
    schemaRef: config?.schemaRef,
    name: config?.name,
    fields: cloneBusFields(config?.fields)
  }
})

const selectedSelectorConfig = computed<BusSelectorConfig>(() => {
  const config = selectedNode.value?.data?.selectorConfig
  return {
    sourceSchemaRef: config?.sourceSchemaRef,
    selectedFields: cloneBusFields(config?.selectedFields)
  }
})

const selectedBusAvailableFields = computed<BusField[]>(() => {
  if (!selectedNode.value || selectedNode.value.data?.nodeKind !== 'busSelector') return []
  const inputEdge = edges.value.find((edge) => edge.target === selectedNode.value?.id
    && String(edge.targetHandle || '') === 'bus')
  const sourceNode = nodes.value.find((node) => node.id === inputEdge?.source)
  if (sourceNode?.data?.nodeKind === 'busCreator') {
    return cloneBusFields(sourceNode.data?.busConfig?.fields)
  }
  const sourcePort = sourceNode && findNodePort(sourceNode, 'output', String(inputEdge?.sourceHandle || ''))
  return busFieldsForType(sourcePort?.type)
})

const selectedResourceDefinition = computed(() => {
  const rawResources = selectedNode.value?.data?.resourceDefinitions
  const resources = Array.isArray(rawResources) ? rawResources as Array<Record<string, any>> : []
  return resources.find((resource) => resource.name === 'motorConfig') || null
})

const selectedConfigRecord = computed<MatlabConfigRecord | null>(() => {
  return (selectedNode.value?.data?.motorConfig || null) as MatlabConfigRecord | null
})

const workflowRequiredInputCount = computed(() => nodes.value.reduce((count, node) => {
  const ports = getValidPorts(node.data?.inputPorts)
  return count + ports.filter((port) => port.required !== false).length
}, 0))

const workflowOutputCount = computed(() => nodes.value.reduce((count, node) => {
  return count + getValidPorts(node.data?.outputPorts).length
}, 0))

const catalogComponents = computed(() => components.value)

const componentTreeData = computed<ComponentTreeNode[]>(() => {
  const keyword = componentKeyword.value.trim().toLowerCase()
  const filtered = catalogComponents.value.filter((component) => {
    if (!keyword) return true
    return [component.name, component.functionName, component.description, component.library, component.category]
      .some((value) => String(value || '').toLowerCase().includes(keyword))
  })
  const libraries = new Map<string, ComponentTreeNode>()
  const categories = new Map<string, ComponentTreeNode>()
  filtered.forEach((component) => {
    const library = formatLibrary(component.library)
    const category = formatCategory(component.category)
    if (!libraries.has(library)) {
      libraries.set(library, {
        key: `library:${library}`,
        label: library,
        type: 'folder',
        children: []
      })
    }
    const categoryKey = `${library}:${category}`
    if (!categories.has(categoryKey)) {
      const categoryFolder: ComponentTreeNode = {
        key: `category:${categoryKey}`,
        label: category,
        type: 'folder',
        children: []
      }
      categories.set(categoryKey, categoryFolder)
      libraries.get(library)?.children?.push(categoryFolder)
    }
    categories.get(categoryKey)?.children?.push({
      key: `component:${component.id}`,
      label: component.name,
      type: 'component',
      component
    })
  })
  libraries.forEach((library) => {
    library.children?.forEach((category) => {
      if (library.label === '航空发动机' && category.label === '发动机构型') {
        category.children?.sort((a, b) => {
          return compareEngineConfigurationCatalogOrder(
            { catalogOrder: a.component?.catalogOrder, name: a.label },
            { catalogOrder: b.component?.catalogOrder, name: b.label }
          )
        })
      } else {
        category.children?.sort((a, b) => a.label.localeCompare(b.label, 'zh-CN'))
      }
    })
    library.children?.sort((a, b) => a.label.localeCompare(b.label, 'zh-CN'))
  })
  const libraryOrder = ['PMSM(混动发动机)', 'PMSM(独立)', '航空发动机', '公共工具']
  return Array.from(libraries.values()).sort((a, b) => {
    const left = libraryOrder.indexOf(a.label)
    const right = libraryOrder.indexOf(b.label)
    if (left >= 0 || right >= 0) return (left < 0 ? libraryOrder.length : left) - (right < 0 ? libraryOrder.length : right)
    return a.label.localeCompare(b.label, 'zh-CN')
  })
})

const formatLibrary = (library?: string) => library?.trim() || '未分类组件库'

const formatCategory = (category?: string) => {
  const labels: Record<string, string> = {
    dimension: '尺寸计算',
    loss: '损耗计算',
    'loss-calculation': '损耗计算',
    electrical: '电气计算',
    mechanical: '机械计算',
    'thermal-resistance': '热阻计算',
    'heat-transfer': '换热计算',
    'fluid-property': '流体属性',
    'material-property': '材料属性',
    'workflow-tools': '工作流工具',
    'pmsm尺寸与电磁': '尺寸与电磁',
    'pmsm工作流': '工作流',
    'pmsm换热计算': '换热计算',
    'pmsm损耗计算': '损耗计算',
    'pmsm性能计算': '性能计算',
    'pmsm质量与结构': '质量与结构',
    'pmsm主流程': '主流程',
    '热网络基础组件': '热网络',
    '航空发动机气路部件': '气路部件',
    other: '其他计算'
  }
  return labels[String(category || '').toLowerCase()] || category || 'MATLAB函数'
}

const resolveComponentCover = (component?: MatlabComponent) => {
  return component?.coverImage || component?.fallbackIcon || ''
}

const formatPortLabel = (port: MatlabPort) => {
  return `${port.name}${port.unit ? ` [${port.unit}]` : ''}`
}

const formatInputRange = (port: MatlabPort) => {
  if (port.min == null && port.max == null) return ''
  const lower = port.min == null ? '-∞' : port.min
  const upper = port.max == null ? '+∞' : port.max
  return `；范围 [${lower}, ${upper}]`
}

const normalizeInstanceName = (value: string) => {
  // instanceName is a user-facing label, not a MATLAB identifier. Internal
  // node IDs and function names are stored separately and keep their own rules.
  return value.trim() || 'matlabFunction1'
}

const nextInstanceName = (functionName: string) => {
  const usedNames = new Set<string>([
    ...nodes.value.map((node) => String(node.data?.instanceName || node.label || '')),
    ...components.value.map((component) => component.name)
  ])
  let index = 1
  let candidate = `${functionName}${index}`
  while (usedNames.has(candidate)) {
    index += 1
    candidate = `${functionName}${index}`
  }
  return candidate
}

const toScalarNumber = (value: unknown) => {
  if (typeof value === 'number') return value
  if (typeof value === 'string' && value.trim() !== '') return Number(value)
  return Number.NaN
}

const addLog = (type: string, message: string) => {
  simulationLogs.value.push({
    time: new Date().toLocaleTimeString('zh-CN', { hour12: false }),
    type,
    message
  })
}

const { lastSubmittedWorkflowNodes, resultVariables, resultValues, selectedResultVariables, expandedResultGroups, activeResultNodeId, activeResultPortKey, hasCachedResult, lastWorkflowResult, resultBatchId, activeArtifactPhase, generatedJuliaCode, formattedWorkflowResult, resultVariableGroups, resultArtifactGroups, artifactPhaseLabel, selectedArrayVariables, selectedLineArrayVariables, selectedPlotVariables, availableResultNodes, activeResultNode, activeResultPorts, activeResultPort, resultDialogVisible, handleResultNodeSelect, handleResultPortSelect, handleOpenLatestResult, copyGeneratedJuliaCode, applyCalculationResult, resetResultData: resetResultState } = useMatlabResults({ addLog, calculationDialogVisible })


const finiteMetadataNumber = (value: unknown) => {
  // 未设置的元数据不能通过 Number(null/空字符串/布尔值) 变成 0 或 1。
  if (typeof value !== 'number' && typeof value !== 'string') return undefined
  if (typeof value === 'string' && value.trim() === '') return undefined
  const parsed = Number(value)
  return Number.isFinite(parsed) ? parsed : undefined
}

const normalizeComponentPorts = (
  rawPorts: unknown,
  componentName: string,
  direction: '输入' | '输出'
): MatlabPort[] => {
  if (!Array.isArray(rawPorts)) {
    addLog('warning', `${componentName}的${direction}端口不是数组，已按空端口处理`)
    return []
  }
  const names = new Set<string>()
  const ports: MatlabPort[] = []
  rawPorts.forEach((rawPort, index) => {
    if (!isValidPort(rawPort) || names.has(rawPort.name)) {
      addLog('warning', `${componentName}的${direction}端口#${index + 1}无效或重名，已跳过`)
      return
    }
    names.add(rawPort.name)
    let min = finiteMetadataNumber(rawPort.min)
    let max = finiteMetadataNumber(rawPort.max)
    if (min != null && max != null && min > max) {
      addLog('warning', `${componentName}.${rawPort.name}的数值范围无效，已忽略范围限制`)
      min = undefined
      max = undefined
    }
    const portType = rawPort.type.trim()
    const rawDefault = rawPort.defaultValue
    const isNumericArray = (value: unknown): value is number[] | number[][] => Array.isArray(value)
      && value.every((row) => Array.isArray(row)
        ? row.every((item) => typeof item === 'number' && Number.isFinite(item))
        : typeof row === 'number' && Number.isFinite(row))
    const defaultValue = portType === 'number'
      ? finiteMetadataNumber(rawDefault)
      : (portType === 'array' && (isNumericArray(rawDefault) || finiteMetadataNumber(rawDefault) != null) ? rawDefault
      : (typeof rawDefault === 'string' || typeof rawDefault === 'boolean'
          ? rawDefault
          : undefined))
    ports.push({
      ...rawPort,
      name: rawPort.name.trim(),
      type: portType,
      defaultValue,
      min,
      max
    })
  })
  return ports
}

const initialNumericValue = (port: MatlabPort) => {
  const defaultValue = finiteMetadataNumber(port.defaultValue)
  if (defaultValue != null) return defaultValue
  const minimum = finiteMetadataNumber(port.min)
  return minimum ?? 0
}

const initialLiteralValue = (port: MatlabPort): unknown => {
  if (port.type === 'number') return initialNumericValue(port)
  if (port.type === 'array' && Array.isArray(port.defaultValue)) return cloneMatlabGraph(port.defaultValue)
  if (port.type === 'array' && typeof port.defaultValue === 'number') return port.defaultValue
  return typeof port.defaultValue === 'string' || typeof port.defaultValue === 'boolean'
    ? port.defaultValue
    : undefined
}

const isNumericArrayLiteral = (value: unknown): value is number[] | number[][] => {
  if (!Array.isArray(value)) return false
  if (value.every((item) => typeof item === 'number' && Number.isFinite(item))) return true
  return value.every((row) => Array.isArray(row)
    && row.every((item) => typeof item === 'number' && Number.isFinite(item))
    && value.every((row) => row.length === value[0]?.length))
}

const isMatlabLiteral = (value: unknown): value is number | string | boolean | number[] | number[][] => (
  typeof value === 'string' || typeof value === 'boolean'
  || (typeof value === 'number' && Number.isFinite(value))
  || isNumericArrayLiteral(value)
)

const isNodeSelected = (node: Node) => Boolean((node as Node & { selected?: boolean }).selected)

const loadComponents = async () => {
  loadingText.value = '正在加载MATLAB组件库...'
  loading.value = true
  try {
    const [componentResponse, schemaResponse] = await Promise.all([
      matlabModelDeployApi.getComponents(),
      matlabModelDeployApi.getConfigSchema()
    ])
    components.value = [
      ...(builtinBusComponents() as MatlabComponent[]),
      ...builtinBoundaryComponents(),
      ...(componentResponse.data || []).filter(component => !component.hiddenFromCatalog)
    ]
    configSchema.value = schemaResponse.data || null
    if (components.value.length === 0) ElMessage.info('暂无可用MATLAB组件')
  } catch (error: any) {
    ElMessage.error(`MATLAB组件加载失败: ${error.message || '未知错误'}`)
  } finally {
    loading.value = false
  }
}

const handleComponentDragStart = (event: DragEvent, component?: MatlabComponent) => {
  if (!component || !event.dataTransfer) {
    event.preventDefault()
    return
  }
  const payload = JSON.stringify(component)
  event.dataTransfer.setData('application/json', payload)
  event.dataTransfer.setData('text/plain', payload)
  event.dataTransfer.effectAllowed = 'copy'
}


const handleDrop = (event: DragEvent) => {
  event.preventDefault()
  event.stopPropagation()
  if (canvasHasPhysicalComponents.value
      && (physicalLensMode.value === 'shaft' || physicalLensMode.value === 'bleed')) return
  const raw = event.dataTransfer?.getData('application/json')
    || event.dataTransfer?.getData('text/plain')
  if (!raw) {
    ElMessage.warning('未获取到拖拽组件数据')
    return
  }
  let component: MatlabComponent
  try {
    component = JSON.parse(raw) as MatlabComponent
  } catch {
    ElMessage.warning('组件数据格式不正确')
    return
  }

  if (component.executionKind === 'busCreator' || component.executionKind === 'busSelector'
    || isBusComponentId(component.id)) {
    addBusNode(component, event)
    return
  }

  if (component.componentKind === 'boundaryPort' || component.id === BOUNDARY_IN_ID || component.id === BOUNDARY_OUT_ID) {
    addBoundaryNode(component, event)
    return
  }

  if (component.templateDefinition && instantiateTemplateComponent(component, event)) return

  const rect = flowContainer.value?.getBoundingClientRect()
  const position = rect
    ? {
        x: Math.min(Math.max(20, event.clientX - rect.left - 180), Math.max(20, rect.width - 380)),
        y: Math.min(Math.max(20, event.clientY - rect.top - 50), Math.max(20, rect.height - 240))
      }
    : { x: 120, y: 80 }
  const inputPorts = normalizeComponentPorts(component.inputs, component.name, '输入')
  const outputPorts = normalizeComponentPorts(component.outputs, component.name, '输出')
  const values = Object.fromEntries(inputPorts
    .map((port) => [port.name, initialLiteralValue(port)] as const)
    .filter((entry): entry is readonly [string, number | string | boolean] => entry[1] !== undefined))
  const connectors = [
    ...inputPorts.map((port) => ({ name: port.name, type: 'WorkflowInput' })),
    ...outputPorts.map((port) => ({ name: port.name, type: 'WorkflowOutput' }))
  ]
  const instanceName = nextInstanceName(component.functionName)
  const node: Node = {
    id: `matlab_${Date.now()}_${nodes.value.length + 1}`,
    type: 'modelicaComponent',
    position,
    label: instanceName,
    data: {
      componentId: component.id,
      componentName: component.name,
      instanceName,
      componentType: component.functionName,
      functionName: component.functionName,
      componentKind: component.componentKind || 'scalar',
      sceneNodeKind: 'matlabNode',
      assemblyDefaults: component.assemblyDefaults,
      physicalCapabilities: component.physicalCapabilities,
      legacyName: component.legacyName,
      legacyOrder: component.legacyOrder,
      description: component.description || '',
      coverImage: resolveComponentCover(component),
      connectors,
      inputPorts,
      outputPorts,
      portDisplayNames: physicalPortDisplayNames({
        nodeKind: 'matlabNode',
        legacyName: component.legacyName,
        componentId: component.id
      }, inputPorts, outputPorts),
      resourceDefinitions: component.resources || [],
      resources: {},
      motorConfig: null,
      values
    }
  }
  nodes.value = [
    ...nodes.value.map((existingNode) => ({ ...existingNode, selected: false })),
    { ...node, selected: true }
  ]
  ignoreNextPaneClick = true
  nextTick(() => {
    selectNodeById(node.id)
    window.setTimeout(() => {
      ignoreNextPaneClick = false
    }, 250)
  })
  scheduleElkLayout(false, 'routing')
  addLog('info', `已添加组件：${component.name}`)
}

const isCompatiblePortType = (sourceType: string, targetType: string) => (
  targetType === 'unknown'
  || sourceType === targetType
  || (targetType === 'bus' && (sourceType === 'bus' || /^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$/.test(sourceType)))
)

const addBusNode = (component: MatlabComponent, event: DragEvent) => {
  const rect = flowContainer.value?.getBoundingClientRect()
  const position = rect
    ? {
        x: Math.min(Math.max(20, event.clientX - rect.left - 180), Math.max(20, rect.width - 380)),
        y: Math.min(Math.max(20, event.clientY - rect.top - 50), Math.max(20, rect.height - 240))
      }
    : { x: 120, y: 80 }
  const nodeKind = component.executionKind === 'busSelector' ? 'busSelector' : 'busCreator'
  const instanceName = nextInstanceName(nodeKind === 'busCreator' ? 'busCreator' : 'busSelector')
  const makeField = (index: number): BusField => {
    const fieldId = `field_${Date.now()}_${nodes.value.length}_${index}`
    const name = `signal${index}`
    return {
      id: fieldId, path: name, label: name, nameMode: 'auto',
      dataType: 'unknown', contractStatus: 'pending', required: true,
      inputPortId: `bus_in_${fieldId}`, outputPortId: `bus_out_${fieldId}`
    }
  }
  const busConfig: BusConfig = {
    schemaMode: 'anonymous',
    name: instanceName,
    fields: nodeKind === 'busCreator' ? [makeField(1), makeField(2)] : []
  }
  const selectorConfig: BusSelectorConfig = { selectedFields: [] }
  const inputPorts = nodeKind === 'busCreator'
    ? cloneBusFields(busConfig.fields).map((field) => ({
        name: field.inputPortId || field.id,
        type: field.dataType,
        unit: field.unit,
        required: field.required,
        description: field.path
      }))
    : [{ name: 'bus', type: 'bus', required: true }]
  const outputPorts = nodeKind === 'busCreator'
    ? [{ name: 'bus', type: 'bus', description: '结构化Bus' }]
    : []
  const node: Node = {
    id: `matlab_bus_${Date.now()}_${nodes.value.length + 1}`,
    type: 'matlabBus',
    position,
    label: instanceName,
    data: {
      componentId: component.id,
      componentName: component.name,
      instanceName,
      componentType: nodeKind,
      functionName: '',
      componentKind: 'workflow',
      executionKind: nodeKind,
      nodeKind,
      description: component.description || '',
      coverImage: resolveComponentCover(component),
      connectors: [
        ...inputPorts.map((port) => ({ name: port.name, type: 'WorkflowInput' })),
        ...outputPorts.map((port) => ({ name: port.name, type: 'WorkflowOutput' }))
      ],
      inputPorts,
      outputPorts,
      resourceDefinitions: [],
      resources: {},
      values: {},
      busConfig,
      selectorConfig,
      availableBusFields: [],
      portDisplayNames: Object.fromEntries([
        ...inputPorts.map((port) => [port.name, cloneBusFields(busConfig.fields).find((field) => (field.inputPortId || field.id) === port.name)?.label || port.name]),
        ...outputPorts.map((port) => [port.name, port.name])
      ]),
      portPaths: Object.fromEntries(cloneBusFields(busConfig.fields).map((field) => [field.inputPortId || field.id, field.path]))
    }
  }
  nodes.value = [
    ...nodes.value.map((existingNode) => ({ ...existingNode, selected: false })),
    { ...node, selected: true }
  ]
  ignoreNextPaneClick = true
  nextTick(() => {
    selectNodeById(node.id)
    window.setTimeout(() => { ignoreNextPaneClick = false }, 250)
  })
  resetResultData()
  scheduleElkLayout(false, 'routing')
  addLog('info', `已添加工作流节点：${component.name}`)
}

const addBoundaryNode = (component: MatlabComponent, event: DragEvent) => {
  const direction = component.id === BOUNDARY_OUT_ID ? 'output' : 'input'
  const rect = flowContainer.value?.getBoundingClientRect()
  const position = rect ? {
    x: Math.min(Math.max(20, event.clientX - rect.left - 46), Math.max(20, rect.width - 120)),
    y: Math.min(Math.max(20, event.clientY - rect.top - 30), Math.max(20, rect.height - 90))
  } : { x: 120, y: 80 }
  const label = nextInstanceName(direction === 'input' ? 'In' : 'Out')
  const inputPorts = direction === 'output' ? [{ name: 'in', type: 'unknown' }] : []
  const outputPorts = direction === 'input' ? [{ name: 'out', type: 'unknown' }] : []
  const node: Node = {
    id: `matlab_boundary_${Date.now()}_${nodes.value.length + 1}`,
    type: 'matlabBoundary', position, label,
    data: {
      componentId: component.id, componentName: component.name, instanceName: label,
      componentKind: 'boundaryPort', nodeKind: 'boundaryPort', executionKind: 'boundaryPort',
      boundaryDirection: direction, functionName: '', description: component.description || '',
      inputPorts, outputPorts, connectors: [], values: {}, resources: {},
      presentationSize: { width: 104, height: 58 }
    }
  }
  nodes.value = [...nodes.value.map(existing => ({ ...existing, selected: false })), { ...node, selected: true }]
  nextTick(() => selectNodeById(node.id))
  resetResultData()
}

const boundarySignalSummary = (node: Node) => {
  const direction = boundaryDirection(node)
  const edge = direction === 'input'
    ? edges.value.find(item => item.source === node.id)
    : edges.value.find(item => item.target === node.id)
  const other = edge ? nodes.value.find(item => item.id === (direction === 'input' ? edge.target : edge.source)) : undefined
  const port = edge && other
    ? findNodePort(other, direction === 'input' ? 'input' : 'output', String(direction === 'input' ? edge.targetHandle || '' : edge.sourceHandle || ''))
    : undefined
  return { type: port?.type || '由连接推导', unit: port?.unit, shape: port?.shape?.join(' × ') }
}

const selectNodeById = (nodeId: string, preserveSelection = false) => {
  const node = nodes.value.find((candidate) => candidate.id === nodeId)
  if (!node) {
    clearNodeSelection()
    return
  }
  if (!preserveSelection && nodes.value.some((candidate) => isNodeSelected(candidate) !== (candidate.id === node.id))) {
    nodes.value = nodes.value.map((candidate) => ({
      ...candidate,
      selected: candidate.id === node.id
    }))
  }
  selectedNodeId.value = node.id
  selectedNodeInstanceName.value = String(node.data?.instanceName || node.label || '')
  const existingValues = node.data?.values && typeof node.data.values === 'object'
    ? node.data.values as Record<string, unknown>
    : {}
  selectedInputValues.value = Object.fromEntries(
    getValidPorts(node.data?.inputPorts)
      .filter((port) => port.type === 'number' || port.type === 'array')
      .map((port) => {
        const existing = existingValues[port.name]
        if (port.type === 'array') {
          return [port.name, isMatlabLiteral(existing) && Array.isArray(existing)
            ? cloneMatlabGraph(existing)
            : (typeof existing === 'number' && Number.isFinite(existing)
              ? [existing] : cloneMatlabGraph(initialLiteralValue(port)))]
        }
        const currentValue = finiteMetadataNumber(existing)
        return [port.name, currentValue ?? initialNumericValue(port)]
      })
  )
}

const clearNodeSelection = () => {
  if (nodes.value.some((node) => isNodeSelected(node))) {
    nodes.value = nodes.value.map((node) => ({ ...node, selected: false }))
  }
  selectedNodeId.value = null
  selectedNodeInstanceName.value = ''
  selectedInputValues.value = {}
}

const handleCreateAssemblyRelation = () => {
  const selectedIds = new Set(nodes.value.filter(node => isNodeSelected(node)).map(node => node.id))
  const token = `${Date.now()}_${Math.random().toString(36).slice(2, 7)}`
  const assemblyId = `assembly_${token}`
  const result = createAssemblyRelation({
    nodes: nodes.value,
    edges: edges.value,
    assemblies: editorStore.physicalAssemblies,
    scenes: editorStore.scenes,
    selectedIds,
    sceneId: activeSceneId.value,
    assemblyId,
    relationSceneId: `scene_${assemblyId}`,
    descriptorNodeId: `assembly_descriptor_${token}`,
    name: `装配关系 ${Object.keys(editorStore.physicalAssemblies).length + 1}`
  })
  if (!result.ok) {
    ElMessage.warning(result.reason)
    return
  }
  Object.values(editorStore.physicalAssemblies)
    .filter(assembly => assembly.memberNodeIds.some(id => selectedIds.has(id)))
    .forEach(assembly => editorStore.removeAssembly(assembly.id))
  editorStore.upsertAssembly(result.assembly)
  editorStore.activeAssemblyId = result.assembly.id
  editorStore.putScene(result.scene)
  result.scene.nodes.forEach((node: Node) => {
    const nestedScene = editorStore.scenes[String(node.data?.childSceneId || '')]
    if (nestedScene) nestedScene.parentSceneId = result.scene.id
  })
  const movedPhysicalMemberIds = new Set(result.assembly.memberNodeIds)
  edges.value = edges.value.filter(edge => edge.data?.physicalProjection !== true
    || (!movedPhysicalMemberIds.has(edge.source) && !movedPhysicalMemberIds.has(edge.target)))
  nodes.value = result.nodes.map(node => ({ ...node, selected: node.id === result.descriptor.id }))
  selectNodeById(result.descriptor.id)
  nextTick(() => updateNodeInternals([result.descriptor.id]))
  scheduleElkLayout(false, 'routing')
  resetResultData()
  ElMessage.success('已创建装配关系；将其 assembly_json 输出连接到 DP 组装输入')
}

const handleEncapsulateSelection = () => {
  const selectedIds = new Set(nodes.value.filter((node) => isNodeSelected(node)).map((node) => node.id))
  const compositeId = `subsystem_${Date.now()}_${selectedIds.size}`
  const childSceneId = `scene_${compositeId}`
  const instanceName = `Subsystem${Object.keys(sceneStore.value).length}`
  const result = encapsulateSelection({
    nodes: nodes.value,
    dataEdges: edges.value,
    selectedIds,
    findNodePort: findNodePort,
    compositeId,
    childSceneId,
    parentSceneId: activeSceneId.value,
    instanceName
  })
  if (!result.ok) {
    if (result.reason === 'empty-selection') {
      ElMessage.info('请先按住 Shift 选择需要封装的节点')
    } else {
      ElMessage.error(`无法识别跨边界端口：边 ${result.edgeId || '-'}，节点 ${result.nodeId || '-'}，端口 ${result.portId || '-'}`)
    }
    return
  }
  editorStore.putScene(result.childScene)
  result.childScene.nodes.forEach(node => {
    const nested = editorStore.scenes[node.data?.childSceneId]
    if (nested) nested.parentSceneId = childSceneId
  })
  nodes.value = result.nextNodes
  edges.value = result.nextEdges
  selectNodeById(compositeId)
  nextTick(() => updateNodeInternals([compositeId]))
  scheduleElkLayout(false, 'routing')
  ElMessage.success(`已封装 ${result.wrappedCount} 个节点；生成 ${result.boundaryPorts.length} 个边界端口`)
}

const handleUnencapsulateSelection = () => {
  const composite = selectedCompositeNode.value
  const childSceneId = String(composite?.data?.childSceneId || '')
  const childScene = childSceneId ? sceneStore.value[childSceneId] : undefined
  if (!composite || !childScene || !activeScene.value) return
  const result = unencapsulateSubsystem({
    compositeNode: composite,
    childScene,
    nodes: nodes.value,
    edges: edges.value
  })
  if (!result.ok) return
  nodes.value = result.nextNodes
  edges.value = result.nextEdges
  result.nextNodes.forEach(node => {
    const nested = editorStore.scenes[node.data?.childSceneId]
    if (nested) nested.parentSceneId = activeSceneId.value
  })
  editorStore.removeScene(childSceneId)
  clearNodeSelection()
  scheduleElkLayout(false, 'routing')
  ElMessage.success('已解封装子系统，恢复内部节点和边界连接')
}

const busPortsForNode = (node: Node) => {
  const nodeKind = node.data?.nodeKind
  if (nodeKind === 'busCreator') {
    const fields = cloneBusFields(node.data?.busConfig?.fields).filter((field) => validBusPath(field.path))
    return {
      inputs: fields.map((field) => ({
        name: field.inputPortId || field.id,
        type: field.dataType || 'unknown',
        unit: field.unit,
        required: field.required,
        description: field.path
      })),
      outputs: [{
        name: 'bus',
        type: node.data?.busConfig?.schemaRef || 'bus',
        description: '结构化Bus'
      }]
    }
  }
  if (nodeKind === 'busSelector') {
    const selected = cloneBusFields(node.data?.selectorConfig?.selectedFields).filter((field) => validBusPath(field.path))
    return {
      inputs: [{ name: 'bus', type: 'bus', required: true }],
      outputs: selected.map((field) => ({
        name: field.outputPortId || `bus_out_${field.id}`,
        type: field.dataType || 'unknown',
        unit: field.unit,
        description: field.path
      }))
    }
  }
  return null
}

const syncBusNodePorts = (nodeId: string) => {
  const node = nodes.value.find((candidate) => candidate.id === nodeId)
  if (!node || !isBusNode(node)) return
  const ports = busPortsForNode(node)
  if (!ports) return
  const connectors = [
    ...ports.inputs.map((port) => ({ name: port.name, type: 'WorkflowInput' })),
    ...ports.outputs.map((port) => ({ name: port.name, type: 'WorkflowOutput' }))
  ]
  const config = node.data?.busConfig as BusConfig | undefined
  const selectorConfig = node.data?.selectorConfig as BusSelectorConfig | undefined
  const fields = node.data?.nodeKind === 'busCreator'
    ? cloneBusFields(config?.fields)
    : cloneBusFields(selectorConfig?.selectedFields)
  const portDisplayNames: Record<string, string> = {}
  const portPaths: Record<string, string> = {}
  fields.forEach((field) => {
    const portId = node.data?.nodeKind === 'busCreator'
      ? (field.inputPortId || field.id)
      : (field.outputPortId || `bus_out_${field.id}`)
    portDisplayNames[portId] = String(field.label || field.path || portId)
    portPaths[portId] = field.path
  })
  if (node.data?.nodeKind === 'busCreator') portDisplayNames.bus = 'bus'
  if (node.data?.nodeKind === 'busSelector') portDisplayNames.bus = 'bus'
  nodes.value = nodes.value.map((candidate) => candidate.id === nodeId
    ? { ...candidate, data: { ...candidate.data, inputPorts: ports.inputs, outputPorts: ports.outputs, connectors, portDisplayNames, portPaths } }
    : candidate)
  const current = nodes.value.find((candidate) => candidate.id === nodeId)
  const inputMap = new Map(getValidPorts(current?.data?.inputPorts).map((port) => [port.name, port]))
  const outputMap = new Map(getValidPorts(current?.data?.outputPorts).map((port) => [port.name, port]))
  const removed = edges.value.filter((edge) => {
    if (edge.source === nodeId && !outputMap.has(String(edge.sourceHandle || ''))) return true
    if (edge.target === nodeId && !inputMap.has(String(edge.targetHandle || ''))) return true
    return false
  })
  if (removed.length > 0) {
    edges.value = edges.value.map((edge) => removed.includes(edge)
      ? { ...edge, data: { ...(edge.data || {}), unresolved: true } }
      : edge)
    ElMessage.warning(`Bus端口变化，已保留并标记 ${removed.length} 条未解析连线`)
  }
  nextTick(() => updateNodeInternals([nodeId]))
  resetResultData()
  scheduleElkLayout(false, 'routing')
}

const updateSelectedBusConfig = async (config: BusConfig) => {
  const node = selectedNode.value
  if (!node || node.data?.nodeKind !== 'busCreator') return
  const previousFields = cloneBusFields(node.data?.busConfig?.fields)
  const nextFieldIds = new Set(cloneBusFields(config.fields).map((field) => field.inputPortId || field.id))
  const removedFieldIds = new Set(previousFields
    .map((field) => field.inputPortId || field.id)
    .filter((fieldId) => !nextFieldIds.has(fieldId)))
  const affectedSelectorOutputIds = new Set<string>()
  edges.value.filter((edge) => edge.source === node.id && String(edge.sourceHandle || '') === 'bus')
    .forEach((edge) => {
      const selector = nodes.value.find((candidate) => candidate.id === edge.target)
      if (selector?.data?.nodeKind !== 'busSelector') return
      cloneBusFields(selector.data?.selectorConfig?.selectedFields)
        .filter((field) => removedFieldIds.has(field.inputPortId || field.id))
        .forEach((field) => affectedSelectorOutputIds.add(`${selector.id}:${field.outputPortId || `bus_out_${field.id}`}`))
    })
  const affectedEdges = edges.value.filter((edge) => (
    (edge.target === node.id && removedFieldIds.has(String(edge.targetHandle || '')))
    || affectedSelectorOutputIds.has(`${edge.source}:${String(edge.sourceHandle || '')}`)
  ))
  if (affectedEdges.length > 0) {
    try {
      await ElMessageBox.confirm(
        `删除或重命名字段将使 ${affectedEdges.length} 条相关连线暂时未解析，是否继续？`,
        '确认字段变更',
        { type: 'warning', confirmButtonText: '继续', cancelButtonText: '取消' }
      )
    } catch {
      // 通过恢复旧配置触发编辑器回滚。
      nodes.value = nodes.value.map((candidate) => candidate.id === node.id
        ? { ...candidate, data: { ...candidate.data, busConfig: { ...node.data.busConfig, fields: previousFields } } }
        : candidate)
      return
    }
  }
  nodes.value = nodes.value.map((candidate) => candidate.id === node.id
    ? { ...candidate, data: { ...candidate.data, busConfig: { ...config, fields: cloneBusFields(config.fields) } } }
    : candidate)
  syncBusNodePorts(node.id)
  // 字段被删除或改名时，清理下游选择器中无法继续追踪的选择，避免
  // 保存一个看似存在但执行时才失败的动态输出端口。
  const available = cloneBusFields(config.fields)
  const downstreamSelectorIds = edges.value
    .filter((edge) => edge.source === node.id && String(edge.sourceHandle || '') === 'bus')
    .map((edge) => edge.target)
  downstreamSelectorIds.forEach((selectorId) => {
    const selector = nodes.value.find((candidate) => candidate.id === selectorId)
    if (selector?.data?.nodeKind !== 'busSelector') return
    const selectorConfig = selector.data?.selectorConfig as BusSelectorConfig | undefined
    const selectedFields = cloneBusFields(selectorConfig?.selectedFields)
      .filter((field) => available.some((candidate) => candidate.id === field.id))
      .map((field) => available.find((candidate) => candidate.id === field.id) || field)
    nodes.value = nodes.value.map((candidate) => candidate.id === selectorId
      ? { ...candidate, data: { ...candidate.data, selectorConfig: { ...selectorConfig, selectedFields }, availableBusFields: available } }
      : candidate)
    syncBusNodePorts(selectorId)
  })
}

const updateSelectedSelectorConfig = async (config: BusSelectorConfig) => {
  const node = selectedNode.value
  if (!node || node.data?.nodeKind !== 'busSelector') return
  const previousSelectorConfig = node.data?.selectorConfig as BusSelectorConfig | undefined
  const available = selectedBusAvailableFields.value
  const selectedIds = new Set(cloneBusFields(config.selectedFields).map((field) => field.outputPortId || `bus_out_${field.id}`))
  const affectedEdges = edges.value.filter((edge) => edge.source === node.id
    && !selectedIds.has(String(edge.sourceHandle || '')))
  if (affectedEdges.length > 0) {
    try {
      await ElMessageBox.confirm(
        `取消选择字段将移除 ${affectedEdges.length} 条相关连线，是否继续？`,
        '确认字段选择变更',
        { type: 'warning', confirmButtonText: '继续', cancelButtonText: '取消' }
      )
    } catch {
      nodes.value = nodes.value.map((candidate) => candidate.id === node.id
        ? { ...candidate, data: { ...candidate.data, selectorConfig: previousSelectorConfig } }
        : candidate)
      return
    }
  }
  const selectedFields = cloneBusFields(config.selectedFields)
    .map((field) => available.find((candidate) => candidate.id === field.id) || field)
  nodes.value = nodes.value.map((candidate) => candidate.id === node.id
    ? {
        ...candidate,
        data: {
          ...candidate.data,
          selectorConfig: { ...config, selectedFields },
          availableBusFields: available
        }
      }
    : candidate)
  syncBusNodePorts(node.id)
}























const clearAutoConnectSource = () => {
  autoConnectSourceNodeId.value = null
}







const nodeDisplayName = (node: Node | undefined) => {
  return String(node?.data?.instanceName || node?.label || node?.id || '组件')
}

const handleNodeClick = (event: NodeMouseEvent) => {
  if (!event.node?.id) return
  if (!isNodeFocused(event.node.id)) return
  selectedEdgeId.value = null
  if (event.event?.ctrlKey && !physicalLensFocused.value) {
    handleAutoConnectNode(event.node.id)
    return
  }
  if (event.event?.shiftKey) {
    const id = event.node.id
    const selected = applyAdditiveSelection(id)
    if (selected) selectNodeById(id, true)
    else if (selectedNodeId.value === id) selectedNodeId.value = null
    return
  }
  clearAutoConnectSource()
  selectNodeById(event.node.id)
}

const handleEdgeClick = (event: EdgeMouseEvent) => {
  const edge = event.edge
  if (!edge?.id) return
  if (!isEdgeFocused(edge.id)) return
  selectedEdgeId.value = edge.id
  if (edge.data?.assemblyId) editorStore.activeAssemblyId = edge.data.assemblyId
  activeRelationGroupId.value = String(edge.data?.groupId || '') || null
  clearNodeSelection()
  const relation = edge.data?.relation
  if (relation === 'flow' || relation === 'shaft' || relation === 'bleed') {
    physicalRelation.value = relation
  }
}

const handleDeleteSelectedEdge = () => {
  const edgeId = selectedEdgeId.value
  if (!edgeId) return
  const edge = selectedEdge.value
  if (edge?.data?.physicalProjection) {
    const assembly = editorStore.physicalAssemblies[edge.data.assemblyId]
    if (assembly) {
      if (edge.data.relation === 'flow') assembly.flowRelations = assembly.flowRelations.filter(flow => flow.id !== edge.data?.relationId)
      else {
        const groups = edge.data.relation === 'shaft' ? assembly.shaftGroups : assembly.bleedGroups
        const group = groups.find(item => item.id === edge.data?.groupId)
        if (group) group.memberNodeIds = group.memberNodeIds.filter(id => id !== edge.data?.memberNodeId)
      }
      editorStore.upsertAssembly({ ...assembly })
    }
  } else {
    edges.value = edges.value.filter((edge) => edge.id !== edgeId)
    synchronizeSubsystemInterfaces()
  }
  selectedEdgeId.value = null
  resetResultData()
}

const handlePaneClick = () => {
  clearAutoConnectSource()
  if (ignoreNextPaneClick) {
    ignoreNextPaneClick = false
    return
  }
  selectedEdgeId.value = null
  clearNodeSelection()
}

const handleNodeNameChange = () => {
  if (!selectedNode.value) return
  const name = normalizeInstanceName(selectedNodeInstanceName.value)
  selectedNodeInstanceName.value = name
  const selectedId = selectedNode.value.id
  nodes.value = nodes.value.map((node) => node.id === selectedId
    ? {
        ...node,
        label: name,
        data: { ...node.data, instanceName: name }
      }
    : node)
  if (selectedNode.value?.data?.componentKind === 'boundaryPort') synchronizeSubsystemInterfaces()
}

const handleInputChange = () => {
  if (!selectedNode.value) return
  const selectedId = selectedNode.value.id
  const previousInputs = { ...(selectedNode.value.data?.values || {}) }
  const currentInputs: Record<string, unknown> = { ...previousInputs }
  Object.entries(selectedInputValues.value).forEach(([name, value]) => {
    if (Array.isArray(value) ? isMatlabLiteral(value) : Number.isFinite(toScalarNumber(value))) {
      currentInputs[name] = Array.isArray(value) ? cloneMatlabGraph(value) : toScalarNumber(value)
    }
  })
  nodes.value = nodes.value.map((node) => node.id === selectedId
    ? {
        ...node,
        data: { ...node.data, values: currentInputs }
      }
    : node)
  if (JSON.stringify(previousInputs) !== JSON.stringify(currentInputs)) resetResultData()
}

const numericMatrixInput = (name: string): number[][] => {
  const value = selectedInputValues.value[name]
  if (typeof value === 'number' && Number.isFinite(value)) return [[value]]
  if (!Array.isArray(value)) return []
  if (!value.length) return []
  if (Array.isArray(value[0])) return value as number[][]
  return [value as number[]]
}

const selectedShaftGroupNames = computed(() => {
  const visited = new Set<string>()
  const assemblyIds = new Set<string>()
  const collect = (sceneId?: string) => {
    if (!sceneId || visited.has(sceneId)) return
    visited.add(sceneId)
    const scene = editorStore.scenes[sceneId]
    scene?.nodes.forEach(node => {
      if (node.data?.physicalAssemblyId) assemblyIds.add(String(node.data.physicalAssemblyId))
      if (node.data?.childSceneId) collect(String(node.data.childSceneId))
    })
  }
  collect(selectedNode.value?.data?.childSceneId)
  return [...assemblyIds]
    .flatMap(id => editorStore.physicalAssemblies[id]?.shaftGroups || [])
    .sort((a, b) => a.order - b.order)
    .map(group => group.name)
})

const numericAxisLabel = (index: number) => selectedShaftGroupNames.value[index] || `轴 ${index + 1}`

const arrayDimensionWarning = (port: MatlabPort) => {
  if (port.type !== 'array' || port.dynamicLength?.source !== 'shaftGroups') return ''
  const expected = selectedShaftGroupNames.value.length
  if (!expected) return ''
  const actual = numericMatrixInput(port.name).reduce((count, row) => count + row.length, 0)
  return actual === expected ? '' : `当前有 ${expected} 个轴组，但功率数组含 ${actual} 个值；请检查数据长度。`
}

const handleArrayInputChange = (name: string, row: number, column: number, nextValue: unknown) => {
  const matrix = numericMatrixInput(name).map((values) => [...values])
  const parsed = toScalarNumber(nextValue)
  if (!Number.isFinite(parsed) || !matrix[row] || column >= matrix[row].length) return
  matrix[row][column] = parsed
  const current = selectedInputValues.value[name]
  selectedInputValues.value = { ...selectedInputValues.value, [name]: Array.isArray(current) && Array.isArray(current[0]) ? matrix : matrix[0] }
  handleInputChange()
}

const getInputConnection = (portName: string) => {
  if (!selectedNodeId.value) return undefined
  return edges.value.find((edge) => edge.target === selectedNodeId.value
    && edge.targetHandle === portName)
}

const getInputConnectionLabel = (portName: string) => {
  const edge = getInputConnection(portName)
  if (!edge) return '未连接'
  const sourceNode = nodes.value.find((node) => node.id === edge.source)
  const sourceName = String(sourceNode?.data?.instanceName || sourceNode?.label || edge.source)
  return `${sourceName}.${edge.sourceHandle || ''}`
}

const findNodePort = (node: Node | undefined, direction: 'input' | 'output', name: string) => {
  if (node?.data?.nodeKind === 'physicalComponent'
    && name === (direction === 'input' ? 'SHAFT_IN' : 'SHAFT_OUT')) {
    return { name, type: 'PhysicalShaft', required: false, description: '轴系关系' } as MatlabPort
  }
  if (node?.data?.nodeKind === 'physicalComponent'
    && name === (direction === 'input' ? 'BLEED_IN' : 'BLEED_OUT')) {
    return { name, type: 'PhysicalBleed', required: false, description: '引气关系' } as MatlabPort
  }
  const ports = getValidPorts(direction === 'input'
    ? node?.data?.inputPorts
    : node?.data?.outputPorts)
  return ports.find((port) => port.name === name)
}

const createConnectionCandidate = (
  sourceNode: Node | undefined,
  targetNode: Node | undefined,
  sourceHandle: string,
  targetHandle: string
): WorkflowConnectionCandidate | null => {
  if (!sourceNode || !targetNode) return null
  const sourcePort = findNodePort(sourceNode, 'output', sourceHandle)
  const targetPort = findNodePort(targetNode, 'input', targetHandle)
  if (!sourcePort || !targetPort || !isCompatiblePortType(sourcePort.type, targetPort.type)) return null
  return {
    sourceNode,
    targetNode,
    sourcePort,
    targetPort,
    sourceHandle,
    targetHandle
  }
}

const getTopologicalOrder = (candidateEdges: Edge[] = edges.value) => {
  const indegrees = new Map(nodes.value.map((node) => [node.id, 0]))
  const adjacency = new Map(nodes.value.map((node) => [node.id, [] as string[]]))
  candidateEdges.forEach((edge) => {
    if (!indegrees.has(edge.source) || !indegrees.has(edge.target)) return
    adjacency.get(edge.source)?.push(edge.target)
    indegrees.set(edge.target, (indegrees.get(edge.target) || 0) + 1)
  })
  const ready = nodes.value.filter((node) => indegrees.get(node.id) === 0).map((node) => node.id)
  const order: string[] = []
  while (ready.length > 0) {
    const nodeId = ready.shift() as string
    order.push(nodeId)
    ;(adjacency.get(nodeId) || []).forEach((targetId) => {
      const nextValue = (indegrees.get(targetId) || 0) - 1
      indegrees.set(targetId, nextValue)
      if (nextValue === 0) ready.push(targetId)
    })
  }
  return order.length === nodes.value.length ? order : null
}

const inferBusFieldFromConnection = (edge: Edge) => {
  const targetNode = nodes.value.find((node) => node.id === edge.target)
  const sourceNode = nodes.value.find((node) => node.id === edge.source)
  if (!targetNode || !sourceNode || targetNode.data?.nodeKind !== 'busCreator') return
  const fields = cloneBusFields(targetNode.data?.busConfig?.fields)
  const field = fields.find((candidate) => (candidate.inputPortId || candidate.id) === String(edge.targetHandle || ''))
  const sourcePort = findNodePort(sourceNode, 'output', String(edge.sourceHandle || ''))
  if (!field || !sourcePort) return
  const sourceDisplayName = String(sourceNode.data?.portDisplayNames?.[String(edge.sourceHandle || '')] || sourcePort.name)
  const normalized = normalizeSignalName(sourceDisplayName, 'signal')
  const used = new Set(fields.filter((candidate) => candidate.id !== field.id)
    .map((candidate) => String(candidate.label || candidate.path || '').toLowerCase()))
  let displayName = normalized
  let suffix = 2
  while (used.has(displayName.toLowerCase())) displayName = `${normalized}_${suffix++}`
  const nextField: BusField = {
    ...field,
    label: field.nameMode === 'manual' ? field.label : displayName,
    path: field.nameMode === 'manual' ? field.path : displayName,
    sourceName: sourceDisplayName,
    dataType: sourcePort.type,
    shape: Array.isArray(sourcePort.shape) ? [...sourcePort.shape] : field.shape,
    unit: sourcePort.unit || field.unit,
    inferred: true,
    contractStatus: 'inferred'
  }
  const nextFields = fields.map((candidate) => candidate.id === field.id ? nextField : candidate)
  nodes.value = nodes.value.map((node) => node.id === targetNode.id
    ? { ...node, data: { ...node.data, busConfig: { ...node.data.busConfig, fields: nextFields } } }
    : node)
  syncBusNodePorts(targetNode.id)
  edges.value.filter((candidate) => candidate.source === targetNode.id && String(candidate.sourceHandle || '') === 'bus')
    .forEach((candidate) => {
      const selector = nodes.value.find((node) => node.id === candidate.target)
      if (selector?.data?.nodeKind !== 'busSelector') return
      const selectedFields = cloneBusFields(selector.data?.selectorConfig?.selectedFields)
        .map((selected) => nextFields.find((available) => available.id === selected.id) || selected)
      nodes.value = nodes.value.map((node) => node.id === selector.id
        ? { ...node, data: { ...node.data, selectorConfig: { ...node.data.selectorConfig, selectedFields } } }
        : node)
      syncBusNodePorts(selector.id)
    })
}

const inferAcceptedBusContracts = (newEdges: Edge[]) => newEdges.forEach(inferBusFieldFromConnection)

const appendConnectionCandidates = (
  candidates: WorkflowConnectionCandidate[]
): ConnectionBatchResult => {
  const enforceSingleInput = !physicalLensFocused.value
  const occupiedInputs = new Set(enforceSingleInput
    ? edges.value.map((edge) => `${edge.target}:${String(edge.targetHandle || '')}`)
    : [])
  const availableCandidates = candidates.filter((candidate) => {
    const inputKey = `${candidate.targetNode.id}:${candidate.targetHandle}`
    if (enforceSingleInput) {
      if (occupiedInputs.has(inputKey)) return false
      occupiedInputs.add(inputKey)
    }
    return true
  })
  const skippedCount = candidates.length - availableCandidates.length
  if (availableCandidates.length === 0) {
    return { addedEdges: [], skippedCount, cycle: false }
  }

  const batchTimestamp = Date.now()
  const newEdges = availableCandidates.map((candidate, index) => ({
    id: `edge_${batchTimestamp}_${edges.value.length + index + 1}`,
    source: candidate.sourceNode.id,
    target: candidate.targetNode.id,
    sourceHandle: candidate.sourceHandle,
    targetHandle: candidate.targetHandle,
    type: 'matlabElk',
    zIndex: 1001,
    markerEnd: MarkerType.ArrowClosed,
    animated: false,
    data: {
      dataType: candidate.sourcePort.type
    }
  } as Edge))
  if (!getTopologicalOrder([...edges.value, ...newEdges])) {
    return { addedEdges: [], skippedCount, cycle: true }
  }
  edges.value = [...edges.value, ...newEdges]
  synchronizeSubsystemInterfaces()
  inferAcceptedBusContracts(newEdges)
  resetResultData()
  return { addedEdges: newEdges, skippedCount, cycle: false }
}

const handleAutoConnectNode = (nodeId: string) => {
  const targetNode = nodes.value.find((node) => node.id === nodeId)
  if (!targetNode) return
  const sourceId = autoConnectSourceNodeId.value
  if (!sourceId) {
    const outputPorts = getValidPorts(targetNode.data?.outputPorts)
    if (outputPorts.length === 0) {
      ElMessage.warning('该部件没有输出端口，不能作为发送部件')
      return
    }
    autoConnectSourceNodeId.value = targetNode.id
    selectNodeById(targetNode.id)
    ElMessage.info(`已选择发送部件“${nodeDisplayName(targetNode)}”，请按住 Ctrl 选择接收部件`)
    return
  }

  const sourceNode = nodes.value.find((node) => node.id === sourceId)
  clearAutoConnectSource()
  if (!sourceNode) {
    ElMessage.warning('发送部件已不存在，请重新选择')
    selectNodeById(targetNode.id)
    return
  }
  if (sourceNode.id === targetNode.id) {
    ElMessage.warning('发送部件和接收部件不能是同一个部件')
    selectNodeById(targetNode.id)
    return
  }
  const targetInputPorts = getValidPorts(targetNode.data?.inputPorts)
  if (targetInputPorts.length === 0) {
    ElMessage.warning('该部件没有输入端口，不能作为接收部件')
    selectNodeById(targetNode.id)
    return
  }

  const sourcePorts = getValidPorts(sourceNode.data?.outputPorts).map(port => ({
    ...port,
    semanticKey: port.semanticKey || port.name,
    displayName: sourceNode.data?.portDisplayNames?.[port.name] || port.description || port.name
  }))
  const targetPorts = targetInputPorts.map(port => ({
    ...port,
    semanticKey: port.semanticKey || port.name,
    displayName: targetNode.data?.portDisplayNames?.[port.name] || port.description || port.name
  }))
  const occupiedTargetNames = new Set(edges.value
    .filter(edge => edge.target === targetNode.id)
    .map(edge => String(edge.targetHandle || '')))
  const matchedPorts = matchPortsInDeclarationOrder(sourcePorts, targetPorts,
    target => !occupiedTargetNames.has(target.name))
  const candidates: WorkflowConnectionCandidate[] = []
  matchedPorts.forEach(({ source: sourcePort, target: targetPort }) => {
    const candidate = createConnectionCandidate(
      sourceNode,
      targetNode,
      sourcePort.name,
      targetPort.name
    )
    if (candidate) candidates.push(candidate)
  })
  if (candidates.length === 0) {
    ElMessage.warning('两个部件没有可兼容的共同端口')
    selectNodeById(targetNode.id)
    return
  }

  const result = appendConnectionCandidates(candidates)
  selectNodeById(targetNode.id)
  if (result.cycle) {
    ElMessage.warning('自动连接会形成环路，未添加任何连线')
    return
  }
  if (result.addedEdges.length === 0) {
    ElMessage.info(`共同端口均已连接，跳过 ${result.skippedCount} 个端口`)
    return
  }
  result.addedEdges.forEach((edge) => {
    addLog(
      'info',
      `已自动连接：${nodeDisplayName(sourceNode)}.${edge.sourceHandle} → `
        + `${nodeDisplayName(targetNode)}.${edge.targetHandle}`
    )
  })
  const skippedText = result.skippedCount > 0 ? `，跳过 ${result.skippedCount} 个已占用端口` : ''
  ElMessage.success(`自动连接完成：新增 ${result.addedEdges.length} 条连线${skippedText}`)
}

const handleConnect = (connection: Connection) => {
  const hasPhysicalContext = canvasHasPhysicalComponents.value
  const sourceNode = nodes.value.find((node) => node.id === connection.source)
  const targetNode = nodes.value.find((node) => node.id === connection.target)
  const sourceHandle = String(connection.sourceHandle || '')
  const targetHandle = String(connection.targetHandle || '')
  if (!sourceNode || !targetNode) {
    ElMessage.warning('连线引用的节点不存在')
    return
  }
  const mode = hasPhysicalContext && physicalLensMode.value !== 'overview' ? physicalLensMode.value : 'data'

  // ---- 气路模式：flow 关系写入当前装配 ----
  if (mode === 'flow') {
    const relationHandle = /^(SHAFT|BLEED)_(IN|OUT)$/
    if (relationHandle.test(sourceHandle) || relationHandle.test(targetHandle)) {
      ElMessage.warning('请使用气路端口建立气路关系')
      return
    }
    const flow = createFlowRelation({
      sourceNodeId: sourceNode.id,
      sourcePortId: sourceHandle,
      targetNodeId: targetNode.id,
      targetPortId: targetHandle
    })
    if (!flow) {
      ElMessage.warning('当前部件无法建立气路关系')
      return
    }
    ElMessage.success('已创建气路关系')
    return
  }

  // ---- 轴系/引气模式：成员加入组 ----
  if (mode === 'shaft' || mode === 'bleed') {
    connectGroup(mode, sourceNode.id, sourceHandle, targetNode.id, targetHandle)
    return
  }

  // ---- 数据模式：普通数据边 ----
  if (physicalCapabilitiesOf(sourceNode.data)?.flow || physicalCapabilitiesOf(targetNode.data)?.flow) {
    ElMessage.warning('请在气路模式下连接物理部件'); return
  }
  const edge: Edge = {
    id: `edge_${Date.now()}_${edges.value.length + 1}`,
    source: sourceNode.id,
    sourceHandle,
    target: targetNode.id,
    targetHandle,
    type: 'matlabElk',
    zIndex: 1001,
    markerEnd: MarkerType.ArrowClosed,
    animated: false,
    data: {
      dataType: findNodePort(sourceNode, 'output', sourceHandle)?.type || 'unknown',
      elkPoints: []
    }
  }
  edges.value = [...edges.value, edge]
  synchronizeSubsystemInterfaces()
  inferAcceptedBusContracts([edge])
}

const resetResultData = () => {
  resetResultState()
  lastTaskId.value = null
}

const handleDeleteNode = () => {
  if (!selectedNode.value) return
  const deletedNodeId = selectedNode.value.id
  const nextEdges = edges.value.filter((edge) => edge.source !== deletedNodeId && edge.target !== deletedNodeId)
  Object.values(editorStore.physicalAssemblies).forEach(assembly => {
    editorStore.upsertAssembly(removeAssemblyMembers(assembly, new Set([deletedNodeId])))
  })
  nodes.value = nodes.value.filter((node) => node.id !== deletedNodeId)
  edges.value = nextEdges
  synchronizeSubsystemInterfaces()
  if (selectedNodeId.value === deletedNodeId) clearNodeSelection()
  resetResultData()
  ElMessage.success('已删除节点')
}

const handleBoundaryPortNameChange = (portId: string, value: string) => {
  if (!selectedNode.value) return
  const selectedId = selectedNode.value.id
  const name = String(value || '').trim() || portId
  const ports = selectedNodeBoundaryPorts.value.map((port) => (
    port.id === portId ? { ...port, name } : { ...port }
  ))
  const portData = makeCompositePortData(ports)
  nodes.value = nodes.value.map((node) => node.id === selectedId
    ? { ...node, data: { ...node.data, boundaryPorts: ports, ...portData } }
    : node)
  const childSceneId = String(selectedNode.value.data?.childSceneId || '')
  const childScene = sceneStore.value[childSceneId]
  if (childScene) {
    childScene.boundaryPorts = childScene.boundaryPorts.map((port) => (
      port.id === portId ? { ...port, name } : port
    ))
  }
  resetResultData()
}

const handleClearCanvas = async () => {
  if (physicalLensFocused.value) return
  if (nodes.value.length === 0) return
  try {
    await ElMessageBox.confirm('确定要清空画布吗？', '提示', { type: 'warning' })
    editorStore.resetProject({
      [rootSceneId]: {
        id: rootSceneId,
        title: '根场景',
        nodes: [],
        dataEdges: [],
        boundaryPorts: [],
        viewport: { x: 0, y: 0, zoom: 1 }
      }
    }, rootSceneId, {})
    projectRootSceneId.value = rootSceneId
    selectedEdgeId.value = null
    physicalRelation.value = 'flow'
    clearAutoConnectSource()
    clearNodeSelection()
    selectedEdgeId.value = null
    physicalRelation.value = 'flow'
    resetResultData()
  } catch {
    // 用户取消
  }
}

const buildExecutionPayload = () => {
  editorStore.physicalAssemblies = synchronizeAssemblyBindings(editorStore.scenes, editorStore.physicalAssemblies)
  const childSceneIds = new Set(Object.values(editorStore.scenes)
    .flatMap(scene => scene.nodes.map(node => String(node.data?.childSceneId || '')).filter(Boolean)))
  const orphanBoundary = Object.values(editorStore.scenes).some(scene => !childSceneIds.has(scene.id)
    && scene.nodes.some(node => node.data?.componentKind === 'boundaryPort'))
  if (orphanBoundary) {
    ElMessage.error('In/Out 接口组件必须封装在子系统中后才能计算')
    return null
  }
  return compileExecutionPayload({
    rootSceneId: projectRootSceneId.value,
    scenes: editorStore.scenes,
    physicalAssemblies: editorStore.physicalAssemblies,
    isBusNode
  })
}

const buildJuliaPreview = (payload: ReturnType<typeof buildExecutionPayload>) => {
  if (!payload) return ''
  const order = getTopologicalOrder() || []
  const variableById = new Map(order.map((nodeId, index) => [nodeId, `node_${index + 1}`]))
  const lines = ['# Julia执行顺序预览（实际代码由可信后端负载生成）', '']
  order.forEach((nodeId) => {
    const incoming = edges.value.filter((edge) => edge.target === nodeId)
    const node = nodes.value.find((item) => item.id === nodeId)
    const executionKind = String(node?.data?.executionKind || 'matlabFunction')
    const runnerName = executionKind === 'busCreator'
      ? 'execute_bus_creator!'
      : executionKind === 'busSelector'
        ? 'execute_bus_selector!'
        : 'execute_node!'
    lines.push(`${variableById.get(nodeId)} = ${runnerName}(`)
    lines.push(`    runtime, "${nodeId}",`)
    lines.push('    Dict(')
    incoming.forEach((edge) => {
      lines.push(`        "${edge.targetHandle}" => output(${variableById.get(edge.source)}, "${edge.sourceHandle}"),`)
    })
    lines.push('    )')
    lines.push(')')
    lines.push('')
  })
  return lines.join('\n')
}

const handlePreviewPayload = () => {
  const payload = buildExecutionPayload()
  const juliaPreview = buildJuliaPreview(payload)
  generatedPayload.value = payload
    ? `${JSON.stringify(payload, null, 2)}${juliaPreview ? `\n\n${juliaPreview}` : ''}`
    : nodes.value.length === 0
      ? '// 画布为空，请添加组件'
      : '// 请选择要执行的组件'
  payloadPreviewVisible.value = true
}

const synchronizeSubsystemInterfaces = () => {
  const boundInitializerIds = new Set(Object.values(editorStore.physicalAssemblies)
    .map(assembly => assembly.initializerBinding.nodeId).filter(Boolean))
  editorStore.scenes = synchronizeProjectInterfaces(editorStore.scenes, boundInitializerIds)
}

const explicitInterfaceEdgeSignature = computed(() => edges.value
  .filter(edge => [edge.source, edge.target].some(nodeId => nodes.value.find(node => node.id === nodeId)?.data?.componentKind === 'boundaryPort'))
  .map(edge => `${edge.id}:${edge.source}.${edge.sourceHandle || ''}>${edge.target}.${edge.targetHandle || ''}`)
  .join('|'))
watch(explicitInterfaceEdgeSignature, (next, previous) => {
  if (next !== previous) synchronizeSubsystemInterfaces()
})

const buildProjectData = () => {
  synchronizeSubsystemInterfaces()
  editorStore.physicalAssemblies = synchronizeAssemblyBindings(editorStore.scenes, editorStore.physicalAssemblies)
  return JSON.stringify(serializeMatlabProject(editorStore.scenes, editorStore.physicalAssemblies, projectRootSceneId.value))
}

const resolveSavedComponent = (saved: SavedMatlabProjectNode) => {
  return components.value.find((component) => component.id === saved.componentId)
    || components.value.find((component) => component.functionName === saved.functionName)
}

const physicalPortDisplayNames = (
  saved: Pick<SavedMatlabProjectNode, 'nodeKind' | 'legacyName' | 'componentId'>,
  inputPorts: MatlabPort[],
  outputPorts: MatlabPort[]
) => {
  if (saved.nodeKind !== 'physicalComponent') return undefined
  const legacyName = String(saved.legacyName || '').toLowerCase()
  const componentId = String(saved.componentId || '').toLowerCase()
  const display: Record<string, string> = {}
  if (componentId.endsWith('.shaft') || legacyName === 'shaft') {
    display.INPUT = '轴 shaft · INPUT'
    display.OUTPUT = '轴 shaft · OUTPUT'
  } else if (componentId.endsWith('.bleed') || legacyName === 'bleed') {
    display.INPUT = '引气 bleed · INPUT'
    display.OUTPUT = '引气 bleed · OUTPUT'
  } else {
    ;[...inputPorts, ...outputPorts].forEach((port) => {
      if (port.name === 'CORE') display.CORE = '内涵 core'
      if (port.name === 'BYPASS') display.BYPASS = '外涵 bypass'
      if (port.name === 'SHAFT') display.SHAFT = '轴 shaft'
      if (port.name === 'BLEED') display.BLEED = '引气 bleed'
    })
  }
  if (legacyName === 'mixer') {
    if (inputPorts.some((port) => port.name === 'INPUT')) display.INPUT = '内涵 core'
    if (inputPorts.some((port) => port.name === 'INPUT1')) display.INPUT1 = '外涵 bypass'
  }
  if (legacyName === 'fan') {
    if (inputPorts.some((port) => port.name === 'INPUT')) display.INPUT = '入口 core/bypass'
    if (outputPorts.some((port) => port.name === 'OUTPUT')) display.OUTPUT = '出口 core/bypass'
    if (inputPorts.some((port) => port.name === 'CORE')) display.CORE = '入口 core'
    if (inputPorts.some((port) => port.name === 'BYPASS')) display.BYPASS = '入口 bypass'
    if (outputPorts.some((port) => port.name === 'CORE')) display.CORE = '出口 core'
    if (outputPorts.some((port) => port.name === 'BYPASS')) display.BYPASS = '出口 bypass'
  }
  inputPorts.forEach((port) => {
    if (!display[port.name] && port.name === 'INPUT') display.INPUT = '气路 flow · INPUT'
  })
  outputPorts.forEach((port) => {
    if (!display[port.name] && port.name === 'OUTPUT') display.OUTPUT = '气路 flow · OUTPUT'
  })
  return Object.keys(display).length > 0 ? display : undefined
}

const rebuildProjectGraph = (
  projectData: Record<string, any>
) => {
  const warnings: string[] = []
  let discardedValueCount = 0
  let missingComponentCount = 0
  const runtimeNodes: Node[] = (projectData.nodes as any[]).map((saved: any, index: number) => {
    if (saved.childSceneId) {
      const physicalAssemblyId = String(saved.physicalAssemblyId || saved.data?.physicalAssemblyId || '')
      const savedBoundaryPorts = cloneMatlabGraph(saved.boundaryPorts?.length ? saved.boundaryPorts
        : projectData.scenes?.[saved.childSceneId]?.boundaryPorts || [])
      const boundaryPorts = physicalAssemblyId
        ? savedBoundaryPorts.filter((port: any) => !String(port.mapping?.childNodeId || '').startsWith('$physicalAssembly:'))
        : savedBoundaryPorts
      const catalogComponent = components.value.find(component => component.id === saved.componentId)
      const compositePorts = makeCompositePortData(boundaryPorts.filter((port: MatlabBoundaryPort) => port.kind === 'data'))
      // Compile-time assembly descriptors expose one stable data-DAG output.
      // Their child Scene is descriptive and does not produce this value.
      if (physicalAssemblyId && !compositePorts.outputPorts.some((port: any) => port.name === 'assembly_json')) {
        compositePorts.outputPorts = [{
          name: 'assembly_json', type: 'string', required: true,
          description: '发动机装配描述（编译期输入）'
        }]
        compositePorts.connectors = [
          ...(compositePorts.inputPorts || []).map((port: any) => ({ name: port.name, type: 'WorkflowInput' as const })),
          { name: 'assembly_json', type: 'WorkflowOutput' as const }
        ]
      }
      // A bound initializer opens a part container but retains its real function ports.
      if (!physicalAssemblyId && !boundaryPorts.length && catalogComponent) {
        compositePorts.inputPorts = getValidPorts(catalogComponent.inputs).map(port => ({ ...port, required: false, description: port.description || port.name }))
        compositePorts.outputPorts = getValidPorts(catalogComponent.outputs).map(port => ({ ...port, required: false, description: port.description || port.name }))
      }
      const subsystemKind = physicalAssemblyId ? 'assemblyDescriptor' : 'subsystem'
      const executionKind = physicalAssemblyId ? 'compileTimeAssembly' : 'subsystem'
      const subsystemName = saved.instanceName || projectData.scenes?.[saved.childSceneId]?.title
        || catalogComponent?.name || `Subsystem${index + 1}`

      return {
        id: saved.id,
        type: 'matlabComposite',
        position: saved.position || { x: 40, y: index * 120 },
        label: subsystemName,
        data: {
          componentId: saved.componentId || `project.subsystem.${saved.id}`,
          componentName: catalogComponent?.name || subsystemName,
          instanceName: subsystemName,
          functionName: saved.functionName || 'projectSubsystem',
          executionKind,
          nodeKind: subsystemKind,
          sceneNodeKind: subsystemKind,
          childSceneId: saved.childSceneId,
          modelEntrypoints: saved.modelEntrypoints,
          activeModes: Array.isArray(saved.activeModes) ? [...saved.activeModes] : undefined,
          physicalCapabilities: catalogComponent?.physicalCapabilities,
          physicalAssemblyId: physicalAssemblyId || undefined,
          boundaryPorts,
          ...compositePorts,
          values: saved.values || {},
          resources: saved.resources || {},
          legacyOrder: saved.legacyOrder,
          assemblyDefaults: saved.assemblyDefaults,
          legacyName: saved.legacyName,
          unresolved: saved.unresolved === true,
          presentationSize: saved.presentation?.size
        }
      }
    }
    if (saved.unresolved) {
      missingComponentCount += 1
      return {
        id: saved.id,
        type: 'modelicaComponent',
        position: saved.position || { x: 0, y: index * 120 },
        label: saved.instanceName || saved.functionName || '旧项目节点（不可解析）',
        data: {
          componentId: saved.componentId,
          componentName: '旧项目节点（不可解析）',
          instanceName: saved.instanceName || saved.functionName || '旧项目节点（不可解析）',
          componentType: saved.functionName,
          functionName: saved.functionName,
          description: '该节点来自旧版平铺项目，不能按当前 MATLAB 场景格式执行',
          connectors: [],
          inputPorts: [],
          outputPorts: [],
          resourceDefinitions: [],
          values: saved.values,
          resources: saved.resources,
          unresolved: true,
          presentationSize: saved.presentation?.size
        }
      }
    }
    if (saved.nodeKind === 'boundaryPort' || saved.componentId === BOUNDARY_IN_ID || saved.componentId === BOUNDARY_OUT_ID) {
      const direction = saved.boundaryDirection || (saved.componentId === BOUNDARY_OUT_ID ? 'output' : 'input')
      const inputPorts = direction === 'output' ? [{ name: 'in', type: 'unknown' }] : []
      const outputPorts = direction === 'input' ? [{ name: 'out', type: 'unknown' }] : []
      return {
        id: saved.id,
        type: 'matlabBoundary',
        position: saved.position || { x: 0, y: index * 100 },
        label: saved.instanceName || `${direction === 'input' ? 'In' : 'Out'} ${index + 1}`,
        data: {
          componentId: saved.componentId || (direction === 'input' ? BOUNDARY_IN_ID : BOUNDARY_OUT_ID),
          componentName: direction === 'input' ? 'In' : 'Out', instanceName: saved.instanceName,
          componentKind: 'boundaryPort', nodeKind: 'boundaryPort', executionKind: 'boundaryPort',
          boundaryDirection: direction, functionName: '', inputPorts, outputPorts,
          connectors: [], values: saved.values || {}, resources: {}, presentationSize: saved.presentation?.size
        }
      }
    }
    if (saved.nodeKind === 'busCreator' || saved.nodeKind === 'busSelector'
      || isBusComponentId(saved.componentId)) {
      const nodeKind = saved.nodeKind === 'busSelector' || saved.componentId === BUS_SELECTOR_ID
        ? 'busSelector' : 'busCreator'
      const rawSavedFields = Array.isArray(saved.busConfig?.fields) ? saved.busConfig.fields : []
      const restoredFields = cloneBusFields(rawSavedFields).map((field, fieldIndex) => ({
        ...field,
        // 老项目没有 nameMode，必须按用户已有字段名恢复为手动名称。
        nameMode: (rawSavedFields[fieldIndex] as any)?.nameMode ? field.nameMode : 'manual'
      }))
      const busConfig: BusConfig = {
        schemaMode: saved.busConfig?.schemaMode === 'named' ? 'named' : 'anonymous',
        schemaRef: saved.busConfig?.schemaRef,
        name: saved.busConfig?.name || saved.instanceName,
        fields: restoredFields
      }
      const selectorConfig: BusSelectorConfig = {
        sourceSchemaRef: saved.selectorConfig?.sourceSchemaRef,
        selectedFields: cloneBusFields(saved.selectorConfig?.selectedFields)
      }
      const inputPorts = nodeKind === 'busCreator'
        ? busConfig.fields.map((field) => ({
            name: field.inputPortId || field.id,
            type: field.dataType,
            unit: field.unit,
            required: field.required,
            description: field.path
          }))
        : [{ name: 'bus', type: 'bus', required: true }]
      const outputPorts = nodeKind === 'busCreator'
        ? [{ name: 'bus', type: busConfig.schemaRef || 'bus', description: '结构化Bus' }]
        : selectorConfig.selectedFields.map((field) => ({
            name: field.outputPortId || `bus_out_${field.id}`,
            type: field.dataType,
            unit: field.unit,
            description: field.path
          }))
      const busFieldsForDisplay = nodeKind === 'busCreator'
        ? cloneBusFields(busConfig.fields)
        : cloneBusFields(selectorConfig.selectedFields)
      const portDisplayNames = Object.fromEntries(busFieldsForDisplay.map((field) => [
        nodeKind === 'busCreator' ? (field.inputPortId || field.id) : (field.outputPortId || `bus_out_${field.id}`),
        field.label || field.path
      ]))
      portDisplayNames.bus = 'bus'
      const portPaths = Object.fromEntries(busFieldsForDisplay.map((field) => [
        nodeKind === 'busCreator' ? (field.inputPortId || field.id) : (field.outputPortId || `bus_out_${field.id}`),
        field.path
      ]))
      return {
        id: saved.id,
        type: 'matlabBus',
        position: saved.position || { x: 0, y: index * 120 },
        label: saved.instanceName || (nodeKind === 'busCreator' ? 'busCreator' : 'busSelector'),
        data: {
          componentId: nodeKind === 'busCreator' ? BUS_CREATOR_ID : BUS_SELECTOR_ID,
          componentName: nodeKind === 'busCreator' ? 'Bus创建器' : 'Bus选择器',
          instanceName: saved.instanceName || `${nodeKind}${index + 1}`,
          componentType: nodeKind,
          functionName: '',
          componentKind: 'workflow',
          executionKind: nodeKind,
          nodeKind,
          description: nodeKind === 'busCreator' ? '将多个输入信号组装为结构化Bus' : '从结构化Bus中选择信号',
          connectors: [
            ...inputPorts.map((port) => ({ name: port.name, type: 'WorkflowInput' })),
            ...outputPorts.map((port) => ({ name: port.name, type: 'WorkflowOutput' }))
          ],
          inputPorts,
          outputPorts,
          resourceDefinitions: [],
          values: {},
          resources: {},
          busConfig,
          selectorConfig,
          availableBusFields: [],
          presentationSize: saved.presentation?.size,
          portDisplayNames,
          portPaths
        }
      }
    }
    const component = resolveSavedComponent(saved)
    if (!component) {
      missingComponentCount += 1
      return {
        id: saved.id,
        type: 'modelicaComponent',
        position: saved.position || { x: 0, y: index * 120 },
        label: saved.instanceName || saved.functionName || '组件不可用',
        data: {
          componentId: saved.componentId,
          componentName: '组件不可用',
          instanceName: saved.instanceName || saved.functionName || '组件不可用',
          componentType: saved.functionName,
          functionName: saved.functionName,
          description: '当前组件清单中未找到该组件',
          connectors: [],
          inputPorts: [],
          outputPorts: [],
          resourceDefinitions: [],
          values: saved.values,
          resources: saved.resources,
          unresolved: true,
          presentationSize: saved.presentation?.size
        }
      }
    }

    const inputPorts = normalizeComponentPorts(component.inputs, component.name, '输入')
    const outputPorts = normalizeComponentPorts(component.outputs, component.name, '输出')
    const inputPortNames = new Set(inputPorts.map((port) => port.name))
    const values = Object.fromEntries(inputPorts
      .map((port) => {
        const rawSavedValue = saved.values[port.name]
        const savedValue = port.type === 'number'
          ? finiteMetadataNumber(rawSavedValue)
          : (port.type === 'array' && typeof rawSavedValue === 'number' && Number.isFinite(rawSavedValue)
            ? rawSavedValue
          : (isMatlabLiteral(rawSavedValue) ? rawSavedValue : undefined)
          )
        return [port.name, savedValue ?? initialLiteralValue(port)] as const
      })
      .filter((entry): entry is readonly [string, any] => entry[1] !== undefined))
    discardedValueCount += Object.keys(saved.values)
      .filter((name) => !inputPortNames.has(name)).length
    const resourceDefinitions = component.resources || []
    // resources 保存的是执行器需要的资源引用，例如 motorConfigId，
    // 其键不一定与资源定义名称相同，必须原样保留。
    const resources = { ...saved.resources }
    const connectors = [
      ...inputPorts.map((port) => ({ name: port.name, type: 'WorkflowInput' })),
      ...outputPorts.map((port) => ({ name: port.name, type: 'WorkflowOutput' }))
    ]
    const instanceName = saved.instanceName || `${component.functionName}${index + 1}`
    return {
      id: saved.id,
      type: 'modelicaComponent',
      position: saved.position || { x: 0, y: index * 120 },
      label: instanceName,
      data: {
        componentId: component.id,
        componentName: component.name,
        instanceName,
        componentType: component.functionName,
        functionName: component.functionName,
        componentKind: component.componentKind || 'scalar',
        nodeKind: saved.nodeKind || saved.executionKind || 'matlabFunction',
        sceneNodeKind: saved.nodeKind || saved.executionKind || 'workflowNode',
        executionKind: saved.executionKind,
        activeModes: Array.isArray(saved.activeModes) ? [...saved.activeModes] : undefined,
        description: component.description || '',
        coverImage: resolveComponentCover(component),
        connectors,
        inputPorts,
        outputPorts,
        portDisplayNames: physicalPortDisplayNames(saved, inputPorts, outputPorts),
        resourceDefinitions,
        resources,
        motorConfig: null,
        values,
        unresolved: false,
        presentationSize: saved.presentation?.size,
        legacyOrder: saved.legacyOrder,
        assemblyDefaults: (saved as any).assemblyDefaults,
        physicalCapabilities: component.physicalCapabilities,
        legacyName: (saved as any).legacyName
      }
    }
  })

  const nodeMap = new Map(runtimeNodes.map((node) => [node.id, node]))
  let invalidEdgeCount = 0
  const invalidEdgeDetails: string[] = []
  const occupiedInputs = new Set<string>()
  const runtimeEdges: Edge[] = []
  const restoredEdges = readPersistedDataEdges(projectData.dataEdges as any[], runtimeNodes, isCompatiblePortType)
  restoredEdges.forEach((saved) => {
    const sourceNodeId = saved.sourceNodeId
    const sourcePortId = saved.sourcePort
    const targetNodeId = saved.targetNodeId
    const targetPortId = saved.targetPort
    const sourceNode = nodeMap.get(sourceNodeId)
    const targetNode = nodeMap.get(targetNodeId)
    const sourcePort = findNodePort(sourceNode, 'output', sourcePortId)
    const targetPort = findNodePort(targetNode, 'input', targetPortId)
    const targetKey = `${targetNodeId}:${targetPortId}`
    const edgeInvalid = saved.unresolved
      || !sourcePort || !targetPort
      || !isCompatiblePortType(sourcePort.type, targetPort.type)
      || (Boolean(targetPortId) && occupiedInputs.has(targetKey))
    if (edgeInvalid) {
      invalidEdgeCount += 1
      invalidEdgeDetails.push(`${saved.id || '未命名连线'}：${sourceNodeId || '?'}.${sourcePortId || '?'} → ${targetNodeId || '?'}.${targetPortId || '?'}${saved.warning ? `（${saved.warning}）` : ''}`)
    }
    if (targetPortId && !occupiedInputs.has(targetKey)) occupiedInputs.add(targetKey)
    runtimeEdges.push({
      id: saved.id,
      source: saved.source || sourceNodeId || `__unresolved_source_${saved.id}`,
      sourceHandle: saved.sourceHandle || sourcePortId || `__unresolved_source_port_${saved.id}`,
      target: saved.target || targetNodeId || `__unresolved_target_${saved.id}`,
      targetHandle: saved.targetHandle || targetPortId || `__unresolved_target_port_${saved.id}`,
      type: 'matlabElk',
      zIndex: 1001,
      animated: false,
      markerEnd: saved.relation === 'shaft' || saved.relation === 'bleed' ? undefined : MarkerType.ArrowClosed,
      data: {
        ...(saved.data || {}),
        dataType: sourcePort?.type || 'unknown',
        elkPoints: [],
        relation: saved.relation || saved.data?.relation,
        streamRole: saved.streamRole || saved.data?.streamRole,
        groupId: saved.groupId || saved.data?.groupId,
        unresolved: edgeInvalid,
        originalSourceNodeId: sourceNodeId,
        originalSourceHandle: sourcePortId,
        originalTargetNodeId: targetNodeId,
        originalTargetHandle: targetPortId
      }
    })
  })

  if (missingComponentCount > 0) warnings.push(`${missingComponentCount} 个组件当前不可用`)
  if (invalidEdgeCount > 0) {
    const details = invalidEdgeDetails.slice(0, 3).join('；')
    warnings.push(`${invalidEdgeCount} 条连线已标记为未解析并保留${details ? `：${details}` : ''}`)
  }
  if (discardedValueCount > 0) warnings.push(`${discardedValueCount} 个过期参数值已忽略`)
  return { runtimeNodes, runtimeEdges, warnings }
}

const restoreProjectConfigRecords = async () => {
  const configIds = new Set(nodes.value
    .map((node) => String(node.data?.resources?.motorConfigId || ''))
    .filter(Boolean))
  if (configIds.size === 0) return 0
  try {
    const response = await matlabModelDeployApi.getMyConfigs()
    const records = response.data || []
    const recordMap = new Map(records.map((record) => [record.configId, record]))
    let missingCount = 0
    nodes.value = nodes.value.map((node) => {
      const configId = String(node.data?.resources?.motorConfigId || '')
      if (!configId) return node
      const record = recordMap.get(configId) || null
      if (!record) missingCount += 1
      return { ...node, data: { ...node.data, motorConfig: record } }
    })
    return missingCount
  } catch {
    return configIds.size
  }
}







const handleNewProject = () => {
  editorStore.resetProject({
    [rootSceneId]: {
      id: rootSceneId,
      title: '根场景',
      nodes: [],
      dataEdges: [],
      boundaryPorts: [],
      viewport: { x: 0, y: 0, zoom: 1 }
    }
  }, rootSceneId, {})
  projectRootSceneId.value = rootSceneId
  selectedEdgeId.value = null
  physicalRelation.value = 'flow'
  currentProject.value = null
  designPointUpgradePending.value = false
  clearAutoConnectSource()
  clearNodeSelection()
  resetResultData()
  ElMessage.success('已创建新的 MATLAB 项目')
}



const handleLoadProject = async (project: ModelingProject) => {
  try {
    if (components.value.length === 0) await loadComponents()
    const response = await modelDeployApi.getProject(project.id, 'JULIA_MATLAB')
    const parseResult = parseMatlabProject(response.data?.projectData || '{}')
    const data = parseResult.project
    const rebuiltScenes: Record<string, RuntimeScene> = {}
    const loadWarnings: string[] = [...parseResult.upgradeWarnings]
    if (parseResult.wrongPhysicalSceneIds.length > 0) {
      // 规格：禁止静默修改——错误 PMSM 物理子系统需用户确认转换
      try {
        await ElMessageBox.confirm(
          `检测到旧版错误物理子系统（${parseResult.wrongPhysicalSceneIds.join('、')}），是否转换为通用子系统？`,
          'V2 → V3 导入',
          { type: 'warning', confirmButtonText: '转换', cancelButtonText: '取消' }
        )
        loadWarnings.push('旧错误物理子系统已转换为通用子系统')
      } catch {
        ElMessage.info('已取消加载；旧工程未被修改')
        return
      }
    }
    Object.entries(data.scenes).forEach(([sceneId, scene]) => {
      const rebuilt = rebuildProjectGraph({
        schemaVersion: 3,
        engineType: 'matlab',
        rootSceneId: sceneId,
        scenes: data.scenes,
        physicalAssemblies: data.physicalAssemblies,
        nodes: scene.nodes,
        dataEdges: scene.dataEdges
      })
      rebuiltScenes[sceneId] = {
        ...scene,
        nodes: rebuilt.runtimeNodes,
        dataEdges: rebuilt.runtimeEdges
      }
      loadWarnings.push(...rebuilt.warnings)
    })
    // Only derive the binding summary from saved data connections; do not repair saved topology.
    const assemblies = synchronizeAssemblyBindings(rebuiltScenes, data.physicalAssemblies)
    editorStore.resetProject(rebuiltScenes, data.rootSceneId, assemblies)
    projectRootSceneId.value = data.rootSceneId
    const rebuilt = rebuildProjectGraph({
      schemaVersion: 3,
      engineType: 'matlab',
      rootSceneId: data.rootSceneId,
      scenes: {},
      physicalAssemblies: data.physicalAssemblies,
      nodes: data.scenes[data.rootSceneId]?.nodes || [],
      dataEdges: data.scenes[data.rootSceneId]?.dataEdges || []
    })
    // 兼容旧项目中未保存推导契约的 Bus 字段：按当前来源重新继承一次。
    rebuilt.runtimeEdges.forEach((edge) => inferBusFieldFromConnection(edge))
    const missingConfigCount = await restoreProjectConfigRecords()
    if (missingConfigCount > 0) {
      loadWarnings.push(`${missingConfigCount} 个用户配置记录无法恢复`)
    }
    currentProject.value = { id: project.id, name: project.name, description: project.description }
    clearAutoConnectSource()
    clearNodeSelection()
    resetResultData()
    projectDialogVisible.value = false
    void setViewport(editorStore.scenes[data.rootSceneId]?.viewport || { x: 0, y: 0, zoom: 1 })
    scheduleElkLayout(false, 'full')
    if (loadWarnings.length > 0) {
      ElMessage.warning(`项目已加载；${loadWarnings.join('，')}`)
    } else {
      ElMessage.success(`已加载项目：${project.name}`)
    }
  } catch (error: any) {
    ElMessage.error(`MATLAB项目加载失败：${error.message || '项目数据格式错误'}`)
  }
}




const handleCopyPayload = async () => {
  try {
    await navigator.clipboard.writeText(generatedPayload.value)
    ElMessage.success('执行负载已复制')
  } catch {
    ElMessage.warning('复制失败，请手动复制')
  }
}

const handleOpenCalculationDialog = () => {
  if (!validateInputs()) return
  calculationDialogVisible.value = true
}

const handleGlobalKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape') clearAutoConnectSource()
}
const { captureNodeSelection, applyAdditiveSelection } = useMatlabNodeSelection(nodes)

const { configSchema, configFileInput, configPreviewVisible, configUploading, pendingConfigFile, configPreviewRows, configPreviewMaterialCount, configPreviewOptimizationCount, configPreviewWarnings, handleDownloadConfigTemplate, formatFileSize, openConfigFilePicker, handleConfigFileSelected, cancelConfigPreview, confirmConfigUpload, handleRestoreDefaultConfig, handleViewCurrentConfig } = useMatlabConfigWorkbook({ selectedNode, nodes, resetResultData, selectedConfigRecord: () => selectedConfigRecord.value })

const { projectDialogVisible, saveProjectDialogVisible, projectLoading, projectSaving, projectList, currentProject, saveProjectForm, loadProjectList, handleOpenProjectDialog, handleSaveProject, handleConfirmSaveProject, handleDeleteProject } = useMatlabProject({ buildProjectData })

const resultBindings: MatlabResultsDialogBindings = { resultArtifactGroups, artifactPhaseLabel, activeArtifactPhase, resultDialogVisible, resultTab, selectedResultVariables, selectedPlotVariables, resultVariableGroups, expandedResultGroups, selectedLineArrayVariables, resultValues, selectedArrayVariables, resultVariables, activeResultNodeId, handleResultNodeSelect, availableResultNodes, activeResultPorts, activeResultPortKey, handleResultPortSelect, activeResultNode, activeResultPort, resultBatchId, lastWorkflowResult, formattedWorkflowResult, generatedJuliaCode, copyGeneratedJuliaCode, simulationLogs, lastTaskId }









const { elkLayoutBusy, scheduleElkLayout, handleManualLayout, cancelLayout: cancelCanvasLayout } = useMatlabCanvasLayout({
  nodes,
  edges,
  layoutEdges: physicalLayoutEdges,
  routingEdges: canvasEdges,
  applyTransientRoutes: (routes) => {
    transientPhysicalRoutes.value = Object.fromEntries(
      Object.entries(routes).filter(([edgeId]) => edgeId.startsWith('physical:'))
    )
  },
  sceneId: activeSceneId,
  sceneHydrating,
  sceneRevision: computed(() => editorStore.sceneRevision),
  getValidPorts,
  addLog
})

const {
  activeRelationGroupId,
  setPhysicalLensMode,
  createSelectedRelationGroup, addSelectedNodeToGroup, removeSelectedNodeFromGroup,
  updateActiveRelationGroup, deleteActiveRelationGroup,
  updatePhysicalNodeParameter, createFlowRelation, connectGroup
} = useMatlabPhysicalAssemblyEditor({
  nodes, edges, physicalLensMode, physicalRelation,
  selectedNode, selectedNodeId, selectedEdgeId,
  resetResultData
})
const {
  handleSceneBreadcrumbClick, handleViewportChange, handleNodeDoubleClick
} = useMatlabSubsystemNavigation({
  activeSceneId, sceneHydrating, selectedEdgeId, activeRelationGroupId, physicalRelation,
  isNodeFocused, cancelCanvasLayout, clearAutoConnectSource, clearNodeSelection,
  setViewport, scheduleElkLayout, nodesCount: computed(() => nodes.value.length)
})

const { validateInputs } = useMatlabSubmissionValidation({
  nodesCount: computed(() => nodes.value.length),
  scenes: sceneStore,
  nodeDisplayName: (node) => nodeDisplayName(node) || '',
  findNodePort
})

const { instantiateTemplateComponent } = useMatlabTemplateOperations({
  nodes, activeSceneId,
  normalizeComponentPorts: (ports, name, direction) => normalizeComponentPorts(ports, name, direction),
  nextInstanceName,
  rebuildProjectGraph,
  flowContainer,
  selectNodeById,
  scheduleElkLayout
})


const lastExecutionFailure = ref<MatlabStructuredError | null>(null)
const failureDialogVisible = ref(false)
const { calculating, stopPolling, handleStartCalculation } = useMatlabExecution({ lastSubmittedWorkflowNodes, resultDialogVisible, calculationDialogVisible, lastTaskId, sceneStore, scenePathTitle, getValidPorts, nodes, edges, validateInputs, buildExecutionPayload, getTopologicalOrder, addLog, applyCalculationResult, onExecutionFailure: (failure) => { lastExecutionFailure.value = failure; failureDialogVisible.value = true } })


onMounted(() => {
  loadComponents()
  window.addEventListener('keydown', handleGlobalKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleGlobalKeydown)
  stopPolling()
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

/* The lens only changes presentation. Scene nodes and edges remain untouched. */
:deep(.vue-flow__node:has(.matlab-lens-dimmed)),
:deep(.vue-flow__edge:has(.matlab-lens-dimmed)) {
  opacity: 0.16;
  pointer-events: none;
}
:deep(.matlab-edge-label.matlab-lens-dimmed) { opacity: 0.16; }

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
.canvas-card :deep(.panel-header) { display: flex; align-items: flex-start; justify-content: space-between; gap: 8px; }
.canvas-card :deep(.panel-header > div) { display: flex; align-items: center; justify-content: flex-end; flex-wrap: wrap; gap: 6px; }
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
