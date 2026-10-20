<template>
  <div class="boundary-node" :class="[{ selected: selected }, direction]" :style="nodeStyle">
    <Handle v-if="direction === 'output'" :id="inputName" type="target" :position="Position.Left" class="boundary-handle" />
    <div class="boundary-glyph">{{ direction === 'input' ? 'In' : 'Out' }}</div>
    <div class="boundary-title" :title="displayName">{{ displayName }}</div>
    <Handle v-if="direction === 'input'" :id="outputName" type="source" :position="Position.Right" class="boundary-handle" />
    <MatlabNodeResizeHandles v-if="selected" :id="id" :width="size.width" :height="size.height" :position="position" :min-width="72" :min-height="54" />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Handle, Position } from '@vue-flow/core'
import MatlabNodeResizeHandles from './MatlabNodeResizeHandles.vue'

const props = defineProps<{ id: string; label?: string; selected?: boolean; position?: {x?:number;y?:number}; dimensions?: {width?:number;height?:number}; data?: { boundaryDirection?: 'input'|'output'; instanceName?: string; presentationSize?: {width?:number;height?:number} } }>()
const direction = computed(() => props.data?.boundaryDirection || 'input')
const displayName = computed(() => props.data?.instanceName || props.label || (direction.value === 'input' ? 'In 1' : 'Out 1'))
const inputName = computed(() => 'in')
const outputName = computed(() => 'out')
const size = computed(() => ({ width: Math.max(72, Number(props.data?.presentationSize?.width || props.dimensions?.width || 92)), height: Math.max(54, Number(props.data?.presentationSize?.height || props.dimensions?.height || 58)) }))
const nodeStyle = computed(() => ({ width: `${size.value.width}px`, height: `${size.value.height}px` }))
</script>

<style scoped>
.boundary-node { box-sizing:border-box; position:relative; display:flex; align-items:center; justify-content:center; gap:7px; border:2px solid #606266; border-radius:5px; background:#f5f7fa; color:#303133; box-shadow:0 1px 4px #0002; }
.boundary-node.selected { border-color:#409eff; box-shadow:0 0 0 2px #409eff33; }
.boundary-node.input { border-left:9px solid #606266; }
.boundary-node.output { border-right:9px solid #606266; }
.boundary-glyph { font-size:12px; font-weight:700; color:#409eff; }
.boundary-title { max-width:calc(100% - 28px); overflow:hidden; text-overflow:ellipsis; white-space:nowrap; font-size:12px; }
.boundary-handle { width:10px; height:10px; border:2px solid #409eff; background:#fff; }
</style>
