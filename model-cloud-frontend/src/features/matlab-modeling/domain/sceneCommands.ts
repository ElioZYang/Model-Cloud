import type { Edge, Node } from '@vue-flow/core'
import type { BoundaryPort, DataEdge } from './physicalAssembly'
import { cloneMatlabGraph, makeCompositePortData } from './projectCodec'
import { isBoundaryDeclarationNode, synchronizeExplicitBoundaryPorts } from './boundaryComponents'

/**
 * 通用子系统 Scene 命令（V3）。
 *
 * 封装不再产生任何物理类型：子系统只负责层级、边界端口与导航。
 * 跨边界的数据连线生成 kind=data 边界端口。气路、轴系和引气关系
 * 始终保存在 PhysicalAssembly 中，不转换为通用子系统端口。
 */

export type RuntimeSceneData = {
  id: string
  parentSceneId?: string
  title: string
  nodes: Node[]
  dataEdges: Edge[]
  boundaryPorts: BoundaryPort[]
  viewport: { x: number; y: number; zoom: number }
}

export type PortLookup = (
  node: Node | undefined,
  direction: 'input' | 'output',
  handle: string
) => {
  name?: string
  type?: string
  unit?: string
  shape?: number[]
  required?: boolean
  defaultValue?: number | string | boolean | number[] | number[][]
  description?: string
} | undefined

export type EncapsulateSplitError = {
  ok: false
  reason: 'empty-selection' | 'invalid-boundary-port'
  edgeId?: string
  nodeId?: string
  portId?: string
}

export type EncapsulateSuccess = {
  ok: true
  compositeNode: Node
  childScene: RuntimeSceneData
  nextNodes: Node[]
  nextEdges: Edge[]
  boundaryPorts: BoundaryPort[]
  wrappedCount: number
}

type BoundaryInferenceSuccess = {
  ok: true
  boundaryPorts: BoundaryPort[]
  boundaryByEdge: Map<string, BoundaryPort>
}

type DeclaredPort = NonNullable<ReturnType<PortLookup>> & { name: string }

const scalarDefault = (value: unknown): number | string | boolean | number[] | number[][] | undefined => {
  if (typeof value === 'number' || typeof value === 'string' || typeof value === 'boolean') return value
  if (!Array.isArray(value)) return undefined
  const vector = value.every((item) => typeof item === 'number' && Number.isFinite(item))
  const matrix = value.every((row) => Array.isArray(row)
    && row.every((item) => typeof item === 'number' && Number.isFinite(item)))
    && value.every((row) => row.length === value[0]?.length)
  return vector || matrix ? cloneMatlabGraph(value) : undefined
}

const declaredPorts = (node: Node, direction: 'input' | 'output'): DeclaredPort[] => {
  // Engine part ports describe physical relations and their calculation payloads.
  // They are not ordinary subsystem data interfaces, even though the catalog
  // also exposes them as MATLAB function inputs/outputs for inspection.
  if (node.data?.nodeKind === 'physicalComponent' || node.data?.physicalCapabilities?.flow) return []
  const raw = direction === 'input' ? node.data?.inputPorts : node.data?.outputPorts
  if (!Array.isArray(raw)) return []
  const names = new Set<string>()
  return raw.flatMap((candidate) => {
    const name = String(candidate?.name || '').trim()
    if (!name || names.has(name)) return []
    names.add(name)
    return [{ ...candidate, name } as DeclaredPort]
  })
}

const endpointKey = (direction: 'input' | 'output', nodeId: string, portId: string) => (
  `${direction}\u0000${nodeId}\u0000${portId}`
)

const isPhysicalPartNode = (node: Node | undefined) => Boolean(node && (
  node.data?.nodeKind === 'physicalComponent' || node.data?.physicalCapabilities?.flow
))

/**
 * Derive a subsystem's public data interface from both crossing edges and
 * unoccupied terminal ports.  Physical relations never participate here.
 */
