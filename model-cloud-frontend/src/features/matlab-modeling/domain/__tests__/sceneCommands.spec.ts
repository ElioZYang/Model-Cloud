import { describe, expect, it } from 'vitest'
import type { Edge, Node } from '@vue-flow/core'
import {
  encapsulateSelection,
  inferSubsystemBoundaryPorts,
  unencapsulateSubsystem
} from '../sceneCommands'

const pmsmNode = (id: string, inputValue?: number): Node => ({
  id,
  type: 'matlabComponent',
  position: { x: 0, y: 0 },
  data: {
    componentId: `pmsm.${id}`,
    instanceName: id,
    nodeKind: 'matlabFunction',
    inputPorts: [{ name: 'IN', type: 'number', required: false, defaultValue: 7, description: `${id} input` }],
    outputPorts: [{ name: 'OUT', type: 'number', description: `${id} output` }],
    values: inputValue === undefined ? {} : { IN: inputValue }
  }
})

const dataEdge = (id: string, source: string, target: string): Edge => ({
  id, source, sourceHandle: 'OUT', target, targetHandle: 'IN', data: {}
})

const findNodePort = (node: Node | undefined, direction: 'input' | 'output', handle: string) => {
  const ports = direction === 'input' ? node?.data?.inputPorts : node?.data?.outputPorts
  return (ports || []).find((port: any) => port.name === handle)
}

