import type { Edge, Node } from '@vue-flow/core'
import { upgradeProjectToV3 } from './projectUpgradeV3'
import type {
  BoundaryPort,
  DataEdge,
  MatlabProjectV3,
  MatlabSceneV3,
  PhysicalAssembly,
  SceneNode
} from './physicalAssembly'

/**
 * MATLAB 建模工程文档编解码（V3：通用子系统 + 物理装配域）。
 *
 * parse 接受 V2 或 V3 文本：V2 经一次性导入器（projectUpgradeV3）升级，
 * 生产代码不再存在 V2 运行路径。根镜像等旧概念已删除。
 */
export type MatlabViewport = { x: number; y: number; zoom: number }
export type MatlabScene = MatlabSceneV3
export type MatlabProject = MatlabProjectV3
export type SavedMatlabProjectNode = SceneNode
export type SavedMatlabProjectEdge = DataEdge
export type MatlabBoundaryPort = BoundaryPort
export type SavedMatlabProjectData = MatlabProjectV3

export const cloneMatlabGraph = <T>(value: T): T => {
  if (value == null) return value
  return JSON.parse(JSON.stringify(value)) as T
}

export const boundaryPortToMatlabPort = (port: BoundaryPort) => ({
  name: port.id,
  type: port.dataType || 'unknown',
  unit: port.unit,
  shape: port.shape,
  dynamicLength: port.dynamicLength,
  required: port.required ?? false,
  defaultValue: port.defaultValue,
  description: port.displayName || port.name,
  semanticKey: port.semanticKey
})

export const makeCompositePortData = (ports: BoundaryPort[]): MatlabCompositePortData => {
  const inputPorts = ports.filter((port) => port.direction === 'input').map(boundaryPortToMatlabPort)
  const outputPorts = ports.filter((port) => port.direction === 'output').map(boundaryPortToMatlabPort)
  return {
    inputPorts,
    outputPorts,
    connectors: [
      ...inputPorts.map((port) => ({ name: port.name, type: 'WorkflowInput' as const })),
      ...outputPorts.map((port) => ({ name: port.name, type: 'WorkflowOutput' as const }))
    ]
  }
}

export type MatlabCompositePortData = {
  inputPorts: Array<{ name: string; type: string; unit?: string; shape?: number[]; dynamicLength?: { source: 'shaftGroups'; defaultValue: number }; required: boolean; defaultValue?: number | string | boolean | number[] | number[][]; description: string; semanticKey?: string }>
  outputPorts: Array<{ name: string; type: string; unit?: string; shape?: number[]; dynamicLength?: { source: 'shaftGroups'; defaultValue: number }; required: boolean; defaultValue?: number | string | boolean | number[] | number[][]; description: string; semanticKey?: string }>
  connectors: Array<{ name: string; type: 'WorkflowInput' | 'WorkflowOutput' }>
}

const numberOr = (value: unknown, fallback: number) => {
  const number = Number(value)
  return Number.isFinite(number) ? number : fallback
}

/** V3 场景（运行时形态）→ 可序列化场景。 */
export const serializeScene = (
  scene: Omit<MatlabSceneV3, 'nodes' | 'dataEdges'> & { nodes: Node[]; dataEdges: Edge[] }
): MatlabSceneV3 => ({
  id: scene.id,
  parentSceneId: scene.parentSceneId,
  title: scene.title,
  nodes: scene.nodes.map(serializeNode),
  dataEdges: scene.dataEdges.map(serializeEdge),
  boundaryPorts: cloneMatlabGraph(scene.boundaryPorts || []),
  viewport: {
    x: numberOr(scene.viewport?.x, 0),
    y: numberOr(scene.viewport?.y, 0),
    zoom: numberOr(scene.viewport?.zoom, 1)
  }
})

const serializeNode = (node: Node): SceneNode => ({
  id: String(node.id),
  componentId: String(node.data?.componentId || ''),
  nodeKind: String(node.data?.nodeKind || node.data?.executionKind || 'matlabFunction'),
  physicalAssemblyId: node.data?.physicalAssemblyId ? String(node.data.physicalAssemblyId) : undefined,
  boundaryDirection: node.data?.boundaryDirection === 'input' || node.data?.boundaryDirection === 'output'
    ? node.data.boundaryDirection : undefined,
  childSceneId: node.data?.childSceneId ? String(node.data.childSceneId) : undefined,
  modelEntrypoints: node.data?.modelEntrypoints ? cloneMatlabGraph(node.data.modelEntrypoints) : undefined,
  activeModes: Array.isArray(node.data?.activeModes) ? [...node.data.activeModes] : undefined,
  instanceName: String(node.data?.instanceName || node.label || ''),
  functionName: String(node.data?.functionName || ''),
  executionKind: node.data?.executionKind ? String(node.data.executionKind) : undefined,
  values: { ...(node.data?.values || {}) },
  resources: { ...(node.data?.resources || {}) },
  legacyOrder: Number.isFinite(Number(node.data?.legacyOrder)) ? Number(node.data.legacyOrder) : undefined,
  legacyName: node.data?.legacyName ? String(node.data.legacyName) : undefined,
  assemblyDefaults: node.data?.assemblyDefaults ? cloneMatlabGraph(node.data.assemblyDefaults) : undefined,
  busConfig: node.data?.busConfig ? cloneMatlabGraph(node.data.busConfig) : undefined,
  selectorConfig: node.data?.selectorConfig ? cloneMatlabGraph(node.data.selectorConfig) : undefined,
  boundaryPorts: Array.isArray(node.data?.boundaryPorts) ? cloneMatlabGraph(node.data.boundaryPorts) : undefined,
  presentation: node.data?.presentationSize ? { size: cloneMatlabGraph(node.data.presentationSize) } : undefined,
  position: { x: numberOr(node.position?.x, 0), y: numberOr(node.position?.y, 0) },
  unresolved: node.data?.unresolved === true
})

