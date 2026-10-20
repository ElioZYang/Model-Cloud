import type { MatlabProjectV3, MatlabSceneV3, PhysicalAssembly, FlowRelation, ShaftRelationGroup, BleedRelationGroup, DataEdge, SceneNode, BoundaryPort } from './physicalAssembly'
import { emptyPhysicalAssembly } from './physicalAssembly'
import { cloneMatlabGraph } from './projectCodec'

/**
 * V2 → V3 一次性导入器（唯一允许引用旧物理语义的模块之一）。
 *
 * 转换规则：
 * - Scene kind 删除；所有子系统统一为 nodeKind 'subsystem'；
 * - 普通数据边剥离 relation/streamRole/groupId；
 * - "错误的 PMSM 物理子系统"（内部全为 pmsm/Bus/普通函数且无真实物理关系）
 *   转成通用 Scene，并写入升级报告；
 * - 真实发动机物理 Scene 转成 通用 Scene + PhysicalAssembly
 *   （flow 边→FlowRelation，relationGroups→shaft/bleed 组，assemblyDefaults→defaults）；
 * - initializerBinding 取包装初始化节点（initialize-configuration / physical_configuration），
 *   不得按名称猜测以外的来源。
 */

export type V3UpgradeReport = {
  /** 被识别为"错误 PMSM 物理子系统"并转换的场景 ID。 */
  wrongPhysicalSceneIds: string[]
  /** 被识别为真实发动机物理场景并生成装配的场景 ID → 装配 ID。 */
  convertedAssemblyScenes: Record<string, string>
  warnings: string[]
}

const ENGINE_GAS_PATH_PREFIX = 'engine.gas-path.'
const INITIALIZER_COMPONENT = 'engine.stage.initialize-configuration'

const isEngineGasPathNode = (node: SceneNode | any): boolean =>
  String(node?.componentId || '').startsWith(ENGINE_GAS_PATH_PREFIX)

const isInitializerNode = (node: SceneNode | any): boolean =>
  String(node?.componentId || '') === INITIALIZER_COMPONENT
  || node?.id === 'physical_configuration'


/** 判断旧 physical 场景是否为"错误的 PMSM 物理子系统"。 */
export const isWrongPmsmPhysicalScene = (scene: any): boolean => {
  if (scene?.kind !== 'physical') return false
  const nodes: any[] = Array.isArray(scene?.nodes) ? scene.nodes : []
  if (nodes.length === 0) return false
  const hasEnginePart = nodes.some(isEngineGasPathNode)
  if (hasEnginePart) return false
  const groups: any[] = Array.isArray(scene?.relationGroups) ? scene.relationGroups : []
  const hasRealGroups = groups.some((group) => Array.isArray(group?.members) || group?.memberNodeIds?.length)
  // 旧错误子系统可能带空组或无组
  return !hasRealGroups
}

const toDataEdge = (edge: any): DataEdge => ({
  id: String(edge?.id || ''),
  sourceNodeId: String(edge?.sourceNodeId || edge?.source || ''),
  sourcePort: String(edge?.sourcePort || edge?.sourceHandle || ''),
  targetNodeId: String(edge?.targetNodeId || edge?.target || ''),
  targetPort: String(edge?.targetPort || edge?.targetHandle || ''),
  legacyRuntimeEndpoints: edge?.source != null || edge?.sourceHandle != null
    || edge?.target != null || edge?.targetHandle != null ? {
        source: edge?.source == null ? undefined : String(edge.source),
        sourceHandle: edge?.sourceHandle == null ? undefined : String(edge.sourceHandle),
        target: edge?.target == null ? undefined : String(edge.target),
        targetHandle: edge?.targetHandle == null ? undefined : String(edge.targetHandle)
      } : undefined,
  unresolved: edge?.unresolved === true || edge?.data?.unresolved === true || undefined
})

const edgeNodeCandidates = (edge: any, direction: 'source' | 'target'): string[] => direction === 'source'
  ? [edge?.sourceNodeId, edge?.source, edge?.legacyRuntimeEndpoints?.source].map(value => String(value || '').trim()).filter(Boolean)
  : [edge?.targetNodeId, edge?.target, edge?.legacyRuntimeEndpoints?.target].map(value => String(value || '').trim()).filter(Boolean)