describe('encapsulateSelection（通用子系统，V3）', () => {
  it('显式 In 可扇出，Out 可公开已经被内部使用的输出', () => {
    const inlet = { id: 'In1', type: 'matlabBoundary', label: 'shaft_power', data: {
      componentKind: 'boundaryPort', componentId: 'builtin.boundary.in', boundaryDirection: 'input',
      instanceName: 'shaft_power', outputPorts: [{ name: 'out', type: 'number' }]
    } } as any
    const producer = { id: 'producer', type: 'modelicaComponent', data: { outputPorts: [{ name: 'Y', type: 'number' }], inputPorts: [] } } as any
    const consumerA = { id: 'consumerA', type: 'modelicaComponent', data: { inputPorts: [{ name: 'P', type: 'number' }, { name: 'Q', type: 'number' }], outputPorts: [] } } as any
    const consumerB = { id: 'consumerB', type: 'modelicaComponent', data: { inputPorts: [{ name: 'P', type: 'number' }], outputPorts: [] } } as any
    const outlet = { id: 'Out1', type: 'matlabBoundary', label: 'result', data: {
      componentKind: 'boundaryPort', componentId: 'builtin.boundary.out', boundaryDirection: 'output',
      instanceName: 'result', inputPorts: [{ name: 'in', type: 'number' }]
    } } as any
    const edges = [
      { id: 'in_a', source: 'In1', sourceHandle: 'out', target: 'consumerA', targetHandle: 'P' },
      { id: 'in_b', source: 'In1', sourceHandle: 'out', target: 'consumerB', targetHandle: 'P' },
      { id: 'producer_a', source: 'producer', sourceHandle: 'Y', target: 'consumerA', targetHandle: 'Q' },
      { id: 'producer_out', source: 'producer', sourceHandle: 'Y', target: 'Out1', targetHandle: 'in' }
    ] as any[]
    const result = encapsulateSelection({
      nodes: [inlet, producer, consumerA, consumerB, outlet], dataEdges: edges,
      selectedIds: new Set(['In1', 'producer', 'consumerA', 'consumerB', 'Out1']),
      findNodePort: (node, direction, handle) => (direction === 'input' ? node?.data?.inputPorts : node?.data?.outputPorts)?.find((port: any) => port.name === handle),
      compositeId: 'subsystem', childSceneId: 'child', parentSceneId: 'root', instanceName: 'Subsystem'
    })
    expect(result.ok).toBe(true)
    if (!result.ok) return
    const explicitInput = result.boundaryPorts.find(port => port.interfaceNodeId === 'In1')!
    expect(explicitInput.mappings).toEqual([
      { childNodeId: 'consumerA', childPortId: 'P' },
      { childNodeId: 'consumerB', childPortId: 'P' }
    ])
    const explicitOutput = result.boundaryPorts.find(port => port.interfaceNodeId === 'Out1')!
    expect(explicitOutput.mapping).toEqual({ childNodeId: 'producer', childPortId: 'Y' })
    expect(result.childScene.dataEdges).toHaveLength(4)
  })

  it('封装 PMSM 节点生成通用子系统：无物理类型、数据边原样保留', () => {
    const nodes = [pmsmNode('m1'), pmsmNode('m2'), pmsmNode('m3')]
    const edges = [dataEdge('e1', 'm1', 'm2'), dataEdge('e2', 'm2', 'm3')]
    const result = encapsulateSelection({
      nodes, dataEdges: edges,
      selectedIds: new Set(['m1', 'm2', 'm3']),
      findNodePort,
      compositeId: 's1', childSceneId: 'scene_s1', parentSceneId: 'root', instanceName: 'S1'
    }) as any
    expect(result.ok).toBe(true)
    // 通用子系统：无 physicalSubsystem/physical 语义
    expect(result.compositeNode.data.nodeKind).toBe('subsystem')
    expect(result.compositeNode.data.executionKind).toBe('subsystem')
    expect(result.compositeNode.data.nodeKind).not.toBe('physicalSubsystem')
    // 子场景没有 kind；内部节点保持 matlabFunction
    expect(result.childScene.kind).toBeUndefined()
    expect(result.childScene.nodes.every((n: Node) => n.data?.nodeKind === 'matlabFunction')).toBe(true)
    // 内部数据边原样保留、无 flow 关系
    expect(result.childScene.dataEdges.map((e: Edge) => e.id)).toEqual(['e1', 'e2'])
    expect(result.childScene.dataEdges.every((e: Edge) => !e.data?.relation)).toBe(true)
    // 整段流程全部选中仍能从自由首尾端口推导公共接口。
    expect(result.boundaryPorts).toHaveLength(2)
    expect(result.boundaryPorts.map((p: any) => p.name)).toEqual(['in_1', 'out_1'])
    expect(result.boundaryPorts[0].mapping).toEqual({ childNodeId: 'm1', childPortId: 'IN' })
    expect(result.boundaryPorts[1].mapping).toEqual({ childNodeId: 'm3', childPortId: 'OUT' })
    expect(result.compositeNode.data.inputPorts).toHaveLength(1)
    expect(result.compositeNode.data.outputPorts).toHaveLength(1)
  })

  it('跨边界数据边生成 kind=data 边界端口并重连', () => {
    const nodes = [pmsmNode('a'), pmsmNode('b'), pmsmNode('c')]
    const edges = [dataEdge('e1', 'a', 'b'), dataEdge('e2', 'b', 'c')]
    const result = encapsulateSelection({
      nodes, dataEdges: edges,
      selectedIds: new Set(['b']),
      findNodePort,
      compositeId: 's1', childSceneId: 'scene_s1', parentSceneId: 'root', instanceName: 'S1'
    }) as any
    expect(result.ok).toBe(true)
    expect(result.boundaryPorts).toHaveLength(2)
    expect(result.boundaryPorts.every((p: any) => p.kind === 'data')).toBe(true)
    expect(result.boundaryPorts.map((p: any) => p.name)).toEqual(['in_1', 'out_1'])
    expect(result.nextEdges[0].target).toBe('s1')
    expect(result.nextEdges[0].data.subsystemBridge.originalTarget).toBe('b')
    expect(result.nextEdges[1].source).toBe('s1')
  })

  it('父场景只保留外部边和跨界边，内部边仅进入子场景', () => {
    const nodes = [pmsmNode('external'), pmsmNode('a'), pmsmNode('b'), pmsmNode('after')]
    const edges = [
      dataEdge('outside', 'external', 'after'),
      dataEdge('enter', 'external', 'a'),
      dataEdge('inside', 'a', 'b'),
      dataEdge('leave', 'b', 'after')
    ]
    const result = encapsulateSelection({
      nodes, dataEdges: edges, selectedIds: new Set(['a', 'b']), findNodePort,
      compositeId: 's1', childSceneId: 'scene_s1', parentSceneId: 'root', instanceName: 'S1'
    }) as any
    expect(result.nextEdges.map((edge: Edge) => edge.id).sort()).toEqual(['enter', 'leave', 'outside'])
    expect(result.childScene.dataEdges.map((edge: Edge) => edge.id)).toEqual(['inside'])
    expect(new Set(result.nextEdges.map((edge: Edge) => edge.id)).size).toBe(result.nextEdges.length)
  })

  it('保留自由输入的内部值与端口默认值', () => {
    const withValue = inferSubsystemBoundaryPorts({
      nodes: [pmsmNode('a', 12)], dataEdges: [], selectedIds: new Set(['a']), findNodePort
    }) as any
    expect(withValue.boundaryPorts.find((port: any) => port.direction === 'input').defaultValue).toBe(12)
    const withCatalogDefault = inferSubsystemBoundaryPorts({
      nodes: [pmsmNode('b')], dataEdges: [], selectedIds: new Set(['b']), findNodePort
    }) as any
    expect(withCatalogDefault.boundaryPorts.find((port: any) => port.direction === 'input').defaultValue).toBe(7)
  })

  it('空选择被拒绝', () => {
    const result = encapsulateSelection({
      nodes: [pmsmNode('a')], dataEdges: [], selectedIds: new Set(),
      findNodePort,
      compositeId: 's1', childSceneId: 'scene_s1', parentSceneId: 'root', instanceName: 'S1'
    })
    expect(result.ok).toBe(false)
  })

  it('输出扇出共享同一个子系统输出端口', () => {
    const nodes = [pmsmNode('inside'), pmsmNode('outside1'), pmsmNode('outside2')]
    const edges = [dataEdge('e1', 'inside', 'outside1'), dataEdge('e2', 'inside', 'outside2')]
    const result = encapsulateSelection({
      nodes, dataEdges: edges, selectedIds: new Set(['inside']), findNodePort,
      compositeId: 's1', childSceneId: 'scene_s1', parentSceneId: 'root', instanceName: 'S1'
    }) as any
    const output = result.boundaryPorts.filter((port: any) => port.direction === 'output')
    expect(output).toHaveLength(1)
    expect(result.nextEdges[0].sourceHandle).toBe(output[0].id)
    expect(result.nextEdges[1].sourceHandle).toBe(output[0].id)
  })

  it('跨界边引用不存在的端口时拒绝封装', () => {
    const edge = { ...dataEdge('broken', 'a', 'b'), targetHandle: 'MISSING' }
    const result = encapsulateSelection({
      nodes: [pmsmNode('a'), pmsmNode('b')], dataEdges: [edge],
      selectedIds: new Set(['b']), findNodePort,
      compositeId: 's1', childSceneId: 'scene_s1', parentSceneId: 'root', instanceName: 'S1'
    })
    expect(result).toMatchObject({ ok: false, reason: 'invalid-boundary-port', edgeId: 'broken', nodeId: 'b', portId: 'MISSING' })
  })
})

