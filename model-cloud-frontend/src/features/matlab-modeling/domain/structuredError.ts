import type { MatlabSimulationTask, MatlabStructuredError } from '@/api/matlab-model-deploy'

/**
 * 从失败任务中解析结构化错误。
 *
 * 兼容三种形态：
 * 1. 新投影：resultData = {schemaVersion:'matlab.public-result.v1', status:'failed', error:{...}}
 * 2. 旧透传：resultData = {errorDetail:{stage,originPath,...}}
 * 3. 仅文本：task.errorMessage
 *
 * 结构化错误沿 originPath 定位到递归层级节点（如 完整构型/设计点模型/物理构型/hpc_1）。
 */
export const parseTaskFailure = (
  task: Pick<MatlabSimulationTask, 'resultData' | 'errorMessage'> | null | undefined
): MatlabStructuredError | null => {
  if (!task) return null
  const raw = task.resultData
  const payload = typeof raw === 'string' ? safeJsonParse(raw) : raw
  if (payload && typeof payload === 'object') {
    const candidate = (payload as Record<string, any>).error
      || (payload as Record<string, any>).errorDetail
    const structured = normalizeStructuredError(candidate)
    if (structured) return structured
  }
  const message = task.errorMessage?.trim()
  if (message) {
    return { stage: 'unknown', message }
  }
  return null
}

const normalizeStructuredError = (candidate: unknown): MatlabStructuredError | null => {
  if (!candidate || typeof candidate !== 'object') return null
  const record = candidate as Record<string, any>
  const message = typeof record.message === 'string' ? record.message : ''
  const originPath = Array.isArray(record.originPath)
    ? record.originPath.map((segment) => String(segment)).filter(Boolean)
    : []
  // 至少要携带可定位信息（消息或路径/节点）才算结构化错误。
  if (!message && originPath.length === 0 && !record.nodeId && !record.exceptionIdentifier) {
    return null
  }
  return {
    stage: typeof record.stage === 'string' && record.stage ? record.stage : 'unknown',
    originPath,
    nodeId: typeof record.nodeId === 'string' ? record.nodeId : '',
    sourceNodeId: typeof record.sourceNodeId === 'string' ? record.sourceNodeId : '',
    exceptionType: typeof record.exceptionType === 'string' ? record.exceptionType : '',
    exceptionIdentifier: typeof record.exceptionIdentifier === 'string'
      ? record.exceptionIdentifier : '',
    message,
    details: record.details && typeof record.details === 'object' ? record.details : {}
  }
}

const safeJsonParse = (text: string): Record<string, any> | null => {
  try {
    const parsed = JSON.parse(text)
    return parsed && typeof parsed === 'object' ? parsed : null
  } catch {
    return null
  }
}

/** originPath 的展示形式：完整构型 / 设计点模型 / 物理构型 / hpc_1 */
export const formatOriginPath = (originPath?: string[]): string => (
  originPath && originPath.length > 0 ? originPath.join(' / ') : ''
)