const resolveEdgeNodeId = (edge: any, direction: 'source' | 'target', knownNodeIds: Set<string>): string => {
  const candidates = edgeNodeCandidates(edge, direction)
  return candidates.find(candidate => knownNodeIds.has(candidate)) || candidates[0] || ''
}

const toSceneNode = (node: any): SceneNode => {
  const nodeKindRaw = String(node?.nodeKind || node?.executionKind || node?.sceneNodeKind || 'matlabFunction')
  const isSubsystem = nodeKindRaw === 'workflowSubsystem' || nodeKindRaw === 'physicalSubsystem'
    || Boolean(node?.childSceneId)
  return {
    id: String(node?.id || ''),
    componentId: String(node?.data?.componentId || node?.componentId || ''),
    nodeKind: isSubsystem ? 'subsystem' : nodeKindRaw,
    physicalAssemblyId: node?.data?.physicalAssemblyId || node?.physicalAssemblyId
      ? String(node?.data?.physicalAssemblyId || node?.physicalAssemblyId) : undefined,
    boundaryDirection: node?.boundaryDirection === 'input' || node?.boundaryDirection === 'output'
      ? node.boundaryDirection : undefined,
    childSceneId: node?.data?.childSceneId ? String(node.data.childSceneId) : node?.childSceneId ? String(node.childSceneId) : undefined,
    instanceName: node?.data?.instanceName || node?.instanceName || node?.label || '',
    functionName: node?.data?.functionName || node?.functionName || '',
    executionKind: isSubsystem ? 'subsystem' : (node?.data?.executionKind || node?.executionKind),
    values: { ...(node?.data?.values || node?.values || {}) },
    resources: { ...(node?.data?.resources || node?.resources || {}) },
    legacyOrder: Number.isFinite(Number(node?.data?.legacyOrder ?? node?.legacyOrder))
      ? Number(node?.data?.legacyOrder ?? node?.legacyOrder) : undefined,
    legacyName: node?.data?.legacyName || node?.legacyName,
    assemblyDefaults: node?.data?.assemblyDefaults || node?.assemblyDefaults,
    busConfig: node?.data?.busConfig || node?.busConfig,
    selectorConfig: node?.data?.selectorConfig || node?.selectorConfig,
    boundaryPorts: (node?.data?.boundaryPorts || node?.boundaryPorts || []).map(upgradeBoundaryPort),
    position: node?.position ? { x: Number(node.position.x) || 0, y: Number(node.position.y) || 0 } : undefined,
    unresolved: node?.data?.unresolved === true || node?.unresolved === true
  }
}

