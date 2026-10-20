import { describe, expect, it } from 'vitest'
import type { Node } from '@vue-flow/core'
import { parseMatlabProject, serializeMatlabProject } from '../projectCodec'
import { readPersistedDataEdges } from '../dataEdgeAdapter'

const toRuntimeNode = (saved: any): Node => ({
  id: saved.id,
  position: saved.position || { x: 0, y: 0 },
  data: { ...saved }
} as Node)

const toRuntimeScene = (scene: any) => ({
  ...scene,
  nodes: scene.nodes.map(toRuntimeNode),
  edges: scene.dataEdges.map((edge: any) => ({ id: edge.id, source: edge.sourceNodeId, target: edge.targetNodeId, data: { ...edge } }))
})

const buildV3Project = () => ({
  schemaVersion: 3,
  engineType: 'matlab',
  rootSceneId: 'scene_root',
  scenes: {
    scene_root: {
      id: 'scene_root',
      title: '根场景',
      boundaryPorts: [],
      viewport: { x: 10, y: 20, zoom: 1.5 },
      nodes: [{
        id: 'config_1',
        componentId: 'engine.configuration.turboshaft',
        functionName: '',
        instanceName: '涡轴构型',
        nodeKind: 'subsystem',
        childSceneId: 'scene_child',
        activeModes: ['design'],
        values: { THRUST: 98, generator_power_kw: [0, 1000] },
        resources: {},
        boundaryPorts: [{
          id: 'DP', name: 'DP', displayName: '设计点', kind: 'data', direction: 'output',
          required: false, defaultValue: 12,
          mapping: { childNodeId: 'init_1', childPortId: 'DP' }
        }, {
          id: 'generator_power_kw', name: 'generator_power_kw', kind: 'data', direction: 'input', dataType: 'array',
          dynamicLength: { source: 'shaftGroups', defaultValue: 0 },
          mapping: { childNodeId: 'conditions_1', childPortId: 'generator_power_kw' }
        }],
        position: { x: 100, y: 80 }
      }],
      dataEdges: []
    },
    scene_child: {
      id: 'scene_child',
      parentSceneId: 'scene_root',
      title: '设计点',
      boundaryPorts: [],
      viewport: { x: 0, y: 0, zoom: 1 },
      nodes: [{
        id: 'init_1',
        componentId: 'engine.stage.initialize-configuration',
        functionName: 'component_engine_initialize_configuration',
        instanceName: '初始化',
        nodeKind: 'matlabFunction',
        values: {},
        resources: {}
      }, {
        id: 'assembly_descriptor',
        componentId: 'project.subsystem.engine-assembly-relations',
        functionName: '',
        instanceName: '装配关系',
        nodeKind: 'subsystem',
        executionKind: 'subsystem',
        physicalAssemblyId: 'assembly_turboshaft',
        childSceneId: 'scene_physical',
        boundaryPorts: [{ id: 'assembly_json', name: 'assembly_json', kind: 'data', direction: 'output',
          dataType: 'string', mapping: { childNodeId: '$physicalAssembly:assembly_turboshaft', childPortId: 'assembly_json' } }],
        values: {}, resources: {}
      }],
      dataEdges: []
    },
    scene_physical: {
      id: 'scene_physical', parentSceneId: 'scene_child', title: '装配关系',
      boundaryPorts: [], viewport: { x: 0, y: 0, zoom: 1 },
      nodes: [{ id: 'inlet_1', componentId: 'engine.gas-path.inlet', instanceName: '进气道 1',
        nodeKind: 'physicalComponent', values: {}, resources: {} }],
      dataEdges: []
    }
  },
  physicalAssemblies: {
    assembly_turboshaft: {
      id: 'assembly_turboshaft',
      name: '涡轴',
      domain: 'aircraft-engine',
      memberNodeIds: ['inlet_1'],
      flowRelations: [],
      shaftGroups: [],
      bleedGroups: [],
      initializerBinding: { nodeId: 'init_1', inputPort: 'assembly_json' },
      defaults: { type: 'turboshaft' }
    }
  }
})

