<script setup lang="ts">
import { ref, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { matlabModelDeployApi, type MatlabPlotArtifact } from '@/api/matlab-model-deploy'

export type MatlabArtifactGroup = {
  phase: string
  artifacts: MatlabPlotArtifact[]
}

const props = defineProps<{
  /** 按 design/power/final 分组的图片清单（任务内 ID，不含服务器路径）。 */
  groups: MatlabArtifactGroup[]
  taskId: number | null
  phaseLabel: (phase: string) => string
  /** 弹窗关闭或批次切换时变化，触发 ObjectURL 回收。 */
  resetToken?: number | string
}>()

const activePhase = defineModel<string>('activePhase', { default: '' })

const previewUrls = ref<Record<string, string>>({})
const loading = ref<Record<string, boolean>>({})

watch(() => props.resetToken, () => {
  Object.values(previewUrls.value).forEach((url) => URL.revokeObjectURL(url))
  previewUrls.value = {}
  loading.value = {}
})

const fetchArtifactBlob = async (artifact: MatlabPlotArtifact) => {
  if (!props.taskId) {
    ElMessage.warning('当前结果没有可下载的任务ID')
    return null
  }
  loading.value = { ...loading.value, [artifact.id]: true }
  try {
    return await matlabModelDeployApi.downloadArtifact(props.taskId, artifact.id)
  } catch (error: any) {
    ElMessage.error(error.message || '结果图下载失败')
    return null
  } finally {
    const next = { ...loading.value }
    delete next[artifact.id]
    loading.value = next
  }
}

const handlePreviewArtifact = async (artifact: MatlabPlotArtifact) => {
  const existing = previewUrls.value[artifact.id]
  if (existing) return
  const blob = await fetchArtifactBlob(artifact)
  if (!blob) return
  previewUrls.value = {
    ...previewUrls.value,
    [artifact.id]: URL.createObjectURL(blob)
  }
}

const handleDownloadArtifact = async (artifact: MatlabPlotArtifact) => {
  let url = previewUrls.value[artifact.id]
  let revoke = false
  if (!url) {
    const blob = await fetchArtifactBlob(artifact)
    if (!blob) return
    url = URL.createObjectURL(blob)
    revoke = true
  }
  const anchor = document.createElement('a')
  anchor.href = url
  anchor.download = artifact.fileName || `matlab-${artifact.phase}-${artifact.id}.png`
  anchor.click()
  if (revoke) URL.revokeObjectURL(url)
}
</script>

<template>
  <div v-if="groups.length" class="result-artifact-panel">
    <div class="result-artifact-header">
      <strong>MATLAB 绘图结果</strong>
      <el-tag size="small" type="info">PNG manifest</el-tag>
    </div>
    <el-tabs v-model="activePhase" class="result-artifact-tabs">
      <el-tab-pane
        v-for="group in groups"
        :key="group.phase"
        :label="phaseLabel(group.phase)"
        :name="group.phase"
      >
        <div class="result-artifact-grid">
          <div v-for="artifact in group.artifacts" :key="artifact.id" class="result-artifact-card">
            <div class="result-artifact-name" :title="artifact.fileName">{{ artifact.fileName }}</div>
            <div class="result-artifact-source">{{ artifact.source || 'MATLAB' }}</div>
            <el-image
              v-if="previewUrls[artifact.id]"
              :src="previewUrls[artifact.id]"
              fit="contain"
              class="result-artifact-image"
              :preview-src-list="previewUrls[artifact.id] ? [previewUrls[artifact.id]] : []"
            />
            <el-empty v-else description="点击预览" :image-size="48" />
            <div class="result-artifact-actions">
              <el-button size="small" :loading="loading[artifact.id]" @click="handlePreviewArtifact(artifact)">
                预览
              </el-button>
              <el-button size="small" type="primary" @click="handleDownloadArtifact(artifact)">
                下载PNG
              </el-button>
            </div>
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>
