<template>
  <el-card class="filter-card">
    <el-form :inline="true" class="filter-form">
      <el-form-item label="模型名称">
        <el-input
          v-model="keywordProxy"
          placeholder="搜索模型名称或描述"
          clearable
          @keyup.enter="emitSearch"
        />
      </el-form-item>

      <el-form-item label="标签">
        <el-select
          v-model="tagProxy"
          clearable
          placeholder="选择标签"
          style="width: 160px"
        >
          <el-option
            v-for="label in labelList"
            :key="label.id"
            :label="label.name"
            :value="label.name"
          />
        </el-select>
      </el-form-item>

      <el-form-item v-if="showPublicFilter" label="公开状态">
        <el-select
          v-model="isPublicProxy"
          clearable
          placeholder="全部"
          style="width: 120px"
        >
          <el-option :value="1" label="公开" />
          <el-option :value="0" label="不公开" />
        </el-select>
      </el-form-item>

      <el-form-item>
        <el-button type="primary" :icon="Search" @click="emitSearch">查询</el-button>
        <el-button :icon="Refresh" @click="emitReset">重置</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Search, Refresh } from '@element-plus/icons-vue'
import { modelApi } from '@/api/model'

const props = defineProps<{
  keyword: string
  tag?: string | null
  isPublic?: number | null
  showPublicFilter?: boolean
}>()

const emit = defineEmits<{
  (e: 'update:keyword', value: string): void
  (e: 'update:tag', value: string | null): void
  (e: 'update:isPublic', value: number | null): void
  (e: 'search'): void
  (e: 'reset'): void
}>()

const labelList = ref<any[]>([])

const keywordProxy = computed({
  get: () => props.keyword,
  set: (val: string) => emit('update:keyword', val),
})

const tagProxy = computed({
  get: () => props.tag ?? null,
  set: (val: string | null) => emit('update:tag', val),
})

const isPublicProxy = computed({
  get: () => (props.isPublic === 0 || props.isPublic === 1 ? props.isPublic : null),
  set: (val: number | null) => emit('update:isPublic', val),
})

const fetchLabels = async () => {
  try {
    const res: any = await modelApi.getLabelList()
    if (res.code === 200) {
      labelList.value = res.data || []
    }
  } catch (error) {
    console.error('获取标签列表失败', error)
  }
}

const emitSearch = () => {
  emit('search')
}

const emitReset = () => {
  emit('reset')
}

onMounted(() => {
  fetchLabels()
})
</script>

<style scoped>
.filter-card {
  margin-bottom: 20px;
}

.filter-form {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 16px;
}
</style>


