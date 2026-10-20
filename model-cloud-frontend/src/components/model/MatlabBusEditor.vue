<template>
  <div class="bus-editor">
    <el-form-item label="Bus类型">
      <el-select v-model="mode" size="small" style="width: 100%" @change="emitConfig">
        <el-option label="匿名Bus" value="anonymous" />
        <el-option label="命名Bus" value="named" />
      </el-select>
    </el-form-item>
    <el-form-item v-if="mode === 'named'" label="结构类型">
      <el-select v-model="schemaRef" placeholder="选择已注册结构" style="width: 100%" @change="emitConfig">
        <el-option v-for="(fields, schema) in structureDefinitions" :key="schema" :label="schema" :value="schema">
          <span>{{ schema }}（{{ fields.length }} 个字段）</span>
        </el-option>
      </el-select>
    </el-form-item>
    <el-form-item label="Bus名称">
      <el-input v-model="busName" placeholder="Bus名称" @change="emitConfig" />
    </el-form-item>

    <template v-if="nodeKind === 'busCreator'">
      <el-divider>输入字段</el-divider>
      <div v-for="(field, index) in fields" :key="field.id" class="bus-field-row">
        <el-input v-model="field.label" size="small" placeholder="信号名称" @change="markManual(field)" />
        <div class="field-contract" :title="field.path">
          <span>{{ field.dataType === 'unknown' ? '待连接' : field.dataType }}</span>
          <span v-if="field.shape?.length">[{{ field.shape.join(' × ') }}]</span>
          <span v-if="field.unit">{{ field.unit }}</span>
        </div>
        <el-tag size="small" :type="field.contractStatus === 'invalid' ? 'danger' : field.inferred ? 'success' : 'info'">
          {{ field.contractStatus === 'invalid' ? '无效' : field.inferred ? '已继承' : '待连接' }}
        </el-tag>
        <el-button size="small" text @click="restoreAutoName(field)">自动命名</el-button>
        <el-button size="small" type="danger" text @click="removeField(index)">删除</el-button>
      </div>
      <el-button size="small" type="primary" plain @click="addField">添加字段</el-button>
    </template>

    <template v-else>
      <el-divider>选择输出字段</el-divider>
      <el-empty v-if="availableFields.length === 0" :description="availableFieldsHint" :image-size="50" />
      <el-checkbox-group v-model="selectedIds" @change="emitConfig">
        <el-checkbox v-for="field in availableFields" :key="field.id" :label="field.id">
          {{ field.path }}{{ field.unit ? ` [${field.unit}]` : '' }}
        </el-checkbox>
      </el-checkbox-group>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import type { BusConfig, BusField, BusSelectorConfig } from '@/utils/matlabBus'
import { BUS_STRUCTURE_DEFINITIONS, cloneBusFields, nextSignalName, validBusPath } from '@/utils/matlabBus'

const props = defineProps<{
  nodeKind: 'busCreator' | 'busSelector'
  config?: BusConfig
  selectorConfig?: BusSelectorConfig
  availableFields?: BusField[]
}>()

const emit = defineEmits<{
  (event: 'update:config', value: BusConfig): void
  (event: 'update:selectorConfig', value: BusSelectorConfig): void
}>()

const mode = ref(props.config?.schemaMode || 'anonymous')
const schemaRef = ref(props.config?.schemaRef || '')
const busName = ref(props.config?.name || '')
const fields = ref<BusField[]>(cloneBusFields(props.config?.fields))
const selectedIds = ref<string[]>(
  cloneBusFields(props.selectorConfig?.selectedFields).map((field) => field.id)
)

const availableFields = computed(() => cloneBusFields(props.availableFields))
const structureDefinitions = BUS_STRUCTURE_DEFINITIONS
const availableFieldsHint = computed(() => availableFields.value.length > 0
  ? ''
  : '请先连接已声明字段的Bus Creator；未注册结构不会猜测字段')

watch(() => props.config, (value) => {
  mode.value = value?.schemaMode || 'anonymous'
  schemaRef.value = value?.schemaRef || ''
  busName.value = value?.name || ''
  fields.value = cloneBusFields(value?.fields)
}, { deep: true })

watch(() => props.selectorConfig, (value) => {
  selectedIds.value = cloneBusFields(value?.selectedFields).map((field) => field.id)
}, { deep: true })

const emitConfig = () => {
  if (props.nodeKind === 'busCreator') {
    emit('update:config', {
      schemaMode: mode.value as 'anonymous' | 'named',
      schemaRef: schemaRef.value || undefined,
      name: busName.value || undefined,
      fields: cloneBusFields(fields.value)
    })
    return
  }
  emit('update:selectorConfig', {
    sourceSchemaRef: props.selectorConfig?.sourceSchemaRef,
    selectedFields: availableFields.value.filter((field) => selectedIds.value.includes(field.id))
  })
}

const markManual = (field: BusField) => {
  const name = String(field.label || '').trim()
  field.label = name
  field.path = name
  field.nameMode = 'manual'
  field.contractStatus = validBusPath(name) ? (field.inferred ? 'inferred' : 'pending') : 'invalid'
  emitConfig()
}

const restoreAutoName = (field: BusField) => {
  field.nameMode = 'auto'
  field.label = nextSignalName(fields.value.filter((candidate) => candidate.id !== field.id))
  field.path = field.label
  emitConfig()
}

const addField = () => {
  const id = `field_${Date.now()}_${fields.value.length + 1}`
  const name = nextSignalName(fields.value)
  fields.value.push({
    id,
    path: name,
    label: name,
    nameMode: 'auto',
    dataType: 'unknown',
    contractStatus: 'pending',
    required: true,
    inputPortId: `bus_in_${id}`,
    outputPortId: `bus_out_${id}`
  })
  emitConfig()
}

const removeField = (index: number) => {
  fields.value.splice(index, 1)
  emitConfig()
}
</script>

<style scoped>
.bus-editor { padding-bottom: 8px; }
.bus-field-row { display: grid; grid-template-columns: minmax(100px, 1fr) minmax(120px, 1.2fr) 58px 58px 42px; gap: 6px; margin-bottom: 8px; align-items: center; }
.field-contract { min-width: 0; overflow: hidden; color: #606266; font-size: 12px; white-space: nowrap; text-overflow: ellipsis; }
.bus-editor :deep(.el-checkbox) { display: flex; margin: 4px 0; white-space: normal; }
</style>
