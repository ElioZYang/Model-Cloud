import { computed, ref } from 'vue'
import { ElMessage } from 'element-plus'
import type { Edge, Node } from '@vue-flow/core'
import type { PhysicalLensMode } from '@/composables/useMatlabPhysicalLens'
export type PhysicalStreamRole = 'core' | 'bypass'
import type {
  BleedRelationGroup,
  PhysicalAssembly,
  ShaftOrBleedGroup,
  ShaftRelationGroup
} from '../domain/physicalAssembly'
import { useMatlabEditorStore } from '../stores/useMatlabEditorStore'
import { emptyPhysicalAssembly, physicalCapabilitiesOf } from '../domain/physicalAssembly'
import { resolvePhysicalLeaf } from '../domain/physicalView'

/**
 * 物理装配编辑（V3）：轴/引气组与气路关系的增删改，直接作用于
 * 编辑器 store 的 PhysicalAssembly。透视入口由部件能力与装配成员决定，
 * 不再由 Scene 类型决定。
 */
export function useMatlabPhysicalAssemblyEditor(deps: {
  nodes: { value: Node[] }
  edges: { value: Edge[] }
  physicalLensMode: { value: PhysicalLensMode }
  physicalRelation: { value: 'flow' | 'shaft' | 'bleed' }
  selectedNode: { value: Node | null | undefined }
  selectedNodeId: { value: string | null }
  selectedEdgeId: { value: string | null }
  resetResultData: () => void
}) {
  const store = useMatlabEditorStore()
  const {
    nodes, edges, physicalLensMode, physicalRelation,
    selectedNode, selectedNodeId, selectedEdgeId, resetResultData
  } = deps

  const activeRelationGroupId = ref<string | null>(null)
  const activeAssembly = computed<PhysicalAssembly | undefined>(() => store.activeAssembly)
  const activeRelationGroup = computed<ShaftOrBleedGroup | null>(() => {
    if (!activeRelationGroupId.value) return null
    return Object.values(store.physicalAssemblies).flatMap(assembly =>
      [...assembly.shaftGroups, ...assembly.bleedGroups])
      .find(group => group.id === activeRelationGroupId.value) || null
  })
  const assemblyForGroup = (groupId: string) => Object.values(store.physicalAssemblies)
    .find(assembly => [...assembly.shaftGroups, ...assembly.bleedGroups].some(group => group.id === groupId))

  /** 当前画布是否存在发动机部件（物理入口显示依据）。 */
  const canvasHasPhysicalComponents = computed(() => nodes.value.some((node) => (
    Boolean(physicalCapabilitiesOf(node.data)?.flow)
  )))
  /** 当前画布是否存在装配成员（允许打开透视）。 */
  const canvasHasAssemblyMembers = computed(() => {
    const memberIds = new Set<string>()
    Object.values(store.physicalAssemblies).forEach((assembly) => {
      assembly.memberNodeIds.forEach((id) => memberIds.add(id))
    })
    return nodes.value.some((node) => memberIds.has(node.id))
  })

  const assemblyForNode = (nodeId: string) => Object.values(store.physicalAssemblies)
    .find(assembly => assembly.memberNodeIds.includes(nodeId))

  const mutateAssembly = (assemblyId: string, mutator: (assembly: PhysicalAssembly) => void) => {
    const current = store.physicalAssemblies[assemblyId]
    if (!current) return
    const assembly = JSON.parse(JSON.stringify(current)) as PhysicalAssembly
    mutator(assembly)
    store.upsertAssembly(assembly)
    resetResultData()
  }

  /** Physical editing no longer needs the legacy assembly management panel. */
  const ensureAssemblyForNode = (nodeId: string): PhysicalAssembly => {
    const owner = assemblyForNode(nodeId)
    if (owner) return owner
    const id = `assembly_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`
    const assembly = emptyPhysicalAssembly(id, `发动机构型装配 ${Object.keys(store.physicalAssemblies).length + 1}`)
    assembly.memberNodeIds = [nodeId]
    store.upsertAssembly(assembly)
    return assembly
  }

  const setPhysicalLensMode = (mode: PhysicalLensMode) => {
    if (physicalLensMode.value === mode) return
    selectedEdgeId.value = null
    if (edges.value.some((edge) => 'selected' in edge && edge.selected)) {
      edges.value = edges.value.map((edge) => ('selected' in edge && edge.selected) ? { ...edge, selected: false } : edge)
    }
    physicalLensMode.value = mode
    activeRelationGroupId.value = null
    if (mode !== 'overview') physicalRelation.value = mode
  }

  const nextGroup = (assembly: PhysicalAssembly, relation: 'shaft' | 'bleed'): ShaftOrBleedGroup => {
    const existing = relation === 'shaft' ? assembly.shaftGroups : assembly.bleedGroups
    const nextNumber = existing.length + 1
    const base = {
      id: `group_${relation}_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`,
      kind: relation,
      name: `${relation === 'shaft' ? '轴' : '引气组'} ${nextNumber}`,
      order: Math.max(0, ...existing.map((group) => Number(group.order) || 0)) + 1
    }
    return relation === 'shaft'
      ? { ...base, memberNodeIds: [], parameters: { E_mech: 0.985 } } as ShaftRelationGroup
      : { ...base, memberNodeIds: [] } as BleedRelationGroup
  }

  const createSelectedRelationGroup = () => {
    const node = selectedNode.value
    if (!node || (physicalLensMode.value !== 'shaft' && physicalLensMode.value !== 'bleed')) return
    if (!physicalCapabilitiesOf(node.data)?.[physicalLensMode.value]?.joinable) {
      ElMessage.warning('所选部件不支持当前关系'); return
    }
    const assembly = ensureAssemblyForNode(node.id)
    const group = nextGroup(assembly, physicalLensMode.value)
    group.memberNodeIds = [node.id]
    store.activeAssemblyId = assembly.id
    mutateAssembly(assembly.id, (target) => {
      if (group.kind === 'shaft') target.shaftGroups.push(group as ShaftRelationGroup)
      else target.bleedGroups.push(group as BleedRelationGroup)
      if (!target.memberNodeIds.includes(node.id)) target.memberNodeIds.push(node.id)
    })
    activeRelationGroupId.value = group.id
  }

  const addSelectedNodeToGroup = () => {
    const node = selectedNode.value
    const group = activeRelationGroup.value
    if (!node || !group || group.kind !== physicalLensMode.value) return
    if (!physicalCapabilitiesOf(node.data)?.[group.kind]?.joinable) {
      ElMessage.warning('所选部件不支持当前关系'); return
    }
    if (group.memberNodeIds.includes(node.id)) return
    const owner = assemblyForGroup(group.id)
    if (!owner || (assemblyForNode(node.id) && assemblyForNode(node.id)?.id !== owner.id)) {
      ElMessage.warning('部件属于其他发动机装配，不能加入当前关系组'); return
    }
    store.activeAssemblyId = owner.id
    mutateAssembly(owner.id, (target) => {
      const groups = (group.kind === 'shaft' ? target.shaftGroups : target.bleedGroups) as ShaftOrBleedGroup[]
      const candidate = groups.find((item) => item.id === group.id)
      if (candidate) candidate.memberNodeIds.push(node.id)
      if (!target.memberNodeIds.includes(node.id)) target.memberNodeIds.push(node.id)
    })
  }

  const removeSelectedNodeFromGroup = () => {
    const node = selectedNode.value
    const group = activeRelationGroup.value
    if (!node || !group) return
    const owner = assemblyForGroup(group.id)
    if (!owner) return
    mutateAssembly(owner.id, (target) => {
      const groups = (group.kind === 'shaft' ? target.shaftGroups : target.bleedGroups) as ShaftOrBleedGroup[]
      const candidate = groups.find((item) => item.id === group.id)
      if (candidate) candidate.memberNodeIds = candidate.memberNodeIds.filter((id) => id !== node.id)
    })
  }

  const updateActiveRelationGroup = (key: string, value: any) => {
    const group = activeRelationGroup.value
    if (!group) return
    const owner = assemblyForGroup(group.id)
    if (!owner) return
    mutateAssembly(owner.id, (target) => {
      const groups = (group.kind === 'shaft' ? target.shaftGroups : target.bleedGroups) as ShaftOrBleedGroup[]
      const candidate = groups.find((item) => item.id === group.id)
      if (!candidate) return
      if (key === 'name') candidate.name = String(value || candidate.name)
      else if (key === 'order') candidate.order = Number(value) || candidate.order
      else candidate.parameters = { ...candidate.parameters, [key]: value }
    })
  }

  const deleteActiveRelationGroup = () => {
    const id = activeRelationGroupId.value
    const assembly = id ? assemblyForGroup(id) : undefined
    if (!id || !assembly) return
    mutateAssembly(assembly.id, (target) => {
      target.shaftGroups = target.shaftGroups.filter((group) => group.id !== id)
      target.bleedGroups = target.bleedGroups.filter((group) => group.id !== id)
      if (target.motorBindings) target.motorBindings = target.motorBindings.filter(binding => binding.shaftGroupId !== id)
    })
    activeRelationGroupId.value = null
    selectedEdgeId.value = null
  }

  const updatePhysicalNodeParameter = (key: string, value: any) => {
    if (!selectedNodeId.value) return
    if (key === 'motorShaftGroupId') {
      const motorNodeId = selectedNodeId.value
      const assembly = assemblyForNode(motorNodeId)
      if (!assembly) return
      mutateAssembly(assembly.id, target => {
        target.motorBindings = (target.motorBindings || []).filter(binding => binding.motorNodeId !== motorNodeId)
        if (value) target.motorBindings.push({ motorNodeId, shaftGroupId: String(value) })
      })
      return
    }
    nodes.value = nodes.value.map((node) => node.id !== selectedNodeId.value ? node : {
      ...node,
      data: key === 'legacyOrder'
        ? { ...node.data, legacyOrder: value }
        : { ...node.data, assemblyDefaults: { ...(node.data?.assemblyDefaults || {}), [key]: value } }
    })
    resetResultData()
  }

  /** 气路连接模式：新建 flow 关系写入当前装配。 */
  const createFlowRelation = (relation: {
    sourceNodeId: string
    sourcePortId: string
    targetNodeId: string
    targetPortId: string
    streamRole?: PhysicalStreamRole
  }) => {
    const sourceOwner = assemblyForNode(relation.sourceNodeId)
    const targetOwner = assemblyForNode(relation.targetNodeId)
    if (sourceOwner && targetOwner && sourceOwner.id !== targetOwner.id) {
      ElMessage.warning('两个部件属于不同的发动机装配，不能直接建立关系')
      return null
    }
    const assembly = sourceOwner || targetOwner || ensureAssemblyForNode(relation.sourceNodeId)
    if (!assembly) return null
    store.activeAssemblyId = assembly.id
    const source = resolvePhysicalLeaf(store.scenes, relation.sourceNodeId, relation.sourcePortId, 'flow')
    const target = resolvePhysicalLeaf(store.scenes, relation.targetNodeId, relation.targetPortId, 'flow')
    if (!source || !target) { ElMessage.warning('气路边界端口无法解析'); return null }
    const allNodes = Object.values(store.scenes).flatMap(scene => scene.nodes)
    const sourceCap = physicalCapabilitiesOf(allNodes.find(node => node.id === source.nodeId)?.data)?.flow
    const targetCap = physicalCapabilitiesOf(allNodes.find(node => node.id === target.nodeId)?.data)?.flow
    if (!sourceCap?.outputs.some(port => port.id === source.portId)
      || !targetCap?.inputs.some(port => port.id === target.portId)) {
      ElMessage.warning('连接端点不支持对应的气路端口'); return null
    }
    const flow: {
      id: string
      kind: 'flow'
      sourceNodeId: string
      sourcePortId: string
      targetNodeId: string
      targetPortId: string
      streamRole?: PhysicalStreamRole
    } = {
      id: `flow_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`,
      kind: 'flow' as const,
      ...relation,
      sourceNodeId: source.nodeId, sourcePortId: source.portId,
      targetNodeId: target.nodeId, targetPortId: target.portId
    }
    if (relation.streamRole) flow.streamRole = relation.streamRole
    mutateAssembly(assembly.id, (target) => {
      target.flowRelations.push(flow)
      ;[flow.sourceNodeId, flow.targetNodeId].forEach((id) => {
        if (!target.memberNodeIds.includes(id)) target.memberNodeIds.push(id)
      })
    })
    return flow
  }

  const connectGroup = (kind: 'shaft' | 'bleed', sourceId: string, sourcePort: string, targetId: string, targetPort: string) => {
    const sourceOwner = assemblyForNode(sourceId)
    const targetOwner = assemblyForNode(targetId)
    if (sourceOwner && targetOwner && sourceOwner.id !== targetOwner.id) {
      ElMessage.warning('两个部件属于不同的发动机装配，不能直接建立关系')
      return
    }
    const assembly = sourceOwner || targetOwner || ensureAssemblyForNode(sourceId)
    store.activeAssemblyId = assembly.id
    const source = resolvePhysicalLeaf(store.scenes, sourceId, sourcePort, kind)
    const target = resolvePhysicalLeaf(store.scenes, targetId, targetPort, kind)
    const allNodes = Object.values(store.scenes).flatMap(scene => scene.nodes)
    if (!source || !target || ![source, target].every(endpoint =>
      physicalCapabilitiesOf(allNodes.find(node => node.id === endpoint.nodeId)?.data)?.[kind]?.joinable)) {
      ElMessage.warning('所选部件不支持当前关系'); return
    }
    let group = activeRelationGroup.value
    if (group && assemblyForGroup(group.id)?.id !== assembly.id) group = null
    if (!group || group.kind !== kind) {
      group = nextGroup(assembly, kind)
      const newGroup = group
      mutateAssembly(assembly.id, assembly => {
        if (kind === 'shaft') assembly.shaftGroups.push(newGroup as ShaftRelationGroup)
        else assembly.bleedGroups.push(newGroup as BleedRelationGroup)
      })
      activeRelationGroupId.value = group.id
    }
    const groupId = group.id
    mutateAssembly(assembly.id, assembly => {
      const groups = kind === 'shaft' ? assembly.shaftGroups : assembly.bleedGroups
      const candidate = groups.find(item => item.id === groupId)
      if (candidate) candidate.memberNodeIds = [...new Set([...candidate.memberNodeIds, source.nodeId, target.nodeId])]
      assembly.memberNodeIds = [...new Set([...assembly.memberNodeIds, source.nodeId, target.nodeId])]
    })
  }

  return {
    activeRelationGroupId,
    activeRelationGroup,
    activeAssembly,
    canvasHasPhysicalComponents,
    canvasHasAssemblyMembers,
    setPhysicalLensMode,
    createSelectedRelationGroup,
    addSelectedNodeToGroup,
    removeSelectedNodeFromGroup,
    updateActiveRelationGroup,
    deleteActiveRelationGroup,
    updatePhysicalNodeParameter,
    createFlowRelation,
    connectGroup
  }
}
