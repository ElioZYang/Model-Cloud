<template>
  <div class="matlab-component-node" :class="{ selected: !!props.selected, unresolved: !!props.data?.unresolved, 'matlab-lens-dimmed': lens && !lens.isNodeFocused(props.id), 'matlab-lens-relations': relationMode }" :style="nodeStyle">
    <div class="node-header">
      <div class="node-cover">
        <el-image v-if="coverImage" :src="coverImage" class="node-image" fit="contain">
          <template #error><el-icon class="node-icon"><Box /></el-icon></template>
        </el-image>
        <el-icon v-else class="node-icon"><Box /></el-icon>
      </div>
      <div class="node-title" :title="displayName">{{ displayName }}</div>
      <el-tag v-if="props.data?.unresolved" size="small" type="danger">不可用</el-tag>
    </div>
    <template v-if="lens?.isPhysical.value">
      <template v-for="relation in relationKinds" :key="relation">
        <Handle :id="`${relation.toUpperCase()}_IN`" type="target" :position="Position.Left"
          class="relation-handle relation-input" :class="[relation, { inactive: relationMode !== relation }]" :title="`${relation} 关系输入`" />
        <Handle :id="`${relation.toUpperCase()}_OUT`" type="source" :position="Position.Right"
          class="relation-handle relation-output" :class="[relation, { inactive: relationMode !== relation }]" :title="`${relation} 关系输出`" />
      </template>
    </template>

    <div v-if="inputPorts.length || outputPorts.length" class="ports-header">
      <span>输入</span><span>输出</span>
    </div>
    <div v-if="inputPorts.length || outputPorts.length" class="ports-body">
      <div class="port-column">
        <div v-for="port in inputPorts" :key="`input-${port.name}`" class="port-row input-row">
          <Handle :id="port.name" type="target" :position="Position.Left" :connectable="canConnectPorts" class="port-handle input-handle" :title="port.name" :aria-label="`输入端口 ${port.name}`" />
          <span class="port-name" :title="port.name">{{ portLabel(port.name) }}</span>
        </div>
      </div>
      <div class="port-column output-column">
        <div v-for="port in outputPorts" :key="`output-${port.name}`" class="port-row output-row">
          <span class="port-name" :title="port.name">{{ portLabel(port.name) }}</span>
          <Handle :id="port.name" type="source" :position="Position.Right" :connectable="canConnectPorts" class="port-handle output-handle" :title="port.name" :aria-label="`输出端口 ${port.name}`" />
        </div>
      </div>
    </div>
    <MatlabNodeResizeHandles
      v-if="props.selected"
      :id="props.id"
      :width="nodeSize.width"
      :height="nodeSize.height"
      :position="props.position"
      :min-width="220"
      :min-height="minimumHeight"
    />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Handle, Position } from '@vue-flow/core'
import { Box } from '@element-plus/icons-vue'
import type { Connector } from '@/api/model-deploy'
import MatlabNodeResizeHandles from './MatlabNodeResizeHandles.vue'
import { injectMatlabPhysicalLens } from '@/composables/useMatlabPhysicalLens'
import type { PhysicalCapabilities } from '@/features/matlab-modeling/domain/physicalAssembly'

type NodeData = {
  componentName?: string
  instanceName?: string
  coverImage?: string
  connectors?: Connector[]
  unresolved?: boolean
  presentationSize?: { width?: number; height?: number }
  portDisplayNames?: Record<string, string>
  physicalCapabilities?: PhysicalCapabilities
}

const props = defineProps<{
  id: string
  data?: NodeData
  selected?: boolean
  label?: string
  dimensions?: { width?: number; height?: number }
  position?: { x?: number; y?: number }
}>()
const lens = injectMatlabPhysicalLens()
const relationMode = computed(() => lens?.isPhysical.value
  && (lens.mode.value === 'shaft' || lens.mode.value === 'bleed') ? lens.mode.value : null)
const connectors = computed(() => Array.isArray(props.data?.connectors) ? props.data!.connectors! : [])
const relationKinds = computed(() => (['shaft', 'bleed'] as const).filter(kind => props.data?.physicalCapabilities?.[kind]?.joinable))
const canConnectPorts = computed(() => !lens?.isPhysical.value || (props.data?.physicalCapabilities?.flow
  ? lens.mode.value === 'flow' : lens.mode.value === 'overview'))