const serializeEdge = (edge: Edge): DataEdge => ({
  id: String(edge.id),
  sourceNodeId: String(edge.data?.unresolved
    ? (edge.data.originalSourceNodeId ?? edge.source ?? '')
    : (edge.source || edge.data?.originalSourceNodeId || '')),
  sourcePort: String(edge.data?.unresolved
    ? (edge.data.originalSourceHandle ?? edge.sourceHandle ?? '')
    : (edge.sourceHandle || edge.data?.originalSourceHandle || '')),
  targetNodeId: String(edge.data?.unresolved
    ? (edge.data.originalTargetNodeId ?? edge.target ?? '')
    : (edge.target || edge.data?.originalTargetNodeId || '')),
  targetPort: String(edge.data?.unresolved
    ? (edge.data.originalTargetHandle ?? edge.targetHandle ?? '')
    : (edge.targetHandle || edge.data?.originalTargetHandle || '')),
  unresolved: edge.data?.unresolved === true || undefined
})

export const serializeMatlabProject = (
  scenes: Record<string, Omit<MatlabSceneV3, 'nodes' | 'dataEdges'> & { nodes: Node[]; dataEdges: Edge[] }>,
  physicalAssemblies: Record<string, PhysicalAssembly>,
  rootSceneId: string
): MatlabProjectV3 => ({
  schemaVersion: 3,
  engineType: 'matlab',
  rootSceneId,
  scenes: Object.fromEntries(Object.entries(scenes).map(([id, scene]) => [id, serializeScene({ ...scene, id })])),
  physicalAssemblies: cloneMatlabGraph(physicalAssemblies)
})

const deserializeNode = (node: any, index: number): SceneNode => ({
  id: String(node?.id || ''),
  componentId: String(node?.componentId || node?.data?.componentId || ''),
  nodeKind: String(node?.nodeKind || node?.data?.nodeKind || node?.data?.executionKind || 'matlabFunction'),
  physicalAssemblyId: node?.physicalAssemblyId || node?.data?.physicalAssemblyId
    ? String(node?.physicalAssemblyId || node?.data?.physicalAssemblyId) : undefined,
  boundaryDirection: node?.boundaryDirection === 'input' || node?.boundaryDirection === 'output'
    ? node.boundaryDirection : undefined,
  childSceneId: node?.childSceneId ? String(node.childSceneId) : node?.data?.childSceneId ? String(node.data.childSceneId) : undefined,
  modelEntrypoints: node?.modelEntrypoints || node?.data?.modelEntrypoints,
  activeModes: Array.isArray(node?.activeModes || node?.data?.activeModes)
    ? [...(node?.activeModes || node?.data?.activeModes)] : undefined,
  instanceName: String(node?.instanceName || node?.data?.instanceName || node?.label || ''),
  functionName: String(node?.functionName || node?.data?.functionName || ''),
  executionKind: node?.executionKind || node?.data?.executionKind,
  values: { ...(node?.values || node?.data?.values || {}) },
  resources: { ...(node?.resources || node?.data?.resources || {}) },
  legacyOrder: Number.isFinite(Number(node?.legacyOrder)) ? Number(node.legacyOrder) : undefined,
  legacyName: node?.legacyName || node?.data?.legacyName,
  assemblyDefaults: node?.assemblyDefaults || node?.data?.assemblyDefaults,
  busConfig: node?.busConfig || node?.data?.busConfig,
  selectorConfig: node?.selectorConfig || node?.data?.selectorConfig,
  boundaryPorts: Array.isArray(node?.boundaryPorts) ? cloneMatlabGraph(node.boundaryPorts) : undefined,
  presentation: node?.presentation ? cloneMatlabGraph(node.presentation) : undefined,
  position: node?.position
    ? { x: numberOr(node.position.x, 0), y: numberOr(node.position.y, index * 120) }
    : { x: 0, y: index * 120 },
  unresolved: node?.unresolved === true
})

