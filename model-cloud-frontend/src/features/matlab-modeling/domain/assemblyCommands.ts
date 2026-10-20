import type { Node, Edge } from '@vue-flow/core'
import type { PhysicalAssembly } from './physicalAssembly'
import { emptyPhysicalAssembly, physicalCapabilitiesOf } from './physicalAssembly'

/** Remove members without changing other assemblies, remaining order, or parameters. */
export function removeAssemblyMembers(assembly: PhysicalAssembly, ids: Set<string>): PhysicalAssembly {
  const groups = <T extends { memberNodeIds: string[] }>(items: T[]) => items
    .map(group => ({ ...group, memberNodeIds: group.memberNodeIds.filter(id => !ids.has(id)) }))
    .filter(group => group.memberNodeIds.length > 0)
  return {
    ...assembly,
    memberNodeIds: assembly.memberNodeIds.filter(id => !ids.has(id)),
    flowRelations: assembly.flowRelations.filter(flow => !ids.has(flow.sourceNodeId) && !ids.has(flow.targetNodeId)),
    shaftGroups: groups(assembly.shaftGroups), bleedGroups: groups(assembly.bleedGroups),
    ...(assembly.motorBindings ? { motorBindings: assembly.motorBindings.filter(binding => !ids.has(binding.motorNodeId)
      && groups(assembly.shaftGroups).some(group => group.id === binding.shaftGroupId)) } : {})
  }
}

/** Build a compile-time assembly container from selected engine part instances. */
export function createAssemblyRelation(input: {
  nodes: Node[]
  edges: Edge[]
  assemblies: Record<string, PhysicalAssembly>
  scenes?: Record<string, { nodes: Node[]; dataEdges: Edge[] }>
  selectedIds: Set<string>
  sceneId: string
  assemblyId: string
  relationSceneId: string
  descriptorNodeId: string
  name: string
}): { ok: true; scene: any; nodes: Node[]; assembly: PhysicalAssembly; descriptor: Node } | { ok: false; reason: string } {
  const selected = input.nodes.filter(node => input.selectedIds.has(node.id))
  if (!selected.length) return { ok: false, reason: '请先选择发动机部件' }
  const physicalMemberIds: string[] = []
  const visitedScenes = new Set<string>()
  const collectMembers = (node: Node): boolean => {
    const capabilities = physicalCapabilitiesOf(node.data)
    if (capabilities?.assemblyMember || capabilities?.flow) {
      physicalMemberIds.push(node.id)
      return true
    }
    const childSceneId = String(node.data?.childSceneId || '')
    if (node.data?.nodeKind !== 'subsystem' || !childSceneId || node.data?.physicalAssemblyId) return false
    if (visitedScenes.has(childSceneId)) return false
    visitedScenes.add(childSceneId)
    const child = input.scenes?.[childSceneId]
    if (!child || child.dataEdges.some(edge => edge.data?.physicalProjection !== true)) return false
    return child.nodes.length > 0 && child.nodes.every(collectMembers)
  }
  if (selected.some(node => !collectMembers(node))) {
    return { ok: false, reason: '选区包含计算组件、In/Out 或普通数据流；装配关系只能包含发动机部件及纯物理组织子系统' }
  }
  const selectedIds = new Set(selected.map(node => node.id))
  const cutDataEdges = input.edges.filter(edge => edge.data?.physicalProjection !== true
    && (selectedIds.has(edge.source) || selectedIds.has(edge.target)))
  if (cutDataEdges.length) return { ok: false, reason: '选中部件与普通数据流相连，请先断开数据边或调整选区' }

  const memberIds = new Set(physicalMemberIds)
  const owners = Object.values(input.assemblies).filter(assembly => assembly.memberNodeIds.some(id => memberIds.has(id)))
  if (owners.some(assembly => assembly.memberNodeIds.some(id => !memberIds.has(id)))) {
    return { ok: false, reason: '选区会拆开已有发动机装配，请一次选择该装配的全部部件' }
  }
  const defaults = new Map<string, unknown>()
  for (const assembly of owners) {
    for (const [key, value] of Object.entries(assembly.defaults || {})) {
      if (defaults.has(key) && JSON.stringify(defaults.get(key)) !== JSON.stringify(value)) {
        return { ok: false, reason: `多个装配的构型参数 ${key} 不同，请先统一参数` }
      }
      defaults.set(key, value)
    }
  }
  const assembly = emptyPhysicalAssembly(input.assemblyId, input.name)
  assembly.memberNodeIds = [...memberIds]
  assembly.defaults = Object.fromEntries(defaults)
  assembly.flowRelations = owners.flatMap(item => item.flowRelations.map(flow => ({ ...flow })))
  assembly.shaftGroups = owners.flatMap(item => item.shaftGroups.map(group => ({
    ...group,
    id: `${input.assemblyId}_${group.id}`,
    memberNodeIds: [...group.memberNodeIds],
    parameters: { ...group.parameters }
  })))
  assembly.bleedGroups = owners.flatMap(item => item.bleedGroups.map(group => ({
    ...group,
    id: `${input.assemblyId}_${group.id}`,
    memberNodeIds: [...group.memberNodeIds],
    parameters: { ...group.parameters }
  })))

  const scene = {
    id: input.relationSceneId,
    parentSceneId: input.sceneId,
    title: '装配关系',
    nodes: selected,
    dataEdges: [],
    boundaryPorts: [],
    viewport: { x: 0, y: 0, zoom: 1 }
  }
  const descriptor: Node = {
    id: input.descriptorNodeId,
    type: 'matlabComposite',
    position: { x: 80, y: 100 },
    label: input.name,
    data: {
      componentId: 'project.subsystem.engine-assembly-relations',
      componentName: '装配关系',
      componentKind: 'workflow',
      nodeKind: 'assemblyDescriptor',
      executionKind: 'compileTimeAssembly',
      sceneNodeKind: 'assemblyDescriptor',
      physicalAssemblyId: input.assemblyId,
      childSceneId: input.relationSceneId,
      instanceName: input.name,
      functionName: 'engineAssemblyDescriptor',
      values: {}, resources: {}, boundaryPorts: [],
      inputPorts: [],
      outputPorts: [{ name: 'assembly_json', type: 'string', required: true,
        description: '发动机装配描述（编译期生成）' }],
      connectors: [{ name: 'assembly_json', type: 'WorkflowOutput' }]
    }
  }
  return {
    ok: true,
    scene,
    nodes: input.nodes.filter(node => !selectedIds.has(node.id)).concat(descriptor),
    assembly,
    descriptor
  }
}