describe('projectCodec（V3）', () => {
  it('V3 工程 serialize→parse 往返保持场景与装配一致', () => {
    const project = buildV3Project() as any
    const serialized = serializeMatlabProject(
      Object.fromEntries(Object.entries(project.scenes).map(([id, scene]: [string, any]) => [id, toRuntimeScene(scene)])) as any,
      project.physicalAssemblies,
      'scene_root'
    )
    const roundTripped = parseMatlabProject(JSON.stringify(serialized))
    expect(roundTripped.project.schemaVersion).toBe(3)
    expect(Object.keys(roundTripped.project.scenes).sort()).toEqual(['scene_child', 'scene_physical', 'scene_root'])
    expect(roundTripped.project.scenes.scene_root.nodes[0].instanceName).toBe('涡轴构型')
    expect(roundTripped.project.scenes.scene_root.nodes[0].activeModes).toEqual(['design'])
    expect(roundTripped.project.scenes.scene_root.nodes[0].boundaryPorts?.[0]).toMatchObject({
      displayName: '设计点', required: false, defaultValue: 12
    })
    expect(roundTripped.project.scenes.scene_root.nodes[0].values.generator_power_kw).toEqual([0, 1000])
    expect(roundTripped.project.scenes.scene_root.nodes[0].boundaryPorts?.[1].dynamicLength)
      .toEqual({ source: 'shaftGroups', defaultValue: 0 })
    expect(roundTripped.project.physicalAssemblies.assembly_turboshaft.defaults).toEqual({ type: 'turboshaft' })
    expect(roundTripped.project.physicalAssemblies.assembly_turboshaft.initializerBinding.nodeId).toBe('init_1')
    expect(roundTripped.project.scenes.scene_child.nodes[1].physicalAssemblyId).toBe('assembly_turboshaft')
  })

  it('V2 工程（kind 场景）经导入器升级为 V3', () => {
    const v2 = {
      schemaVersion: 2,
      engineType: 'matlab',
      rootSceneId: 'scene_root',
      scenes: {
        scene_root: {
          id: 'scene_root', kind: 'workflow', title: '根场景', boundaryPorts: [],
          viewport: { x: 0, y: 0, zoom: 1 },
          nodes: [{ id: 'a', componentId: 'pmsm.x', functionName: 'X', instanceName: 'a', nodeKind: 'matlabFunction', values: {}, resources: {} }],
          edges: [{ id: 'e1', source: 'a', sourceHandle: 'OUT', target: 'a', targetHandle: 'IN' }]
        }
      },
      nodes: [], edges: []
    }
    const result = parseMatlabProject(JSON.stringify(v2))
    expect(result.project.schemaVersion).toBe(3)
    expect(result.project.scenes.scene_root.nodes[0].nodeKind).toBe('matlabFunction')
    expect(result.wrongPhysicalSceneIds).toHaveLength(0)
  })

  it('错误的 PMSM 物理子系统被识别并报告（不静默修改）', () => {
    const v2 = {
      schemaVersion: 2,
      engineType: 'matlab',
      rootSceneId: 'scene_root',
      scenes: {
        scene_root: {
          id: 'scene_root', kind: 'workflow', title: '根场景', boundaryPorts: [],
          viewport: { x: 0, y: 0, zoom: 1 },
          nodes: [{ id: 'w', componentId: 'pmsm.wrap', nodeKind: 'physicalSubsystem', childSceneId: 'scene_p', values: {}, resources: {} }],
          edges: []
        },
        scene_p: {
          id: 'scene_p', kind: 'physical', parentSceneId: 'scene_root', title: '误封',
          boundaryPorts: [], viewport: { x: 0, y: 0, zoom: 1 },
          nodes: [
            { id: 'm1', componentId: 'pmsm.a', nodeKind: 'matlabFunction', values: {}, resources: {} },
            { id: 'm2', componentId: 'pmsm.b', nodeKind: 'matlabFunction', values: {}, resources: {} }
          ],
          edges: [{ id: 'e1', source: 'm1', sourceHandle: 'OUT', target: 'm2', targetHandle: 'IN', data: { relation: 'flow' } }],
          relationGroups: []
        }
      },
      nodes: [], edges: []
    }
    const result = parseMatlabProject(JSON.stringify(v2))
    expect(result.wrongPhysicalSceneIds).toEqual(['scene_p'])
    const scene = result.project.scenes.scene_p
    expect(scene.dataEdges[0]).not.toHaveProperty('relation')
    expect(result.project.physicalAssemblies).toEqual({})
  })

  it('真实发动机物理场景转换为 PhysicalAssembly', () => {
    const v2 = {
      schemaVersion: 2,
      engineType: 'matlab',
      rootSceneId: 'scene_root',
      scenes: {
        scene_root: {
          id: 'scene_root', kind: 'workflow', title: '根场景', boundaryPorts: [],
          viewport: { x: 0, y: 0, zoom: 1 },
          nodes: [{ id: 'phys_configuration', componentId: 'engine.stage.initialize-configuration', nodeKind: 'physicalSubsystem', childSceneId: 'scene_p', values: {}, resources: {} }],
          edges: []
        },
        scene_p: {
          id: 'scene_p', kind: 'physical', parentSceneId: 'scene_root', title: '涡轴',
          boundaryPorts: [],
          assemblyDefaults: { type: 'turboshaft', THRUST: 0 },
          viewport: { x: 0, y: 0, zoom: 1 },
          nodes: [
            { id: 'inlet_1', componentId: 'engine.gas-path.inlet', nodeKind: 'physicalComponent', legacyName: 'inlet', legacyOrder: 1, values: {}, resources: {} },
            { id: 'hpc_1', componentId: 'engine.gas-path.hpc', nodeKind: 'physicalComponent', legacyName: 'hpc', legacyOrder: 2, values: {}, resources: {} }
          ],
          edges: [
            { id: 'f1', source: 'inlet_1', sourceHandle: 'OUTPUT', target: 'hpc_1', targetHandle: 'INPUT', data: { relation: 'flow' } }
          ],
          relationGroups: [
            { id: 'shaft_1', relation: 'shaft', name: '轴 1', order: 1, anchorNodeId: 'hpc_1', parameters: { E_mech: 0.985 } }
          ]
        }
      },
      nodes: [], edges: []
    }
    const result = parseMatlabProject(JSON.stringify(v2))
    const assemblies = result.project.physicalAssemblies
    expect(Object.keys(assemblies)).toHaveLength(1)
    const assembly = Object.values(assemblies)[0]
    expect(assembly.memberNodeIds).toEqual(['inlet_1', 'hpc_1'])
    expect(assembly.flowRelations).toHaveLength(1)
    expect(assembly.flowRelations[0].sourceNodeId).toBe('inlet_1')
    expect(assembly.shaftGroups[0].parameters.E_mech).toBe(0.985)
    expect(assembly.defaults.type).toBe('turboshaft')
    expect(assembly.initializerBinding.nodeId).toBe('phys_configuration')
  })

  it('缺少端点的数据边保留并标记 unresolved', () => {
    const v3 = {
      schemaVersion: 3,
      engineType: 'matlab',
      rootSceneId: 'scene_root',
      scenes: {
        scene_root: {
          id: 'scene_root', title: '根场景', boundaryPorts: [],
          viewport: { x: 0, y: 0, zoom: 1 },
          nodes: [],
          dataEdges: [{ id: 'bad', sourceNodeId: 'a', sourcePort: 'OUT', targetNodeId: '', targetPort: '' }]
        }
      },
      physicalAssemblies: {}
    }
    const result = parseMatlabProject(JSON.stringify(v3))
    const edges = result.project.scenes.scene_root.dataEdges
    expect(edges).toHaveLength(1)
    expect(edges[0].unresolved).toBe(true)
  })

  it('保留持久化端点，不用旧画布端点替换缺失节点', () => {
    const v3 = {
      schemaVersion: 3,
      engineType: 'matlab',
      rootSceneId: 'scene_root',
      scenes: {
        scene_root: {
          id: 'scene_root', title: '根场景', boundaryPorts: [],
          viewport: { x: 0, y: 0, zoom: 1 },
          nodes: [
            { id: 'source_current', componentId: 'source', nodeKind: 'matlabFunction', values: {}, resources: {} },
            { id: 'target_current', componentId: 'target', nodeKind: 'matlabFunction', values: {}, resources: {} }
          ],
          dataEdges: [{
            id: 'legacy-remapped-edge',
            sourceNodeId: 'source_before_remap', sourcePort: 'OUT',
            targetNodeId: 'target_before_remap', targetPort: 'IN',
            source: 'source_current', sourceHandle: 'OUT',
            target: 'target_current', targetHandle: 'IN'
          }]
        }
      },
      physicalAssemblies: {}
    }
    const parsed = parseMatlabProject(JSON.stringify(v3)).project
    const persisted = parsed.scenes.scene_root.dataEdges[0]
    expect(persisted).toMatchObject({
      sourceNodeId: 'source_before_remap',
      targetNodeId: 'target_before_remap',
      legacyRuntimeEndpoints: { source: 'source_current', target: 'target_current' }
    })

    const nodes = [
      { id: 'source_current', position: { x: 0, y: 0 }, data: { outputPorts: [{ name: 'OUT', type: 'number' }] } },
      { id: 'target_current', position: { x: 0, y: 0 }, data: { inputPorts: [{ name: 'IN', type: 'number' }] } }
    ] as any
    const [restored] = readPersistedDataEdges([persisted], nodes, (sourceType, targetType) => sourceType === targetType)
    expect(restored).toMatchObject({
      sourceNodeId: 'source_before_remap', sourcePort: 'OUT',
      targetNodeId: 'target_before_remap', targetPort: 'IN', unresolved: true
    })
  })
})
