import { describe, expect, it } from 'vitest'
import { compareEngineConfigurationCatalogOrder } from '../componentCatalogOrdering'

describe('engine configuration catalog ordering', () => {
  it('uses original engine-list order and keeps unknown entries after ordered templates', () => {
    const entries = [
      { name: '三轴分排涡扇', catalogOrder: 11 },
      { name: '涵道风扇', catalogOrder: 1 },
      { name: '自由涡轮涡轴发动机', catalogOrder: 4 },
      { name: '未编号构型' }
    ]

    expect([...entries].sort(compareEngineConfigurationCatalogOrder).map(entry => entry.name)).toEqual([
      '涵道风扇', '自由涡轮涡轴发动机', '三轴分排涡扇', '未编号构型'
    ])
  })
})
