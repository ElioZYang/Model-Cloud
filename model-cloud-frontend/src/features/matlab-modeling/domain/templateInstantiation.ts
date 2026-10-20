import type {
  BoundaryPort,
  PhysicalAssembly,
  SceneNode
} from './physicalAssembly'
import { cloneMatlabGraph, makeCompositePortData, parseMatlabProject } from './projectCodec'

/** 目录端口的结构化子集（与 api 层 MatlabPort 结构兼容，避免 domain 依赖 api）。 */
export type TemplatePort = {
  name: string
  type: string
  unit?: string
  shape?: number[]
  dynamicLength?: { source: 'shaftGroups'; defaultValue: number }
  defaultValue?: number | string | boolean | number[] | number[][]
  min?: number
  max?: number
}

/**
 * 完整构型模板实例化（V3）：所有内部 Scene 都是通用 Scene；
 * 物理语义由模板携带的 PhysicalAssembly 定义。
 * ID 深复制由 instanceToken 唯一化；位置、运行时重建与持久化由调用方负责。
 */
export type RemappedTemplateScene = {
  sceneId: string
  parentSceneId?: string
  title: string
  isRoot: boolean
  savedNodes: SceneNode[]
  savedEdges: Array<Record<string, any>>
  boundaryPorts: BoundaryPort[]
  viewport: { x: number; y: number; zoom: number }
}

export type WorkflowTemplateInstance = {
  ok: true
  rootChildId: string
  rootBoundaryPorts: BoundaryPort[]
  scenes: RemappedTemplateScene[]
  compositeId: string
  compositeNodeData: Record<string, any>
  assemblies: Record<string, PhysicalAssembly>
  nodeIdMap: Map<string, string>
  sceneIdMap: Map<string, string>
}

type TemplateDefinition = {
  rootSceneId?: string
  scenes?: unknown
  physicalAssemblies?: Record<string, any>
}

