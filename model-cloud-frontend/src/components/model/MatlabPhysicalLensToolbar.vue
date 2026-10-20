<template>
  <div class="physical-lens-toolbar" role="group" aria-label="物理构型拓扑透视">
    <span class="physical-lens-title">拓扑透视</span>
    <el-radio-group :model-value="modelValue" size="small" @update:model-value="onChange">
      <el-radio-button label="overview">总览</el-radio-button>
      <el-radio-button label="flow">气路</el-radio-button>
      <el-radio-button label="shaft">轴系</el-radio-button>
      <el-radio-button label="bleed">引气</el-radio-button>
    </el-radio-group>
    <span v-if="modelValue !== 'overview'" class="physical-lens-hint">
      {{ activeCount === 0 ? '当前关系暂无连线 · ' : '' }}拖动部件端口建立当前关系
    </span>
  </div>
</template>

<script setup lang="ts">
import type { PhysicalLensMode } from '@/composables/useMatlabPhysicalLens'

defineProps<{ modelValue: PhysicalLensMode; activeCount: number }>()
const emit = defineEmits<{ 'update:modelValue': [value: PhysicalLensMode] }>()
const onChange = (value: string | number | boolean | undefined) => {
  if (value === 'overview' || value === 'flow' || value === 'shaft' || value === 'bleed') {
    emit('update:modelValue', value)
  }
}
</script>

<style scoped>
.physical-lens-toolbar { display: inline-flex; align-items: center; gap: 8px; margin-left: 8px; vertical-align: middle; }
.physical-lens-title { color: #606266; font-size: 12px; white-space: nowrap; }
.physical-lens-hint { color: #909399; font-size: 12px; white-space: nowrap; }
</style>