const inputPorts = computed(() => props.data?.physicalCapabilities?.flow
  ? props.data.physicalCapabilities.flow.inputs.map(port => ({ name: port.id }))
  : connectors.value.filter((port) => String(port?.type || '').toLowerCase().includes('input') && String(port?.name || '').trim()))
const outputPorts = computed(() => props.data?.physicalCapabilities?.flow
  ? props.data.physicalCapabilities.flow.outputs.map(port => ({ name: port.id }))
  : connectors.value.filter((port) => String(port?.type || '').toLowerCase().includes('output') && String(port?.name || '').trim()))
// Keep enough room for the title, port headings, one row of whitespace and
// every visible port row.  The measured Vue Flow height may be smaller while
// mounting, but it must never shrink the rendered card below this value.
const minimumHeight = computed(() => {
  const rows = Math.max(inputPorts.value.length, outputPorts.value.length, 1)
  return Math.max(128, 58 + 28 + rows * 28 + 20)
})
const displayName = computed(() => props.label || props.data?.instanceName || props.data?.componentName || 'MATLAB组件')
const portLabel = (name: string) => props.data?.portDisplayNames?.[name] || name
const coverImage = computed(() => props.data?.coverImage || '')
const nodeSize = computed(() => ({
  width: Math.max(220, Number(props.data?.presentationSize?.width || props.dimensions?.width || 360)),
  height: Math.max(minimumHeight.value, Number(props.data?.presentationSize?.height || props.dimensions?.height || 96))
}))
const nodeStyle = computed(() => ({
  width: `${nodeSize.value.width}px`,
  height: `${nodeSize.value.height}px`
}))
</script>

<style scoped>
.matlab-component-node { position: relative; box-sizing: border-box; display: flex; flex-direction: column; width: 360px; min-height: 128px; background: #fff; border: 2px solid #dcdfe6; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,.1); overflow: visible; }
.matlab-component-node.selected { border-color: #409eff; box-shadow: 0 2px 12px rgba(64,158,255,.3); }
.matlab-component-node.unresolved { border-color: #f56c6c; background: #fef0f0; }
.node-header { display: flex; align-items: center; min-height: 58px; border-bottom: 1px solid #ebeef5; padding: 6px 10px; gap: 10px; }
.node-cover { width: 44px; height: 44px; flex: 0 0 44px; display: flex; align-items: center; justify-content: center; background: #f5f9ff; border-radius: 5px; overflow: hidden; }
.node-image { width: 100%; height: 100%; }
.node-icon { font-size: 24px; color: #409eff; }
.node-title { min-width: 0; color: #303133; font-size: 14px; font-weight: 600; line-height: 20px; overflow-wrap: anywhere; }
.ports-header, .ports-body { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); column-gap: 18px; padding: 0 7px; }
.ports-header { flex: 0 0 auto; }
.ports-header { color: #909399; font-size: 12px; font-weight: 600; padding-top: 7px; padding-bottom: 3px; }
.ports-header span:last-child { text-align: right; }
.ports-body { flex: 1 1 auto; min-height: 0; padding-top: 8px; padding-bottom: 8px; align-items: stretch; }
.port-column { display: flex; flex-direction: column; justify-content: space-evenly; min-width: 0; min-height: 0; }
.port-row { position: relative; display: flex; flex: 0 0 28px; align-items: center; gap: 8px; min-width: 0; min-height: 28px; line-height: 18px; }
.output-row { justify-content: flex-end; }
.port-name { flex: 1 1 auto; min-width: 0; max-width: 100%; overflow: hidden; color: #606266; font-size: 12px; line-height: 18px; text-overflow: ellipsis; white-space: nowrap; overflow-wrap: normal; word-break: normal; }
.output-row .port-name { text-align: right; }
.port-handle { position: relative; inset: auto; transform: none; flex: 0 0 10px; width: 10px; height: 10px; margin: 0; border: 0; border-radius: 50%; background: #409eff; }
.port-handle::after { content: ''; position: absolute; inset: 2px; border-radius: 50%; background: #fff; }
.matlab-lens-relations .port-handle { opacity: .2; pointer-events: none; }
.relation-handle { position: absolute; top: 20px; width: 13px; height: 13px; border: 2px solid #fff; border-radius: 50%; z-index: 2; }
.relation-input { left: -7px; }
.relation-output { right: -7px; }
.relation-handle.shaft { background: #e6a23c; }
.relation-handle.bleed { background: #9c27b0; }
.relation-handle.bleed { top: 40px; }
.relation-handle.inactive { opacity: .25; pointer-events: none; }
</style>
