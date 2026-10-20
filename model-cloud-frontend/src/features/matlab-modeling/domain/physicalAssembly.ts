import type { Edge, Node } from '@vue-flow/core'
import type { BusConfig, BusSelectorConfig } from '@/utils/matlabBus'

/**
 * V3 领域类型：通用子系统 + 部件物理能力 + 物理装配域。
 *
 * 核心不变式：
 * - Scene 没有物理类型；物理性属于部件能力与装配域，不属于 Scene。
 * - 数据连线（dataEdges）不携带 relation/streamRole/groupId；
 *   发动机物理关系（flow/shaft/bleed）保存在 PhysicalAssembly 中。
 * - 装配成员与关系使用项目唯一节点 ID，封装/解封装不改变归属。
 */

export type BoundaryPortKind = 'data' | 'flow' | 'shaft' | 'bleed'

export type BoundaryPort = {
  id: string
  name: string
  displayName?: string
  kind: BoundaryPortKind
  direction?: 'input' | 'output'
  dataType?: string
  unit?: string
  shape?: number[]
  dynamicLength?: { source: 'shaftGroups'; defaultValue: number }
  required?: boolean
  defaultValue?: number | string | boolean | number[] | number[][]
  mapping?: {
    childNodeId: string
    childPortId: string
  }
  mappings?: Array<{ childNodeId: string; childPortId: string }>
  semanticKey?: string
  interfaceNodeId?: string
}

export type DataEdge = {
  id: string
  sourceNodeId: string
  sourcePort: string
  targetNodeId: string
  targetPort: string
  /** Input-only compatibility data; stripped when the project is serialized. */
  legacyRuntimeEndpoints?: {
    source?: string
    sourceHandle?: string
    target?: string
    targetHandle?: string
  }
  unresolved?: boolean
}

export type SceneNode = {
  id: string
  componentId: string
  nodeKind: string
  /** Stable reference used by the compile-time engine assembly descriptor. */
  physicalAssemblyId?: string
  boundaryDirection?: 'input' | 'output'
  childSceneId?: string
  modelEntrypoints?: Record<string, string>
  activeModes?: Array<'design' | 'offdesign' | 'thermal'>
  instanceName?: string
  functionName?: string
  executionKind?: string
  values: Record<string, any>
  resources: Record<string, any>
  legacyOrder?: number
  legacyName?: string
  assemblyDefaults?: Record<string, any>
  busConfig?: BusConfig
  selectorConfig?: BusSelectorConfig
  boundaryPorts?: BoundaryPort[]
  position?: { x: number; y: number }
  presentation?: { size?: { width: number; height: number } }
  unresolved?: boolean
}

export type MatlabSceneV3 = {
  id: string
  parentSceneId?: string
  title: string
  nodes: SceneNode[]
  dataEdges: DataEdge[]
  boundaryPorts: BoundaryPort[]
  viewport: { x: number; y: number; zoom: number }
}

export type MatlabProjectV3 = {
  schemaVersion: 3
  engineType: 'matlab'
  rootSceneId: string
  scenes: Record<string, MatlabSceneV3>
  physicalAssemblies: Record<string, PhysicalAssembly>
}

export type StreamRole = 'core' | 'bypass'

export type FlowRelation = {
  id: string
  kind: 'flow'
  sourceNodeId: string
  sourcePortId: string
  targetNodeId: string
  targetPortId: string
  streamRole?: StreamRole
}

export type ShaftRelationGroup = {
  id: string
  kind: 'shaft'
  name: string
  order: number
  memberNodeIds: string[]
  parameters: {
    E_mech?: number
    E_motor?: number
  }
}

export type BleedRelationGroup = {
  id: string
  kind: 'bleed'
  name: string
  order: number
  memberNodeIds: string[]
  parameters?: Record<string, any>
}

export type ShaftOrBleedGroup = ShaftRelationGroup | BleedRelationGroup

export type PhysicalAssembly = {
  id: string
  name: string
  domain: 'aircraft-engine'
  memberNodeIds: string[]
  flowRelations: FlowRelation[]
  shaftGroups: ShaftRelationGroup[]
  bleedGroups: BleedRelationGroup[]
  motorBindings?: Array<{ motorNodeId: string; shaftGroupId: string }>
  initializerBinding: {
    nodeId: string
    inputPort: 'assembly_json'
  }
  defaults: Record<string, unknown>
}

/** 发动机部件的物理能力（来自可信组件目录，不得由前端按名称硬编码）。 */
export type PhysicalPort = {
  id: string
  role?: string
}

export type PhysicalCapabilities = {
  assemblyMember?: boolean
  flow?: {
    inputs: PhysicalPort[]
    outputs: PhysicalPort[]
  }
  shaft?: {
    joinable: boolean
  }
  bleed?: {
    joinable: boolean
  }
}

export const emptyPhysicalAssembly = (id: string, name: string): PhysicalAssembly => ({
  id,
  name,
  domain: 'aircraft-engine',
  memberNodeIds: [],
  flowRelations: [],
  shaftGroups: [],
  bleedGroups: [],
  initializerBinding: { nodeId: '', inputPort: 'assembly_json' },
  defaults: {}
})

/** 目录组件（api 层 MatlabComponent）携带的物理能力读取。 */
export const physicalCapabilitiesOf = (component: {
  physicalCapabilities?: PhysicalCapabilities
} | null | undefined): PhysicalCapabilities | undefined => {
  if (!component?.physicalCapabilities) return undefined
  const caps = component.physicalCapabilities
  return {
    ...(caps.assemblyMember === true ? { assemblyMember: true } : {}),
    flow: caps.flow ? { inputs: caps.flow.inputs || [], outputs: caps.flow.outputs || [] } : undefined,
    shaft: caps.shaft ? { joinable: caps.shaft.joinable === true } : undefined,
    bleed: caps.bleed ? { joinable: caps.bleed.joinable === true } : undefined
  }
}

/** 查找节点所属装配（按成员 ID）。 */
export const findAssemblyByMember = (
  assemblies: Record<string, PhysicalAssembly>,
  nodeId: string
): PhysicalAssembly | undefined => (
  Object.values(assemblies).find((assembly) => assembly.memberNodeIds.includes(nodeId))
)

/** 运行时场景：V3 场景 + Vue Flow 运行时对象（无 kind）。 */
export type RuntimeSceneV3 = Omit<MatlabSceneV3, 'nodes' | 'dataEdges'> & {
  nodes: Node[]
  dataEdges: Edge[]
}
