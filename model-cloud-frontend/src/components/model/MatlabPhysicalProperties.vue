<template>
  <div class="physical-properties">
    <el-alert :title="modeTitle" type="info" :closable="false" show-icon />

    <template v-if="mode === 'shaft' || mode === 'bleed'">
      <el-divider>{{ mode === 'shaft' ? '轴组' : '引气组' }}</el-divider>
      <el-select :model-value="activeGroupId || ''" placeholder="选择关系组" clearable style="width: 100%"
        @change="(id: string) => emit('selectGroup', id || null)">
        <el-option v-for="group in visibleGroups" :key="group.id" :label="group.name" :value="group.id" />
      </el-select>
      <div class="action-row">
        <el-button size="small" :disabled="!selectedNode" @click="emit('createGroup')">新建{{ mode === 'shaft' ? '轴组' : '引气组' }}</el-button>
        <el-button size="small" :disabled="!selectedNode || !activeGroup" @click="emit('addNodeToGroup')">加入当前组</el-button>
        <el-button size="small" :disabled="!selectedNode || !groupMembers.includes(selectedNode.id)" @click="emit('removeNodeFromGroup')">移出当前组</el-button>
      </div>
      <template v-if="activeGroup">
        <el-form label-width="95px" size="small">
          <el-form-item label="组名">
            <el-input :model-value="activeGroup.name" @change="(value: string) => emit('updateGroup', 'name', value)" />
          </el-form-item>
          <el-form-item v-if="mode === 'shaft'" label="电机效率">
            <el-input-number v-if="!Array.isArray(activeGroupParameter('E_motor'))"
              :model-value="optionalNumber(activeGroupParameter('E_motor'))" :controls="false" style="width: 100%"
              :placeholder="assemblyDefaults.E_motor === undefined ? '此轴必填' : undefined"
              @change="(value: number | undefined) => emit('updateGroup', 'E_motor', value)" />
            <el-input v-else :model-value="formatValue(activeGroupParameter('E_motor'))"
              @change="(value: string) => emit('updateGroup', 'E_motor', parseValue(value))" />
          </el-form-item>
          <el-form-item label="组顺序">
            <el-input-number :model-value="activeGroup.order" :controls="false" style="width: 100%"
              @change="(value: number | undefined) => emit('updateGroup', 'order', value)" />
          </el-form-item>
          <el-form-item v-if="mode === 'shaft'" label="机械效率">
            <el-input-number v-if="!Array.isArray(activeGroupParameter('E_mech'))"
              :model-value="optionalNumber(activeGroupParameter('E_mech'))" :controls="false" style="width: 100%"
              :placeholder="assemblyDefaults.E_mech === undefined ? '此轴必填' : undefined"
              @change="(value: number | undefined) => emit('updateGroup', 'E_mech', value)" />
            <el-input v-else :model-value="formatValue(activeGroupParameter('E_mech'))"
              @change="(value: string) => emit('updateGroup', 'E_mech', parseValue(value))" />
          </el-form-item>
        </el-form>
        <div class="member-list">部件：{{ groupMembers.join('、') || '无' }}</div>
        <el-button size="small" type="danger" plain @click="emit('deleteGroup')">删除此组及组内连线</el-button>
      </template>
    </template>

    <el-alert v-if="mode !== 'overview'" type="info" :closable="false" :title="`当前轴组 NS=${shaftGroupCount}，引气组 NW=${bleedGroupCount}`" />

    <template v-if="selectedNode">
      <el-divider>{{ selectedNode.data?.instanceName || selectedNode.label || selectedNode.id }}</el-divider>
      <el-form label-width="95px" size="small">
        <el-form-item v-if="selectedNode.data?.modelEntrypoints" label="耦合轴组">
          <el-select :model-value="motorShaftGroupId || ''" clearable style="width: 100%"
            @change="(value: string) => emit('updateNodeParameter', 'motorShaftGroupId', value)">
            <el-option v-for="group in groups.filter(item => item.kind === 'shaft')" :key="group.id" :label="group.name" :value="group.id" />
          </el-select>
        </el-form-item>
        <el-form-item v-for="key in nodeParameterKeys" :key="key"
          :label="`${physicalParameterDefinition(key)?.label || key}${physicalParameterDefinition(key)?.unit ? ` (${physicalParameterDefinition(key)?.unit})` : ''}`">
          <el-input-number v-if="isNumberParameter(key)"
            :model-value="optionalNumber(selectedNode.data?.assemblyDefaults?.[key])"
            :controls="false" style="width: 100%"
            :placeholder="selectedNode.data?.assemblyDefaults?.[key] === undefined ? '请填写该部件参数' : undefined"
            @change="(value: number | undefined) => emit('updateNodeParameter', key, value)" />
          <el-switch v-else-if="isBooleanParameter(key)"
            :model-value="Boolean(selectedNode.data?.assemblyDefaults?.[key])"
            @change="(value: boolean) => emit('updateNodeParameter', key, value)" />
          <el-input v-else-if="!isComplexParameter(key)"
            :model-value="String(selectedNode.data?.assemblyDefaults?.[key] ?? '')"
            @change="(value: string) => emit('updateNodeParameter', key, value)" />
          <el-input v-else type="textarea" :rows="3"
            :model-value="formatValue(selectedNode.data?.assemblyDefaults?.[key])"
            @change="(value: string) => emit('updateNodeParameter', key, parseValue(value))" />
        </el-form-item>
        <div v-for="key in nodeParameterKeys" :key="`${key}-hint`" class="parameter-hint">
          {{ physicalParameterDefinition(key)?.description }}
          <span v-if="physicalParameterDefinition(key)?.source">来源：{{ physicalParameterDefinition(key)?.source }}</span>
        </div>
        <el-form-item v-if="mode === 'bleed' && !nodeParameterKeys.includes('WA_extraction')" label="WA_extraction">
          <el-input model-value="0" @change="(value: string) => emit('updateNodeParameter', 'WA_extraction', parseValue(value))" />
        </el-form-item>
      </el-form>
      <el-button v-if="mode !== 'overview'" size="small" type="danger" plain @click="emit('deleteNode')">删除部件</el-button>
    </template>

    <template v-if="selectedEdge">
      <el-divider>所选{{ relationLabel }}</el-divider>
      <div class="member-list">{{ selectedEdge.source }} — {{ selectedEdge.target }}</div>
      <el-select v-if="mode === 'flow'" :model-value="selectedEdge.data?.streamRole || ''" style="width: 100%"
        @change="(value: string) => emit('updateStreamRole', value)">
        <el-option label="未指定" value="" />
        <el-option label="核心流 core" value="core" />
        <el-option label="旁通流 bypass" value="bypass" />
      </el-select>
      <el-button v-if="mode !== 'overview'" size="small" type="danger" plain @click="emit('deleteEdge')">删除连线</el-button>
    </template>

    <el-divider>构型级参数</el-divider>
    <el-form label-width="120px" size="small">
      <el-form-item v-for="key in sceneParameterKeys" :key="key" :label="parameterDefinition(key)?.label || key">
        <el-input-number v-if="parameterDefinition(key)?.kind === 'number' || (typeof sceneParameterValue(key) === 'number' && parameterDefinition(key)?.kind !== 'number-list')"
          :model-value="sceneParameterValue(key) as number | undefined" :controls="false" style="width: 100%"
          :placeholder="parameterDefinition(key)?.commonDefault === undefined ? '按构型填写，无通用默认值' : undefined"
          :disabled="mode === 'overview'"
          @change="(value: number | undefined) => emit('updateSceneParameter', key, value)" />
        <el-switch v-else-if="parameterDefinition(key)?.kind === 'boolean' || typeof sceneParameterValue(key) === 'boolean'"
          :model-value="Boolean(sceneParameterValue(key))" :disabled="mode === 'overview'"
          @change="(value: boolean) => emit('updateSceneParameter', key, value)" />
        <el-select v-else-if="parameterDefinition(key)?.kind === 'choice'"
          :model-value="String(sceneParameterValue(key) ?? '')" style="width: 100%" :disabled="mode === 'overview'"
          @change="(value: string) => emit('updateSceneParameter', key, value)">
          <el-option v-for="option in parameterDefinition(key)?.options || []" :key="option.value"
            :label="option.label" :value="option.value" />
        </el-select>
        <el-input v-else-if="parameterDefinition(key)?.kind === 'number-list' || isNumericList(sceneParameterValue(key))"
          :model-value="formatNumberList(sceneParameterValue(key))" :disabled="mode === 'overview'"
          placeholder="逗号分隔，例如 0, 1" @change="(value: string) => emit('updateSceneParameter', key, parseNumberList(value, sceneParameterValue(key)))" />
        <el-input v-else :model-value="String(sceneParameterValue(key) ?? '')" :disabled="mode === 'overview'"
          :placeholder="parameterDefinition(key)?.commonDefault === undefined ? '按原 MATLAB 构型分支填写' : undefined"
          @change="(value: string) => emit('updateSceneParameter', key, value)" />
        <div v-if="parameterDefinition(key)" class="parameter-hint">
          {{ parameterDefinition(key)?.description }}
          <span v-if="parameterDefinition(key)?.source">来源：{{ parameterDefinition(key)?.source }}</span>
        </div>
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { Edge, Node } from '@vue-flow/core'
import type { ShaftOrBleedGroup } from '@/features/matlab-modeling/domain/physicalAssembly'
import {
  assemblyParameterByKey,
  assemblyParameterDisplayValue,
  assemblyParameterKeys,
  physicalComponentParameterByKey,
  physicalComponentParameterDefinitions
} from '@/features/matlab-modeling/domain/assemblyParameterCatalog'

