<template>
  <div class="matlab-composite-node" :class="{ selected: !!props.selected, unresolved: !!props.data?.unresolved, 'matlab-lens-dimmed': lens && !lens.isNodeFocused(props.id) }" :style="nodeStyle">
    <div class="composite-header">
      <div class="composite-icon">⌘</div>
      <div class="composite-title" :title="displayName">{{ displayName }}</div>
      <el-tag size="small" type="success">子系统</el-tag>
    </div>
    <div v-if="inputPorts.length || outputPorts.length" class="ports-body">
      <div class="port-column">
        <div v-for="port in inputPorts" :key="`input-${port.name}`" class="port-row">
          <Handle :id="port.name" type="target" :position="Position.Left" class="port-handle" :title="port.name" />
          <span class="port-name" :title="`${port.description || port.name} (${port.type})`">{{ port.description || port.name }}</span>
        </div>
      </div>
      <div class="port-column output-column">
        <div v-for="port in outputPorts" :key="`output-${port.name}`" class="port-row output-row">
          <span class="port-name" :title="`${port.description || port.name} (${port.type})`">{{ port.description || port.name }}</span>
          <Handle :id="port.name" type="source" :position="Position.Right" class="port-handle" :title="port.name" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Handle, Position } from '@vue-flow/core'
import type { MatlabPort } from '@/api/matlab-model-deploy'
import { injectMatlabPhysicalLens } from '@/composables/useMatlabPhysicalLens'
import type { BoundaryPort } from '@/features/matlab-modeling/domain/physicalAssembly'

const props = defineProps<{
  id: string
  data?: {
    instanceName?: string
    componentName?: string
    inputPorts?: MatlabPort[]
    outputPorts?: MatlabPort[]
    unresolved?: boolean
    presentationSize?: { width?: number; height?: number }
    boundaryPorts?: BoundaryPort[]
  }
  label?: string
  selected?: boolean
  dimensions?: { width?: number; height?: number }
}>()
const lens = injectMatlabPhysicalLens()

const physicalPorts = (direction: 'input' | 'output') => (props.data?.boundaryPorts || [])
  .filter(port => port.kind !== 'data' && (port.direction === direction || !port.direction))
  .map(port => ({ name: port.id, type: port.kind, description: port.name }))
const inputPorts = computed(() => [...(props.data?.inputPorts || []), ...physicalPorts('input')])
const outputPorts = computed(() => [...(props.data?.outputPorts || []), ...physicalPorts('output')])
const displayName = computed(() => props.data?.instanceName || props.label || props.data?.componentName || 'MATLAB子系统')
const minimumHeight = computed(() => {
  const rows = Math.max(inputPorts.value.length, outputPorts.value.length, 1)
  return Math.max(128, 54 + rows * 28 + 30)
})
const nodeStyle = computed(() => ({
  width: `${Math.max(250, Number(props.data?.presentationSize?.width || props.dimensions?.width || 320))}px`,
  minHeight: `${Math.max(minimumHeight.value, Number(props.data?.presentationSize?.height || props.dimensions?.height || minimumHeight.value))}px`
}))
</script>

<style scoped>
.matlab-composite-node { position: relative; box-sizing: border-box; min-height: 128px; overflow: visible; border: 2px solid #67c23a; border-radius: 8px; background: #f6ffed; box-shadow: 0 2px 8px rgba(103,194,58,.16); }
.matlab-composite-node.selected { border-color: #409eff; box-shadow: 0 0 0 2px rgba(64,158,255,.2); }
.matlab-composite-node.unresolved { border-color: #f56c6c; background: #fef0f0; }
.composite-header { display: flex; align-items: center; gap: 8px; min-height: 54px; padding: 7px 10px; border-bottom: 1px solid #d9ecce; }
.composite-icon { display: flex; align-items: center; justify-content: center; width: 32px; height: 32px; border-radius: 6px; color: #fff; background: #67c23a; font-size: 20px; }
.composite-title { flex: 1; min-width: 0; overflow: hidden; color: #303133; font-weight: 600; text-overflow: ellipsis; white-space: nowrap; }
.ports-body { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); gap: 18px; padding: 8px; }
.port-column { display: flex; flex-direction: column; justify-content: space-evenly; gap: 4px; }
.port-row { position: relative; display: flex; align-items: center; min-height: 24px; gap: 7px; }
.output-row { justify-content: flex-end; }
.port-name { min-width: 0; overflow: hidden; color: #606266; font-size: 12px; text-overflow: ellipsis; white-space: nowrap; }
.output-row .port-name { text-align: right; }
.port-handle { position: relative; inset: auto; width: 10px; height: 10px; flex: 0 0 10px; margin: 0; border: 0; border-radius: 50%; background: #67c23a; transform: none; }
</style>
