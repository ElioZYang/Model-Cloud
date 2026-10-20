import { computed, ref } from 'vue'
import { ElMessage } from 'element-plus'
import type { Ref } from 'vue'
import type { MatlabPlotArtifact } from '@/api/matlab-model-deploy'
import { collectResultVariables, displayResultOriginPath, normalizePlotArtifacts, parseResult, publicOutputEntries, type ResultVariable, type SubmittedWorkflowNode, type ResultNodeView, type ResultPortView } from '@/utils/matlabResultData'

type Dependencies = { addLog: (type: string, message: string) => void; calculationDialogVisible: Ref<boolean> }

export function useMatlabResults(deps: Dependencies) {
  const resultDialogVisible = ref(false)

  const lastSubmittedWorkflowNodes = ref<Record<string, SubmittedWorkflowNode>>({})
  
  const resultVariables = ref<ResultVariable[]>([])
  
  const resultValues = ref<Record<string, unknown>>({})
  
  const selectedResultVariables = ref<string[]>([])
  
  const expandedResultGroups = ref<string[]>([])
  
  const activeResultNodeId = ref('')
  
  const activeResultPortKey = ref('')
  
  const hasCachedResult = ref(false)
  
  const lastWorkflowResult = ref<Record<string, any> | null>(null)
  
  const resultBatchId = ref(0)
  
  const resultArtifacts = ref<MatlabPlotArtifact[]>([])
  
  const activeArtifactPhase = ref('design')
  
  const generatedJuliaCode = ref('')
  
  const formattedWorkflowResult = computed(() => {
    return lastWorkflowResult.value ? JSON.stringify(lastWorkflowResult.value, null, 2) : ''
  })
  
  const resultVariableGroups = computed(() => {
    const groups = new Map<string, ResultVariable[]>()
    resultVariables.value.forEach((variable) => {
      if (!groups.has(variable.group)) groups.set(variable.group, [])
      groups.get(variable.group)?.push(variable)
    })
    return Array.from(groups.entries()).map(([group, variables]) => ({ group, variables }))
  })
  
  const resultArtifactGroups = computed(() => {
    const groups = new Map<string, MatlabPlotArtifact[]>()
    resultArtifacts.value.forEach((artifact) => {
      if (!groups.has(artifact.phase)) groups.set(artifact.phase, [])
      groups.get(artifact.phase)?.push(artifact)
    })
    const phases = ['design', 'power', 'final']
    return Array.from(groups.entries()).map(([phase, artifacts]) => ({ phase, artifacts }))
      .sort((left, right) => {
        const rank = (phase: string) => phases.includes(phase) ? phases.indexOf(phase) : phases.length
        return rank(left.phase) - rank(right.phase)
      })
  })
  
  const artifactPhaseLabel = (phase: string) => ({
    design: '设计 design',
    power: '功率 power',
    final: '最终 final'
  }[phase] || phase)
  
  const selectedArrayVariables = computed(() => resultVariables.value.filter((variable) => (
    selectedResultVariables.value.includes(variable.key) && variable.valueType !== 'scalar'
  )))
  
  const selectedLineArrayVariables = computed(() => selectedArrayVariables.value.filter((variable) => (
    variable.valueType === 'vector' || variable.valueType === 'ndarray'
  )))
  
  const selectedPlotVariables = computed(() => resultVariables.value.filter((variable) => (
    selectedResultVariables.value.includes(variable.key)
    && variable.valueType === 'scalar'
  )))
  
  const availableResultNodes = computed<ResultNodeView[]>(() => {
    const parsed = lastWorkflowResult.value
    const nodeResults = parsed?.nodeResults && typeof parsed.nodeResults === 'object'
      ? parsed.nodeResults as Record<string, any>
      : {}
    const order = [...new Set([...(Array.isArray(parsed?.executionOrder) ? parsed.executionOrder as string[] : []), ...Object.keys(nodeResults)])]
    return order.map((nodeId) => {
      const result = nodeResults[nodeId] || {}
      const outputs = result.outputs && typeof result.outputs === 'object'
        ? result.outputs as Record<string, unknown>
        : {}
      const sourceNodeId = String(result.sourceNodeId || result.__sourceNodeId || '')
      const snapshot = lastSubmittedWorkflowNodes.value[nodeId]
        || (sourceNodeId ? lastSubmittedWorkflowNodes.value[sourceNodeId] : undefined)
      const originPath = displayResultOriginPath(
        result.originPath || result.__originPath,
        snapshot?.originPath
      )
      const declaredNames = snapshot?.outputPorts.map((port) => port.name) || []
      const availableNames = Array.isArray(result.availableOutputPorts)
        ? result.availableOutputPorts.map((name: unknown) => String(name))
        : []
      const names = [...declaredNames, ...availableNames, ...Object.keys(outputs)]
        .filter((name, index, all) => Boolean(name) && all.indexOf(name) === index)
      return {
        id: nodeId,
        instanceName: snapshot?.instanceName
          || (originPath ? originPath.split(' / ')[originPath.split(' / ').length - 1] : '')
          || nodeId,
        componentName: snapshot?.componentName || String(result.functionName || result.componentId || nodeId),
        originPath,
        ports: names.map((name) => ({
          key: `${nodeId}:output:${name}`,
          name,
          hasValue: Object.prototype.hasOwnProperty.call(outputs, name),
          value: outputs[name]
        }))
      }
    }).filter((node) => node.ports.length > 0).concat((() => {
      const ports = publicOutputEntries(parsed?.publicOutputs).map((item) => ({
        key: '__publicOutputs__:output:' + item.name,
        name: item.name,
        hasValue: item.value !== undefined,
        value: item.value
      }))
      return ports.length > 0 ? [{
        id: '__publicOutputs__',
        instanceName: '父层公开结果',
        componentName: '复合节点公开输出',
        originPath: '父层公开输出',
        ports
      }] : []
    })())
  })
  
  const activeResultNode = computed(() => {
    return availableResultNodes.value.find((node) => node.id === activeResultNodeId.value) || null
  })
  
  const activeResultPorts = computed<ResultPortView[]>(() => activeResultNode.value?.ports || [])
  
  const activeResultPort = computed<ResultPortView | null>(() => {
    return activeResultPorts.value.find((port) => port.key === activeResultPortKey.value) || null
  })
  
  const handleResultNodeSelect = (nodeId: string | number) => {
    activeResultNodeId.value = String(nodeId)
    activeResultPortKey.value = activeResultNode.value?.ports[0]?.key || ''
  }
  
  const handleResultPortSelect = (portKey: string) => {
    activeResultPortKey.value = portKey
  }
  
  const applyGraphResult = (raw: unknown, taskArtifacts: MatlabPlotArtifact[] = []) => {
    const parsed = parseResult(raw)
    if (!parsed || !parsed.nodeResults) {
      ElMessage.error('MATLAB图结果格式不正确')
      return false
    }
    const variables: ResultVariable[] = []
    const values: Record<string, unknown> = {}
    const order = [...new Set([...(Array.isArray(parsed.executionOrder) ? parsed.executionOrder as string[] : []), ...Object.keys(parsed.nodeResults)])]
    order.forEach((nodeId: string) => {
      const nodeResult = parsed.nodeResults[nodeId]
      const sourceNodeId = String(nodeResult?.sourceNodeId || nodeResult?.__sourceNodeId || '')
      const snapshot = lastSubmittedWorkflowNodes.value[nodeId]
        || (sourceNodeId ? lastSubmittedWorkflowNodes.value[sourceNodeId] : undefined)
      const originPath = displayResultOriginPath(
        nodeResult?.originPath || nodeResult?.__originPath,
        snapshot?.originPath
      )
      const outputs = nodeResult?.outputs || {}
      Object.entries(outputs).forEach(([outputName, outputValue]) => {
        const sourceName = originPath || snapshot?.instanceName || nodeId
        const group = `${sourceName} · ${outputName}`
        collectResultVariables(outputValue, outputName, nodeId, group, variables, values)
      })
    })
    publicOutputEntries(parsed.publicOutputs).forEach((item) => {
      const group = item.originPath
        ? `${item.originPath} · 父层公开输出`
        : '父层公开输出'
      collectResultVariables(item.value, item.name, '__publicOutputs__', group, variables, values)
    })
    resultVariables.value = variables
    resultValues.value = values
    const preferred = variables.filter((variable) => /stator_OD|mass\.total|losses\.total|efficiency|speed$/i.test(variable.label))
    selectedResultVariables.value = (preferred.length > 0 ? preferred : variables.slice(0, 12))
      .slice(0, 16)
      .map((variable) => variable.key)
    expandedResultGroups.value = resultVariableGroups.value.map((item) => item.group)
    lastWorkflowResult.value = parsed
    resultArtifacts.value = taskArtifacts.length > 0 ? taskArtifacts : normalizePlotArtifacts(parsed)
    activeArtifactPhase.value = resultArtifacts.value[0]?.phase || 'design'
    resultBatchId.value += 1
    generatedJuliaCode.value = String(parsed.generatedCode || '')
    const defaultNode = [...availableResultNodes.value].reverse().find((node) => node.ports.length > 0)
    activeResultNodeId.value = defaultNode?.id || ''
    activeResultPortKey.value = defaultNode?.ports[0]?.key || ''
    hasCachedResult.value = true
    deps.addLog('success', `图执行顺序：${order.join(' → ')}`)
    return true
  }
  
  const applyCalculationResult = (raw: unknown, taskArtifacts: MatlabPlotArtifact[] = []) => {
    return applyGraphResult(raw, taskArtifacts)
  }
  
  const handleOpenLatestResult = () => {
    if (!hasCachedResult.value) {
      ElMessage.info('暂无可查看的计算结果')
      return
    }
    deps.calculationDialogVisible.value = false
    resultDialogVisible.value = true
  }
  
  const copyGeneratedJuliaCode = async () => {
    try {
      await navigator.clipboard.writeText(generatedJuliaCode.value)
      ElMessage.success('Julia代码已复制')
    } catch {
      ElMessage.warning('复制失败，请手动复制')
    }
  }

  const resetResultData = () => {
    resultVariables.value = []
    resultValues.value = {}
    selectedResultVariables.value = []
    expandedResultGroups.value = []
    activeResultNodeId.value = ''
    activeResultPortKey.value = ''
    hasCachedResult.value = false
    lastSubmittedWorkflowNodes.value = {}
    lastWorkflowResult.value = null
    resultArtifacts.value = []
    activeArtifactPhase.value = 'design'
    generatedJuliaCode.value = ''
    resultBatchId.value += 1
  }

  return { resultDialogVisible, lastSubmittedWorkflowNodes, resultVariables, resultValues, selectedResultVariables, expandedResultGroups, activeResultNodeId, activeResultPortKey, hasCachedResult, lastWorkflowResult, resultBatchId, resultArtifacts, activeArtifactPhase, generatedJuliaCode, formattedWorkflowResult, resultVariableGroups, resultArtifactGroups, artifactPhaseLabel, selectedArrayVariables, selectedLineArrayVariables, selectedPlotVariables, availableResultNodes, activeResultNode, activeResultPorts, activeResultPort, handleResultNodeSelect, handleResultPortSelect, applyGraphResult, applyCalculationResult, handleOpenLatestResult, copyGeneratedJuliaCode, resetResultData }
}