export const inferSubsystemBoundaryPorts = (input: {
  nodes: Node[]
  dataEdges: Edge[]
  selectedIds: Set<string>
  findNodePort: PortLookup
}): BoundaryInferenceSuccess | EncapsulateSplitError => {
  const { nodes, dataEdges, selectedIds, findNodePort } = input
  const selected = nodes.filter((node) => selectedIds.has(node.id) && !isBoundaryDeclarationNode(node))
  if (selected.length === 0) return { ok: false, reason: 'empty-selection' }
  const ordinaryDataEdges = dataEdges.filter(edge => !isPhysicalPartNode(nodes.find(node => node.id === edge.source))
    && !isPhysicalPartNode(nodes.find(node => node.id === edge.target)))

  const occupiedInputs = new Set<string>()
  const occupiedOutputs = new Set<string>()
  ordinaryDataEdges.forEach((edge) => {
    const sourceHandle = String(edge.sourceHandle || '')
    const targetHandle = String(edge.targetHandle || '')
    if (selectedIds.has(edge.source) && sourceHandle) {
      occupiedOutputs.add(endpointKey('output', edge.source, sourceHandle))
    }
    if (selectedIds.has(edge.target) && targetHandle) {
      occupiedInputs.add(endpointKey('input', edge.target, targetHandle))
    }
  })

  const crossingEdges = ordinaryDataEdges.filter((edge) => selectedIds.has(edge.source) !== selectedIds.has(edge.target))
  const crossingEndpoints = new Map<string, { node: Node; direction: 'input' | 'output'; port: DeclaredPort }>()
  for (const edge of crossingEdges) {
    const targetInside = selectedIds.has(edge.target)
    const direction = targetInside ? 'input' : 'output'
    const nodeId = targetInside ? edge.target : edge.source
    const portId = String(targetInside ? edge.targetHandle : edge.sourceHandle)
    const node = nodes.find((candidate) => candidate.id === nodeId)
    const port = findNodePort(node, direction, portId)
    if (!node || !portId || !port) {
      return { ok: false, reason: 'invalid-boundary-port', edgeId: edge.id, nodeId, portId }
    }
    crossingEndpoints.set(endpointKey(direction, nodeId, portId), {
      node,
      direction,
      port: { ...port, name: portId }
    })
  }

  const candidates: Array<{ node: Node; direction: 'input' | 'output'; port: DeclaredPort }> = []
  const candidateKeys = new Set<string>()
  const addCandidate = (node: Node, direction: 'input' | 'output', port: DeclaredPort) => {
    const key = endpointKey(direction, node.id, port.name)
    if (candidateKeys.has(key)) return
    candidateKeys.add(key)
    candidates.push({ node, direction, port })
  }

  ;(['input', 'output'] as const).forEach((direction) => {
    selected.forEach((node) => {
      declaredPorts(node, direction).forEach((port) => {
        const key = endpointKey(direction, node.id, port.name)
        const occupied = direction === 'input' ? occupiedInputs.has(key) : occupiedOutputs.has(key)
        if (!occupied || crossingEndpoints.has(key)) addCandidate(node, direction, port)
      })
    })
    // Preserve malformed-but-resolvable legacy nodes whose handle is available
    // through the lookup callback but absent from the serialized port list.
    crossingEndpoints.forEach((candidate, key) => {
      if (candidate.direction === direction && !candidateKeys.has(key)) {
        addCandidate(candidate.node, candidate.direction, candidate.port)
      }
    })
  })

  let inputIndex = 0
  let outputIndex = 0
  const boundaryByEndpoint = new Map<string, BoundaryPort>()
  const boundaryPorts = candidates.map(({ node, direction, port }) => {
    const index = direction === 'input' ? ++inputIndex : ++outputIndex
    const values = node.data?.values && typeof node.data.values === 'object'
      ? node.data.values as Record<string, unknown>
      : {}
    const defaultValue = direction === 'input'
      ? scalarDefault(values[port.name]) ?? scalarDefault(port.defaultValue)
      : undefined
    const displayNames = node.data?.portDisplayNames && typeof node.data.portDisplayNames === 'object'
      ? node.data.portDisplayNames as Record<string, unknown>
      : {}
    const boundaryPort: BoundaryPort = {
      id: `boundary_data_${direction === 'input' ? 'in' : 'out'}_${index}`,
      name: `${direction === 'input' ? 'in' : 'out'}_${index}`,
      displayName: String(displayNames[port.name] || port.description || port.name),
      kind: 'data',
      direction,
      dataType: port.type || 'unknown',
      unit: port.unit,
      shape: port.shape,
      required: port.required,
      defaultValue,
      semanticKey: String((direction === 'input' ? node.data?.inputPorts : node.data?.outputPorts)
        ?.find((candidate: any) => candidate?.name === port.name)?.semanticKey || port.name),
      mapping: { childNodeId: node.id, childPortId: port.name }
    }
    boundaryByEndpoint.set(endpointKey(direction, node.id, port.name), boundaryPort)
    return boundaryPort
  })

  const boundaryByEdge = new Map<string, BoundaryPort>()
  crossingEdges.forEach((edge) => {
    const targetInside = selectedIds.has(edge.target)
    const direction = targetInside ? 'input' : 'output'
    const nodeId = targetInside ? edge.target : edge.source
    const portId = String(targetInside ? edge.targetHandle : edge.sourceHandle)
    const boundary = boundaryByEndpoint.get(endpointKey(direction, nodeId, portId))
    if (boundary) boundaryByEdge.set(edge.id, boundary)
  })
  return { ok: true, boundaryPorts, boundaryByEdge }
}

