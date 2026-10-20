import { describe, expect, it } from 'vitest'
import { readPersistedDataEdges } from '../dataEdgeAdapter'

const nodes: any[] = [
  { id: 'a', data: { outputPorts: [{ name: 'DP', type: 'engine.dp' }] } },
  { id: 'b', data: { inputPorts: [{ name: 'DP', type: 'engine.dp' }] } }
]
const compatible = (a: string, b: string) => a === b
const edge = { id: 'e', sourceNodeId: 'a', sourcePort: 'DP', targetNodeId: 'b', targetPort: 'DP' }

describe('readPersistedDataEdges', () => {
  it('adapts complete endpoints without changing them', () => {
    expect(readPersistedDataEdges([edge], nodes, compatible)[0]).toMatchObject({
      ...edge, source: 'a', sourceHandle: 'DP', target: 'b', targetHandle: 'DP', unresolved: false
    })
  })
  it('does not infer a missing port even when only one compatible port exists', () => {
    expect(readPersistedDataEdges([{ ...edge, targetPort: '' }], nodes, compatible)[0])
      .toMatchObject({ targetPort: '', unresolved: true })
  })
  it('retains duplicate records and reports the conflict', () => {
    const result = readPersistedDataEdges([edge, { ...edge }], nodes, compatible)
    expect(result).toHaveLength(2)
    expect(result[1].unresolved).toBe(true)
    expect(result[1].warning).toContain('重复连接')
  })
  it('does not select alternative runtime node IDs', () => {
    expect(readPersistedDataEdges([{ ...edge, sourceNodeId: 'missing', source: 'a' }], nodes, compatible)[0])
      .toMatchObject({ sourceNodeId: 'missing', source: 'missing', unresolved: true })
  })
})