type MatlabRelationGroup = ShaftOrBleedGroup

const relationGroupMembers = (group: ShaftOrBleedGroup): string[] => group.memberNodeIds

const sortedRelationGroups = (groups: ShaftOrBleedGroup[] | undefined, relation: string) =>
  (groups || []).filter((group) => group.kind === relation)
    .sort((a, b) => a.order - b.order || a.id.localeCompare(b.id))
import type { PhysicalLensMode } from '@/composables/useMatlabPhysicalLens'

const props = defineProps<{
  mode: PhysicalLensMode
  selectedNode: Node | null
  selectedEdge: Edge | null
  activeGroupId: string | null
  groups: MatlabRelationGroup[]
  edges: Edge[]
  assemblyDefaults: Record<string, any>
  motorShaftGroupId?: string
}>()
const emit = defineEmits<{
  selectGroup: [id: string | null]
  createGroup: []
  addNodeToGroup: []
  removeNodeFromGroup: []
  updateGroup: [key: string, value: any]
  deleteGroup: []
  updateNodeParameter: [key: string, value: any]
  updateSceneParameter: [key: string, value: any]
  updateStreamRole: [value: string]
  deleteEdge: []
  deleteNode: []
}>()

const modeTitle = computed(() => ({ overview: '总览：查看全部关系', flow: '气路：编辑部件与气流连接', shaft: '轴系：编辑轴组与机械效率', bleed: '引气：编辑引气组与部件引气量' })[props.mode])
const relationLabel = computed(() => ({ overview: '连接', flow: '气路', shaft: '轴系', bleed: '引气' })[props.mode])
const visibleGroups = computed(() => props.mode === 'shaft' || props.mode === 'bleed'
  ? sortedRelationGroups(props.groups, props.mode) : [])
