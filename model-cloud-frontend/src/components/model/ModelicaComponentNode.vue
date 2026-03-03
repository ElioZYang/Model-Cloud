<template>
  <div class="modelica-component-node" :class="{ selected: !!props.selected }">
    <div class="node-cover">
      <el-image
        v-if="coverImage"
        :src="coverImage"
        class="node-image"
        fit="contain"
      >
        <template #error>
          <div class="node-image-fallback">
            <el-icon class="node-icon-fallback"><Box /></el-icon>
          </div>
        </template>
      </el-image>
      <div v-else class="node-image-fallback">
        <el-icon class="node-icon-fallback"><Box /></el-icon>
      </div>
    </div>
    <div class="node-title">
      <span class="node-label">{{ label || props.data?.componentName || 'Component' }}</span>
    </div>
    <div class="node-connectors-overlay">
      <template v-for="layout in connectorLayouts" :key="layout.connector.name">
        <Handle
          :id="layout.connector.name"
          :type="getConnectorType(layout.connector, layout.position)"
          :position="layout.position"
          :style="getHandleStyle(layout)"
          class="connector-handle"
          :class="getConnectorClass(layout.connector)"
        />
        <span class="connector-label" :style="getLabelStyle(layout)">
          {{ layout.connector.name }}
        </span>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Handle, Position } from '@vue-flow/core'
import { Box } from '@element-plus/icons-vue'
import type { Connector } from '@/api/model-deploy'

type NodeData = {
  componentName?: string
  connectors?: Connector[]
  coverImage?: string
}

const props = defineProps<{
  data?: NodeData
  selected?: boolean
  label?: string
}>()

// 从节点数据中获取connectors
const connectorList = computed(() => {
  return props.data?.connectors || []
})

// 从节点数据中获取coverImage
const coverImage = computed(() => {
  return props.data?.coverImage || ''
})

// 从节点数据中获取label
const label = computed(() => {
  return props.label || props.data?.componentName || ''
})

type Side = 'left' | 'right' | 'top' | 'bottom'
type ConnectorLayout = {
  connector: Connector
  position: Position
  side: Side
  sideIndex: number
  sideCount: number
}

const connectorLayouts = computed<ConnectorLayout[]>(() => {
  const list = connectorList.value || []
  const sides: Side[] = list.map((connector, index) => decideSide(connector, index))
  const sideCounts: Record<Side, number> = { left: 0, right: 0, top: 0, bottom: 0 }
  sides.forEach((s) => {
    sideCounts[s] += 1
  })

  const runningIndex: Record<Side, number> = { left: 0, right: 0, top: 0, bottom: 0 }
  return list.map((connector, index) => {
    const side = sides[index]
    runningIndex[side] += 1
    return {
      connector,
      position: sideToPosition(side),
      side,
      sideIndex: runningIndex[side],
      sideCount: sideCounts[side]
    }
  })
})

const sideToPosition = (side: Side): Position => {
  switch (side) {
    case 'left':
      return Position.Left
    case 'right':
      return Position.Right
    case 'top':
      return Position.Top
    case 'bottom':
      return Position.Bottom
  }
}

const decideSide = (connector: Connector, index: number): Side => {
  const name = String(connector.name || '').toLowerCase()
  if (name === 'p') return 'left'
  if (name === 'n') return 'right'

  // 默认端口放置顺序：左、右、上、下
  const baseOrder: Side[] = ['left', 'right', 'top', 'bottom']
  if (index < 4) {
    return baseOrder[index]
  }

  // 超过四个：其余端口依次放在上、下
  return (index - 4) % 2 === 0 ? 'top' : 'bottom'
}

// 获取connector的CSS类
const getConnectorClass = (connector: Connector) => {
  const type = connector.type || ''
  if (type.includes('PositivePin')) return 'connector-positive'
  if (type.includes('NegativePin')) return 'connector-negative'
  if (type.includes('Pin')) return 'connector-pin'
  return 'connector-default'
}

// 获取connector的Handle类型（source或target）
const getConnectorType = (connector: Connector, position: Position): 'source' | 'target' => {
  const name = String(connector.name || '').toLowerCase()
  if (name === 'p') return 'source'
  if (name === 'n') return 'target'

  const type = connector.type || ''
  // 简化处理：PositivePin作为source，NegativePin作为target
  if (type.includes('PositivePin')) return 'source'
  if (type.includes('NegativePin')) return 'target'
  // 其他端口按位置给默认方向
  return position === Position.Right || position === Position.Bottom ? 'target' : 'source'
}

const getHandleStyle = (layout: ConnectorLayout) => {
  const ratio = layout.sideIndex / (layout.sideCount + 1)
  const percent = `${Math.round(ratio * 100)}%`
  if (layout.side === 'left' || layout.side === 'right') {
    return { top: percent }
  }
  return { left: percent }
}

const getLabelStyle = (layout: ConnectorLayout) => {
  const ratio = layout.sideIndex / (layout.sideCount + 1)
  const percent = `${Math.round(ratio * 100)}%`
  if (layout.side === 'left') {
    return { left: '-24px', top: `calc(${percent} - 8px)` }
  }
  if (layout.side === 'right') {
    return { right: '-24px', top: `calc(${percent} - 8px)` }
  }
  if (layout.side === 'top') {
    return { top: '-22px', left: `calc(${percent} - 10px)` }
  }
  return { bottom: '-22px', left: `calc(${percent} - 10px)` }
}
</script>

<style scoped>
.modelica-component-node {
  position: relative;
  background: white;
  border: 2px solid #e4e7ed;
  border-radius: 8px;
  padding: 0;
  min-width: 160px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.2s;
  overflow: hidden;
}

.modelica-component-node.selected {
  border-color: #409eff;
  box-shadow: 0 2px 12px rgba(64, 158, 255, 0.3);
}

.node-cover {
  width: 100%;
  height: 96px;
  overflow: hidden;
  border-bottom: 1px solid #e4e7ed;
  background: #fff;
}

.node-image {
  width: 100%;
  height: 100%;
  display: block;
}

.node-image-fallback {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #f8fbff, #eef5ff);
}

.node-icon-fallback {
  font-size: 26px;
  color: #409eff;
}

.node-title {
  margin: 0;
  padding: 4px 6px;
  text-align: center;
}

.node-label {
  font-size: 13px;
  font-weight: 500;
  color: #303133;
  display: inline-block;
  max-width: 142px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.node-connectors-overlay {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.connector-handle {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  border: none;
  background: transparent;
  cursor: crosshair;
  pointer-events: all;
}

.connector-handle::after {
  content: '';
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  width: 10px;
  height: 10px;
  border-radius: 50%;
  border: 2px solid #fff;
  background: #409eff;
  box-sizing: border-box;
}

.connector-positive .connector-handle {
  background: transparent;
}

.connector-positive .connector-handle::after {
  background: #67c23a;
}

.connector-negative .connector-handle {
  background: transparent;
}

.connector-negative .connector-handle::after {
  background: #f56c6c;
}

.connector-label {
  position: absolute;
  font-size: 12px;
  color: #606266;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 3px;
  padding: 0 2px;
  line-height: 16px;
  user-select: none;
  pointer-events: none;
}
</style>

