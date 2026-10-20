import { describe, expect, it } from 'vitest'
import type { Node } from '@vue-flow/core'
import { emptyPhysicalAssembly } from '../../domain/physicalAssembly'
import { compileExecutionPayload, type ExecutionSceneSnapshot } from '../executionPayloadCompiler'

const node = (id: string, extra: Record<string, any> = {}): Node => ({
  id,
  position: { x: 0, y: 0 },
  data: { componentId: `engine.stage.${id}`, instanceName: id, values: {}, resources: {}, ...extra }
} as Node)

const edge = (id: string, source: string, target: string) => ({
  id, source, sourceHandle: 'OUT', target, targetHandle: 'IN', data: {}
})

const scenes = (): Record<string, ExecutionSceneSnapshot> => ({
  root: {
    id: 'root', title: '根场景', boundaryPorts: [],
    nodes: [node('init', { nodeKind: 'subsystem', childSceneId: 'design' })],
    dataEdges: []
  },
  design: {
    id: 'design', title: '设计点',
    boundaryPorts: [{ id: 'V', name: 'V', kind: 'data', direction: 'input', dataType: 'number', mapping: { childNodeId: 'init2', childPortId: 'V' } }],
    nodes: [node('init2')],
    dataEdges: [edge('e1', 'init2', 'init2')]
  }
})

describe('compileExecutionPayload', () => {
  it('画布为空时返回 null', () => {
    const empty = { root: { ...scenes().root, nodes: [] } }
    expect(compileExecutionPayload({ rootSceneId: 'root', scenes: empty, isBusNode: () => false })).toBeNull()
  })

  it('负载包含 schemaVersion/rootSceneId/nodes/edges/scenes/physicalAssemblies', () => {
    const assemblies = { a1: emptyPhysicalAssembly('a1', '构型') }
    const result = compileExecutionPayload({ rootSceneId: 'root', scenes: scenes(), physicalAssemblies: assemblies, isBusNode: () => false })!
    expect(result.engineType).toBe('matlab')
    expect(result.executionPayload.schemaVersion).toBe(2)
    expect(result.executionPayload.physicalAssemblies.a1.name).toBe('构型')
    expect(result.executionPayload.scenes).toHaveLength(2)
  })

  it('数据边不携带 relation/streamRole/groupId', () => {
    const snapshot = scenes()
    snapshot.physical = {
      id: 'physical', title: '物理构型', boundaryPorts: [],
      nodes: [node('inlet_1', { nodeKind: 'physicalComponent', values: { TPR: -1 } })],
      dataEdges: [edge('f1', 'inlet_1', 'inlet_1')]
    }
    const result = compileExecutionPayload({ rootSceneId: 'root', scenes: snapshot, isBusNode: () => false })!
    const physicalScene = result.executionPayload.scenes.find((scene) => scene.id === 'physical')!
    expect(physicalScene.edges[0].relation).toBeUndefined()
    expect(physicalScene.edges[0].groupId).toBeUndefined()
    expect(physicalScene.nodes[0].parameters.TPR).toBe(-1)
  })

  it('Bus 节点附加 busConfig 且不被改写', () => {
    const snapshot = scenes()
    snapshot.root.nodes.push(node('bus1', {
      nodeKind: 'busCreator', executionKind: 'busCreator',
      busConfig: { schemaMode: 'anonymous', name: 'bus', fields: [] }
    }))
    const result = compileExecutionPayload({ rootSceneId: 'root', scenes: snapshot, isBusNode: (n) => n.id === 'bus1' })!
    const busNode = result.executionPayload.nodes.find((n) => n.id === 'bus1')!
    expect(busNode.nodeKind).toBe('busCreator')
    expect(busNode.busConfig).toBeDefined()
  })
})
