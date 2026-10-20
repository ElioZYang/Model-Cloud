export type AssemblyParameterDefinition = {
  key: string
  label: string
  kind: 'number' | 'boolean' | 'text' | 'choice' | 'number-list'
  unit?: string
  description: string
  source: string
  /** Only fields assigned for every configuration in the original common head get defaults. */
  commonDefault?: number | boolean | string
  options?: Array<{ label: string; value: string }>
}

export type PhysicalComponentParameterDefinition = Pick<AssemblyParameterDefinition, 'key' | 'label' | 'kind' | 'unit' | 'description' | 'source'>

const compressorParameters: PhysicalComponentParameterDefinition[] = [
  { key: 'PRC', label: '压比', kind: 'number', description: '压气机总压比。', source: '对应 INPUT_TURBO 构型分支' },
  { key: 'EFFC', label: '压气机效率', kind: 'number', description: '压气机等熵效率。', source: '对应 INPUT_TURBO 构型分支' }
]
const turbineParameters: PhysicalComponentParameterDefinition[] = [
  { key: 'PRT', label: '膨胀比', kind: 'number', description: '涡轮膨胀比；非正值由原设计点求解逻辑处理。', source: '对应 INPUT_TURBO 构型分支' },
  { key: 'EFFT', label: '涡轮效率', kind: 'number', description: '涡轮等熵效率。', source: '对应 INPUT_TURBO 构型分支' }
]
const combustorParameters: PhysicalComponentParameterDefinition[] = [
  { key: 'EB', label: '燃烧效率', kind: 'number', description: '燃烧室燃烧效率。', source: '对应 INPUT_TURBO 构型分支' },
  { key: 'HU', label: '燃料热值', kind: 'number', unit: 'J/kg', description: '燃料低位热值。', source: '对应 INPUT_TURBO 构型分支' },
  { key: 'TO', label: '燃烧后温度', kind: 'number', unit: 'K', description: '燃烧室或加力燃烧室出口总温。', source: '对应 INPUT_TURBO 构型分支' }
]

const physicalComponentParameters: Record<string, PhysicalComponentParameterDefinition[]> = {
  fan: compressorParameters,
  lpc: compressorParameters,
  ipc: compressorParameters,
  hpc: compressorParameters,
  hpt: turbineParameters,
  ipt: turbineParameters,
  lpt: turbineParameters,
  burn: combustorParameters,
  afterburn: combustorParameters
}

export const physicalComponentParameterDefinitions = (legacyName: string) => (
  physicalComponentParameters[legacyName.toLowerCase()] || []
)

export const physicalComponentParameterByKey = (legacyName: string, key: string) => (
  physicalComponentParameterDefinitions(legacyName).find(parameter => parameter.key === key)
)

/** Values and provenance transcribed from INPUT_TURBO_COMMON_HEAD.m and branch assignments. */
export const assemblyParameterCatalog: AssemblyParameterDefinition[] = [
  {
    key: 'type', label: '构型标识', kind: 'text', description: '原 INPUT_TURBO 分支标识；手工装配必须明确选择或填写。',
    source: 'INPUT_TURBO.m 各构型分支'
  },
  {
    key: 'flow', label: '涵道模式', kind: 'choice', description: '混排或分排，仅对原模型支持的涡扇构型有意义。',
    source: 'INPUT_TURBO_COMMON_HEAD.m', commonDefault: 'mixed',
    options: [{ label: '混排 mixed', value: 'mixed' }, { label: '分排 separated', value: 'separated' }]
  },
  {
    key: 'PRC_outerfan', label: '外涵风扇压比', kind: 'number', description: '外部风扇压比。',
    source: 'INPUT_TURBO_COMMON_HEAD.m', commonDefault: 1
  },
  {
    key: 'BYPASS_RATIO', label: '涵道比', kind: 'number', description: '旁通流与核心流质量流量之比。',
    source: 'INPUT_TURBO_COMMON_HEAD.m', commonDefault: 0
  },
  {
    key: 'reheat', label: '加力状态', kind: 'number', description: '是否启用加力燃烧室（沿用原 MATLAB 数值标记）。',
    source: 'INPUT_TURBO_COMMON_HEAD.m', commonDefault: 0
  },
  {
    key: 'TPRM', label: '混合器总压恢复系数', kind: 'number', description: '由原 INPUT_TURBO 的具体构型分支设置；不设通用默认值。',
    source: 'INPUT_TURBO.m 各构型分支'
  },
  {
    key: 'SHAFT_CONTROL', label: '轴/电机映射', kind: 'number-list', description: '按 MATLAB 原始语义填写轴与电机实例的对应向量。',
    source: 'INPUT_TURBO_COMMON_HEAD.m 或 INPUT_TURBO.m 分支', commonDefault: 1
  }
]

export const assemblyParameterByKey = (key: string) => assemblyParameterCatalog.find(item => item.key === key)

export function assemblyParameterDisplayValue(key: string, values: Record<string, unknown>) {
  const existing = values[key]
  if (existing !== undefined && existing !== null) return existing
  return assemblyParameterByKey(key)?.commonDefault
}

export function assemblyParameterKeys(values: Record<string, unknown>, mode: 'overview' | 'flow' | 'shaft' | 'bleed') {
  const keys = new Set([...assemblyParameterCatalog.map(item => item.key), ...Object.keys(values)])
  return [...keys].filter(key => {
    if (key === 'NS' || key === 'NW') return false
    if (mode === 'shaft') return key === 'SHAFT_CONTROL'
    if (mode === 'bleed') return false
    if (mode === 'flow') return !['E_motor', 'E_mech', 'SHAFT_CONTROL'].includes(key)
    return true
  })
}
