import { beforeEach, describe, expect, it } from 'vitest'
import { createPinia, setActivePinia } from 'pinia'
import type { Node } from '@vue-flow/core'
import { emptyPhysicalAssembly, type PhysicalAssembly } from '../../domain/physicalAssembly'
import { DEFAULT_MATLAB_ROOT_SCENE_ID, useMatlabEditorStore } from '../useMatlabEditorStore'

const node = (id: string): Node => ({ id, position: { x: 0, y: 0 }, data: { instanceName: id } })

const scene = (id: string, nodes: Node[]) => ({
  id,
  title: id,
  nodes,
  dataEdges: [],
  boundaryPorts: [],
  viewport: { x: 0, y: 0, zoom: 1 }
})

const assembly = (id: string, memberNodeIds: string[]): PhysicalAssembly => ({
  ...emptyPhysicalAssembly(id, id),
  memberNodeIds
})

describe('useMatlabEditorStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('切层不复制图数据：画布读取的就是场景自己的数组', () => {
    const store = useMatlabEditorStore()
    const sharedNodes = [node('a'), node('b')]
    store.resetProject({ root: scene('root', []), child: scene('child', sharedNodes) }, 'root')
    store.setActiveScene('child')
    expect(store.activeSceneNodes).toBe(store.scenes.child.nodes)
    const replaced = [node('c')]
    store.setActiveSceneNodes(replaced)
    expect(store.scenes.child.nodes).toBe(store.activeSceneNodes)
    expect(store.scenes.child.nodes).toHaveLength(1)
    store.setActiveScene('root')
    store.setActiveScene('child')
    expect(store.activeSceneNodes).toBe(store.scenes.child.nodes)
  })

  it('切层递增 layoutRevision，使旧布局任务失效', () => {
    const store = useMatlabEditorStore()
    store.resetProject({ root: scene('root', []), child: scene('child', []) }, 'root')
    const before = store.layoutRevisions.child ?? 0
    store.setActiveScene('child')
    const afterFirst = store.sceneRevision
    expect(afterFirst).toBeGreaterThan(before)
    store.setActiveScene('root')
    store.setActiveScene('child')
    expect(store.sceneRevision).toBeGreaterThan(afterFirst)
  })

  it('viewport 显式保存到指定场景', () => {
    const store = useMatlabEditorStore()
    store.resetProject({ root: scene('root', []) }, 'root')
    store.saveViewport('root', { x: 120, y: -40, zoom: 1.5 })
    expect(store.scenes.root.viewport).toEqual({ x: 120, y: -40, zoom: 1.5 })
  })

  it('resetProject 重置 revision 且默认根场景常驻', () => {
    const store = useMatlabEditorStore()
    expect(store.scenes[DEFAULT_MATLAB_ROOT_SCENE_ID]).toBeDefined()
    store.resetProject({ other: scene('other', []) }, 'other')
    expect(store.activeSceneId).toBe('other')
    expect(Object.keys(store.scenes)).toEqual(['other'])
    expect(store.layoutRevisions.other).toBe(1)
  })

  it('物理装配域：upsert/remove/activeAssembly 语义', () => {
    const store = useMatlabEditorStore()
    store.resetProject({ root: scene('root', []) }, 'root', {})
    const a = assembly('assembly_a', ['n1'])
    store.upsertAssembly(a)
    expect(store.activeAssemblyId).toBe('assembly_a')
    expect(store.activeAssembly?.memberNodeIds).toEqual(['n1'])
    const b = assembly('assembly_b', ['n2'])
    store.upsertAssembly(b)
    expect(store.activeAssemblyId).toBe('assembly_a')
    store.removeAssembly('assembly_a')
    expect(store.activeAssemblyId).toBe('assembly_b')
    store.removeAssembly('assembly_b')
    expect(store.activeAssembly).toBeUndefined()
  })

  it('轴组重排或新增时按稳定组 ID 同步逐轴功率', () => {
    const store = useMatlabEditorStore()
    const shaftPort = { name: 'generator_power_kw', type: 'array', dynamicLength: { source: 'shaftGroups', defaultValue: 0 } }
    const root = scene('root', [
      { ...node('engine'), data: { ...node('engine').data, childSceneId: 'workflow', inputPorts: [shaftPort], values: { generator_power_kw: [100, 200] } } }
    ])
    const workflow = scene('workflow', [
      { ...node('design'), data: { ...node('design').data, childSceneId: 'design_point' } }
    ])
    const designPoint = scene('design_point', [
      { ...node('physical'), data: { ...node('physical').data, childSceneId: 'physical', physicalAssemblyId: 'assembly_engine' } }
    ])
    const physical = scene('physical', [
      { ...node('descriptor'), data: { ...node('descriptor').data, childSceneId: 'assembly_relations', physicalAssemblyId: 'assembly_engine' } }
    ])
    const groups = [
      { id: 'shaft_a', kind: 'shaft' as const, name: '低压轴', order: 1, memberNodeIds: [], parameters: {} },
      { id: 'shaft_b', kind: 'shaft' as const, name: '高压轴', order: 2, memberNodeIds: [], parameters: {} }
    ]
    const original = { ...assembly('assembly_engine', []), shaftGroups: groups }
    store.resetProject({ root, workflow, design_point: designPoint, physical }, 'root', { assembly_engine: original })
    store.upsertAssembly({ ...original, shaftGroups: [
      { ...groups[1], order: 1 }, { ...groups[0], order: 2 }, { ...groups[0], id: 'shaft_c', name: '新轴', order: 3 }
    ] })
    expect(store.scenes.root.nodes[0].data.values.generator_power_kw).toEqual([200, 100, 0])
  })
})
