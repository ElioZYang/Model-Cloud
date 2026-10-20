<template>
  <section class="online-ide-page">
    <div class="editor-shell">
      <iframe
        :key="iframeKey"
        class="editor-frame"
        :src="editorUrl"
        title="Nimbus 在线代码编辑器"
        allow="clipboard-read; clipboard-write; fullscreen"
        allowfullscreen
        @load="handleFrameLoad"
      />

      <div v-if="isLoading || connectionFailed" class="loading-mask">
        <el-icon v-if="!connectionFailed" class="loading-icon"><Loading /></el-icon>
        <el-icon v-else class="error-icon"><WarningFilled /></el-icon>
        <p>
          {{
            connectionFailed
              ? '无法连接在线代码编辑器'
              : loadTimedOut
                ? '编辑器加载时间较长'
                : '正在加载在线代码编辑器…'
          }}
        </p>
        <span v-if="loadTimedOut || connectionFailed">
          请确认编辑器容器正在运行，并且可以访问 {{ editorUrl }}
        </span>
        <div v-if="loadTimedOut || connectionFailed" class="loading-actions">
          <el-button size="small" @click="reloadEditor">重新加载</el-button>
          <el-button size="small" type="primary" @click="openInNewWindow">
            新窗口打开
          </el-button>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { onBeforeUnmount, ref } from 'vue'
import { Loading, WarningFilled } from '@element-plus/icons-vue'

const DEFAULT_EDITOR_URL = 'http://localhost:8081/'
const configuredEditorUrl = String(import.meta.env.VITE_IDE_URL || '').trim()
const editorUrl = configuredEditorUrl || DEFAULT_EDITOR_URL

const iframeKey = ref(0)
const isLoading = ref(true)
const loadTimedOut = ref(false)
const connectionFailed = ref(false)
const frameLoaded = ref(false)
const connectionConfirmed = ref(false)
let loadingTimer: ReturnType<typeof setTimeout> | undefined

const clearLoadingTimer = () => {
  if (loadingTimer !== undefined) {
    window.clearTimeout(loadingTimer)
    loadingTimer = undefined
  }
}

const startLoadingTimer = () => {
  clearLoadingTimer()
  isLoading.value = true
  loadTimedOut.value = false
  connectionFailed.value = false
  frameLoaded.value = false
  connectionConfirmed.value = false
  loadingTimer = window.setTimeout(() => {
    loadTimedOut.value = true
  }, 15000)
}

const completeLoading = () => {
  clearLoadingTimer()
  isLoading.value = false
  loadTimedOut.value = false
  connectionFailed.value = false
}

const probeEditor = async (attempt: number) => {
  try {
    await fetch(editorUrl, { mode: 'no-cors', cache: 'no-store' })
    if (attempt !== iframeKey.value) return
    connectionConfirmed.value = true
    if (frameLoaded.value) completeLoading()
  } catch {
    if (attempt !== iframeKey.value) return
    clearLoadingTimer()
    isLoading.value = false
    connectionFailed.value = true
  }
}

const handleFrameLoad = () => {
  frameLoaded.value = true
  if (connectionConfirmed.value) completeLoading()
}

const reloadEditor = () => {
  iframeKey.value += 1
  startLoadingTimer()
  void probeEditor(iframeKey.value)
}

const openInNewWindow = () => {
  window.open(editorUrl, '_blank', 'noopener,noreferrer')
}

startLoadingTimer()
void probeEditor(iframeKey.value)

onBeforeUnmount(() => {
  clearLoadingTimer()
})
</script>

<style scoped>
.online-ide-page {
  display: flex;
  flex-direction: column;
  height: calc(100vh - 100px);
  min-height: 520px;
  overflow: hidden;
  background: #ffffff;
  border-radius: 6px;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
}

.editor-shell {
  position: relative;
  flex: 1 1 auto;
  min-height: 0;
  overflow: hidden;
  background: #1e1e1e;
}

.editor-frame {
  display: block;
  width: 100%;
  height: 100%;
  border: 0;
  background: #1e1e1e;
}

.loading-mask {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-direction: column;
  gap: 10px;
  padding: 24px;
  color: #606266;
  text-align: center;
  background: #f5f7fa;
  box-sizing: border-box;
}

.loading-icon {
  font-size: 30px;
  color: #409eff;
  animation: loading-rotate 1.2s linear infinite;
}

.error-icon {
  font-size: 30px;
  color: #f56c6c;
}

.loading-mask p {
  margin: 0;
  color: #303133;
  font-size: 16px;
  font-weight: 600;
}

.loading-mask span {
  max-width: 680px;
  font-size: 13px;
  overflow-wrap: anywhere;
}

.loading-actions {
  display: flex;
  gap: 8px;
  margin-top: 4px;
}

.loading-actions :deep(.el-button + .el-button) {
  margin-left: 0;
}

@keyframes loading-rotate {
  to {
    transform: rotate(360deg);
  }
}

</style>
