<template>
  <BaseEdge
    :id="props.id"
    :path="edgePath"
    :marker-start="props.markerStart"
    :marker-end="edgeRelation === 'shaft' || edgeRelation === 'bleed' ? undefined : props.markerEnd"
    :interaction-width="props.interactionWidth"
    :class="edgeClass"
  />
  <EdgeLabelRenderer v-if="edgeLabel">
    <div
      class="matlab-edge-label"
      :class="{ 'matlab-lens-dimmed': lens && !lens.isEdgeFocused(props.id) }"
      :style="labelStyle"
      :data-edge-label="edgeLabel"
    >{{ edgeLabel }}</div>
  </EdgeLabelRenderer>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { BaseEdge, EdgeLabelRenderer } from '@vue-flow/core'
import type { EdgeProps } from '@vue-flow/core'
import type { MatlabElkPoint } from '@/composables/useMatlabElkLayout'
import { injectMatlabPhysicalLens } from '@/composables/useMatlabPhysicalLens'

const props = defineProps<EdgeProps>()
const lens = injectMatlabPhysicalLens()

const appendPoint = (segments: string[], command: 'M' | 'L', x: number, y: number) => {
  const segment = `${command} ${x} ${y}`
  if (segments[segments.length - 1] !== segment) segments.push(segment)
}

const edgePath = computed(() => {
  const rawPoints = Array.isArray(props.data?.elkPoints)
    ? props.data.elkPoints as MatlabElkPoint[]
    : []
  const points = rawPoints.every((point) => (
    Number.isFinite(point?.x) && Number.isFinite(point?.y)
  )) ? rawPoints : []
  if (points.length < 2) {
    return `M ${props.sourceX} ${props.sourceY} L ${props.targetX} ${props.targetY}`
  }

  const segments: string[] = []
  const start = points[0]
  const end = points[points.length - 1]
  appendPoint(segments, 'M', props.sourceX, props.sourceY)
  // A moved/unmeasured node invalidates the old route. Do not stitch it back
  // with vertical detours: use a temporary line until layout finishes.
  if (Math.abs(props.sourceY - start.y) > 1 || Math.abs(props.targetY - end.y) > 1
    || Math.abs(props.sourceX - start.x) > 24 || Math.abs(props.targetX - end.x) > 24) {
    return `M ${props.sourceX} ${props.sourceY} L ${props.targetX} ${props.targetY}`
  }
  // Only horizontal stubs connect the inset Handles to the node boundary.
  const aligned = points.map((point) => ({ ...point }))
  aligned[0].y = props.sourceY
  aligned[aligned.length - 1].y = props.targetY
  aligned.forEach((point) => appendPoint(segments, 'L', point.x, point.y))
  appendPoint(segments, 'L', props.targetX, props.targetY)
  return segments.join(' ')
})

const edgeRelation = computed(() => String(props.data?.relation || 'workflow'))
const edgeStreamRole = computed(() => String(props.data?.streamRole || ''))
const edgeLabel = computed(() => {
  const relation = edgeRelation.value === 'workflow' ? '' : edgeRelation.value
  const stream = edgeStreamRole.value ? ` · ${edgeStreamRole.value}` : ''
  const group = props.data?.groupName ? ` · ${props.data.groupName}` : ''
  return relation || stream || group ? `${relation}${stream}${group}`.replace(/^ · /, '') : ''
})
const edgeClass = computed(() => [
  `matlab-edge-${edgeRelation.value}`,
  edgeStreamRole.value ? `matlab-edge-${edgeStreamRole.value}` : '',
  props.data?.unresolved ? 'matlab-edge-unresolved' : '',
  lens && !lens.isEdgeFocused(props.id) ? 'matlab-lens-dimmed' : ''
])
const labelPosition = computed(() => {
  const points = Array.isArray(props.data?.elkPoints) ? props.data.elkPoints as MatlabElkPoint[] : []
  const midpoint = points.length > 1 ? points[Math.floor(points.length / 2)] : null
  return {
    x: Number(midpoint?.x ?? ((props.sourceX + props.targetX) / 2)),
    y: Number(midpoint?.y ?? ((props.sourceY + props.targetY) / 2))
  }
})
const labelStyle = computed(() => ({
  transform: `translate(-50%, -50%) translate(${labelPosition.value.x}px, ${labelPosition.value.y}px)`
}))
</script>

<style scoped>
:deep(.matlab-edge-shaft) { stroke: #e6a23c; stroke-width: 2.5px; stroke-dasharray: 7 4; }
:deep(.matlab-edge-bleed) { stroke: #9c27b0; stroke-width: 2.5px; stroke-dasharray: 3 3; }
:deep(.matlab-edge-flow) { stroke: #409eff; stroke-width: 2.5px; }
:deep(.matlab-edge-core) { stroke: #409eff; }
:deep(.matlab-edge-bypass) { stroke: #67c23a; }
:deep(.matlab-edge-unresolved) { stroke: #f56c6c; stroke-dasharray: 4 3; }
.matlab-edge-label {
  position: absolute;
  pointer-events: none;
  padding: 3px 5px;
  border: 1px solid #dcdfe6;
  border-radius: 3px;
  background: #fff;
  color: #606266;
  font-size: 10px;
  line-height: 14px;
  white-space: nowrap;
  transform-origin: center;
}
</style>
