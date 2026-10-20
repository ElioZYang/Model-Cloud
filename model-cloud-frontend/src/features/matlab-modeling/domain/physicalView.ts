import type { Edge } from '@vue-flow/core'
import { MarkerType } from '@vue-flow/core'
import type { PhysicalAssembly, BoundaryPortKind } from './physicalAssembly'
import type { RuntimeSceneData } from './sceneCommands'

type Endpoint = { nodeId: string; portId: string }
export type PhysicalEdgeRoutes = Record<string, Array<{ x: number; y: number }>>

/**
 * Choose edges that may influence node placement. Physical relation overlays are
 * view projections: only the directed gas path defines component order. Shaft
 * and bleed groups are routed after placement and never affect ELK layering.
 */
export function selectPhysicalLayoutEdges(
  dataEdges: Edge[],
  projectedEdges: Edge[],
  physicalActive: boolean
): Edge[] {
  if (!physicalActive) return dataEdges
  return projectedEdges.filter(edge => (
    edge.data?.physicalProjection === true && edge.data?.relation === 'flow'
  ))
}

/** Resolve a visible subsystem handle to its original physical member. */
export function resolvePhysicalLeaf(
  scenes: Record<string, RuntimeSceneData>, nodeId: string, portId: string,
  kind: BoundaryPortKind, visited = new Set<string>()
): Endpoint | null {
  if (visited.has(nodeId)) return null
  visited.add(nodeId)
  const node = Object.values(scenes).flatMap(scene => scene.nodes).find(node => node.id === nodeId)
  if (!node) return null
  if (node.data?.physicalCapabilities?.assemblyMember) return { nodeId, portId }
  if (!node.data?.childSceneId) return { nodeId, portId }
  const child = scenes[node.data.childSceneId]
  const boundary = child?.boundaryPorts.find(port => port.id === portId && port.kind === kind)
  return boundary?.mapping ? resolvePhysicalLeaf(scenes, boundary.mapping.childNodeId,
    boundary.mapping.childPortId, kind, visited) : null
}

/** Project a member onto this Scene without changing assembly IDs or relations. */
export function visiblePhysicalEndpoint(
  scenes: Record<string, RuntimeSceneData>, sceneId: string, memberId: string,
  portId: string, kind: BoundaryPortKind, direction: 'input' | 'output', visited = new Set<string>()
): Endpoint | null {
  if (visited.has(sceneId)) return null
  visited.add(sceneId)
  const scene = scenes[sceneId]
  if (!scene) return null
  if (scene.nodes.some(node => node.id === memberId)) return { nodeId: memberId, portId }
  for (const node of scene.nodes) {
    const childId = node.data?.childSceneId
    if (!childId) continue
    const nested = visiblePhysicalEndpoint(scenes, childId, memberId, portId, kind, direction, new Set(visited))
    if (!nested) continue
    const boundary = scenes[childId]?.boundaryPorts.find(port => port.kind === kind
      && (kind !== 'flow' || port.direction === direction)
      && port.mapping?.childNodeId === nested.nodeId
      && (kind !== 'flow' || port.mapping.childPortId === nested.portId))
    if (boundary) return { nodeId: node.id, portId: boundary.id }
  }
  return null
}

export function projectPhysicalEdges(
  scenes: Record<string, RuntimeSceneData>, sceneId: string,
  assemblies: Record<string, PhysicalAssembly>,
  routes: PhysicalEdgeRoutes = {}
): Edge[] {
  const edges: Edge[] = []
  const colors = { flow: '#409eff', shaft: '#e6a23c', bleed: '#9c27b0' }
  const add = (assembly: PhysicalAssembly, kind: 'flow' | 'shaft' | 'bleed', id: string,
    source: Endpoint | null, target: Endpoint | null, metadata: Record<string, unknown>) => {
    if (!source || !target || source.nodeId === target.nodeId) return
    const edgeId = `physical:${assembly.id}:${id}`
    edges.push({
      id: edgeId, type: 'matlabElk',
      source: source.nodeId, sourceHandle: source.portId,
      target: target.nodeId, targetHandle: target.portId,
      ...(kind === 'flow' ? { markerEnd: MarkerType.ArrowClosed } : {}),
      style: { stroke: colors[kind], strokeWidth: 2, ...(kind === 'bleed' ? { strokeDasharray: '5 4' } : {}) },
      data: {
        physicalProjection: true,
        assemblyId: assembly.id,
        relation: kind,
        ...metadata,
        elkPoints: routes[edgeId] || []
      }
    })
  }
  for (const assembly of Object.values(assemblies)) {
    for (const flow of assembly.flowRelations) {
      add(assembly, 'flow', flow.id,
        visiblePhysicalEndpoint(scenes, sceneId, flow.sourceNodeId, flow.sourcePortId, 'flow', 'output'),
        visiblePhysicalEndpoint(scenes, sceneId, flow.targetNodeId, flow.targetPortId, 'flow', 'input'),
        { relationId: flow.id, streamRole: flow.streamRole })
    }
    for (const group of [...assembly.shaftGroups, ...assembly.bleedGroups]) {
      const members = group.memberNodeIds
      for (let index = 1; index < members.length; index++) {
        add(assembly, group.kind, `${group.id}:${members[index]}`,
          visiblePhysicalEndpoint(scenes, sceneId, members[0], `${group.kind.toUpperCase()}_OUT`, group.kind, 'output'),
          visiblePhysicalEndpoint(scenes, sceneId, members[index], `${group.kind.toUpperCase()}_IN`, group.kind, 'input'),
          { groupId: group.id, memberNodeId: members[index] })
      }
    }
    for (const binding of assembly.motorBindings || []) {
      const shaft = assembly.shaftGroups.find(group => group.id === binding.shaftGroupId)
      if (!shaft?.memberNodeIds.length) continue
      add(assembly, 'shaft', `motor:${binding.motorNodeId}`,
        visiblePhysicalEndpoint(scenes, sceneId, shaft.memberNodeIds[0], 'SHAFT_OUT', 'shaft', 'output'),
        visiblePhysicalEndpoint(scenes, sceneId, binding.motorNodeId, 'INPUT', 'shaft', 'input'),
        { motorBinding: true, motorNodeId: binding.motorNodeId, groupId: binding.shaftGroupId })
    }
  }
  return edges
}