/** 真实发动机物理场景 → PhysicalAssembly。 */
const convertEnginePhysicalScene = (
  scene: any,
  assemblyId: string,
  warnings: string[]
): PhysicalAssembly => {
  const assembly = emptyPhysicalAssembly(assemblyId, String(scene?.title || assemblyId))
  const nodes: any[] = Array.isArray(scene?.nodes) ? scene.nodes : []
  const knownNodeIds = new Set(nodes.map((node) => String(node?.id || '')).filter(Boolean))
  assembly.memberNodeIds = nodes.filter(isEngineGasPathNode).map((node) => String(node.id))

  const edges: any[] = Array.isArray(scene?.edges) ? scene.edges : []
  assembly.flowRelations = edges
    .filter((edge) => (edge?.data?.relation || edge?.relation) === 'flow')
    .map((edge): FlowRelation => ({
      id: `flow_${assemblyId}_${String(edge?.id || assembly.flowRelations.length + 1)}`,
      kind: 'flow',
      sourceNodeId: resolveEdgeNodeId(edge, 'source', knownNodeIds),
      sourcePortId: String(edge?.sourceHandle || edge?.sourcePort || 'OUTPUT'),
      targetNodeId: resolveEdgeNodeId(edge, 'target', knownNodeIds),
      targetPortId: String(edge?.targetHandle || edge?.targetPort || 'INPUT'),
      streamRole: edge?.data?.streamRole === 'bypass' || edge?.data?.streamRole === 'core'
        ? edge.data.streamRole : undefined
    }))

  const groups: any[] = Array.isArray(scene?.relationGroups) ? scene.relationGroups : []
  let shaftIndex = 0
  let bleedIndex = 0
  groups.forEach((group, index) => {
    const relation = String(group?.relation || 'shaft')
    const members = Array.isArray(group?.members) ? group.members.map(String)
      : Array.isArray(group?.memberNodeIds) ? group.memberNodeIds.map(String)
      : memberNodeIdsFromEdges(group, edges, knownNodeIds)
    if (relation === 'shaft') {
      shaftIndex += 1
      assembly.shaftGroups.push({
        id: String(group?.id || `shaft_${assemblyId}_${index}`),
        kind: 'shaft',
        name: String(group?.name || `轴 ${shaftIndex}`),
        order: Number(group?.order) || shaftIndex,
        memberNodeIds: members,
        parameters: {
          ...cloneMatlabGraph(group?.parameters || {}),
          E_mech: cloneMatlabGraph(group?.parameters?.E_mech ?? 0.985)
        }
      } satisfies ShaftRelationGroup)
    } else if (relation === 'bleed') {
      bleedIndex += 1
      assembly.bleedGroups.push({
        id: String(group?.id || `bleed_${assemblyId}_${index}`),
        kind: 'bleed',
        name: String(group?.name || `引气组 ${bleedIndex}`),
        order: Number(group?.order) || bleedIndex,
        memberNodeIds: members
      } satisfies BleedRelationGroup)
    }
  })

  const initializer = nodes.find(isInitializerNode)
  if (initializer) {
    assembly.initializerBinding.nodeId = String(initializer.id)
  } else {
    warnings.push(`物理场景 ${scene?.id || assemblyId} 缺少构型初始化节点，绑定需要手动补齐`)
  }
  assembly.defaults = { ...(scene?.assemblyDefaults || {}) }
  return assembly
}

const memberNodeIdsFromEdges = (group: any, edges: any[], knownNodeIds: Set<string>): string[] => {
  const members = new Set<string>([String(group?.anchorNodeId || '')])
  edges.forEach((edge) => {
    if ((edge?.data?.groupId || edge?.groupId) !== group?.id) return
    if ((edge?.data?.relation || edge?.relation) === group?.relation) {
      members.add(resolveEdgeNodeId(edge, 'source', knownNodeIds))
      members.add(resolveEdgeNodeId(edge, 'target', knownNodeIds))
    }
  })
  members.delete('')
  return [...members]
}

const upgradeBoundaryPort = (port: any): BoundaryPort => ({
  id: String(port.id), name: String(port.name || port.id), kind: port.kind || 'data',
  displayName: port.displayName || port.description,
  direction: port.direction, dataType: port.dataType || port.type, unit: port.unit, shape: port.shape,
  required: typeof port.required === 'boolean' ? port.required : undefined,
  defaultValue: typeof port.defaultValue === 'number' || typeof port.defaultValue === 'string'
    || typeof port.defaultValue === 'boolean' ? port.defaultValue : undefined,
  mapping: port.mapping ? { childNodeId: String(port.mapping.childNodeId || ''),
    childPortId: String(port.mapping.childPortId || port.mapping.childHandle || '') } : undefined,
  mappings: Array.isArray(port.mappings) ? port.mappings.map((mapping: any) => ({
    childNodeId: String(mapping.childNodeId || ''),
    childPortId: String(mapping.childPortId || mapping.childHandle || '')
  })) : undefined,
  semanticKey: port.semanticKey ? String(port.semanticKey) : undefined,
  interfaceNodeId: port.interfaceNodeId ? String(port.interfaceNodeId) : undefined
})

