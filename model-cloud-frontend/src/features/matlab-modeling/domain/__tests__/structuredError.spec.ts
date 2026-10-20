import { describe, expect, it } from 'vitest'
import { formatOriginPath, parseTaskFailure } from '../structuredError'

describe('parseTaskFailure', () => {
  it('解析新投影：{schemaVersion, status:"failed", error:{...}}', () => {
    const failure = parseTaskFailure({
      resultData: JSON.stringify({
        schemaVersion: 'matlab.public-result.v1',
        status: 'failed',
        error: {
          stage: 'execute-node',
          originPath: ['涡轴构型', '构型设计点模型', '物理构型', 'hpc_1'],
          nodeId: 'root__design_point__physical_configuration__hpc_1',
          sourceNodeId: 'hpc_1',
          exceptionType: 'MATLAB',
          exceptionIdentifier: 'engine:FlowTopology',
          message: '物理气路 flow 边无法线性化'
        }
      }),
      errorMessage: '整包消息'
    })
    expect(failure).not.toBeNull()
    expect(failure!.stage).toBe('execute-node')
    expect(failure!.exceptionIdentifier).toBe('engine:FlowTopology')
    expect(failure!.originPath).toHaveLength(4)
    expect(failure!.originPath).toContain('物理构型')
  })

  it('解析旧透传形态：{errorDetail:{...}}', () => {
    const failure = parseTaskFailure({
      resultData: { errorDetail: { stage: 'execute-node', message: '节点执行失败', nodeId: 'n1' } },
      errorMessage: 'x'
    })
    expect(failure).not.toBeNull()
    expect(failure!.nodeId).toBe('n1')
    expect(failure!.message).toBe('节点执行失败')
  })

  it('无结构化数据时退回 errorMessage', () => {
    const failure = parseTaskFailure({ resultData: undefined, errorMessage: 'MATLAB计算失败' })
    expect(failure).not.toBeNull()
    expect(failure!.stage).toBe('unknown')
    expect(failure!.message).toBe('MATLAB计算失败')
  })

  it('既无 resultData 数据也无消息时返回 null', () => {
    expect(parseTaskFailure({ resultData: undefined, errorMessage: '' })).toBeNull()
    expect(parseTaskFailure(null)).toBeNull()
  })

  it('拒绝缺少可定位信息的空对象', () => {
    const failure = parseTaskFailure({ resultData: { errorDetail: { stage: 'execute-node' } }, errorMessage: '' })
    expect(failure).toBeNull()
  })

  it('resultData 为非法 JSON 字符串时退回 errorMessage', () => {
    const failure = parseTaskFailure({ resultData: '{broken', errorMessage: '兜底消息' })
    expect(failure!.message).toBe('兜底消息')
  })
})

describe('formatOriginPath', () => {
  it('按 " / " 连接层级', () => {
    expect(formatOriginPath(['完整构型', '设计点模型', '物理构型', 'hpc_1']))
      .toBe('完整构型 / 设计点模型 / 物理构型 / hpc_1')
  })

  it('空路径返回空串', () => {
    expect(formatOriginPath([])).toBe('')
    expect(formatOriginPath(undefined)).toBe('')
  })
})
