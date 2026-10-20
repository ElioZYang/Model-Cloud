import type { MatlabComponent } from '@/api/matlab-model-deploy'
import { cloneMatlabGraph, makeCompositePortData } from './projectCodec'

export const BOUNDARY_IN_ID = 'builtin.boundary.in'
export const BOUNDARY_OUT_ID = 'builtin.boundary.out'

/** Editor-only interface declarations. The hierarchy compiler consumes them. */
export const builtinBoundaryComponents = (): MatlabComponent[] => [
  {
    id: BOUNDARY_IN_ID, name: 'In', engineType: 'matlab', executorType: 'julia-matlab-graph',
    componentKind: 'boundaryPort', functionName: '', description: '声明子系统输入端口',
    library: '公共工具', category: 'In/Out', inputs: [],
    outputs: [{ name: 'out', type: 'unknown' }], resources: []
  },
  {
    id: BOUNDARY_OUT_ID, name: 'Out', engineType: 'matlab', executorType: 'julia-matlab-graph',
    componentKind: 'boundaryPort', functionName: '', description: '声明子系统输出端口',
    library: '公共工具', category: 'In/Out', inputs: [{ name: 'in', type: 'unknown' }],
    outputs: [], resources: []
  }
]

export const isBoundaryDeclarationNode = (node: any): boolean => (
  node?.data?.componentKind === 'boundaryPort'
  || node?.data?.nodeKind === 'boundaryPort'
  || node?.data?.executionKind === 'boundaryPort'
)

export const boundaryDirection = (node: any): 'input' | 'output' | undefined => {
  if (!isBoundaryDeclarationNode(node)) return undefined
  const direction = node?.data?.boundaryDirection
  if (direction === 'input' || direction === 'output') return direction
  const id = String(node?.data?.componentId || '')
  return id === BOUNDARY_IN_ID ? 'input' : id === BOUNDARY_OUT_ID ? 'output' : undefined
}

export const synchronizeExplicitBoundaryPorts = (nodes: any[], edges: any[], existing: any[] = []) => {
  const declarations = nodes.filter(isBoundaryDeclarationNode)
  const explicit: any[] = []
  const consumedEdges = new Set<string>()
  const usedEndpoints = new Set<string>()
  for (const node of declarations) {
    const direction = boundaryDirection(node)
    if (!direction) continue
    const links = direction === 'input'
      ? edges.filter(edge => edge.source === node.id)
      : edges.filter(edge => edge.target === node.id)
    const mappings = links.flatMap(edge => {
      consumedEdges.add(String(edge.id))
      const target = direction === 'input'
        ? { childNodeId: String(edge.target), childPortId: String(edge.targetHandle || '') }
        : { childNodeId: String(edge.source), childPortId: String(edge.sourceHandle || '') }
      if (!target.childNodeId || !target.childPortId || isBoundaryDeclarationNode(nodes.find(item => item.id === target.childNodeId))) return []
      const key = `${target.childNodeId}\u0000${target.childPortId}`
      if (usedEndpoints.has(key)) return []
      usedEndpoints.add(key)
      return [target]
    })
    if (!mappings.length) continue
    const nodeName = String(node.data?.instanceName || node.label || (direction === 'input' ? 'In' : 'Out'))
    const prior = existing.find(port => port.kind === 'data' && port.direction === direction && (
      port.id === `boundary_explicit_${node.id}`
      || [port.mapping, ...(port.mappings || [])].some((mapping: any) => mappings.some(target => target.childNodeId === mapping?.childNodeId && target.childPortId === mapping?.childPortId))
    ))
    const mapping = mappings[0]
    const endpointNode = nodes.find(item => item.id === mapping.childNodeId)
    const endpointPort = (direction === 'input' ? endpointNode?.data?.inputPorts : endpointNode?.data?.outputPorts)
      ?.find((port: any) => port.name === mapping.childPortId)
    const semanticKey = String(endpointPort?.semanticKey || endpointPort?.name || mapping.childPortId)
    explicit.push({
      ...(prior || {}),
      id: prior?.id || `boundary_explicit_${node.id}`,
      name: nodeName,
      displayName: nodeName,
      kind: 'data', direction,
      dataType: endpointPort?.type || 'unknown', unit: endpointPort?.unit,
      shape: endpointPort?.shape, required: endpointPort?.required,
      semanticKey,
      mapping,
      mappings: direction === 'input' ? mappings : undefined,
      interfaceNodeId: node.id
    })
  }
  const explicitKeys = new Set(explicit.flatMap(port => [port.mapping, ...(port.mappings || [])]
    .filter(Boolean).map((mapping: any) => `${port.direction}\u0000${mapping.childNodeId}\u0000${mapping.childPortId}`)))
  const automatic = existing.filter(port => port.kind !== 'data' || ![port.mapping, ...(port.mappings || [])]
    .filter(Boolean).some((mapping: any) => explicitKeys.has(`${port.direction}\u0000${mapping.childNodeId}\u0000${mapping.childPortId}`)))
  return { boundaryPorts: [...explicit, ...automatic], consumedEdges }
}
export const synchronizeProjectInterfaces = <T extends Record<string, any>>(
  source: T,
  protectedNodeIds: Set<string> = new Set()
): T => {
  const scenes = cloneMatlabGraph(source)
  for (const scene of Object.values(scenes) as any[]) {
    const result = synchronizeExplicitBoundaryPorts(scene.nodes || [], scene.dataEdges || [], scene.boundaryPorts || [])
    scene.boundaryPorts = result.boundaryPorts
  }
  for (const scene of Object.values(scenes) as any[]) {
    scene.nodes = (scene.nodes || []).map((node: any) => {
      const childId = String(node?.data?.childSceneId || '')
      const child = childId ? scenes[childId] : undefined
      // A physical assembly descriptor owns a compile-time assembly_json
      // output. Its descriptive child Scene must never infer/replace that port.
      if (!child || node?.data?.modelEntrypoints || node?.data?.physicalAssemblyId || protectedNodeIds.has(String(node.id))) return node
      const ports = Array.isArray(child.boundaryPorts) ? child.boundaryPorts : []
      return { ...node, data: { ...node.data, boundaryPorts: ports, ...makeCompositePortData(ports.filter((port: any) => port.kind === 'data')) } }
    })
  }
  return scenes
}
