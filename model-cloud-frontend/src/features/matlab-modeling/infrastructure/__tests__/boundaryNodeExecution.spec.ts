import { describe, expect, it } from 'vitest'
import type { Edge, Node } from '@vue-flow/core'
import { compileExecutionPayload, type ExecutionSceneSnapshot } from '../executionPayloadCompiler'

const node = (id: string, extra: Record<string, any> = {}): Node => ({
  id, position: { x: 0, y: 0 }, data: { values: {}, resources: {}, ...extra }
} as Node)
const edge = (id: string, source: string, sourceHandle: string, target: string, targetHandle: string): Edge => ({
  id, source, sourceHandle, target, targetHandle, data: {}
} as Edge)

describe('explicit In/Out execution projection', () => {
  it('removes interface declarations and keeps a one-to-many input mapping', () => {
    const scenes: Record<string, ExecutionSceneSnapshot> = {
      root: {
        id: 'root', title: '根场景', boundaryPorts: [],
        nodes: [node('sub', { componentId: 'sub', nodeKind: 'subsystem', childSceneId: 'child', boundaryPorts: [] })],
        dataEdges: []
      },
      child: {
        id: 'child', title: 'child', boundaryPorts: [],
        nodes: [
          node('in', { componentId: 'builtin.boundary.in', componentKind: 'boundaryPort', nodeKind: 'boundaryPort', boundaryDirection: 'input', instanceName: 'shaft_power', outputPorts: [{ name: 'out', type: 'number' }] }),
          node('a', { inputPorts: [{ name: 'P', type: 'number' }] }),
          node('b', { inputPorts: [{ name: 'P', type: 'number' }] }),
          node('out', { componentId: 'builtin.boundary.out', componentKind: 'boundaryPort', nodeKind: 'boundaryPort', boundaryDirection: 'output', instanceName: 'result', inputPorts: [{ name: 'in', type: 'number' }] })
        ],
        dataEdges: [edge('i-a', 'in', 'out', 'a', 'P'), edge('i-b', 'in', 'out', 'b', 'P'), edge('a-out', 'a', 'Y', 'out', 'in')]
      }
    }
    const result = compileExecutionPayload({ rootSceneId: 'root', scenes, isBusNode: () => false })!
    const child = result.executionPayload.scenes.find(scene => scene.id === 'child')!
    expect(child.nodes.map((item: any) => item.id)).toEqual(['a', 'b'])
    expect(child.edges).toHaveLength(0)
    const input = child.boundaryPorts.find((port: any) => port.direction === 'input')
    expect(input.mappings).toEqual([
      { childNodeId: 'a', childPortId: 'P' },
      { childNodeId: 'b', childPortId: 'P' }
    ])
    const output = child.boundaryPorts.find((port: any) => port.direction === 'output')
    expect(output.mapping).toEqual({ childNodeId: 'a', childPortId: 'Y' })
  })
})
