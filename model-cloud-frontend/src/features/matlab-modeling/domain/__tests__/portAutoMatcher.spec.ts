import { describe, expect, it } from 'vitest'
import { matchPortsInDeclarationOrder } from '../portAutoMatcher'

describe('matchPortsInDeclarationOrder', () => {
  it('matches subsystem ports by semantic key even when generated IDs differ', () => {
    const result = matchPortsInDeclarationOrder(
      [{ name: 'out_1', type: 'number', semanticKey: 'shaft_power' }],
      [{ name: 'boundary_data_in_2', type: 'number', semanticKey: 'shaft_power' }]
    )
    expect(result[0]?.target.name).toBe('boundary_data_in_2')
    expect(result[0]?.score).toBe(500)
  })

  it('uses declaration order for equal compatible candidates', () => {
    const result = matchPortsInDeclarationOrder(
      [{ name: 'signal', type: 'number' }],
      [{ name: 'first', type: 'number' }, { name: 'second', type: 'number' }]
    )
    expect(result.map(item => item.target.name)).toEqual(['first'])
  })
})
