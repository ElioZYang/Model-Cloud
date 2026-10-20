<script setup lang="ts">
import type { MatlabStructuredError } from '@/api/matlab-model-deploy'
import { formatOriginPath } from '../domain/structuredError'

defineProps<{
  failure: MatlabStructuredError | null
}>()

const visible = defineModel<boolean>('visible', { default: false })

const stageLabel = (stage?: string) => {
  const labels: Record<string, string> = {
    'execute-node': '节点执行',
    validate: '图校验',
    prepare: '资源准备',
    collect: '结果收集',
    project: '结果投影',
    unknown: '未知阶段'
  }
  return labels[stage || 'unknown'] || stage || '未知阶段'
}
</script>

<template>
  <el-dialog
    v-model="visible"
    title="计算失败详情"
    width="640px"
    :close-on-click-modal="false"
  >
    <template v-if="failure">
      <div class="failure-meta">
        <el-tag type="danger">{{ stageLabel(failure.stage) }}</el-tag>
        <el-tag v-if="failure.exceptionIdentifier" type="warning" class="failure-identifier">
          {{ failure.exceptionIdentifier }}
        </el-tag>
      </div>
      <div v-if="formatOriginPath(failure.originPath)" class="failure-origin">
        <div class="failure-origin-label">失败位置</div>
        <el-breadcrumb separator="/">
          <el-breadcrumb-item v-for="(segment, index) in failure.originPath" :key="index">
            {{ segment }}
          </el-breadcrumb-item>
        </el-breadcrumb>
      </div>
      <div v-if="failure.nodeId || failure.sourceNodeId" class="failure-node">
        <span v-if="failure.nodeId">执行节点：<code>{{ failure.nodeId }}</code></span>
        <span v-if="failure.sourceNodeId">来源节点：<code>{{ failure.sourceNodeId }}</code></span>
      </div>
      <div class="failure-message">{{ failure.message || '未提供错误消息' }}</div>
      <el-alert
        type="info"
        :closable="false"
        title="结构化错误沿 originPath 定位到递归层级节点；MATLAB 原生异常标识可用于在原模型中定位函数。"
      />
    </template>
    <el-empty v-else description="暂无失败详情" :image-size="60" />
    <template #footer>
      <el-button @click="visible = false">关闭</el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.failure-meta {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}
.failure-origin {
  margin-bottom: 12px;
}
.failure-origin-label {
  font-size: 12px;
  color: var(--el-text-color-secondary);
  margin-bottom: 4px;
}
.failure-node {
  display: flex;
  flex-direction: column;
  gap: 2px;
  margin-bottom: 12px;
  font-size: 12px;
  color: var(--el-text-color-regular);
}
.failure-message {
  padding: 10px 12px;
  margin-bottom: 12px;
  background: var(--el-fill-color-light);
  border-radius: 4px;
  white-space: pre-wrap;
  word-break: break-word;
  font-size: 13px;
  line-height: 1.6;
}
</style>
