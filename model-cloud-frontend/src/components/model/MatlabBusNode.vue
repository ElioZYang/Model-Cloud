<template>
  <div
    class="matlab-bus-node"
    :class="{ selected: props.selected, invalid: hasInvalidField, 'matlab-lens-dimmed': lens && !lens.isNodeFocused(props.id) }"
    :style="nodeStyle"
    :title="nodeTitle"
  >
    <div class="bus-body">
      <div
        v-for="port in inputPorts"
        :key="`input-${port.name}`"
        class="bus-port input-port"
        :style="portStyle(port.name, 'input')"
      >
        <Handle
          :id="port.name"
          type="target"
          :position="Position.Left"
          class="bus-handle"
          :title="portTooltip(port, '输入')"
          :aria-label="portTooltip(port, '输入')"
        />
      </div>
      <div
        v-for="port in outputPorts"
        :key="`output-${port.name}`"
        class="bus-port output-port"
        :style="portStyle(port.name, 'output')"
      >
        <Handle
          :id="port.name"
          type="source"
          :position="Position.Right"
          class="bus-handle"
          :title="portTooltip(port, '输出')"
          :aria-label="portTooltip(port, '输出')"
        />
      </div>
      <div class="bus-spine" />
    </div>
    <div class="bus-instance-name" :title="instanceName">{{ instanceName }}</div>
    <MatlabNodeResizeHandles
      v-if="props.selected"
      :id="props.id"
      :width="size.width"
      :height="size.height"
      :position="props.position"
      :min-width="16"
      :min-height="minimumHeight"
    />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Handle, Position } from '@vue-flow/core'
import MatlabNodeResizeHandles from './MatlabNodeResizeHandles.vue'
import type { MatlabPort } from '@/api/matlab-model-deploy'
import { injectMatlabPhysicalLens } from '@/composables/useMatlabPhysicalLens'

type BusNodeData = {
  nodeKind?: 'busCreator' | 'busSelector'
  instanceName?: string
  inputPorts?: MatlabPort[]
  outputPorts?: MatlabPort[]
  portDisplayNames?: Record<string, string>
  portPaths?: Record<string, string>
  fieldErrors?: Record<string, string>
  presentationSize?: { width?: number; height?: number }
}

const props = defineProps<{
  id: string
  data?: BusNodeData
  selected?: boolean
  dimensions?: { width?: number; height?: number }
  position?: { x?: number; y?: number }
  label?: string
}>()
const lens = injectMatlabPhysicalLens()

const inputPorts = computed(() => Array.isArray(props.data?.inputPorts) ? props.data!.inputPorts! : [])
const outputPorts = computed(() => Array.isArray(props.data?.outputPorts) ? props.data!.outputPorts! : [])
const signalCount = computed(() => Math.max(inputPorts.value.length, outputPorts.value.length, 1))
const minimumHeight = computed(() => Math.max(72, signalCount.value * 28 + 16))
const size = computed(() => ({
  width: Math.max(16, Number(props.data?.presentationSize?.width || 24)),
  height: Math.max(minimumHeight.value, Number(props.data?.presentationSize?.height || minimumHeight.value))
}))
const nodeStyle = computed(() => ({ width: `${size.value.width}px`, height: `${size.value.height}px` }))
const instanceName = computed(() => props.data?.instanceName || props.label || 'bus')
const hasInvalidField = computed(() => Object.keys(props.data?.fieldErrors || {}).length > 0)
const nodeTitle = computed(() => hasInvalidField.value
  ? `${instanceName.value}：存在无效信号`
  : instanceName.value)

const portStyle = (name: string, direction: 'input' | 'output') => {
  const ports = direction === 'input' ? inputPorts.value : outputPorts.value
  const index = Math.max(0, ports.findIndex((port) => port.name === name))
  const count = Math.max(ports.length, 1)
  const usableHeight = Math.max(0, size.value.height - 16)
  return { top: `${8 + ((index + 0.5) / count) * usableHeight}px` }
}

const displayPortName = (port: MatlabPort) => props.data?.portDisplayNames?.[port.name] || port.name
const portTooltip = (port: MatlabPort, direction: '输入' | '输出') => {
  const path = props.data?.portPaths?.[port.name]
  const type = port.type && port.type !== 'unknown' ? port.type : '待连接'
  const details = [direction, displayPortName(port), path, type, port.shape, port.unit].filter(Boolean)
  const error = props.data?.fieldErrors?.[port.name]
  return [...details, error ? `无效：${error}` : ''].filter(Boolean).join(' · ')
}
</script>

<style scoped>
.matlab-bus-node { position: relative; box-sizing: border-box; min-width: 16px; min-height: 72px; overflow: visible; }
.bus-body { position: relative; box-sizing: border-box; width: 100%; height: 100%; min-height: 72px; border: 2px solid #606266; border-radius: 3px; background: linear-gradient(90deg, #606266 0 20%, #f5f7fa 20% 80%, #606266 80% 100%); box-shadow: 0 1px 4px rgba(0,0,0,.18); }
.selected .bus-body { border-color: #409eff; box-shadow: 0 0 0 2px rgba(64,158,255,.22); }
.invalid .bus-body { border-color: #f56c6c; }
.bus-spine { position: absolute; left: 50%; top: 6px; bottom: 6px; width: 2px; transform: translateX(-50%); background: #409eff; opacity: .9; }
.bus-port { position: absolute; z-index: 25; width: 0; height: 0; transform: translateY(-50%); }
.input-port { left: -2px; }
.output-port { right: -2px; }
:deep(.bus-handle) { position: absolute !important; z-index: 30; inset: auto !important; top: 0 !important; width: 10px; height: 10px; margin: 0; border: 2px solid #409eff; border-radius: 50%; background: #fff; transform: translateY(-50%); }
.input-port :deep(.bus-handle) { left: 0 !important; transform: translate(-50%, -50%); }
.output-port :deep(.bus-handle) { right: 0 !important; transform: translate(50%, -50%); }
.bus-instance-name { position: absolute; top: calc(100% + 8px); left: 50%; width: 180px; max-width: 180px; transform: translateX(-50%); overflow: hidden; text-align: center; text-overflow: ellipsis; white-space: nowrap; color: #606266; font-size: 12px; line-height: 18px; }
</style>
