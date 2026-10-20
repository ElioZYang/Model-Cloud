import { describe, expect, it } from 'vitest'
import { emptyPhysicalAssembly } from '../physicalAssembly'
import { instantiateWorkflowTemplate } from '../templateInstantiation'

const buildTemplate = () => ({
  rootSceneId: 'workflow',
  scenes: {
    workflow: {
      id: 'workflow',
      title: '构型工作流',
      boundaryPorts: [],
      viewport: { x: 0, y: 0, zoom: 1 },
      nodes: [{
        id: 'design_point', componentId: 'engine.configuration.design-point',
        functionName: '', instanceName: '设计点模型', values: {}, resources: {},
        nodeKind: 'subsystem', childSceneId: 'design_scene'
      }, {
        id: 'result_sink', componentId: 'test.result-sink', functionName: 'result_sink',
        instanceName: '结果接收', values: {}, resources: {}, nodeKind: 'workflowNode'
      }],
      dataEdges: [{ id: 'workflow_dp_to_sink', sourceNodeId: 'design_point', sourcePort: 'DP', targetNodeId: 'result_sink', targetPort: 'DP' }]
    },
    design_scene: {
      id: 'design_scene',
      parentSceneId: 'workflow',
      title: '设计点',
      boundaryPorts: [
        { id: 'V', name: 'V', kind: 'data', direction: 'input', dataType: 'number', mapping: { childNodeId: 'init_1', childPortId: 'V' } },
        { id: 'DP', name: 'DP', kind: 'data', direction: 'output', mapping: { childNodeId: 'init_1', childPortId: 'DP' } }
      ],
      viewport: { x: 0, y: 0, zoom: 1 },
      nodes: [{
        id: 'init_1', componentId: 'engine.stage.initialize-configuration',
        functionName: 'component_engine_initialize_configuration', instanceName: '初始化',
        nodeKind: 'matlabFunction', values: {}, resources: {}
      }, {
        id: 'inlet_1', componentId: 'engine.gas-path.inlet',
        functionName: 'INLET', instanceName: '进气道',
        nodeKind: 'physicalComponent', legacyName: 'inlet', legacyOrder: 1,
        values: {}, resources: {}
      }],
      dataEdges: []
    }
  },
  physicalAssemblies: (() => {
    const assembly = emptyPhysicalAssembly('turboshaft', '涡轴')
    assembly.memberNodeIds = ['inlet_1']
    assembly.flowRelations = [{
      id: 'flow_1', kind: 'flow', sourceNodeId: 'inlet_1', sourcePortId: 'OUTPUT',
      targetNodeId: 'inlet_1', targetPortId: 'INPUT'
    }]
    return { turboshaft: assembly }
  })()
})

describe('instantiateWorkflowTemplate（V3）', () => {
  it('修改实例轴参数不会污染另一实例或模板', () => {
    const template = buildTemplate()
    template.physicalAssemblies.turboshaft.shaftGroups = [{ id: 'shaft', kind: 'shaft', name: '轴', order: 1,
      memberNodeIds: ['inlet_1'], parameters: { E_mech: 0.985 } }]
    const make = (token: string) => instantiateWorkflowTemplate({ template, templateInputs: [], templateOutputs: [],
      instanceToken: token, instanceName: token, componentId: 'engine.configuration.turboshaft', componentName: '涡轴' })
    const first = make('first')
    const second = make('second')
    if (!first.ok || !second.ok) throw new Error('模板实例化失败')
    Object.values(first.assemblies)[0].shaftGroups[0].parameters.E_mech = 0.9
    expect(Object.values(second.assemblies)[0].shaftGroups[0].parameters.E_mech).toBe(0.985)
    expect(template.physicalAssemblies.turboshaft.shaftGroups[0].parameters.E_mech).toBe(0.985)
    const child = first.scenes.find(scene => scene.sceneId.endsWith('design_scene'))!
    expect(child.boundaryPorts[0].mapping?.childNodeId).toBe('node_first_init_1')
  })
  const instance = instantiateWorkflowTemplate({
    template: buildTemplate() as any,
    templateInputs: [{ name: 'V', type: 'number', min: 0 }],
    templateOutputs: [{ name: 'DP', type: 'unknown' }],
    instanceToken: 'T1',
    instanceName: '构型 1',
    componentId: 'engine.configuration.turboshaft',
    componentName: '涡轴'
  }) as any

  it('拒绝无效模板', () => {
    const bad = instantiateWorkflowTemplate({
      template: {}, templateInputs: [], templateOutputs: [],
      instanceToken: 'T', instanceName: 'x',
      componentId: 'c', componentName: 'c'
    })
    expect(bad.ok).toBe(false)
  })

  it('实例化后场景、节点、边 ID 全部带实例标记且不重复', () => {
    expect(instance.ok).not.toBe(false)
    expect(instance.scenes).toHaveLength(2)
    expect(instance.rootChildId).toBe('scene_T1_workflow')
    const allNodeIds = instance.scenes.flatMap((s: any) => s.savedNodes.map((n: any) => n.id))
    expect(new Set(allNodeIds).size).toBe(allNodeIds.length)
    expect(allNodeIds).toContain('node_T1_init_1')
  })

  it('模板实例化保留持久化 DAG 边字段并重映射源和目标节点', () => {
    const workflow = instance.scenes.find((scene: any) => scene.sceneId === 'scene_T1_workflow')
    expect(workflow.savedEdges).toHaveLength(1)
    expect(workflow.savedEdges[0]).toMatchObject({
      sourceNodeId: 'node_T1_design_point',
      sourcePort: 'DP',
      targetNodeId: 'node_T1_result_sink',
      targetPort: 'DP'
    })
    expect(workflow.savedEdges[0]).not.toHaveProperty('source')
    expect(workflow.savedEdges[0]).not.toHaveProperty('target')
  })

  it('子系统统一为 nodeKind=subsystem', () => {
    const workflow = instance.scenes.find((s: any) => s.sceneId === 'scene_T1_workflow')
    expect(workflow.savedNodes[0].nodeKind).toBe('subsystem')
    expect(workflow.savedNodes[0].nodeKind).not.toBe('physicalSubsystem')
    expect(workflow.savedNodes[0].boundaryPorts[0].mapping.childNodeId).toBe('node_T1_init_1')
    expect(workflow.savedNodes[0].boundaryPorts[0].mapping.childPortId).toBe('V')
  })

  it('装配域深复制：成员与关系 ID 重映射', () => {
    const assembly = instance.assemblies['assembly_T1_turboshaft']
    expect(assembly).toBeDefined()
    expect(assembly.memberNodeIds).toContain('node_T1_inlet_1')
    expect(assembly.flowRelations[0].sourceNodeId).toBe('node_T1_inlet_1')
  })

  it('两次实例化使用不同 token 时 ID 完全隔离', () => {
    const second = instantiateWorkflowTemplate({
      template: buildTemplate() as any,
      templateInputs: [{ name: 'V', type: 'number' }],
      templateOutputs: [{ name: 'DP', type: 'unknown' }],
      instanceToken: 'T2',
      instanceName: '构型 2',
      componentId: 'engine.configuration.turboshaft',
      componentName: '涡轴'
    }) as any
    const firstIds = new Set(instance.scenes.flatMap((s: any) => s.savedNodes.map((n: any) => n.id)))
    const secondIds = second.scenes.flatMap((s: any) => s.savedNodes.map((n: any) => n.id))
    secondIds.forEach((id: string) => expect(firstIds.has(id)).toBe(false))
  })
})
