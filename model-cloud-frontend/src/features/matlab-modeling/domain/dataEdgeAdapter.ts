import type { Node } from '@vue-flow/core'

/** Read saved endpoints verbatim. Validation reports errors without choosing replacement endpoints. */
export const readPersistedDataEdges = (
  edges: any[],
  nodes: Node[],
  isCompatible: (sourceType: string, targetType: string) => boolean
) => {
  const nodesById = new Map(nodes.map(node => [String(node.id), node]))
  const occupiedInputs = new Set<string>()
  return (edges || []).map((edge, index) => {
    const id = String(edge?.id || `unresolved_edge_${index + 1}`)
    const sourceNodeId = String(edge?.sourceNodeId ?? '')
    const targetNodeId = String(edge?.targetNodeId ?? '')
    const sourcePort = String(edge?.sourcePort ?? '')
    const targetPort = String(edge?.targetPort ?? '')
    const sourceNode = nodesById.get(sourceNodeId)
    const targetNode = nodesById.get(targetNodeId)
    const output = sourceNode?.data?.outputPorts?.find((port: any) => port.name === sourcePort)
    const input = targetNode?.data?.inputPorts?.find((port: any) => port.name === targetPort)
    let warning: string | undefined
    if (!sourceNode || !targetNode) warning = '源节点或目标节点不存在'
    else if (!output || !input) warning = '保存的源端口或目标端口不存在'
    else if (!isCompatible(output.type || 'unknown', input.type || 'unknown')) warning = '端口类型不兼容'
    const key = `${targetNodeId}:${targetPort}`
    if (targetPort && occupiedInputs.has(key)) warning = `目标输入重复连接：${targetNodeId}.${targetPort}`
    if (targetPort) occupiedInputs.add(key)
    return {
      ...edge,
      id, sourceNodeId, sourcePort, targetNodeId, targetPort,
      relation: edge?.relation ?? edge?.data?.relation,
      streamRole: edge?.streamRole ?? edge?.data?.streamRole,
      groupId: edge?.groupId ?? edge?.data?.groupId,
      unresolved: Boolean(warning) || edge?.unresolved === true,
      warning,
      source: sourceNodeId || `__unresolved_source_${id}`,
      sourceHandle: sourcePort || `__unresolved_source_port_${id}`,
      target: targetNodeId || `__unresolved_target_${id}`,
      targetHandle: targetPort || `__unresolved_target_port_${id}`,
      data: edge?.data || {}
    }
  })
}