const activeGroup = computed(() => visibleGroups.value.find((group) => group.id === props.activeGroupId))
const groupMembers = computed(() => activeGroup.value ? relationGroupMembers(activeGroup.value) : [])
const shaftGroupCount = computed(() => props.groups.filter(group => group.kind === 'shaft').length)
const bleedGroupCount = computed(() => props.groups.filter(group => group.kind === 'bleed').length)
const activeGroupParameter = (key: 'E_mech' | 'E_motor') => {
  const local = activeGroup.value?.parameters?.[key]
  if (local !== undefined && local !== null) return local
  const global = props.assemblyDefaults[key]
  if (!Array.isArray(global)) return global
  const ordered = [...props.groups].filter(group => group.kind === 'shaft')
    .sort((a, b) => a.order - b.order || a.id.localeCompare(b.id))
  const index = ordered.findIndex(group => group.id === activeGroup.value?.id)
  return index >= 0 ? global[index] : undefined
}
const nodeParameterKeys = computed(() => {
  const legacyName = String(props.selectedNode?.data?.legacyName || '').toLowerCase()
  const instanceKeys = Object.keys(props.selectedNode?.data?.assemblyDefaults || {})
  const requiredKeys = physicalComponentParameterDefinitions(legacyName).map(parameter => parameter.key)
  const knownComponentKeys = ['PRC', 'EFFC', 'PRT', 'EFFT', 'EB', 'HU', 'TO']
  const keys = [...new Set([...requiredKeys, ...instanceKeys])]
    .filter(key => !knownComponentKeys.includes(key) || requiredKeys.includes(key))
  if (props.mode === 'flow') return keys.filter((key) => key !== 'WA_extraction' && key !== 'E_mech')
  if (props.mode === 'bleed') return keys.filter((key) => key === 'WA_extraction')
  return []
})
const sceneParameterKeys = computed(() => assemblyParameterKeys(props.assemblyDefaults, props.mode))
const parameterDefinition = (key: string) => assemblyParameterByKey(key)
const sceneParameterValue = (key: string) => assemblyParameterDisplayValue(key, props.assemblyDefaults)
const physicalParameterDefinition = (key: string) => physicalComponentParameterByKey(
  String(props.selectedNode?.data?.legacyName || ''), key
)
const formatNumberList = (value: unknown) => Array.isArray(value) ? value.join(', ') : String(value ?? '')
const isNumericList = (value: unknown) => Array.isArray(value) && value.every(item => typeof item === 'number')
const parseNumberList = (value: string, previous: unknown) => {
  if (!value.trim()) return undefined
  const parsed = value.split(',').map(item => Number(item.trim()))
  if (!parsed.every(Number.isFinite)) return value
  return parsed.length === 1 && !Array.isArray(previous) ? parsed[0] : parsed
}
const formatValue = (value: any) => typeof value === 'string' ? value : JSON.stringify(value ?? '')
const optionalNumber = (value: unknown) => value === undefined || value === null || value === '' ? undefined : Number(value)
const parseValue = (value: string) => {
  try { return JSON.parse(value) } catch { return value }
}
const parameterValue = (key: string) => props.selectedNode?.data?.assemblyDefaults?.[key]
const isNumberParameter = (key: string) => typeof parameterValue(key) === 'number' || physicalParameterDefinition(key)?.kind === 'number'
const isBooleanParameter = (key: string) => typeof parameterValue(key) === 'boolean'
const isComplexParameter = (key: string) => {
  const value = parameterValue(key)
  return Array.isArray(value) || (value !== null && typeof value === 'object')
}
</script>

<style scoped>
.physical-properties { display: flex; flex-direction: column; gap: 8px; }
.action-row { display: flex; flex-wrap: wrap; gap: 6px; }
.member-list { color: #606266; font-size: 12px; line-height: 1.6; word-break: break-all; }
.parameter-hint { color: #909399; font-size: 11px; line-height: 1.5; margin-top: 2px; }
.parameter-hint span { display: block; }
</style>
