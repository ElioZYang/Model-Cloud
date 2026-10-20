<template>
  <div class="array-view">
    <template v-if="isScalarArray">
      <span v-if="!items.length" class="array-empty">[]</span>
      <div v-else-if="isOneDimensional" class="array-preview-scroll">
        <table class="array-data-table array-preview-table" :style="{ width: `${previewVector.length * cellWidth}px` }">
          <colgroup><col v-for="(_, index) in previewVector" :key="index" :style="{ width: `${cellWidth}px` }" /></colgroup>
          <thead><tr><th v-for="(_, index) in previewVector" :key="index">[{{ index }}]</th></tr></thead>
          <tbody><tr>
            <td v-for="(item, index) in previewVector" :key="index">
              <span class="array-cell-value" :title="formatCell(item)">{{ formatCell(item) }}</span>
            </td>
          </tr></tbody>
        </table>
      </div>
      <div v-else-if="isTwoDimensional" class="array-preview-scroll">
        <table class="array-data-table array-preview-table" :style="{ width: tableWidth(previewColumns.length) }">
          <colgroup>
            <col :style="{ width: `${indexWidth}px` }" />
            <col v-for="column in previewColumns" :key="column" :style="{ width: `${cellWidth}px` }" />
          </colgroup>
          <thead><tr><th>#</th><th v-for="column in previewColumns" :key="column">{{ column }}</th></tr></thead>
          <tbody>
            <tr v-for="(row, rowIndex) in previewMatrix" :key="rowIndex">
              <th>{{ rowIndex }}</th>
              <td v-for="column in previewColumns" :key="column">
                <span class="array-cell-value" :title="formatCell(getMatrixCell(row, column))">{{ formatCell(getMatrixCell(row, column)) }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>
    <div class="array-preview-footer">
      <span class="array-size-hint">{{ sizeLabel }}<span v-if="unit"> [{{ unit }}]</span><template v-if="!isScalarArray"> · 复杂数组</template></span>
      <span v-if="previewRange" class="array-size-hint">{{ previewRange }}</span>
      <el-button v-if="isArray" link type="primary" size="small" @click="openFullView">查看完整表格</el-button>
    </div>

    <el-dialog
      v-model="dialogVisible"
      :title="`${label || '数组'} · ${sizeLabel}`"
      width="min(900px, calc(100vw - 32px))"
      append-to-body
      align-center
      destroy-on-close
      class="matlab-array-dialog"
    >
      <p class="array-index-hint">索引从 0 开始；悬停单元格可查看完整值。</p>
      <div v-if="leadingDimensions.length" class="slice-controls">
        <span>高维切片：</span>
        <el-select v-for="(dimension, index) in leadingDimensions" :key="index" v-model="sliceIndices[index]" size="small">
          <el-option v-for="item in dimension" :key="item - 1" :label="String(item - 1)" :value="item - 1" />
        </el-select>
      </div>
      <div class="full-array-scroll">
        <span v-if="!items.length" class="array-empty">[]</span>
        <table v-else-if="usesMatrixTable" class="array-data-table" :style="{ width: tableWidth(fullColumns.length) }">
          <colgroup>
            <col :style="{ width: `${indexWidth}px` }" />
            <col v-for="column in fullColumns" :key="column" :style="{ width: `${cellWidth}px` }" />
          </colgroup>
          <thead>
            <tr><th>#</th><th v-for="column in fullColumns" :key="column">{{ column }}</th></tr>
          </thead>
          <tbody>
            <tr v-for="(row, index) in pagedMatrix" :key="index">
              <th>{{ matrixPageStart + index }}</th>
              <td v-for="column in fullColumns" :key="column">
                <span class="array-cell-value" :title="formatCell(getMatrixCell(row, column))">{{ formatCell(getMatrixCell(row, column)) }}</span>
              </td>
            </tr>
          </tbody>
        </table>
        <table v-else class="array-data-table" :style="{ width: tableWidth(1) }">
          <colgroup><col :style="{ width: `${indexWidth}px` }" /><col :style="{ width: `${cellWidth}px` }" /></colgroup>
          <thead><tr><th>索引</th><th>值</th></tr></thead>
          <tbody>
            <tr v-for="(item, index) in pagedVector" :key="index">
              <th>{{ vectorPageStart + index }}</th>
              <td><span class="array-cell-value" :title="formatCell(item)">{{ formatCell(item) }}</span></td>
            </tr>
          </tbody>
        </table>
      </div>
      <el-pagination
        v-if="pageCount > 1"
        v-model:current-page="currentPage"
        layout="prev, pager, next, total"
        :page-size="pageSize"
        :total="pageTotal"
        class="array-pagination"
      />
      <template #footer>
        <el-button @click="dialogVisible = false">关闭</el-button>
        <el-button type="primary" @click="copyCurrentTable">复制表格</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { ElMessage } from 'element-plus'

const props = defineProps<{ value: unknown; label?: string; unit?: string }>()
const unit = computed(() => props.unit || '')
const dialogVisible = ref(false)
const currentPage = ref(1)
const pageSize = 50
const sliceIndices = ref<number[]>([])
const cellWidth = 120
const indexWidth = 40
const tableWidth = (columns: number) => `${indexWidth + columns * cellWidth}px`

const isArray = computed(() => Array.isArray(props.value))
const items = computed<unknown[]>(() => Array.isArray(props.value) ? props.value : [])
const isScalar = (value: unknown): boolean => !Array.isArray(value) && (value === null || ['number', 'string', 'boolean'].includes(typeof value))
const isScalarArray = computed(() => {
  const visit = (value: unknown): boolean => Array.isArray(value) ? value.every(visit) : isScalar(value)
  return isArray.value && visit(props.value)
})

const shapeOf = (value: unknown): number[] | null => {
  if (!Array.isArray(value)) return []
  if (!value.length) return [0]
  const children = value.map(shapeOf)
  const first = children[0]
  if (!first || children.some((shape) => shape === null || shape.length !== first.length || shape.some((n, i) => n !== first[i]))) return null
  return [value.length, ...first]
}
const shape = computed(() => shapeOf(props.value))
const isOneDimensional = computed(() => isScalarArray.value && shape.value?.length === 1)
const isTwoDimensional = computed(() => {
  if (!isScalarArray.value) return false
  return items.value.length > 0 && items.value.every((row) => Array.isArray(row) && row.every(isScalar))
})
const leadingDimensions = computed(() => isScalarArray.value && shape.value && shape.value.length > 2 ? shape.value.slice(0, -2) : [])
const usesMatrixTable = computed(() => isTwoDimensional.value || leadingDimensions.value.length > 0)
const sizeLabel = computed(() => {
  if (!isArray.value) return '非数组'
  if (!shape.value) return `不规则数组 [${(props.value as unknown[]).length}]`
  if (shape.value.length === 1) return `数组 [${shape.value[0]}]`
  if (shape.value.length === 2) return `矩阵 [${shape.value[0]} × ${shape.value[1]}]`
  return `数组 [${shape.value.join(' × ')}]`
})
const previewVector = computed(() => items.value.slice(0, 8))

const currentMatrix = computed<unknown[][]>(() => {
  if (!usesMatrixTable.value) return []
  let matrix: unknown = props.value
  for (let index = 0; index < leadingDimensions.value.length; index++) {
    const selectedIndex = sliceIndices.value[index] ?? 0
    if (!Array.isArray(matrix) || selectedIndex < 0 || selectedIndex >= matrix.length) return []
    matrix = matrix[selectedIndex]
  }
  return Array.isArray(matrix) && matrix.every(Array.isArray) ? matrix : []
})
const fullColumns = computed(() => Array.from({ length: currentMatrix.value.reduce((width, row) => Math.max(width, row.length), 0) }, (_, i) => i))
const previewColumns = computed(() => fullColumns.value.slice(0, 6))
const previewMatrix = computed(() => currentMatrix.value.slice(0, 6))
const previewRange = computed(() => {
  if (isOneDimensional.value && items.value.length > 8) return `已显示索引 0–7，共 ${items.value.length} 项`
  if (isTwoDimensional.value && (currentMatrix.value.length > 6 || fullColumns.value.length > 6)) {
    return `已显示前 ${previewMatrix.value.length} 行 × ${previewColumns.value.length} 列，共 ${currentMatrix.value.length} 行 × ${fullColumns.value.length} 列`
  }
  return ''
})
const pageTotal = computed(() => usesMatrixTable.value ? currentMatrix.value.length : items.value.length)
const pageCount = computed(() => Math.ceil(pageTotal.value / pageSize))
const vectorPageStart = computed(() => (currentPage.value - 1) * pageSize)
const matrixPageStart = computed(() => (currentPage.value - 1) * pageSize)
const pagedVector = computed(() => items.value.slice(vectorPageStart.value, vectorPageStart.value + pageSize))
const pagedMatrix = computed(() => currentMatrix.value.slice(matrixPageStart.value, matrixPageStart.value + pageSize))

const getMatrixCell = (row: unknown[], column: number) => column < row.length ? row[column] : undefined
const formatCell = (value: unknown) => {
  if (value === undefined) return '无元素'
  if (value === null) return 'null'
  if (typeof value === 'string') return value
  if (typeof value === 'object') {
    try { return JSON.stringify(value) } catch { return '[复杂值]' }
  }
  return String(value)
}
const openFullView = () => {
  currentPage.value = 1
  sliceIndices.value = leadingDimensions.value.map(() => 0)
  dialogVisible.value = true
}
const copyCurrentTable = async () => {
  const rows = usesMatrixTable.value
    ? pagedMatrix.value.map((row, i) => [matrixPageStart.value + i, ...fullColumns.value.map((column) => formatCell(getMatrixCell(row, column)))].join('\t'))
    : pagedVector.value.map((item, i) => `${vectorPageStart.value + i}\t${formatCell(item)}`)
  try { await navigator.clipboard.writeText(rows.join('\n')); ElMessage.success('表格内容已复制') } catch { ElMessage.warning('复制失败，请手动复制') }
}
watch([() => props.value, () => props.label], () => {
  dialogVisible.value = false
  currentPage.value = 1
  sliceIndices.value = []
})
watch(sliceIndices, () => { currentPage.value = 1 }, { deep: true })
</script>

<style scoped>
.array-view { width: 100%; min-width: 0; max-width: 100%; }
.array-preview-scroll { width: 100%; max-width: 100%; min-width: 0; overflow-x: auto; }
.array-preview-footer { display: flex; align-items: center; flex-wrap: wrap; gap: 4px 8px; margin-top: 6px; }
.array-size-hint, .array-index-hint { color: var(--el-text-color-secondary); font-size: 12px; }
.array-index-hint { margin: 0 0 12px; }
.slice-controls { display: flex; align-items: center; gap: 8px; margin-bottom: 12px; flex-wrap: wrap; }
.slice-controls .el-select { width: 90px; }
.full-array-scroll { max-width: 100%; max-height: 55vh; overflow: auto; }
.array-data-table { border-collapse: collapse; table-layout: fixed; font-size: 13px; }
.array-data-table th, .array-data-table td { box-sizing: border-box; border: 1px solid var(--el-border-color-light); padding: 6px; white-space: nowrap; text-align: right; }
.array-data-table th { background: var(--el-fill-color-lighter); color: var(--el-text-color-secondary); text-align: center; overflow: hidden; text-overflow: ellipsis; }
.array-cell-value { display: block; min-width: 0; width: 100%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.array-preview-table { font-size: 12px; }
.array-preview-table th, .array-preview-table td { padding: 3px 6px; }
.array-pagination { justify-content: center; margin-top: 12px; }
:global(.matlab-array-dialog) { max-height: calc(100vh - 32px); display: flex; flex-direction: column; }
:global(.matlab-array-dialog .el-dialog__body) { min-height: 0; overflow: auto; }
</style>
