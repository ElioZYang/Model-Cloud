export type ResultValueType = 'scalar' | 'vector' | 'matrix' | 'ndarray' | 'array'

export type ResultVariable = {
  key: string
  group: string
  label: string
  unit?: string
  kind: 'input' | 'output'
  valueType: ResultValueType
  shape: number[]
}

export const inferResultUnit = (path: string) => {
  // Parent names such as MISSION_power describe containers, not this field's unit.
  const normalized = (path.split('.').pop() || path).toLowerCase()
  if (normalized.endsWith('_mps') || normalized.includes('_speed_mps')) return 'm/s'
  if (normalized.endsWith('_kw') || normalized.includes('_power_kw')) return 'kW'
  if (normalized.endsWith('_kn') || normalized.includes('_thrust_kn')) return 'kN'
  if (normalized.endsWith('_kg_s') || normalized.includes('_mass_flow_kg_s')) return 'kg/s'
  if (normalized.includes('thermal_resistance')) return 'K/W'
  if (normalized.includes('temperature_k')) return 'K'
  if (normalized.includes('pressure_pa')) return 'Pa'
  if (normalized.includes('corrected_mass_flow')) return 'kg/s'
  if (normalized.includes('pressure_ratio')) return '-'
  if (normalized.includes('efficiency')) return '-'
  if (normalized.includes('speed') || normalized.includes('rpm')) return 'rpm'
  if (normalized.includes('loss') || normalized.includes('power')) return 'W'
  if (normalized.includes('mass')) return 'kg'
  if (normalized.includes('torque')) return 'N·m'
  if (normalized.includes('temperature') || normalized.includes('temp_')) return '°C'
  if (normalized.includes('stator_od') || normalized.includes('stator_id')
    || normalized.includes('rotor_od') || normalized.includes('rotor_id')
    || normalized.includes('core_length') || normalized.includes('air_gap')
    || normalized.includes('housing_od') || normalized.includes('cgv_')) return 'mm'
  if (normalized.includes('voltage')) return 'V'
  if (normalized.includes('current')) return 'A'
  if (normalized.includes('resistance')) return 'Ω'
  return undefined
}

const isNumericLeaf = (value: unknown): value is number | null => value === null || typeof value === 'number'

export const isNumericArray = (value: unknown): boolean => {
  if (!Array.isArray(value)) return isNumericLeaf(value)
  return value.every(isNumericArray)
}

export const getArrayShape = (value: unknown): number[] | null => {
  if (!Array.isArray(value)) return []
  if (value.length === 0) return [0]
  const childShapes = value.map((item) => Array.isArray(item) ? getArrayShape(item) : [])
  const first = childShapes[0]
  if (!first || childShapes.some((shape) => shape === null || shape.length !== first.length
    || shape.some((dimension, index) => dimension !== first[index]))) return null
  return [value.length, ...first]
}

export const classifyArray = (value: unknown): Pick<ResultVariable, 'valueType' | 'shape'> => {
  const shape = getArrayShape(value)
  if (!isNumericArray(value) || !shape) return { valueType: 'array', shape: shape || [] }
  if (shape.length === 1) return { valueType: 'vector', shape }
  if (shape.length === 2) return { valueType: 'matrix', shape }
  return { valueType: 'ndarray', shape }
}

export const formatArrayShape = (shape: number[]) => shape.length ? `[${shape.join(' × ')}]` : '不规则数组'

export const collectResultVariables = (
  value: unknown,
  path: string,
  nodeId: string,
  group: string,
  variables: ResultVariable[],
  values: Record<string, unknown>,
  depth = 0
) => {
  if (depth > 14) return
  if (Array.isArray(value)) {
    const arrayInfo = classifyArray(value)
    const key = `${nodeId}:output:${path}`
    variables.push({ key, group, label: path, kind: 'output', unit: inferResultUnit(path), ...arrayInfo })
    values[key] = value
    return
  }
  if (typeof value === 'number' && Number.isFinite(value)) {
    const key = `${nodeId}:output:${path}`
    variables.push({ key, group, label: path, kind: 'output', unit: inferResultUnit(path), valueType: 'scalar', shape: [] })
    values[key] = value
    return
  }
  if (value && typeof value === 'object') {
    Object.entries(value as Record<string, unknown>).forEach(([name, child]) => {
      collectResultVariables(child, path ? `${path}.${name}` : name, nodeId, group, variables, values, depth + 1)
    })
  }
}

export const toPlotValue = (value: unknown): number | null => typeof value === 'number' && Number.isFinite(value) ? value : null

export const highDimensionalRows = (value: unknown) => {
  const rows: Array<{ indices: number[]; data: Array<number | null> }> = []
  const visit = (current: unknown, indices: number[]) => {
    if (!Array.isArray(current) || current.length === 0) return
    if (!Array.isArray(current[0])) {
      rows.push({ indices, data: current.map(toPlotValue) })
      return
    }
    current.forEach((item, index) => visit(item, [...indices, index]))
  }
  visit(value, [])
  return rows
}

export const toCsvCell = (value: unknown) => {
  const text = value == null ? '' : typeof value === 'object' ? JSON.stringify(value) : String(value)
  return `"${text.replace(/"/g, '""')}"`
}