/**
 * 将选中节点封装为通用子系统。
 *
 * 输入当前画布快照、选中集合与装配域物理关系，返回完整新状态；
 * 不修改输入，不生成重复 ID，不产生半完成状态。
 * 物理装配归属不变：成员与关系使用项目唯一节点 ID。
 */
export const encapsulateSelection = (input: {
  nodes: Node[]
  dataEdges: Edge[]
  selectedIds: Set<string>
  findNodePort: PortLookup
  compositeId: string
  childSceneId: string
  parentSceneId: string
  instanceName: string
}): EncapsulateSplitError | EncapsulateSuccess => {
  const { nodes, dataEdges, selectedIds, findNodePort } = input
  const selected = nodes.filter((node) => selectedIds.has(node.id))
  if (selected.length === 0) return { ok: false, reason: 'empty-selection' }

  const { compositeId, childSceneId, instanceName } = input

  const interfaceNodes = selected.filter(isBoundaryDeclarationNode)
  const interfaceIds = new Set(interfaceNodes.map(node => node.id))
  const interfaceEdges = dataEdges.filter(edge => interfaceIds.has(edge.source) || interfaceIds.has(edge.target))
  const regularSelectedIds = new Set([...selectedIds].filter(id => !interfaceIds.has(id)))
  const regularEdges = dataEdges.filter(edge => !interfaceIds.has(edge.source) && !interfaceIds.has(edge.target))
  const inference = inferSubsystemBoundaryPorts({ nodes, dataEdges: regularEdges, selectedIds: regularSelectedIds, findNodePort })
  if (!inference.ok) return inference
  const explicit = synchronizeExplicitBoundaryPorts(selected, interfaceEdges)
  const endpointBoundary = new Map<string, BoundaryPort>()
  ;[...explicit.boundaryPorts, ...inference.boundaryPorts].forEach((port) => {
    ;[port.mapping, ...(port.mappings || [])].filter(Boolean).forEach((mapping) => {
      const key = endpointKey(port.direction || 'input', mapping!.childNodeId, mapping!.childPortId)
      // Explicit In/Out declarations own the public port when both mechanisms
      // expose the same internal endpoint. Keep the inferred port as fallback.
      if (!endpointBoundary.has(key) || port.interfaceNodeId) endpointBoundary.set(key, port)
    })
  })
  const boundaryByEdge = new Map<string, BoundaryPort>()
  inference.boundaryByEdge.forEach((inferredPort, edgeId) => {
    const mapping = inferredPort.mapping
    const port = mapping
      ? endpointBoundary.get(endpointKey(inferredPort.direction || 'input', mapping.childNodeId, mapping.childPortId))
      : undefined
    if (port) boundaryByEdge.set(edgeId, port)
  })
  const unrepresentedCrossing = dataEdges.find((edge) => (
    selectedIds.has(edge.source) !== selectedIds.has(edge.target)
    && !boundaryByEdge.has(edge.id)
  ))
  if (unrepresentedCrossing) {
    const insideTarget = selectedIds.has(unrepresentedCrossing.target)
    return {
      ok: false,
      reason: 'invalid-boundary-port',
      edgeId: unrepresentedCrossing.id,
      nodeId: insideTarget ? unrepresentedCrossing.target : unrepresentedCrossing.source,
      portId: String(insideTarget ? unrepresentedCrossing.targetHandle || '' : unrepresentedCrossing.sourceHandle || '')
    }
  }
  const explicitKeys = new Set(explicit.boundaryPorts.flatMap(port => [port.mapping, ...(port.mappings || [])]
    .filter(Boolean).map(mapping => `${port.direction}\u0000${mapping!.childNodeId}\u0000${mapping!.childPortId}`)))
  const autoPorts = inference.boundaryPorts.filter(port => ![port.mapping, ...(port.mappings || [])]
    .filter(Boolean).some(mapping => explicitKeys.has(`${port.direction}\u0000${mapping!.childNodeId}\u0000${mapping!.childPortId}`)))
  const boundaryPorts = [...explicit.boundaryPorts, ...autoPorts]
  const compositePorts = makeCompositePortData(
    boundaryPorts.filter((port) => port.kind === 'data' && port.direction)
  )
  const compositeNode: Node = {
    id: compositeId,
    type: 'matlabComposite',
    position: { ...selected[0].position },
    label: instanceName,
    data: {
      componentId: `project.subsystem.${compositeId}`,
      componentName: instanceName,
      instanceName,
      functionName: 'projectSubsystem',
      executionKind: 'subsystem',
      nodeKind: 'subsystem',
      sceneNodeKind: 'subsystem',
      childSceneId,
      boundaryPorts: cloneMatlabGraph(boundaryPorts),
      wrappedNodeIds: selected.map((node) => node.id),
      ...compositePorts,
      values: {},
      resources: {}
    }
  }
  const insideEdges = dataEdges.filter((edge) => selectedIds.has(edge.source) && selectedIds.has(edge.target))
  const outsideEdges = dataEdges.filter((edge) => !selectedIds.has(edge.source) && !selectedIds.has(edge.target))
  const crossingEdges = dataEdges.filter((edge) => selectedIds.has(edge.source) !== selectedIds.has(edge.target))
  const rewiredDataEdges = reconnectBoundaryEdges(crossingEdges, selectedIds, compositeId, boundaryByEdge)
  const childScene: RuntimeSceneData = {
    id: childSceneId,
    parentSceneId: input.parentSceneId,
    title: `${instanceName} · 子系统`,
    nodes: cloneMatlabGraph(selected).map((node) => ({
      ...node,
      selected: false,
      data: {
        ...node.data,
        parentSceneId: childSceneId
      }
    })),
    dataEdges: cloneMatlabGraph(insideEdges),
    boundaryPorts,
    viewport: { x: 0, y: 0, zoom: 1 }
  }
  return {
    ok: true,
    compositeNode,
    childScene,
    nextNodes: [
      ...nodes.filter((node) => !selectedIds.has(node.id)).map((node) => ({ ...node, selected: false })),
      compositeNode
    ],
    nextEdges: [
      ...outsideEdges,
      ...rewiredDataEdges
    ],
    boundaryPorts,
    wrappedCount: selected.length
  }
}

