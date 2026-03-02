<template>
  <div class="modelica-component-node" :class="{ selected: selected }">
    <div class="node-header">
      <el-image
        v-if="coverImage"
        :src="coverImage"
        class="node-icon"
        fit="cover"
      >
        <template #error>
          <el-icon class="node-icon-fallback"><Box /></el-icon>
        </template>
      </el-image>
      <el-icon v-else class="node-icon-fallback"><Box /></el-icon>
      <span class="node-label">{{ label || data?.componentName || 'Component' }}</span>
    </div>
    <div class="node-connectors">
      <div
        v-for="connector in connectorList"
        :key="connector.name"
        class="connector-item"
        :class="getConnectorClass(connector)"
      >
        <Handle
          :id="connector.name"
          :type="getConnectorType(connector)"
          :position="getConnectorPosition(connector)"
          class="connector-handle"
        />
        <span class="connector-label">{{ connector.name }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Handle, useNode } from '@vue-flow/core'
import { Box } from '@element-plus/icons-vue'
import type { Connector } from '@/api/model-deploy'

// 使用useNode获取节点数据
const { data, selected } = useNode()

// 从节点数据中获取connectors
const connectorList = computed(() => {
  return data.value?.connectors || []
})

// 从节点数据中获取coverImage
const coverImage = computed(() => {
  return data.value?.coverImage || ''
})

// 从节点数据中获取label
const label = computed(() => {
  return data.value?.componentName || ''
})

// 获取connector的CSS类
const getConnectorClass = (connector: Connector) => {
  const type = connector.type || ''
  if (type.includes('PositivePin')) return 'connector-positive'
  if (type.includes('NegativePin')) return 'connector-negative'
  if (type.includes('Pin')) return 'connector-pin'
  return 'connector-default'
}

// 获取connector的Handle类型（source或target）
const getConnectorType = (connector: Connector): 'source' | 'target' => {
  const type = connector.type || ''
  // 简化处理：PositivePin作为source，NegativePin作为target
  if (type.includes('PositivePin')) return 'source'
  if (type.includes('NegativePin')) return 'target'
  // 默认：第一个为source，其他为target
  const list = connectorList.value
  const index = list.findIndex(c => c.name === connector.name)
  return index === 0 ? 'source' : 'target'
}

// 获取connector的位置（left或right）
const getConnectorPosition = (connector: Connector): 'left' | 'right' => {
  const type = connector.type || ''
  // 简化处理：PositivePin在左侧，NegativePin在右侧
  if (type.includes('PositivePin')) return 'left'
  if (type.includes('NegativePin')) return 'right'
  // 默认：第一个在左侧，其他在右侧
  const list = connectorList.value
  const index = list.findIndex(c => c.name === connector.name)
  return index === 0 ? 'left' : 'right'
}
</script>

<style scoped>
.modelica-component-node {
  background: white;
  border: 2px solid #e4e7ed;
  border-radius: 8px;
  padding: 8px;
  min-width: 120px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.2s;
}

.modelica-component-node.selected {
  border-color: #409eff;
  box-shadow: 0 2px 12px rgba(64, 158, 255, 0.3);
}

.node-header {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
  padding-bottom: 8px;
  border-bottom: 1px solid #e4e7ed;
}

.node-icon {
  width: 32px;
  height: 32px;
  min-width: 32px;
  border-radius: 4px;
  margin-right: 8px;
  border: 1px solid #e4e7ed;
}

.node-icon-fallback {
  width: 32px;
  height: 32px;
  min-width: 32px;
  font-size: 20px;
  color: #409eff;
  margin-right: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.node-label {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.node-connectors {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.connector-item {
  display: flex;
  align-items: center;
  position: relative;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.connector-item:hover {
  background-color: #f5f7fa;
}

.connector-handle {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  border: 2px solid white;
  background: #409eff;
  cursor: crosshair;
}

.connector-positive .connector-handle {
  background: #67c23a;
}

.connector-negative .connector-handle {
  background: #f56c6c;
}

.connector-label {
  font-size: 12px;
  color: #606266;
  margin-left: 8px;
}
</style>