export const instantiateWorkflowTemplate = (input: {
  template: TemplateDefinition
  templateInputs: TemplatePort[]
  templateOutputs: TemplatePort[]
  instanceToken: string
  instanceName: string
  componentId: string
  componentName: string
  functionName?: string
  legacyName?: string
  legacyOrder?: number
  assemblyDefaults?: Record<string, any>
  modelEntrypoints?: Record<string, string>
}): WorkflowTemplateInstance | { ok: false; reason: 'invalid-template' } => {
  const { template } = input
  if (!template || !template.scenes || typeof template.scenes !== 'object') {
    return { ok: false, reason: 'invalid-template' }
  }
  const parsed = parseMatlabProject(JSON.stringify({
    schemaVersion: 3,
    engineType: 'matlab',
    rootSceneId: template.rootSceneId,
    scenes: template.scenes,
    physicalAssemblies: template.physicalAssemblies || {}
  }))
  const instanceToken = input.instanceToken
  const sceneIdMap = new Map<string, string>()
  Object.keys(parsed.project.scenes).forEach((id) => sceneIdMap.set(id, `scene_${instanceToken}_${id}`))
  const assemblyIdMap = new Map<string, string>()
  Object.keys(parsed.project.physicalAssemblies).forEach((id) => assemblyIdMap.set(id, `assembly_${instanceToken}_${id}`))
  const nodeIdMap = new Map<string, string>()
  Object.values(parsed.project.scenes).forEach((scene) => scene.nodes.forEach((node) => {
    nodeIdMap.set(`${scene.id}:${node.id}`, `node_${instanceToken}_${node.id}`)
  }))

  const templateInputs = input.templateInputs
  const templateOutputs = input.templateOutputs
  const rawRootBoundaryPorts = parsed.project.scenes[parsed.project.rootSceneId]?.boundaryPorts || []
  let inputBoundaryIndex = 0
  let outputBoundaryIndex = 0
  const rootBoundaryPorts: BoundaryPort[] = rawRootBoundaryPorts.length > 0
    ? rawRootBoundaryPorts.map((port) => {
        const catalogPort = port.direction === 'input'
          ? templateInputs[inputBoundaryIndex++]
          : templateOutputs[outputBoundaryIndex++]
        const externalName = catalogPort?.name || port.name
        return {
          ...port,
          id: externalName,
          name: externalName,
          dataType: catalogPort?.type || port.dataType,
          unit: catalogPort?.unit || port.unit,
          shape: catalogPort?.shape || port.shape,
          dynamicLength: catalogPort?.dynamicLength || port.dynamicLength
        }
      })
    : [
        ...templateInputs.map((port) => ({
          id: port.name, name: port.name, kind: 'data' as const, direction: 'input' as const,
          dataType: port.type, unit: port.unit, shape: port.shape, dynamicLength: port.dynamicLength,
          mapping: { childNodeId: '', childPortId: '' }
        })),
        ...templateOutputs.map((port) => ({
          id: port.name, name: port.name, kind: 'data' as const, direction: 'output' as const,
          dataType: port.type, unit: port.unit, shape: port.shape,
          mapping: { childNodeId: '', childPortId: '' }
        }))
      ]

  const rootChildId = sceneIdMap.get(parsed.project.rootSceneId) as string
  const enclosingScenes = new Map<string, string>()
  Object.values(parsed.project.scenes).forEach(scene => scene.nodes.forEach(node => {
    if (node.childSceneId) enclosingScenes.set(node.childSceneId, scene.id)
  }))
  const scenes: RemappedTemplateScene[] = Object.values(parsed.project.scenes).map((sourceScene) => {
    const newSceneId = sceneIdMap.get(sourceScene.id) as string
    const savedNodes = sourceScene.nodes.map((saved) => ({
      ...saved,
      id: nodeIdMap.get(`${sourceScene.id}:${saved.id}`) || saved.id,
      childSceneId: saved.childSceneId ? sceneIdMap.get(saved.childSceneId) : undefined,
      modelEntrypoints: saved.modelEntrypoints ? Object.fromEntries(Object.entries(saved.modelEntrypoints)
        .map(([mode, id]) => [mode, sceneIdMap.get(id) || id])) : undefined,
      physicalAssemblyId: saved.physicalAssemblyId
        ? assemblyIdMap.get(saved.physicalAssemblyId) || saved.physicalAssemblyId : undefined,
      boundaryPorts: remapClonedBoundaryPorts(saved.boundaryPorts?.length ? saved.boundaryPorts
        : (saved.childSceneId ? parsed.project.scenes[saved.childSceneId]?.boundaryPorts : []),
        nodeIdMap, [saved.childSceneId, sourceScene.id], assemblyIdMap),
      nodeKind: saved.childSceneId ? 'subsystem' : saved.nodeKind,
      executionKind: saved.childSceneId ? 'subsystem' : saved.executionKind,
      position: saved.position || { x: 40, y: saved.legacyOrder ? saved.legacyOrder * 120 : 80 }
    }))
    const savedEdges = sourceScene.dataEdges.map((edge) => ({
      ...edge,
      id: `edge_${instanceToken}_${edge.id}`,
      // Keep the persisted graph contract here. Vue Flow's source/target
      // handles are created later by rebuildProjectGraph at the UI boundary.
      sourceNodeId: nodeIdMap.get(`${sourceScene.id}:${edge.sourceNodeId}`) || edge.sourceNodeId,
      sourcePort: edge.sourcePort,
      targetNodeId: nodeIdMap.get(`${sourceScene.id}:${edge.targetNodeId}`) || edge.targetNodeId,
      targetPort: edge.targetPort
    }))
    const sourceBoundaryPorts = sourceScene.id === parsed.project.rootSceneId ? rootBoundaryPorts : sourceScene.boundaryPorts
    return {
      sceneId: newSceneId,
      parentSceneId: sceneIdMap.get(enclosingScenes.get(sourceScene.id) || sourceScene.parentSceneId || ''),
      title: sourceScene.id === parsed.project.rootSceneId
        ? `${input.instanceName} · ${sourceScene.title}`
        : sourceScene.title,
      isRoot: sourceScene.id === parsed.project.rootSceneId,
      savedNodes,
      savedEdges,
      boundaryPorts: remapClonedBoundaryPorts(sourceBoundaryPorts, nodeIdMap, [sourceScene.id], assemblyIdMap),
      viewport: cloneMatlabGraph(sourceScene.viewport)
    }
  })

  // 装配域：成员与关系 ID 深复制（装配引用的是项目唯一节点 ID，用扁平表映射）
  const flatNodeMap = new Map<string, string>()
  nodeIdMap.forEach((newId, key) => {
    flatNodeMap.set(key.split(':').slice(1).join(':'), newId)
  })
  const assemblies: Record<string, PhysicalAssembly> = {}
  Object.entries(parsed.project.physicalAssemblies).forEach(([assemblyId, assembly]) => {
    const remappedAssemblyId = assemblyIdMap.get(assemblyId) || `assembly_${instanceToken}_${assemblyId}`
    assemblies[remappedAssemblyId] = remapAssembly(assembly, remappedAssemblyId, flatNodeMap)
  })

  const compositePorts = makeCompositePortData(
    rootBoundaryPorts.filter((port) => port.kind === 'data' && port.direction)
  )
  const compositeValues = Object.fromEntries(templateInputs
    .filter((port) => port.type === 'number' || port.type === 'array')
    .map((port) => [port.name, port.type === 'array'
      ? cloneMatlabGraph(port.defaultValue ?? [])
      : initialNumericValue(port)]))
  return {
    ok: true,
    rootChildId,
    rootBoundaryPorts,
    scenes,
    compositeId: `matlab_subsystem_${instanceToken}`,
    compositeNodeData: {
      componentId: input.componentId,
      componentName: input.componentName,
      instanceName: input.instanceName,
      functionName: input.functionName,
      nodeKind: 'subsystem',
      sceneNodeKind: 'subsystem',
      executionKind: 'subsystem',
      childSceneId: rootChildId,
      modelEntrypoints: input.modelEntrypoints ? Object.fromEntries(Object.entries(input.modelEntrypoints)
        .map(([mode, id]) => [mode, sceneIdMap.get(id) || id])) : undefined,
      boundaryPorts: cloneMatlabGraph(rootBoundaryPorts),
      assemblyDefaults: input.assemblyDefaults,
      legacyName: input.legacyName,
      legacyOrder: input.legacyOrder,
      ...compositePorts,
      values: compositeValues,
      resources: {}
    },
    assemblies,
    nodeIdMap,
    sceneIdMap
  }
}

