import { ElMessage } from 'element-plus'
import type { Edge, Node } from '@vue-flow/core'
import type { RuntimeSceneData } from '../domain/sceneCommands'

/**
 * 提交前校验：所有工作流 Scene 的结构检查（未解析节点、端口引用、
 * 单输入单来源、DAG 无环）。物理 Scene 是装配关系，不适用 DAG 规则。
 */
export function useMatlabSubmissionValidation(deps: {
  nodesCount: { value: number }
  scenes: { value: Record<string, RuntimeSceneData> }
  nodeDisplayName: (node: Node) => string
  findNodePort: (node: Node | undefined, direction: 'input' | 'output', handle: string) => unknown
}) {
  const validateSceneStructure = (sceneNodes: Node[], sceneEdges: Edge[]): string => {
    const nodeMap = new Map(sceneNodes.map((node) => [node.id, node]))
    const occupied = new Map<string, Edge>()
    for (const node of sceneNodes) {
      if (node.data?.unresolved) return `${deps.nodeDisplayName(node)}对应的组件当前不可用`
    }
    for (const edge of sceneEdges) {
      const sourceNode = nodeMap.get(edge.source)
      const targetNode = nodeMap.get(edge.target)
      const sourcePort = deps.findNodePort(sourceNode, 'output', String(edge.sourceHandle || ''))
      const targetPort = deps.findNodePort(targetNode, 'input', String(edge.targetHandle || ''))
      if (!sourceNode || !targetNode || !sourcePort || !targetPort) return `连线 ${edge.id} 引用了不存在的节点或端口`
      const targetKey = `${edge.target}:${String(edge.targetHandle || '')}`
      const previous = occupied.get(targetKey)
      if (previous) {
        const targetPortName = String((targetPort as any)?.displayName || (targetPort as any)?.name || edge.targetHandle || '')
        const sourceSummary = (candidate: Edge) => {
          const source = nodeMap.get(candidate.source)
          const sourcePort = deps.findNodePort(source, 'output', String(candidate.sourceHandle || '')) as any
          return `${deps.nodeDisplayName(source as Node)}.${sourcePort?.displayName || sourcePort?.name || candidate.sourceHandle}（边 ${candidate.id}）`
        }
        const sameEdge = previous.id === edge.id
          && previous.source === edge.source
          && previous.sourceHandle === edge.sourceHandle
          && previous.target === edge.target
          && previous.targetHandle === edge.targetHandle
          && JSON.stringify(previous.data || {}) === JSON.stringify(edge.data || {})
        const sameSource = previous.source === edge.source && previous.sourceHandle === edge.sourceHandle
        return sameEdge
          ? `子系统“${deps.nodeDisplayName(targetNode)}”输入“${targetPortName}”包含重复边记录 ${edge.id}，请重新保存工程或删除重复记录`
          : sameSource
            ? `子系统“${deps.nodeDisplayName(targetNode)}”输入“${targetPortName}”存在边记录冲突：${sourceSummary(previous)}；${sourceSummary(edge)}（相同边 ID 的内容或端点不一致时请检查工程数据）`
            : `子系统“${deps.nodeDisplayName(targetNode)}”输入“${targetPortName}”被多个来源占用：${sourceSummary(previous)}；${sourceSummary(edge)}`
      }
      occupied.set(targetKey, edge)
    }
    const indegree = new Map(sceneNodes.map((node) => [node.id, 0]))
    const adjacency = new Map(sceneNodes.map((node) => [node.id, [] as string[]]))
    sceneEdges.forEach((edge) => {
      if (!indegree.has(edge.source) || !indegree.has(edge.target)) return
      adjacency.get(edge.source)?.push(edge.target)
      indegree.set(edge.target, (indegree.get(edge.target) || 0) + 1)
    })
    const queue = sceneNodes.filter((node) => indegree.get(node.id) === 0).map((node) => node.id)
    let visited = 0
    while (queue.length > 0) {
      const id = queue.shift() as string
      visited += 1
      ;(adjacency.get(id) || []).forEach((target) => {
        const next = (indegree.get(target) || 0) - 1
        indegree.set(target, next)
        if (next === 0) queue.push(target)
      })
    }
    return visited === sceneNodes.length ? '' : '工作流包含环路'
  }

  const validateInputs = () => {
    if (deps.nodesCount.value === 0) {
      ElMessage.warning('请先拖入一个MATLAB函数组件')
      return false
    }
    // V3：所有 Scene 都是通用场景，工作流 DAG 规则适用于数据边
    const scenesToValidate = Object.values(deps.scenes.value)
    for (const scene of scenesToValidate) {
      // The active canvas can be a physical scene. Physical connections are
      // assembly relations (flow/shaft/bleed), so workflow DAG rules do not
      // apply to them.
      const error = validateSceneStructure(scene.nodes, scene.dataEdges)
      if (error) {
        ElMessage.warning(`场景“${scene.title}”提交前结构检查失败：${error}`)
        return false
      }
    }
    return true
  }

  return { validateInputs, validateSceneStructure }
}
