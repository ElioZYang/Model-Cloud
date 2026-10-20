<template>
  <template v-if="isBundled">
    <path
      v-if="isTrunkOwner"
      class="matlab-bundle-trunk"
      :d="trunkPath"
    />
    <BaseEdge
      :id="`${props.id}-source-branch`"
      :path="sourceBranchPath"
      :marker-start="props.markerStart"
      :interaction-width="props.interactionWidth"
    />
    <BaseEdge
      :id="`${props.id}-target-branch`"
      :path="targetBranchPath"
      :marker-end="props.markerEnd"
      :interaction-width="props.interactionWidth"
    />
  </template>

  <BaseEdge
    v-else
    :id="props.id"
    :path="singleEdgePath"
    :label-x="singleLabelX"
    :label-y="singleLabelY"
    :marker-start="props.markerStart"
    :marker-end="props.markerEnd"
    :interaction-width="props.interactionWidth"
  />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { BaseEdge, useVueFlow } from '@vue-flow/core'
import type { EdgeProps } from '@vue-flow/core'

const props = defineProps<EdgeProps>()
const { getEdges } = useVueFlow()

const anchorOffset = 48

const siblingEdges = computed(() => getEdges.value.filter((edge) => {
  return edge.source === props.source && edge.target === props.target
}))

const sortedSiblingEdges = computed(() => [...siblingEdges.value].sort((left, right) => {
  return left.id.localeCompare(right.id)
}))

const isBundled = computed(() => sortedSiblingEdges.value.length >= 2)
const isTrunkOwner = computed(() => sortedSiblingEdges.value[0]?.id === props.id)

const sourceAnchor = computed(() => ({
  x: props.sourceNode.computedPosition.x + props.sourceNode.dimensions.width + anchorOffset,
  y: props.sourceNode.computedPosition.y + props.sourceNode.dimensions.height / 2
}))

const targetAnchor = computed(() => ({
  x: props.targetNode.computedPosition.x - anchorOffset,
  y: props.targetNode.computedPosition.y + props.targetNode.dimensions.height / 2
}))

const sourceBranchPath = computed(() => [
  `M ${props.sourceX} ${props.sourceY}`,
  `L ${sourceAnchor.value.x} ${sourceAnchor.value.y}`
].join(' '))

const trunkPath = computed(() => [
  `M ${sourceAnchor.value.x} ${sourceAnchor.value.y}`,
  `L ${targetAnchor.value.x} ${targetAnchor.value.y}`
].join(' '))

const targetBranchPath = computed(() => [
  `M ${targetAnchor.value.x} ${targetAnchor.value.y}`,
  `L ${props.targetX} ${props.targetY}`
].join(' '))

const singleEdgePath = computed(() => [
  `M ${props.sourceX} ${props.sourceY}`,
  `L ${props.targetX} ${props.targetY}`
].join(' '))
const singleLabelX = computed(() => (props.sourceX + props.targetX) / 2)
const singleLabelY = computed(() => (props.sourceY + props.targetY) / 2)
</script>

<style scoped>
.matlab-bundle-trunk {
  fill: none;
  stroke: #b1b1b7;
  stroke-width: 2;
  stroke-dasharray: none;
  pointer-events: none;
}
</style>
