<script setup lang="ts">
import { Box, Search } from '@element-plus/icons-vue'
import type { MatlabComponent } from '@/api/matlab-model-deploy'

export type MatlabCatalogTreeNode = {
  key: string
  label: string
  type?: string
  component?: MatlabComponent
  children?: MatlabCatalogTreeNode[]
}

defineProps<{
  components: MatlabComponent[]
  treeData: MatlabCatalogTreeNode[]
  resolveComponentCover: (component: MatlabComponent) => string
}>()

const keyword = defineModel<string>('keyword', { default: '' })

const emit = defineEmits<{
  (event: 'drag-start', component: MatlabComponent, dragEvent: DragEvent): void
}>()
</script>

<template>
  <el-card class="component-panel" shadow="never">
    <template #header>
      <div class="panel-header">
        <span>组件库</span>
        <el-tag size="small" type="info">共 {{ components.length }} 个</el-tag>
      </div>
    </template>
    <div class="component-search">
      <el-input
        v-model="keyword"
        clearable
        placeholder="搜索组件名/函数名/描述"
        :prefix-icon="Search"
      />
    </div>
    <div class="component-list">
      <el-tree
        v-if="treeData.length > 0"
        class="component-tree"
        :data="treeData"
        node-key="key"
        :expand-on-click-node="false"
        :default-expand-all="true"
        :props="{ label: 'label', children: 'children' }"
      >
        <template #default="{ data }">
          <div
            v-if="data.type === 'component'"
            class="component-item tree-component-item"
            draggable="true"
            @dragstart.capture="emit('drag-start', data.component, $event)"
          >
            <el-image
              :src="resolveComponentCover(data.component)"
              class="component-icon"
              lazy
              fit="contain"
              :preview-src-list="[]"
            >
              <template #error>
                <el-icon class="component-icon-fallback"><Box /></el-icon>
              </template>
            </el-image>
            <div class="component-info">
              <div class="component-name">{{ data.component.name }}</div>
            </div>
          </div>
          <div v-else class="component-folder">{{ data.label }}</div>
        </template>
      </el-tree>
      <el-empty v-else description="暂无组件" :image-size="80" />
    </div>
  </el-card>
</template>

<style scoped>
.component-panel {
  width: 250px;
  min-width: 250px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
}

.component-panel :deep(.el-card__header) {
  flex: none;
}

.component-panel :deep(.el-card__body) {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  padding: 12px;
}

.panel-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.component-search {
  flex: none;
  margin-bottom: 8px;
}

.component-list {
  flex: 1;
  min-height: 0;
  overflow-x: hidden;
  overflow-y: auto;
  padding: 2px 2px 8px 0;
}

.component-tree {
  min-width: 0;
  background: transparent;
}

.component-tree :deep(.el-tree-node__content) {
  height: auto;
  min-height: 32px;
  align-items: flex-start;
  padding: 2px 0;
}

.component-tree :deep(.el-tree-node__expand-icon) {
  flex: none;
  margin-top: 8px;
}

.component-tree :deep(.el-tree-node__children) {
  overflow: visible;
}

.component-folder {
  min-width: 0;
  padding: 5px 0;
  color: #606266;
  font-size: 13px;
  font-weight: 600;
  line-height: 20px;
  white-space: normal;
  overflow-wrap: anywhere;
}

.component-item {
  width: 100%;
  min-width: 0;
  min-height: 50px;
  box-sizing: border-box;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 8px;
  border: 1px solid #e4e7ed;
  border-radius: 6px;
  background: #fff;
  cursor: move;
  transition: border-color 0.2s, background-color 0.2s, box-shadow 0.2s;
}

.tree-component-item {
  margin: 2px 0;
}

.component-item:hover {
  border-color: #409eff;
  background-color: #f5f9ff;
  box-shadow: 0 1px 4px rgb(64 158 255 / 14%);
}

.component-icon,
.component-icon-fallback {
  width: 38px;
  height: 38px;
  min-width: 38px;
  flex: 0 0 38px;
  box-sizing: border-box;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  background: #fff;
}

.component-icon {
  overflow: hidden;
}

.component-icon :deep(img) {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.component-icon-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #409eff;
  font-size: 20px;
}

.component-info {
  flex: 1;
  min-width: 0;
}

.component-name {
  color: #303133;
  font-size: 13px;
  font-weight: 500;
  line-height: 18px;
  white-space: normal;
  overflow-wrap: anywhere;
}
</style>
