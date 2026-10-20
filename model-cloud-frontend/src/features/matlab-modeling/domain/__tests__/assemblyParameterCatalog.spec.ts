import { describe, expect, it } from 'vitest'
import {
  assemblyParameterDisplayValue,
  assemblyParameterKeys,
  physicalComponentParameterDefinitions
} from '../assemblyParameterCatalog'

describe('engine assembly parameter metadata', () => {
  it('shows only common-head values as defaults and keeps branch values unset', () => {
    expect(assemblyParameterDisplayValue('PRC_outerfan', {})).toBe(1)
    expect(assemblyParameterDisplayValue('flow', {})).toBe('mixed')
    expect(assemblyParameterDisplayValue('TPRM', {})).toBeUndefined()
    expect(assemblyParameterKeys({ NW: 1, NS: 1 }, 'bleed')).not.toContain('NW')
  })

  it('offers fields for an empty hand-built assembly without inventing branch defaults', () => {
    const keys = assemblyParameterKeys({}, 'flow')
    expect(keys).toContain('type')
    expect(keys).toContain('TPRM')
    expect(keys).toContain('BYPASS_RATIO')
    expect(assemblyParameterDisplayValue('TPRM', {})).toBeUndefined()
  })

  it('exposes only parameters belonging to the selected gas-path component kind', () => {
    expect(physicalComponentParameterDefinitions('lpc').map(parameter => parameter.key)).toEqual(['PRC', 'EFFC'])
    expect(physicalComponentParameterDefinitions('hpt').map(parameter => parameter.key)).toEqual(['PRT', 'EFFT'])
    expect(physicalComponentParameterDefinitions('burn').map(parameter => parameter.key)).toEqual(['EB', 'HU', 'TO'])
  })
})
