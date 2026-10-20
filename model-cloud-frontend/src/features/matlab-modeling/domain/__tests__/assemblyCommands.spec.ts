import { describe, expect, it } from 'vitest'
import { createAssemblyRelation, resolveAssemblyInitializer, synchronizeAssemblyBindings } from '../assemblyCommands'
import { emptyPhysicalAssembly } from '../physicalAssembly'

const part = (id: string) => ({
  id,
  position: { x: 10, y: 20 },
  data: { componentId: 'engine.physical.hpc', physicalCapabilities: { flow: { inputs: [], outputs: [] } } }
}) as any

describe('manual engine assembly creation', () => {
  it('moves selected parts into a compile-time descriptor and preserves relations', () => {
    const assembly = emptyPhysicalAssembly('old', 'old')
    assembly.memberNodeIds = ['a', 'b']
    assembly.flowRelations = [{ id: 'f1', kind: 'flow', sourceNodeId: 'a', sourcePortId: 'OUT', targetNodeId: 'b', targetPortId: 'IN' }]
    const result = createAssemblyRelation({
      nodes: [part('a'), part('b')], edges: [], assemblies: { old: assembly },
      selectedIds: new Set(['a', 'b']), sceneId: 'root', assemblyId: 'new',
      relationSceneId: 'relations', descriptorNodeId: 'descriptor', name: '装配关系 1'
    })
    expect(result.ok).toBe(true)
    if (!result.ok) return
    expect(result.scene.nodes.map((node: any) => node.id)).toEqual(['a', 'b'])
    expect(result.nodes.map(node => node.id)).toEqual(['descriptor'])
    expect(result.assembly.flowRelations).toEqual(assembly.flowRelations)
    expect(result.descriptor.data.outputPorts[0].name).toBe('assembly_json')
    expect(result.descriptor.data.boundaryPorts).toEqual([])
    expect(result.descriptor.data.nodeKind).toBe('assemblyDescriptor')
    expect(result.descriptor.data.executionKind).toBe('compileTimeAssembly')
  })

  it('rejects selections that split a saved assembly or cross an ordinary data edge', () => {
    const assembly = emptyPhysicalAssembly('old', 'old')
    assembly.memberNodeIds = ['a', 'b']
    const split = createAssemblyRelation({
      nodes: [part('a'), part('b')], edges: [], assemblies: { old: assembly },
      selectedIds: new Set(['a']), sceneId: 'root', assemblyId: 'new',
      relationSceneId: 'relations', descriptorNodeId: 'descriptor', name: '装配关系'
    })
    expect(split.ok).toBe(false)

    const connected = createAssemblyRelation({
      nodes: [part('a')], edges: [{ id: 'e', source: 'a', target: 'x' }] as any, assemblies: {},
      selectedIds: new Set(['a']), sceneId: 'root', assemblyId: 'new',
      relationSceneId: 'relations', descriptorNodeId: 'descriptor', name: '装配关系'
    })
    expect(connected.ok).toBe(false)
  })

  it('recursively collects physical members from organization-only subsystems', () => {
    const wrapper = { id: 'group', data: { nodeKind: 'subsystem', childSceneId: 'child' } } as any
    const result = createAssemblyRelation({
      nodes: [wrapper], edges: [], assemblies: {},
      scenes: { child: { nodes: [part('nested-part')], dataEdges: [] } },
      selectedIds: new Set(['group']), sceneId: 'root', assemblyId: 'assembly',
      relationSceneId: 'relations', descriptorNodeId: 'descriptor', name: '装配关系'
    })
    expect(result.ok).toBe(true)
    if (!result.ok) return
    expect(result.assembly.memberNodeIds).toEqual(['nested-part'])
    expect(result.scene.nodes.map((node: any) => node.id)).toEqual(['group'])
  })

  it('derives initializer binding from the visible assembly_json edge', () => {
    const assembly = emptyPhysicalAssembly('assembly', 'assembly')
    const result = synchronizeAssemblyBindings({
      root: {
        nodes: [
          { id: 'descriptor', data: { physicalAssemblyId: 'assembly' } } as any,
          { id: 'dp', data: { componentId: 'engine.stage.initialize-configuration' } } as any
        ],
        dataEdges: [{ id: 'e', source: 'descriptor', sourceHandle: 'assembly_json', target: 'dp', targetHandle: 'assembly_json' } as any]
      }
    }, { assembly })
    expect(result.assembly.initializerBinding).toEqual({ nodeId: 'dp', inputPort: 'assembly_json' })
  })

  it('resolves the visible data route through multiple generic subsystem boundaries', () => {
    const scenes: any = {
      root: {
        nodes: [
          { id: 'left', data: { childSceneId: 'left-child', boundaryPorts: [{ id: 'left_out', kind: 'data', direction: 'output', mapping: { childNodeId: 'left-inner', childPortId: 'inner_out' } }] } },
          { id: 'right', data: { childSceneId: 'right-child', boundaryPorts: [{ id: 'right_in', kind: 'data', direction: 'input', mapping: { childNodeId: 'right-inner', childPortId: 'inner_in' } }] } }
        ],
        dataEdges: [{ id: 'outer', source: 'left', sourceHandle: 'left_out', target: 'right', targetHandle: 'right_in' }]
      },
      'left-child': {
        nodes: [{ id: 'left-inner', data: { childSceneId: 'descriptor-leaf', boundaryPorts: [{ id: 'inner_out', kind: 'data', direction: 'output', mapping: { childNodeId: 'descriptor', childPortId: 'assembly_json' } }] } }], dataEdges: []
      },
      'right-child': {
        nodes: [{ id: 'right-inner', data: { childSceneId: 'dp-leaf', boundaryPorts: [{ id: 'inner_in', kind: 'data', direction: 'input', mapping: { childNodeId: 'dp', childPortId: 'assembly_json' } }] } }], dataEdges: []
      },
      'descriptor-leaf': {
        nodes: [{ id: 'descriptor', data: { physicalAssemblyId: 'assembly' } }], dataEdges: []
      },
      'dp-leaf': {
        nodes: [{ id: 'dp', data: { componentId: 'engine.stage.initialize-configuration' } }], dataEdges: []
      }
    }
    expect(resolveAssemblyInitializer(scenes, 'assembly')).toBe('dp')
    const assembly = emptyPhysicalAssembly('assembly', 'assembly')
    expect(synchronizeAssemblyBindings(scenes, { assembly }).assembly.initializerBinding.nodeId).toBe('dp')
  })
})
