<template>
  <div class="structure-table-toolbar">
    <span>结构体字段</span>
    <el-button-group>
      <el-button size="small" @click="setAllExpanded(true)">全部展开</el-button>
      <el-button size="small" @click="setAllExpanded(false)">全部收起</el-button>
    </el-button-group>
  </div>
  <el-table
    ref="tableRef"
    :data="rows"
    row-key="key"
    :tree-props="{ children: 'children' }"
    :row-class-name="getRowClassName"
    default-expand-all
    border
    stripe
    height="500"
    style="width: 100%"
    empty-text="该输出端口没有返回数据"
  >
    <el-table-column label="字段" min-width="250" show-overflow-tooltip>
      <template #default="{ row }">
        <span :class="{ 'structure-field-name': row.isExpandable }">{{ row.name }}</span>
        <span v-if="row.isObject" class="structure-field-count">包含 {{ row.fieldCount }} 个字段</span>
      </template>
    </el-table-column>
    <el-table-column label="类型" width="145">
      <template #default="{ row }">{{ row.isObject ? '' : row.type }}</template>
    </el-table-column>
    <el-table-column label="值" min-width="320">
      <template #default="{ row }">
        <template v-if="row.isObject"></template>
        <template v-else-if="row.isArray">
          <MatlabArrayTable :value="row.value" :label="row.path" :unit="row.unit" />
        </template>
        <span v-else :title="formatValue(row.value)">{{ formatValue(row.value) }}</span>
      </template>
    </el-table-column>
    <el-table-column label="单位" width="100">
      <template #default="{ row }">{{ row.isObject ? '' : (row.unit || '-') }}</template>
    </el-table-column>
  </el-table>

</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import type { TableInstance } from 'element-plus'
import MatlabArrayTable from './MatlabArrayTable.vue'

type StructureRow = {
  key: string
  name: string
  path: string
  type: string
  value: unknown
  unit?: string
  isArray: boolean
  isObject: boolean
  isExpandable: boolean
  fieldCount: number
  children?: StructureRow[]
}

const props = defineProps<{
  value: unknown
  unitResolver?: (path: string) => string | undefined
}>()
const tableRef = ref<TableInstance>()

const isPlainObject = (value: unknown): value is Record<string, unknown> => {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value)
}

const getArrayShape = (value: unknown): number[] | null => {
  if (!Array.isArray(value)) return []
  if (value.length === 0) return [0]
  const childShapes = value.map((item) => Array.isArray(item) ? getArrayShape(item) : [])
  const firstShape = childShapes[0]
  if (!firstShape || childShapes.some((shape) => shape === null || shape.length !== firstShape.length
    || shape.some((dimension, index) => dimension !== firstShape[index]))) return null
  return [value.length, ...firstShape]
}

const getValueType = (value: unknown) => {
  if (value === null) return 'null'
  if (Array.isArray(value)) {
    const shape = getArrayShape(value)
    if (value.length === 0) return '空数组'
    if (!shape) return `不规则数组 [${value.length}]`
    if (shape.length === 1) return `数组 [${shape[0]}]`
    if (shape.length === 2) return `矩阵 [${shape[0]} × ${shape[1]}]`
    return `数组 [${shape.join(' × ')}]`
  }
  if (isPlainObject(value)) return Object.keys(value).length === 0 ? '空结构体' : '结构体'
  return typeof value
}

const buildRows = (value: unknown, path = ''): StructureRow[] => {
  if (isPlainObject(value)) {
    return Object.entries(value).map(([name, item]) => createRow(name, item, path ? `${path}.${name}` : name))
  }
  return [createRow('值', value, path || 'value')]
}

const createRow = (name: string, value: unknown, path: string): StructureRow => {
  const isObject = isPlainObject(value)
  const fieldCount = isObject ? Object.keys(value).length : 0
  const children = isObject && fieldCount > 0 ? buildRows(value, path) : undefined
  return {
    key: path,
    name,
    path,
    type: getValueType(value),
    value,
    unit: typeof value === 'number' || Array.isArray(value) ? props.unitResolver?.(path) : undefined,
    isArray: Array.isArray(value),
    isObject,
    isExpandable: Boolean(children?.length),
    fieldCount,
    children
  }
}

const rows = computed(() => buildRows(props.value))

const flattenRows = (items: StructureRow[]): StructureRow[] => items.flatMap((row) => [
  row,
  ...(row.children ? flattenRows(row.children) : [])
])

const setAllExpanded = (expanded: boolean) => {
  flattenRows(rows.value).forEach((row) => {
    if (row.isExpandable) tableRef.value?.toggleRowExpansion(row, expanded)
  })
}

const formatValue = (value: unknown) => {
  if (value === null) return 'null'
  if (typeof value === 'string') return value
  if (typeof value === 'number' || typeof value === 'boolean') return String(value)
  if (Array.isArray(value)) return ''
  if (isPlainObject(value)) return Object.keys(value).length === 0 ? '{}' : ''
  return String(value ?? '')
}

const getRowClassName = ({ row }: { row: StructureRow }) => row.isObject ? 'structure-row' : ''
</script>

<style scoped>
.structure-table-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}
.structure-field-name { font-weight: 700; color: var(--el-text-color-primary); }
.structure-field-count { margin-left: 8px; color: var(--el-text-color-secondary); font-size: 12px; }
:deep(.structure-row > td) { background: var(--el-fill-color-lighter) !important; }
</style>
