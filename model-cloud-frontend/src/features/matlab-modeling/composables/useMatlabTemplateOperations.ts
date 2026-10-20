import { ElMessage } from 'element-plus'
import type { Node } from '@vue-flow/core'
import type { MatlabComponent } from '@/api/matlab-model-deploy'
import { cloneMatlabGraph } from '../domain/projectCodec'
import { instantiateWorkflowTemplate } from '../domain/templateInstantiation'
import type { RuntimeSceneData } from '../domain/sceneCommands'
import { useMatlabEditorStore } from '../stores/useMatlabEditorStore'

type MatlabPortLike = { name: string; type: string; unit?: string; shape?: number[]; min?: number; max?: number }

/** 页面侧的运行时场景类型（与 RuntimeSceneData 结构一致）。 */
type RuntimeScene = RuntimeSceneData

/**
 * 模板操作：完整构型模板的实例化。
 * ID 深复制/重映射在 domain 纯函数中完成；本组合式只补充位置计算、
 * 运行时重建、持久化与布局调度。
 */
export function useMatlabTemplateOperations(deps: {
  nodes: { value: Node[] }
  activeSceneId: { value: string }
  normalizeComponentPorts: (rawPorts: unknown, componentName: string, direction: '输入' | '输出') => MatlabPortLike[]
  nextInstanceName: (base: string) => string
  rebuildProjectGraph: (projectData: any) => { runtimeNodes: Node[]; runtimeEdges: any[]; warnings?: string[] }
  flowContainer: { value: HTMLElement | null | undefined }
  selectNodeById: (nodeId: string) => void
  scheduleElkLayout: (fitAfterLayout?: boolean, mode?: 'full' | 'routing') => void
}) {
  const editorStore = useMatlabEditorStore()

  const instantiateTemplateComponent = (component: MatlabComponent, event: DragEvent) => {
    const instance = instantiateWorkflowTemplate({
      template: component.templateDefinition as any,
      templateInputs: deps.normalizeComponentPorts(component.inputs, component.name, '输入'),
      templateOutputs: deps.normalizeComponentPorts(component.outputs, component.name, '输出'),
      instanceToken: `${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
      instanceName: deps.nextInstanceName(component.legacyName || component.functionName || component.name),
      componentId: component.id,
      componentName: component.name,
      functionName: component.functionName,
      legacyName: component.legacyName,
      modelEntrypoints: component.modelEntrypoints,
      legacyOrder: component.legacyOrder,
      assemblyDefaults: component.assemblyDefaults
    })
    if (!instance.ok) return false
    const rect = deps.flowContainer.value?.getBoundingClientRect()
    const position = rect
      ? { x: Math.max(20, event.clientX - rect.left - 160), y: Math.max(20, event.clientY - rect.top - 60) }
      : { x: 120, y: 80 }
    const createdScenes: Record<string, RuntimeScene> = {}
    instance.scenes.forEach((remapped) => {
      const rebuilt = deps.rebuildProjectGraph({
        schemaVersion: 3,
        engineType: 'matlab',
        rootSceneId: remapped.sceneId,
        scenes: {},
        physicalAssemblies: {},
        nodes: remapped.savedNodes,
        dataEdges: remapped.savedEdges
      })
      createdScenes[remapped.sceneId] = {
        id: remapped.sceneId,
        parentSceneId: remapped.parentSceneId ?? deps.activeSceneId.value,
        title: remapped.title,
        nodes: rebuilt.runtimeNodes,
        dataEdges: rebuilt.runtimeEdges as any,
        boundaryPorts: cloneMatlabGraph(remapped.boundaryPorts),
        viewport: remapped.viewport
      }
    })
    Object.assign(editorStore.scenes, createdScenes)
    Object.assign(editorStore.physicalAssemblies, instance.assemblies)
    editorStore.activeAssemblyId = Object.keys(instance.assemblies)[0] || editorStore.activeAssemblyId
    const rootScene = createdScenes[instance.rootChildId]
    const boundaryPorts = rootScene?.boundaryPorts?.length ? rootScene.boundaryPorts : instance.rootBoundaryPorts
    // 复合节点上的边界端口映射必须指向重映射后的子场景节点。
    instance.compositeNodeData.boundaryPorts = cloneMatlabGraph(boundaryPorts)
    instance.compositeNodeData.physicalCapabilities = component.physicalCapabilities
    const compositeNode: Node = {
      id: instance.compositeId,
      type: 'matlabComposite',
      position,
      label: instance.compositeNodeData.instanceName,
      data: instance.compositeNodeData
    }
    deps.nodes.value = [...deps.nodes.value.map((node) => ({ ...node, selected: false })), { ...compositeNode, selected: true }]
    deps.selectNodeById(compositeNode.id)
    deps.scheduleElkLayout(false, 'routing')
    ElMessage.success(`已实例化构型：${component.name}`)
    return true
  }

  return { instantiateTemplateComponent }
}