/** V2 工程文档 → V3。接受 V2 对象形状（scenes 携带 kind/edges/relationGroups）。 */
export const upgradeProjectToV3 = (
  raw: any,
  report: V3UpgradeReport = { wrongPhysicalSceneIds: [], convertedAssemblyScenes: {}, warnings: [] }
): { project: MatlabProjectV3; report: V3UpgradeReport } => {
  const rootSceneId = String(raw?.rootSceneId || 'scene_root')
  const scenes: Record<string, MatlabSceneV3> = {}
  const physicalAssemblies: Record<string, PhysicalAssembly> = {}

  const rawScenes: Record<string, any> = {}
  if (raw?.scenes && typeof raw.scenes === 'object') {
    Object.assign(rawScenes, raw.scenes)
  } else {
    rawScenes[rootSceneId] = {
      id: rootSceneId,
      kind: 'workflow',
      title: '根场景',
      nodes: Array.isArray(raw?.nodes) ? raw.nodes : [],
      edges: Array.isArray(raw?.edges) ? raw.edges : [],
      boundaryPorts: []
    }
  }

  Object.entries(rawScenes).forEach(([sceneId, scene]) => {
    const convertedNodes = (Array.isArray(scene?.nodes) ? scene.nodes : []).map(toSceneNode)
    const wrongPmsm = isWrongPmsmPhysicalScene(scene)
    if (wrongPmsm) {
      report.wrongPhysicalSceneIds.push(sceneId)
    }
    const dataEdges: DataEdge[] = (Array.isArray(scene?.edges) ? scene.edges : []).map(toDataEdge)
    const boundaryPorts: BoundaryPort[] = (Array.isArray(scene?.boundaryPorts) ? scene.boundaryPorts : []).map((port: any) => ({
      ...upgradeBoundaryPort(port)
    }))
    const upgradedScene: MatlabSceneV3 = {
      id: String(scene?.id || sceneId),
      parentSceneId: scene?.parentSceneId ? String(scene.parentSceneId) : undefined,
      title: String(scene?.title || scene?.name || sceneId),
      nodes: convertedNodes,
      dataEdges,
      boundaryPorts,
      viewport: {
        x: Number(scene?.viewport?.x) || 0,
        y: Number(scene?.viewport?.y) || 0,
        zoom: Number(scene?.viewport?.zoom) || 1
      }
    }
    scenes[upgradedScene.id] = upgradedScene

    // 真实发动机物理场景 → PhysicalAssembly
    if (scene?.kind === 'physical' && !wrongPmsm) {
      const hasEnginePart = convertedNodes.some(isEngineGasPathNode)
      if (hasEnginePart) {
        const assemblyId = `assembly_${sceneId}`
        const assembly = convertEnginePhysicalScene(scene, assemblyId, report.warnings)
        // 初始化包装节点通常在父场景中通过 childSceneId 指向本场景
        if (!assembly.initializerBinding.nodeId) {
          for (const otherScene of Object.values(rawScenes)) {
            if (otherScene === scene) continue
            const wrapper = (Array.isArray(otherScene?.nodes) ? otherScene.nodes : []).find((node: any) =>
              String(node?.data?.childSceneId || node?.childSceneId || '') === sceneId && isInitializerNode(node))
            if (wrapper) {
              assembly.initializerBinding.nodeId = String(wrapper?.data?.id || wrapper?.id || '')
              break
            }
          }
        }
        physicalAssemblies[assemblyId] = assembly
        upgradedScene.dataEdges = upgradedScene.dataEdges.filter(edge =>
          !assembly.memberNodeIds.includes(edge.sourceNodeId) && !assembly.memberNodeIds.includes(edge.targetNodeId))
        report.convertedAssemblyScenes[sceneId] = assemblyId
      } else {
        report.warnings.push(`物理场景 ${sceneId} 不含发动机气路部件且非 PMSM 误封，按通用场景转换`)
      }
    }
  })

  // 子系统父指针修正
  Object.values(scenes).forEach((scene) => {
    if (scene.parentSceneId && !scenes[scene.parentSceneId]) scene.parentSceneId = rootSceneId
  })

  return {
    project: {
      schemaVersion: 3,
      engineType: 'matlab',
      rootSceneId,
      scenes,
      physicalAssemblies
    },
    report
  }
}