describe('unencapsulateSubsystem（V3）', () => {
  it('解封装恢复数据边连接；物理关系无需处理', () => {
    const nodes = [pmsmNode('a'), pmsmNode('b'), pmsmNode('c')]
    const edges = [dataEdge('e1', 'a', 'b'), dataEdge('e2', 'b', 'c')]
    const encapsulated = encapsulateSelection({
      nodes, dataEdges: edges,
      selectedIds: new Set(['b']),
      findNodePort,
      compositeId: 's1', childSceneId: 'scene_s1', parentSceneId: 'root', instanceName: 'S1'
    }) as any
    const restored = unencapsulateSubsystem({
      compositeNode: encapsulated.compositeNode,
      childScene: encapsulated.childScene,
      nodes: encapsulated.nextNodes,
      edges: encapsulated.nextEdges
    }) as any
    expect(restored.ok).toBe(true)
    const e1 = restored.nextEdges.find((e: Edge) => e.source === 'a' && e.target === 'b')
    const e2 = restored.nextEdges.find((e: Edge) => e.source === 'b' && e.target === 'c')
    expect(e1).toBeDefined()
    expect(e2).toBeDefined()
  })
})

describe('physical port isolation', () => {
  it('不会把发动机物理部件的 INPUT/OUTPUT 推导为通用数据接口', () => {
    const part = {
      id: 'inlet_1',
      position: { x: 0, y: 0 },
      data: {
        nodeKind: 'physicalComponent',
        physicalCapabilities: { flow: { inputs: [{ id: 'INPUT' }], outputs: [{ id: 'OUTPUT' }] } },
        inputPorts: [{ name: 'INPUT', type: 'bus' }],
        outputPorts: [{ name: 'OUTPUT', type: 'bus' }]
      }
    } as any as Node
    const inferred = inferSubsystemBoundaryPorts({
      nodes: [part], dataEdges: [], selectedIds: new Set(['inlet_1']), findNodePort
    })
    expect(inferred.ok).toBe(true)
    expect(inferred.ok && inferred.boundaryPorts).toEqual([])
  })

})