/** 封装时的数据边跨边界重连（记录 subsystemBridge 供解封装还原）。 */
export const reconnectBoundaryEdges = (
  edges: Edge[],
  selectedIds: Set<string>,
  compositeId: string,
  boundaryByEdge: Map<string, BoundaryPort>
): Edge[] => edges.flatMap((edge) => {
  const insideSource = selectedIds.has(edge.source)
  const insideTarget = selectedIds.has(edge.target)
  // Internal and external edges belong to their existing scene and must not
  // be copied into the parent while rewiring subsystem boundaries.
  if (insideSource === insideTarget) return []
  const boundary = boundaryByEdge.get(edge.id)
  if (!boundary) return []
  return {
    ...edge,
    source: insideTarget ? edge.source : compositeId,
    sourceHandle: insideTarget ? edge.sourceHandle : boundary.id,
    target: insideTarget ? compositeId : edge.target,
    targetHandle: insideTarget ? boundary.id : edge.targetHandle,
    data: {
      ...(edge.data || {}),
      subsystemBridge: {
        originalSource: edge.source,
        originalSourceHandle: String(edge.sourceHandle || ''),
        originalTarget: edge.target,
        originalTargetHandle: String(edge.targetHandle || ''),
        boundaryPortId: boundary.id
      }
    }
  } as Edge
})

