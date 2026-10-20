import { describe, expect, it } from 'vitest'
import type { Node } from '@vue-flow/core'
import { emptyPhysicalAssembly } from '../physicalAssembly'
import { encapsulateSelection, unencapsulateSubsystem, type RuntimeSceneData } from '../sceneCommands'
import { projectPhysicalEdges, selectPhysicalLayoutEdges } from '../physicalView'

const node = (id: string): Node => ({ id, position: { x: 20, y: 40 }, data: {} })
const scene = (id: string, nodes: Node[]): RuntimeSceneData => ({ id, title: id, nodes, dataEdges: [],
  boundaryPorts: [], viewport: { x: 0, y: 0, zoom: 1 } })

describe('递归子系统物理关系投影', () => {
  it('通用子系统封装不生成物理边界端口且不修改物理装配', () => {
    const assembly = emptyPhysicalAssembly('engine', 'engine')
    assembly.memberNodeIds = ['a', 'b']
    assembly.flowRelations = [{ id: 'f', kind: 'flow', sourceNodeId: 'a', sourcePortId: 'OUTPUT',
      targetNodeId: 'b', targetPortId: 'INPUT' }]
    assembly.shaftGroups = [{ id: 's', name: '轴', kind: 'shaft', order: 1,
      memberNodeIds: ['a', 'b'], parameters: { E_mech: 0.985 } }]
    const root = scene('root', [node('a'), node('b')])
    const scenes: Record<string, RuntimeSceneData> = { root }
    const wrap = (selected: string, id: string) => {
      const result = encapsulateSelection({ nodes: root.nodes, dataEdges: [], selectedIds: new Set([selected]),
        findNodePort: () => undefined, compositeId: id, childSceneId: id + '_scene', parentSceneId: 'root', instanceName: id })
      if (!result.ok) throw new Error('封装失败')
      root.nodes = result.nextNodes
      scenes[result.childScene.id] = result.childScene
      return result
    }
    wrap('a', 'inner')
    const outer = wrap('inner', 'outer')
    expect(outer.childScene.boundaryPorts.some(port => port.kind !== 'data')).toBe(false)
    const restored = unencapsulateSubsystem({ compositeNode: outer.compositeNode, childScene: outer.childScene,
      nodes: root.nodes, edges: [] })
    if (!restored.ok) throw new Error('解封装失败')
    root.nodes = restored.nextNodes
    delete scenes.outer_scene
    expect(assembly.memberNodeIds).toEqual(['a', 'b'])
  })
  it('单部件轴组不生成自连线，普通工程不生成任何物理线', () => {
    const assembly = emptyPhysicalAssembly('single', 'single')
    assembly.memberNodeIds = ['a']
    assembly.shaftGroups = [{ id: 's', name: '轴', kind: 'shaft', order: 1, memberNodeIds: ['a'], parameters: {} }]
    const scenes = { root: scene('root', [node('a')]) }
    expect(projectPhysicalEdges(scenes, 'root', { single: assembly })).toEqual([])
    expect(projectPhysicalEdges(scenes, 'root', {})).toEqual([])
  })

  it('物理布局只使用气路投影边，轴系和引气只参与显示布线', () => {
    const dataEdge = { id: 'data', source: 'a', target: 'b', data: {} } as any
    const projected = [
      { id: 'flow', source: 'a', target: 'b', data: { physicalProjection: true, relation: 'flow' } },
      { id: 'shaft', source: 'a', target: 'b', data: { physicalProjection: true, relation: 'shaft' } },
      { id: 'bleed', source: 'a', target: 'b', data: { physicalProjection: true, relation: 'bleed' } }
    ] as any[]
    expect(selectPhysicalLayoutEdges([dataEdge], projected, true).map(edge => edge.id)).toEqual(['flow'])
    expect(selectPhysicalLayoutEdges([dataEdge], projected, false).map(edge => edge.id)).toEqual(['data'])
    expect(selectPhysicalLayoutEdges([dataEdge], projected.slice(1), true)).toEqual([])
    expect(selectPhysicalLayoutEdges([dataEdge], projected, true)).not.toBe(projected)
  })

  it('投影路由只装饰临时边，不修改装配关系', () => {
    const assembly = emptyPhysicalAssembly('engine', 'engine')
    assembly.memberNodeIds = ['a', 'b']
    assembly.flowRelations = [{ id: 'f', kind: 'flow', sourceNodeId: 'a', sourcePortId: 'OUTPUT',
      targetNodeId: 'b', targetPortId: 'INPUT' }]
    const scenes = { root: scene('root', [node('a'), node('b')]) }
    const edgeId = 'physical:engine:f'
    const points = [{ x: 1, y: 2 }, { x: 3, y: 4 }]
    const projected = projectPhysicalEdges(scenes, 'root', { engine: assembly }, { [edgeId]: points })
    expect(projected[0].data.elkPoints).toEqual(points)
    expect(assembly.flowRelations[0]).not.toHaveProperty('elkPoints')
    expect(scenes.root.dataEdges).toEqual([])
  })
})
