import request from './request'
import type { PhysicalCapabilities, PhysicalAssembly } from '@/features/matlab-modeling/domain/physicalAssembly'

export interface MatlabPort {
  name: string
  type: string
  unit?: string
  shape?: number[]
  dynamicLength?: { source: 'shaftGroups'; defaultValue: number }
  required?: boolean
  defaultValue?: number | string | boolean | number[] | number[][]
  min?: number
  max?: number
  description?: string
  semanticKey?: string
  displayName?: string
}

export interface MatlabComponent {
  modelEntrypoints?: Record<string, string>
  hiddenFromCatalog?: boolean
  id: string
  name: string
  engineType: 'matlab'
  executorType: 'julia-matlab-graph'
  componentKind?: 'scalar' | 'configuration' | 'calculation' | 'model' | 'workflow'
    | 'subsystem' | 'workflowSubsystem' | 'physicalComponent' | 'boundaryPort'
  executionKind?: 'matlabFunction' | 'busCreator' | 'busSelector'
  functionName: string
  description?: string
  library: string
  category: string
  catalogOrder?: number
  coverImage?: string
  fallbackIcon?: string
  inputs: MatlabPort[]
  outputs: MatlabPort[]
  resources?: MatlabResourceDefinition[]
  templateDefinition?: {
    rootSceneId: string
    scenes: Record<string, any>
    physicalAssemblies?: Record<string, PhysicalAssembly>
  }
  assemblyDefaults?: Record<string, any>
  physicalCapabilities?: PhysicalCapabilities
  legacyName?: string
  legacyOrder?: number
}

export interface MatlabResourceDefinition {
  name: string
  type: string
  accept: string[]
  required?: boolean
  description?: string
}

export interface MatlabConfigSchema {
  version: string
  designSheet: string
  materialSheet: string
  designColumns: string[]
  materialColumns: string[]
  requiredVariables: string[]
}

export interface MatlabConfigRecord {
  configId: string
  name: string
  fileName: string
  fileSize: number
  sha256: string
  templateVersion: string
  status: string
  createTime?: string
  summary?: Record<string, number>
}

export interface MatlabExecutionRequest {
  engineType: 'matlab'
  executionPayload: {
    schemaVersion?: 2
    rootSceneId?: string
    nodes: Array<Record<string, any>>
    edges: Array<Record<string, any>>
    scenes?: Array<{
      id: string
      parentSceneId?: string
      title?: string
      boundaryPorts?: Array<Record<string, any>>
      assemblyDefaults?: Record<string, any>
      nodes: Array<Record<string, any>>
      edges: Array<Record<string, any>>
    }>
  }
}

export interface MatlabSimulationTask {
  id: number
  taskId: string
  engineType: 'matlab'
  status: 'pending' | 'running' | 'completed' | 'failed' | 'cancelled'
  progress?: number
  resultData?: string | Record<string, any>
  resultFileUrl?: string
  artifacts?: MatlabPlotArtifact[]
  errorMessage?: string
}

/** matlab-public-result-v1 的结构化错误（后端透传 Python errorDetail）。 */
export interface MatlabStructuredError {
  stage?: string
  originPath?: string[]
  nodeId?: string
  sourceNodeId?: string
  exceptionType?: string
  exceptionIdentifier?: string
  message?: string
  details?: Record<string, any>
}

/** 失败任务 resultData 中的错误投影（新包裹 / 旧 errorDetail 两种形态）。 */
export interface MatlabTaskFailure {
  schemaVersion?: string
  status: 'failed'
  error?: MatlabStructuredError
  errorDetail?: MatlabStructuredError
}

export interface MatlabPlotArtifact {
  id: string
  phase: 'design' | 'power' | 'final' | string
  fileName: string
  source?: string
}

export const matlabModelDeployApi = {
  getComponents() {
    return request.get<MatlabComponent[]>('/business/model-deploy/matlab/components')
  },

  getConfigSchema(componentId?: string) {
    return request.get<MatlabConfigSchema>('/business/model-deploy/matlab/config-schema', { params: { componentId } })
  },

  async downloadConfigTemplate(componentId?: string) {
    const token = localStorage.getItem('token')
    const query = componentId ? `?componentId=${encodeURIComponent(componentId)}` : ''
    const response = await fetch(`/api/business/model-deploy/matlab/config-template${query}`, {
      headers: token ? { Authorization: `Bearer ${token}` } : {}
    })
    if (!response.ok) throw new Error(`模板下载失败(${response.status})`)
    return response.blob()
  },

  uploadConfig(file: File, name: string, componentId?: string) {
    const form = new FormData()
    form.append('file', file)
    form.append('name', name)
    if (componentId) form.append('componentId', componentId)
    return request.post<MatlabConfigRecord>(
      '/business/model-deploy/matlab/configs',
      form
    )
  },

  getMyConfigs() {
    return request.get<MatlabConfigRecord[]>('/business/model-deploy/matlab/configs/my')
  },

  submitCalculation(data: MatlabExecutionRequest) {
    return request.post<number>('/business/model-deploy/simulation/submit', data)
  },

  getTaskStatus(taskId: number) {
    return request.get<MatlabSimulationTask>(
      `/business/model-deploy/simulation/${taskId}/status`
    )
  },

  async downloadArtifact(taskId: number, artifactId: string) {
    const token = localStorage.getItem('token')
    const response = await fetch(
      `/api/business/model-deploy/simulation/${taskId}/artifacts/${encodeURIComponent(artifactId)}`,
      { headers: token ? { Authorization: `Bearer ${token}` } : {} }
    )
    if (!response.ok) throw new Error(`结果图下载失败(${response.status})`)
    return response.blob()
  }
}