/** 解封装通用子系统：恢复内部节点与数据边，物理关系无需处理（成员 ID 未变）。 */
export const unencapsulateSubsystem = (input: {
  compositeNode: Node
  childScene: RuntimeSceneData
  nodes: Node[]
  edges: Edge[]
}): { ok: true; nextNodes: Node[]; nextEdges: Edge[] } | { ok: false } => {
  const { compositeNode, childScene, nodes, edges } = input
  if (!compositeNode?.id || !childScene) return { ok: false }
  const compositeId = compositeNode.id
  const boundaryMap = new Map(childScene.boundaryPorts
    .filter((port) => port.kind === 'data')
    .map((port) => [port.id, port]))
  const restoredEdges: Edge[] = edges
    .filter((edge) => edge.source !== compositeId && edge.target !== compositeId)
    .concat(edges.filter((edge) => edge.source === compositeId || edge.target === compositeId))
    .concat(childScene.dataEdges.map((edge) => cloneMatlabGraph(edge)))
    .flatMap((edge) => {
      const next = { ...edge }
      if (next.source === compositeId) {
        const port = boundaryMap.get(String(next.sourceHandle || ''))
        if (port?.mapping) {
          next.source = port.mapping.childNodeId
          next.sourceHandle = port.mapping.childPortId
        }
      }
      if (next.target === compositeId) {
        const port = boundaryMap.get(String(next.targetHandle || ''))
        if (port?.interfaceNodeId) {
          next.target = port.interfaceNodeId
          next.targetHandle = 'out'
          return [next]
        }
        const mappings = port?.direction === 'input' ? (port.mappings?.length ? port.mappings : port.mapping ? [port.mapping] : []) : []
        if (mappings.length > 1) return mappings.map((mapping, index) => ({
          ...next, id: `${next.id}_restore_${index + 1}`, target: mapping.childNodeId, targetHandle: mapping.childPortId
        }))
        const mapping = mappings[0] || port?.mapping
        if (mapping) { next.target = mapping.childNodeId; next.targetHandle = mapping.childPortId }
      }
      return [next]
    })
  return {
    ok: true,
    nextNodes: [
      ...nodes.filter((node) => node.id !== compositeId),
      ...cloneMatlabGraph(childScene.nodes).map((node) => ({ ...node, selected: false }))
    ],
    nextEdges: restoredEdges
  }
}

export type { DataEdge }