export const flattenArrayForCsv = (value: unknown, indices: number[] = []): Array<{ indices: number[]; value: unknown }> => {
  if (!Array.isArray(value)) return [{ indices, value }]
  return value.flatMap((item, index) => flattenArrayForCsv(item, [...indices, index]))
}

import type { ComputedRef, Ref } from 'vue'
import type { MatlabPlotArtifact, MatlabPort } from '@/api/matlab-model-deploy'

type ResultNode = {
  id: string
  instanceName: string
  componentName: string
  originPath?: string
  ports: Array<{ key: string; name: string; hasValue: boolean; value?: unknown }>
}

type ResultPort = { key: string; name: string; hasValue: boolean; value?: unknown }

export type MatlabResultsDialogBindings = {
  resultArtifactGroups: ComputedRef<Array<{ phase: string; artifacts: MatlabPlotArtifact[] }>>
  artifactPhaseLabel: (phase: string) => string
  activeArtifactPhase: Ref<string>
  resultDialogVisible: Ref<boolean>
  resultTab: Ref<string>
  selectedResultVariables: Ref<string[]>
  selectedPlotVariables: ComputedRef<ResultVariable[]>
  resultVariableGroups: ComputedRef<Array<{ group: string; variables: ResultVariable[] }>>
  expandedResultGroups: Ref<string[]>
  selectedLineArrayVariables: ComputedRef<ResultVariable[]>
  resultValues: Ref<Record<string, unknown>>
  selectedArrayVariables: ComputedRef<ResultVariable[]>
  resultVariables: Ref<ResultVariable[]>
  activeResultNodeId: Ref<string>
  handleResultNodeSelect: (nodeId: string | number) => void
  availableResultNodes: ComputedRef<ResultNode[]>
  activeResultPorts: ComputedRef<ResultPort[]>
  activeResultPortKey: Ref<string>
  handleResultPortSelect: (portKey: string) => void
  activeResultNode: ComputedRef<ResultNode | null>
  activeResultPort: ComputedRef<ResultPort | null>
  resultBatchId: Ref<number>
  lastWorkflowResult: Ref<Record<string, any> | null>
  formattedWorkflowResult: ComputedRef<string>
  generatedJuliaCode: Ref<string>
  copyGeneratedJuliaCode: () => Promise<void>
  simulationLogs: Ref<Array<{ time: string; type: string; message: string }>>
  lastTaskId: Ref<number | null>
}

export type SubmittedWorkflowNode = {
  id: string
  instanceName: string
  componentName: string
  outputPorts: MatlabPort[]
  originPath?: string
  sceneId?: string
}

export type ResultNodeView = {
  id: string
  instanceName: string
  componentName: string
  originPath?: string
  ports: Array<{
    key: string
    name: string
    hasValue: boolean
    value?: unknown
  }>
}

export type ResultPortView = {
  key: string
  name: string
  hasValue: boolean
  value?: unknown
}

export const parseResult = (raw: unknown): Record<string, any> | null => {
  if (!raw) return null
  if (typeof raw === 'string') {
    try {
      return JSON.parse(raw)
    } catch {
      return null
    }
  }
  return typeof raw === 'object' ? raw as Record<string, any> : null
}

export const normalizePlotArtifacts = (raw: unknown): MatlabPlotArtifact[] => {
  const parsed = parseResult(raw)
  const source = parsed?.plotArtifacts || parsed?.artifacts || parsed?.plotManifest || parsed?.plot_artifacts
  if (!Array.isArray(source)) return []
  return source.flatMap((item: any) => {
    if (!item || typeof item !== 'object' || !item.id || !item.fileName) return []
    return [{
      id: String(item.id),
      phase: String(item.phase || 'final'),
      fileName: String(item.fileName),
      source: item.source == null ? undefined : String(item.source)
    }]
  })
}

export const displayResultOriginPath = (value: unknown, fallback?: string) => {
  if (Array.isArray(value)) {
    const parts = value.map((item) => String(item || '').trim()).filter(Boolean)
    if (parts.length > 0) return parts.join(' / ')
  } else if (typeof value === 'string' && value.trim()) {
    return value.trim()
  }
  return fallback
}

export const publicOutputEntries = (value: unknown): Array<{ name: string; value: unknown; originPath?: string }> => {
  if (Array.isArray(value)) {
    return value.flatMap((item: any, index) => {
      if (!item || typeof item !== 'object') return []
      const name = String(item.name || item.outputName || `output_${index + 1}`)
      return [{
        name,
        value: Object.prototype.hasOwnProperty.call(item, 'value') ? item.value : item.output,
        originPath: displayResultOriginPath(item.originPath)
      }]
    })
  }
  if (!value || typeof value !== 'object') return []
  return Object.entries(value as Record<string, any>).map(([name, item]) => ({
    name,
    value: item && typeof item === 'object' && Object.prototype.hasOwnProperty.call(item, 'value')
      ? item.value : item,
    originPath: displayResultOriginPath(item && typeof item === 'object' ? item.originPath : undefined)
  }))
}