const deserializeEdge = (edge: any): DataEdge => ({
  id: String(edge?.id || ''),
  // Keep canonical persisted endpoints as the graph contract. Legacy runtime
  // endpoints stay in a compatibility-only field until rebuildProjectGraph
  // can select whichever node IDs actually exist after remapping.
  sourceNodeId: String(edge?.sourceNodeId || edge?.source || ''),
  sourcePort: String(edge?.sourcePort || edge?.sourceHandle || ''),
  targetNodeId: String(edge?.targetNodeId || edge?.target || ''),
  targetPort: String(edge?.targetPort || edge?.targetHandle || ''),
  legacyRuntimeEndpoints: edge?.source != null || edge?.sourceHandle != null
    || edge?.target != null || edge?.targetHandle != null || edge?.legacyRuntimeEndpoints ? {
        source: edge?.source == null
          ? edge?.legacyRuntimeEndpoints?.source : String(edge.source),
        sourceHandle: edge?.sourceHandle == null
          ? edge?.legacyRuntimeEndpoints?.sourceHandle : String(edge.sourceHandle),
        target: edge?.target == null
          ? edge?.legacyRuntimeEndpoints?.target : String(edge.target),
        targetHandle: edge?.targetHandle == null
          ? edge?.legacyRuntimeEndpoints?.targetHandle : String(edge.targetHandle)
      } : undefined,
  unresolved: edge?.unresolved === true || undefined
})

const deserializeScene = (raw: any, fallbackId: string, index: number): MatlabSceneV3 => ({
  id: String(raw?.id || fallbackId),
  parentSceneId: raw?.parentSceneId ? String(raw.parentSceneId) : undefined,
  title: String(raw?.title || raw?.name || `场景${index + 1}`),
  nodes: (Array.isArray(raw?.nodes) ? raw.nodes : []).map(deserializeNode).filter((node: SceneNode) => node.id),
  dataEdges: (Array.isArray(raw?.dataEdges) ? raw.dataEdges : (Array.isArray(raw?.edges) ? raw.edges : []))
    .map(deserializeEdge)
    .map((edge: DataEdge, edgeIndex: number): DataEdge => {
      if (edge.id && edge.sourceNodeId && edge.targetNodeId) return edge
      return {
        ...edge,
        id: edge.id || `unresolved_edge_${index}_${edgeIndex}`,
        sourceNodeId: edge.sourceNodeId || '',
        targetNodeId: edge.targetNodeId || '',
        unresolved: true
      }
    }),
  boundaryPorts: Array.isArray(raw?.boundaryPorts) ? cloneMatlabGraph(raw.boundaryPorts) : [],
  viewport: {
    x: numberOr(raw?.viewport?.x, 0),
    y: numberOr(raw?.viewport?.y, 0),
    zoom: numberOr(raw?.viewport?.zoom, 1)
  }
})

export type ProjectParseResult = {
  project: MatlabProjectV3
  /** V2 升级提示（错误 PMSM 物理子系统等），仅导入时产生。 */
  upgradeWarnings: string[]
  /** 被识别为错误 PMSM 物理子系统的场景 ID（需要用户确认转换提示）。 */
  wrongPhysicalSceneIds: string[]
}

export const parseMatlabProject = (raw: string | null | undefined): ProjectParseResult => {
  const parsed = JSON.parse(raw || '{}') as Record<string, any>
  if (parsed.engineType && parsed.engineType !== 'matlab') throw new Error('该项目不是 MATLAB 项目')
  if (parsed.schemaVersion === 3) {
    const scenes: Record<string, MatlabSceneV3> = {}
    Object.entries(parsed.scenes || {}).forEach(([id, scene], index) => {
      const converted = deserializeScene(scene, id, index)
      scenes[converted.id] = converted
    })
    if (!scenes[parsed.rootSceneId]) {
      throw new Error('工程缺少根场景')
    }
    Object.values(scenes).forEach((scene) => {
      if (scene.parentSceneId && !scenes[scene.parentSceneId]) scene.parentSceneId = parsed.rootSceneId
    })
    return {
      project: {
        schemaVersion: 3,
        engineType: 'matlab',
        rootSceneId: String(parsed.rootSceneId || 'scene_root'),
        scenes,
        physicalAssemblies: cloneMatlabGraph(parsed.physicalAssemblies || {})
      },
      upgradeWarnings: [],
      wrongPhysicalSceneIds: []
    }
  }
  // V2 → V3 一次性导入
  const { project, report } = upgradeProjectToV3(parsed)
  const scenes: Record<string, MatlabSceneV3> = {}
  Object.entries(project.scenes).forEach(([id, scene], index) => {
    scenes[id] = deserializeScene(scene, id, index)
  })
  return {
    project: { ...project, scenes },
    upgradeWarnings: report.warnings,
    wrongPhysicalSceneIds: report.wrongPhysicalSceneIds
  }
}
