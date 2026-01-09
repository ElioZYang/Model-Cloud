<template>
  <el-button
    :type="type"
    :link="link"
    :icon="icon"
    :size="size"
    :loading="loading"
    :disabled="loading"
    @click.stop="confirmDelete"
  >
    {{ loading ? '删除中...' : text }}
  </el-button>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { modelApi } from '@/api/model'
import { refreshHomeStats } from '@/utils/stats'

const props = defineProps<{
  model: { id: number; name: string }
  text?: string
  type?: 'primary' | 'success' | 'warning' | 'danger' | 'info'
  size?: 'small' | 'default' | 'large'
  link?: boolean
  icon?: any
}>()

const emit = defineEmits<{
  (e: 'deleted'): void
}>()

const loading = ref(false)

const confirmDelete = async () => {
  try {
    await ElMessageBox.confirm(
      `确定要删除模型"${props.model.name}"吗？此操作将无法恢复！`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    )

    // 开始删除，显示加载状态
    loading.value = true
    
    try {
      const res: any = await modelApi.deleteModel(props.model.id)
      if (res.code === 200) {
        ElMessage.success('删除成功')
        await refreshHomeStats()
        emit('deleted')
      } else {
        ElMessage.error(res.message || '删除失败')
      }
    } finally {
      // 无论成功还是失败，都要关闭加载状态
      loading.value = false
    }
  } catch (error: any) {
    // 用户取消操作时，不需要关闭加载状态（因为还没开始加载）
    if (error !== 'cancel') {
      console.error('删除失败', error)
      ElMessage.error('删除失败')
      loading.value = false
    }
  }
}

const text = props.text || '删除'
const type = props.type || 'danger'
const size = props.size || 'default'
const link = props.link ?? true
</script>

