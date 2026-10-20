<script setup lang="ts">
export type MatlabBreadcrumbItem = { id: string; title: string }

defineProps<{
  items: MatlabBreadcrumbItem[]
  activeSceneId: string
}>()

const emit = defineEmits<{
  (event: 'navigate', sceneId: string): void
}>()
</script>

<template>
  <el-breadcrumb v-if="items.length > 0" class="scene-breadcrumb" separator="/">
    <el-breadcrumb-item
      v-for="item in items"
      :key="item.id"
      :class="{ 'scene-breadcrumb-current': item.id === activeSceneId }"
      @click="emit('navigate', item.id)"
    >
      {{ item.title }}
    </el-breadcrumb-item>
  </el-breadcrumb>
</template>