const remapAssembly = (
  assembly: any,
  newAssemblyId: string,
  nodeIdMap: Map<string, string>
): PhysicalAssembly => ({
  ...cloneMatlabGraph(assembly),
  id: newAssemblyId,
  memberNodeIds: (assembly.memberNodeIds as string[]).map((id: string) => nodeIdMap.get(id) || id),
  motorBindings: assembly.motorBindings?.map((binding: { motorNodeId: string; shaftGroupId: string }) => ({
    motorNodeId: nodeIdMap.get(binding.motorNodeId) || binding.motorNodeId,
    shaftGroupId: `${newAssemblyId}_${binding.shaftGroupId}`
  })),
  flowRelations: (assembly.flowRelations as any[]).map((relation) => ({
    ...cloneMatlabGraph(relation),
    id: `${newAssemblyId}_${relation.id}`,
    sourceNodeId: nodeIdMap.get(relation.sourceNodeId) || relation.sourceNodeId,
    targetNodeId: nodeIdMap.get(relation.targetNodeId) || relation.targetNodeId
  })),
  shaftGroups: (assembly.shaftGroups as any[]).map((group) => ({
    ...cloneMatlabGraph(group),
    id: `${newAssemblyId}_${group.id}`,
    memberNodeIds: (group.memberNodeIds as string[]).map((id: string) => nodeIdMap.get(id) || id)
  })),
  bleedGroups: (assembly.bleedGroups as any[]).map((group) => ({
    ...cloneMatlabGraph(group),
    id: `${newAssemblyId}_${group.id}`,
    memberNodeIds: (group.memberNodeIds as string[]).map((id: string) => nodeIdMap.get(id) || id)
  })),
  initializerBinding: {
    ...assembly.initializerBinding,
    nodeId: nodeIdMap.get(assembly.initializerBinding?.nodeId) || assembly.initializerBinding?.nodeId
  }
}) as PhysicalAssembly

const remapClonedBoundaryPorts = (
  ports: BoundaryPort[] | undefined,
  nodeIdMap: Map<string, string>,
  preferredSceneIds: Array<string | undefined>,
  assemblyIdMap: Map<string, string>
) => {
  const remapEndpoint = (endpoint: { childNodeId: string; childPortId: string } | undefined) => {
    if (!endpoint) return undefined
    const physicalAssembly = endpoint.childNodeId.match(/^\$physicalAssembly:(.+)$/)
    if (physicalAssembly) {
      const remappedAssemblyId = assemblyIdMap.get(physicalAssembly[1])
      return {
        ...endpoint,
        childNodeId: remappedAssemblyId ? `$physicalAssembly:${remappedAssemblyId}` : endpoint.childNodeId
      }
    }
    return {
      ...endpoint,
      childNodeId: preferredSceneIds
        .filter((sceneId): sceneId is string => Boolean(sceneId))
        .map((sceneId) => nodeIdMap.get(`${sceneId}:${endpoint.childNodeId}`))
        .find(Boolean) || endpoint.childNodeId
    }
  }
  return (ports || []).map((port) => ({
    ...cloneMatlabGraph(port),
    mapping: remapEndpoint(port.mapping),
    mappings: port.mappings?.map(remapEndpoint).filter((endpoint): endpoint is NonNullable<typeof endpoint> => Boolean(endpoint))
  }))
}

const initialNumericValue = (port: TemplatePort) => {
  const defaultValue = finiteMetadataNumber(port.defaultValue)
  if (defaultValue != null) return defaultValue
  const minimum = finiteMetadataNumber(port.min)
  return minimum ?? 0
}

const finiteMetadataNumber = (value: unknown) => {
  // 未设置的元数据不能通过 Number(null/空字符串/布尔值) 变成 0 或 1。
  if (typeof value !== 'number' && typeof value !== 'string') return undefined
  if (typeof value === 'string' && value.trim() === '') return undefined
  const parsed = Number(value)
  return Number.isFinite(parsed) ? parsed : undefined
}
