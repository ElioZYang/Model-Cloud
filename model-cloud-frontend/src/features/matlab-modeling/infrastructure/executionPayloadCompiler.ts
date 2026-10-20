import type { Edge, Node } from '@vue-flow/core'
import type { BoundaryPort, PhysicalAssembly } from '../domain/physicalAssembly'
import { cloneMatlabGraph } from '../domain/projectCodec'
import { isBoundaryDeclarationNode, synchronizeExplicitBoundaryPorts } from '../domain/boundaryComponents'

/**
 * 执行请求编译器（V3）：只接收不可变的工程快照，生成后端提交负载。
 *
 * - 数据边不携带 relation/streamRole/groupId；
 * - physicalAssemblies 原样透传（后端 EngineAssemblyCompiler 的输入）；
 * - 发动机初始化节点仍双写 parameters（物理装配执行器消费同一份值）。
 * Bus 节点判定由调用方注入。
 */
export type ExecutionSceneSnapshot = {
  id: string
  parentSceneId?: string
  title: string
  boundaryPorts: BoundaryPort[]
  nodes: Node[]
  dataEdges: Edge[]
}

export type ExecutionPayloadResult = {
  engineType: 'matlab'
  executionPayload: {
    schemaVersion: 2
    rootSceneId: string
    nodes: Record<string, any>[]
    edges: Record<string, any>[]
    scenes: Record<string, any>[]
    physicalAssemblies: Record<string, PhysicalAssembly>
  }
}

export const compileExecutionPayload = (input: {
  rootSceneId: string
  scenes: Record<string, ExecutionSceneSnapshot>
  physicalAssemblies?: Record<string, PhysicalAssembly>
  isBusNode: (node: Node) => boolean
}): ExecutionPayloadResult | null => {
  const { rootSceneId, scenes, physicalAssemblies, isBusNode } = input
  const rootScene = scenes[rootSceneId]
  if (!rootScene || rootScene.nodes.length === 0) return null

  const compiledScenes = Object.fromEntries(Object.entries(scenes).map(([id, scene]) => {
    const synchronized = synchronizeExplicitBoundaryPorts(scene.nodes, scene.dataEdges, scene.boundaryPorts)
    return [id, {
      ...scene,
      boundaryPorts: synchronized.boundaryPorts,
      nodes: scene.nodes.filter(node => !isBoundaryDeclarationNode(node)),
      dataEdges: scene.dataEdges.filter(edge => !synchronized.consumedEdges.has(String(edge.id)))
    }]
  })) as Record<string, ExecutionSceneSnapshot>

  const executionBoundaryPorts = (node: Node): BoundaryPort[] | undefined => {
    const ownPorts = cloneMatlabGraph(node.data?.boundaryPorts || []) as BoundaryPort[]
    const childSceneId = String(node.data?.childSceneId || '')
    if (!childSceneId) return ownPorts.length ? ownPorts : undefined
    if (node.data?.modelEntrypoints) return ownPorts.length ? ownPorts : undefined
    const childPorts = cloneMatlabGraph(compiledScenes[childSceneId]?.boundaryPorts || [])
    if (childPorts.length > 0) {
      if (ownPorts.length === 0) return childPorts
      return childPorts.map((childPort) => {
        const publicPort = ownPorts.find(port => port.kind === childPort.kind
          && port.direction === childPort.direction
          && (port.id === childPort.id || port.name === childPort.name))
        return {
          ...(publicPort || childPort),
          id: childPort.id,
          name: publicPort?.name || childPort.name,
          mapping: childPort.mapping ? cloneMatlabGraph(childPort.mapping) : undefined,
          mappings: childPort.mappings ? cloneMatlabGraph(childPort.mappings) : undefined,
          semanticKey: childPort.semanticKey || publicPort?.semanticKey
        }
      })
    }
    return ownPorts.length ? ownPorts : undefined
  }

  const toExecutionNode = (node: Node) => {
    const childSceneId = node.data?.childSceneId ? String(node.data.childSceneId) : undefined
    const executionValues = { ...(node.data?.values || {}) }
    // Projects instantiated before string input values were retained received
    // the catalog's "final" default for the stable power-plot template node.
    // Repair that legacy in-memory value at submission time as well as on load.
    if (String(node.data?.componentId || '') === 'engine.plot.map-mission'
      && String(node.id).toLowerCase().includes('plot_power')) {
      executionValues.phase = 'power'
    }
    const payload: Record<string, any> = {
      id: node.id,
      componentId: String(node.data?.componentId || ''),
      functionName: String(node.data?.functionName || ''),
      values: executionValues,
      // Physical assembly executors consume the same values under `parameters`.
      parameters: { ...(node.data?.parameters || node.data?.values || {}) },
      resources: { ...(node.data?.resources || {}) },
      nodeKind: node.data?.nodeKind || node.data?.executionKind || 'matlabFunction',
      executionKind: node.data?.executionKind || (childSceneId ? 'subsystem' : undefined),
      physicalAssemblyId: node.data?.physicalAssemblyId ? String(node.data.physicalAssemblyId) : undefined,
      childSceneId,
      modelEntrypoints: node.data?.modelEntrypoints ? cloneMatlabGraph(node.data.modelEntrypoints) : undefined,
      activeModes: Array.isArray(node.data?.activeModes) ? [...node.data.activeModes] : undefined,
      boundaryPorts: executionBoundaryPorts(node),
      legacyName: node.data?.legacyName,
      legacyOrder: Number.isFinite(Number(node.data?.legacyOrder)) ? Number(node.data.legacyOrder) : undefined,
      assemblyDefaults: node.data?.assemblyDefaults ? cloneMatlabGraph(node.data.assemblyDefaults) : undefined
    }
    if (isBusNode(node)) {
      payload.nodeKind = node.data?.nodeKind
      payload.executionKind = node.data?.executionKind
      if (node.data?.busConfig) payload.busConfig = cloneMatlabGraph(node.data.busConfig)
      if (node.data?.selectorConfig) payload.selectorConfig = cloneMatlabGraph(node.data.selectorConfig)
    }
    return payload
  }

  const toExecutionEdges = (scene: ExecutionSceneSnapshot) => scene.dataEdges.map((edge: Edge) => ({
    id: edge.id,
    sourceNodeId: edge.source,
    sourcePort: String(edge.sourceHandle || ''),
    targetNodeId: edge.target,
    targetPort: String(edge.targetHandle || ''),
    unresolved: edge.data?.unresolved === true
  }))

  return {
    engineType: 'matlab' as const,
    executionPayload: {
      schemaVersion: 2 as const,
      rootSceneId,
      nodes: compiledScenes[rootSceneId].nodes.map(toExecutionNode),
      edges: compiledScenes[rootSceneId].dataEdges.map((edge: Edge) => ({
        id: edge.id,
        sourceNodeId: edge.source,
        sourcePort: String(edge.sourceHandle || ''),
        targetNodeId: edge.target,
        targetPort: String(edge.targetHandle || ''),
        unresolved: edge.data?.unresolved === true
      })),
      scenes: Object.values(compiledScenes).map((scene) => ({
        id: scene.id,
        parentSceneId: scene.parentSceneId,
        title: scene.title,
        boundaryPorts: cloneMatlabGraph(scene.boundaryPorts),
        nodes: scene.nodes.map(toExecutionNode),
        edges: toExecutionEdges(scene)
      })),
      physicalAssemblies: cloneMatlabGraph(physicalAssemblies || {})
    }
  }
}
