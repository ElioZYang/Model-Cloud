import { describe, expect, it } from 'vitest'
import { inferResultUnit } from '@/utils/matlabResultData'

describe('嵌套结果单位', () => {
  it('父层扫描名称不影响叶字段单位', () => {
    expect(inferResultUnit('root.MISSION_power.G.DP.V')).toBeUndefined()
    expect(inferResultUnit('root.speed_sweep.exitflag')).toBeUndefined()
    expect(inferResultUnit('root.MISSION_power.pressure_pa')).toBe('Pa')
    expect(inferResultUnit('root.speed_sweep.power_kw')).toBe('kW')
    expect(inferResultUnit('root.power_sweep.speed_mps')).toBe('m/s')
  })
})
