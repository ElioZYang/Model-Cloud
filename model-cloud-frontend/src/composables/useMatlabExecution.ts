import { ref, type ComputedRef, type Ref } from 'vue'
import { ElMessage } from 'element-plus'
import { matlabModelDeployApi, type MatlabPlotArtifact, type MatlabStructuredError } from '@/api/matlab-model-deploy'
import type { Node, Edge } from '@vue-flow/core'
import type { SubmittedWorkflowNode } from '@/utils/matlabResultData'
import { parseTaskFailure } from '@/features/matlab-modeling/domain/structuredError'

type ExecutionScene = { id: string; title: string; nodes: Node[]; dataEdges: Edge[] }
type Dependencies = {
  lastSubmittedWorkflowNodes: Ref<Record<string, SubmittedWorkflowNode>>
  resultDialogVisible: Ref<boolean>
  calculationDialogVisible: Ref<boolean>
  lastTaskId: Ref<number | null>
  sceneStore: Ref<Record<string, ExecutionScene>> | ComputedRef<Record<string, ExecutionScene>>
  scenePathTitle: (sceneId: string) => string
  getValidPorts: (ports: unknown) => any[]
  nodes: Ref<Node[]>
  edges: Ref<Edge[]>
  validateInputs: () => boolean
  buildExecutionPayload: () => any
  getTopologicalOrder: () => string[] | null
  addLog: (type: string, message: string) => void
  applyCalculationResult: (raw: unknown, artifacts?: MatlabPlotArtifact[]) => boolean
  /** 任务失败时收到结构化错误（含 originPath 层级定位）。 */
  onExecutionFailure?: (failure: MatlabStructuredError) => void
}

export type MatlabSubmissionSnapshot = {
  projectSnapshot: unknown
  nodeMappingSnapshot: Record<string, SubmittedWorkflowNode>
  scenePathSnapshot: Record<string, string>
  submittedAt: number
}

export function useMatlabExecution(deps: Dependencies) {
  const calculating = ref(false)
  let pollingTimer: number | null = null
  let lastStatus = ''
  /** 提交快照：后续结果一律用提交时刻的快照关联，不使用被用户继续编辑的画布。 */
  const lastSubmission: Ref<MatlabSubmissionSnapshot | null> = ref(null)
  const stopPolling = () => {
    if (pollingTimer !== null) {
      window.clearInterval(pollingTimer)
      pollingTimer = null
    }
  }
  
  const pollTask = async (taskId: number) => {
    stopPolling()
    lastStatus = ''
    const fetchStatus = async () => {
      try {
        const response = await matlabModelDeployApi.getTaskStatus(taskId)
        const task = response.data
        if (!task) return
        if (task.status !== lastStatus) {
          lastStatus = task.status
          deps.addLog('info', `任务状态：${task.status}${task.progress == null ? '' : `，进度${task.progress}%`}`)
        }
        if (task.status === 'completed') {
          stopPolling()
          calculating.value = false
          deps.addLog('success', '计算完成，正在展示结果')
          deps.lastTaskId.value = taskId
          if (deps.applyCalculationResult(task.resultData, task.artifacts || [])) deps.resultDialogVisible.value = true
        } else if (task.status === 'failed' || task.status === 'cancelled') {
          stopPolling()
          calculating.value = false
          const failure = parseTaskFailure(task)
          if (failure) {
            const location = failure.originPath && failure.originPath.length > 0
              ? `（${failure.originPath.join(' / ')}）` : ''
            const identifier = failure.exceptionIdentifier ? ` [${failure.exceptionIdentifier}]` : ''
            deps.addLog('error', `MATLAB计算失败${identifier}${location}：${failure.message || '未提供错误消息'}`)
            deps.onExecutionFailure?.(failure)
          } else {
            deps.addLog('error', task.errorMessage || 'MATLAB计算失败')
          }
          ElMessage.error(task.errorMessage || 'MATLAB计算失败')
        }
      } catch (error: any) {
        deps.addLog('warning', `任务状态查询失败：${error.message || '未知错误'}`)
      }
    }
    await fetchStatus()
    if (calculating.value) pollingTimer = window.setInterval(fetchStatus, 2000)
  }
  
  const handleStartCalculation = async () => {
    if (!deps.validateInputs()) return
    const payload = deps.buildExecutionPayload()
    if (!payload) return
    deps.calculationDialogVisible.value = false
    deps.resultDialogVisible.value = false
    calculating.value = true
    const submitted: Record<string, SubmittedWorkflowNode> = {}
    const collectSubmittedNodes = (scene: ExecutionScene, path: string) => {
      scene.nodes.forEach((node) => {
        submitted[node.id] = {
          id: node.id,
          instanceName: String(node.data?.instanceName || node.label || node.id),
          componentName: String(node.data?.componentName || node.data?.functionName || node.id),
          outputPorts: [...deps.getValidPorts(node.data?.outputPorts)],
          originPath: path,
          sceneId: scene.id
        }
      })
    }
    Object.values(deps.sceneStore.value).forEach((scene) => {
      const path = deps.scenePathTitle(scene.id) || scene.title
      collectSubmittedNodes(scene, path)
    })
    deps.lastSubmittedWorkflowNodes.value = submitted
    const scenePaths: Record<string, string> = {}
    Object.values(deps.sceneStore.value).forEach((scene) => {
      scenePaths[scene.id] = deps.scenePathTitle(scene.id) || scene.title
    })
    lastSubmission.value = {
      projectSnapshot: JSON.parse(JSON.stringify(payload)),
      nodeMappingSnapshot: submitted,
      scenePathSnapshot: scenePaths,
      submittedAt: Date.now()
    }
    deps.addLog('info', `正在提交MATLAB组件图：${deps.nodes.value.length}个节点，${deps.edges.value.length}条连线`)
    deps.addLog('info', `预计执行顺序：${(deps.getTopologicalOrder() || []).join(' → ')}`)
    try {
      const response = await matlabModelDeployApi.submitCalculation(payload)
      deps.addLog('success', `任务已提交，数据库任务ID：${response.data}`)
      await pollTask(response.data)
    } catch (error: any) {
      calculating.value = false
      deps.addLog('error', `任务提交失败：${error.message || '未知错误'}`)
      ElMessage.error(error.message || '任务提交失败')
    }
  }
  return { calculating, stopPolling, pollTask, handleStartCalculation, lastSubmission }
}