/** Derive the legacy binding summary from the visible assembly_json data edge. */
export function resolveAssemblyInitializer(
  scenes: Record<string, { nodes: Node[]; dataEdges: Edge[]; boundaryPorts?: any[] }>,
  assemblyId: string
): string {
  const nodes = new Map<string, Node>()
  const nodeScene = new Map<string, string>()
  for (const [sceneId, scene] of Object.entries(scenes)) {
    for (const node of scene.nodes || []) {
      nodes.set(node.id, node)
      nodeScene.set(node.id, sceneId)
    }
  }
  const descriptors = [...nodes.values()].filter(node => String(node.data?.physicalAssemblyId || '') === assemblyId)
  if (descriptors.length !== 1) return ''

  const adjacency = new Map<string, string[]>()
  const endpoint = (nodeId: string, port: string) => `${nodeId}\u0000${port}`
  const link = (from: string, to: string) => adjacency.set(from, [...(adjacency.get(from) || []), to])
  for (const scene of Object.values(scenes)) {
    for (const edge of scene.dataEdges || []) {
      if (edge.source && edge.sourceHandle && edge.target && edge.targetHandle) {
        link(endpoint(edge.source, edge.sourceHandle), endpoint(edge.target, edge.targetHandle))
      }
    }
    for (const wrapper of scene.nodes || []) {
      const childId = String(wrapper.data?.childSceneId || '')
      const child = scenes[childId]
      if (!child || wrapper.data?.componentId === 'project.subsystem.engine-assembly-relations') continue
      const ports = wrapper.data?.boundaryPorts?.length ? wrapper.data.boundaryPorts : child.boundaryPorts || []
      for (const port of ports) {
        if (port.kind && port.kind !== 'data') continue
        const outerPort = String(port.id || port.portId || port.name || '')
        if (!outerPort) continue
        const mappings = Array.isArray(port.mappings) && port.mappings.length
          ? port.mappings : port.mapping ? [port.mapping] : []
        for (const mapping of mappings) {
          const childNodeId = String(mapping.childNodeId || mapping.innerNodeId || mapping.nodeId || '')
          const childPortId = String(mapping.childPortId || mapping.innerPortId || mapping.port || mapping.portId || '')
          if (!childNodeId || !childPortId || nodeScene.get(childNodeId) !== childId) continue
          if (port.direction === 'input') link(endpoint(wrapper.id, outerPort), endpoint(childNodeId, childPortId))
          else if (port.direction === 'output') link(endpoint(childNodeId, childPortId), endpoint(wrapper.id, outerPort))
        }
      }
    }
  }

  const queue = [endpoint(descriptors[0].id, 'assembly_json')]
  const visited = new Set<string>()
  const targets = new Set<string>()
  while (queue.length) {
    const current = queue.shift()!
    if (visited.has(current)) continue
    visited.add(current)
    const separator = current.indexOf('\u0000')
    const nodeId = current.slice(0, separator)
    const portId = current.slice(separator + 1)
    const node = nodes.get(nodeId)
    if (node?.data?.componentId === 'engine.stage.initialize-configuration' && portId === 'assembly_json') {
      targets.add(nodeId)
    }
    queue.push(...(adjacency.get(current) || []))
  }
  return targets.size === 1 ? [...targets][0] : ''
}

export function synchronizeAssemblyBindings(
  scenes: Record<string, { nodes: Node[]; dataEdges: Edge[] }>,
  assemblies: Record<string, PhysicalAssembly>
): Record<string, PhysicalAssembly> {
  const next = { ...assemblies }
  for (const [assemblyId, assembly] of Object.entries(assemblies)) {
    const targetNodeId = resolveAssemblyInitializer(scenes, assemblyId)
    if (assembly.initializerBinding.nodeId !== targetNodeId) {
      next[assemblyId] = {
        ...assembly,
        initializerBinding: { nodeId: targetNodeId, inputPort: 'assembly_json' }
      }
    }
  }
  return next
}
