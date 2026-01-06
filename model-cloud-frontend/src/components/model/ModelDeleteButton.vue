<template>
  <el-button
    :type="type"
    :link="link"
    :icon="icon"
    :size="size"
    @click.stop="confirmDelete"
  >
    {{ text }}
  </el-button>
</template>

<script setup lang="ts">
import { ElMessage, ElMessageBox } from 'element-plus'
import { modelApi } from '@/api/model'

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

    const res: any = await modelApi.deleteModel(props.model.id)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      emit('deleted')
    } else {
      ElMessage.error(res.message || '删除失败')
    }
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('删除失败', error)
      ElMessage.error('删除失败')
    }
  }
}

const text = props.text || '删除'
const type = props.type || 'danger'
const size = props.size || 'default'
const link = props.link ?? true
</script>

