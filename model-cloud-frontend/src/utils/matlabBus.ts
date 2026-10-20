export type BusValueType = 'number' | 'string' | 'boolean' | 'array' | 'struct'

export type BusField = {
  id: string
  path: string
  label?: string
  nameMode?: 'auto' | 'manual'
  sourceName?: string
  dataType: BusValueType | string
  shape?: number[]
  unit?: string
  inferred?: boolean
  contractStatus?: 'pending' | 'inferred' | 'invalid'
  required?: boolean
  defaultValue?: number | string | boolean | null
  inputPortId?: string
  outputPortId?: string
}

export type BusConfig = {
  schemaMode: 'anonymous' | 'named'
  schemaRef?: string
  name?: string
  fields: BusField[]
}

export type BusSelectorConfig = {
  sourceSchemaRef?: string
  selectedFields: BusField[]
}

export const BUS_CREATOR_ID = 'builtin.bus.creator'
export const BUS_SELECTOR_ID = 'builtin.bus.selector'

// 已在 PMSM 结果结构中稳定出现的一级字段。这里只声明字段契约，不执行
// MATLAB 访问；更深层字段应由 Creator 的显式配置提供，避免从运行结果猜测。
export const BUS_STRUCTURE_DEFINITIONS: Record<string, BusField[]> = {
  'pmsm.design_result': [
    { id: 'input', path: 'input', label: 'input', dataType: 'pmsm.input', required: true, outputPortId: 'bus_out_input' },
    { id: 'operating', path: 'operating', label: 'operating', dataType: 'pmsm.operating', required: true, outputPortId: 'bus_out_operating' },
    { id: 'geometry', path: 'geometry', label: 'geometry', dataType: 'pmsm.geometry', required: true, outputPortId: 'bus_out_geometry' },
    { id: 'slot', path: 'slot', label: 'slot', dataType: 'pmsm.slot', required: true, outputPortId: 'bus_out_slot' },
    { id: 'winding', path: 'winding', label: 'winding', dataType: 'pmsm.winding', required: true, outputPortId: 'bus_out_winding' },
    { id: 'magnet', path: 'magnet', label: 'magnet', dataType: 'pmsm.magnet', required: true, outputPortId: 'bus_out_magnet' },
    { id: 'mass', path: 'mass', label: 'mass', dataType: 'pmsm.mass', required: true, outputPortId: 'bus_out_mass' },
    { id: 'losses', path: 'losses', label: 'losses', dataType: 'pmsm.losses', required: true, outputPortId: 'bus_out_losses' },
    { id: 'performance', path: 'performance', label: 'performance', dataType: 'pmsm.performance', required: true, outputPortId: 'bus_out_performance' },
    { id: 'thermal', path: 'thermal', label: 'thermal', dataType: 'pmsm.thermal', required: false, outputPortId: 'bus_out_thermal' }
  ],
  'engine.dp': [
    { id: 'F', path: 'F', label: '部件顺序 F', dataType: 'array', required: true, outputPortId: 'bus_out_F' },
    { id: 'SHAFT', path: 'SHAFT', label: '轴连接 SHAFT', dataType: 'array', required: true, outputPortId: 'bus_out_SHAFT' },
    { id: 'EXT', path: 'EXT', label: '引气连接 EXT', dataType: 'array', required: true, outputPortId: 'bus_out_EXT' },
    { id: 'WA_extraction', path: 'WA_extraction', label: '引气量', dataType: 'array', required: true, outputPortId: 'bus_out_WA_extraction' },
    { id: 'V', path: 'V', label: 'V', dataType: 'number', unit: 'm/s', required: true, outputPortId: 'bus_out_V' },
    { id: 'M', path: 'M', label: 'M', dataType: 'number', required: true, outputPortId: 'bus_out_M' },
    { id: 'H', path: 'H', label: 'H', dataType: 'number', unit: 'm', required: true, outputPortId: 'bus_out_H' },
    { id: 'THRUST', path: 'THRUST', label: 'THRUST', dataType: 'number', unit: 'kN', required: false, outputPortId: 'bus_out_THRUST' },
    { id: 'WA', path: 'WA', label: 'WA', dataType: 'number', unit: 'kg/s', required: false, outputPortId: 'bus_out_WA' },
    { id: 'PWG', path: 'PWG', label: 'PWG', dataType: 'array', unit: 'kW', required: false, outputPortId: 'bus_out_PWG' },
    { id: 'MAP', path: 'MAP', label: 'MAP', dataType: 'struct', required: true, outputPortId: 'bus_out_MAP' },
    { id: 'XD', path: 'XD', label: 'XD', dataType: 'array', required: false, outputPortId: 'bus_out_XD' },
    { id: 'YD', path: 'YD', label: 'YD', dataType: 'array', required: false, outputPortId: 'bus_out_YD' },
    { id: 'GAS_PROPERTY', path: 'GAS_PROPERTY', label: 'GAS_PROPERTY', dataType: 'array', required: false, outputPortId: 'bus_out_GAS_PROPERTY' },
    { id: 'GAS_PROPERTY_1', path: 'GAS_PROPERTY_1', label: 'GAS_PROPERTY_1', dataType: 'array', required: false, outputPortId: 'bus_out_GAS_PROPERTY_1' },
    { id: 'COMP_WP', path: 'COMP_WP', label: 'COMP_WP', dataType: 'array', required: false, outputPortId: 'bus_out_COMP_WP' },
    { id: 'TURB_WP', path: 'TURB_WP', label: 'TURB_WP', dataType: 'array', required: false, outputPortId: 'bus_out_TURB_WP' }
  ],
  'engine.mission': [
    { id: 'G', path: 'G', label: 'G', dataType: 'engine.mission.g', required: true, outputPortId: 'bus_out_G' }
  ],
  'engine.mission.g': [
    { id: 'DP', path: 'DP', label: 'DP', dataType: 'engine.dp', required: true, outputPortId: 'bus_out_DP' },
    { id: 'MAP', path: 'MAP', label: 'MAP', dataType: 'struct', required: true, outputPortId: 'bus_out_MAP' },
    { id: 'COMP_WP', path: 'COMP_WP', label: 'COMP_WP', dataType: 'array', required: true, outputPortId: 'bus_out_COMP_WP' },
    { id: 'TURB_WP', path: 'TURB_WP', label: 'TURB_WP', dataType: 'array', required: true, outputPortId: 'bus_out_TURB_WP' },
    { id: 'MOTOR_WP', path: 'MOTOR_WP', label: 'MOTOR_WP', dataType: 'array', required: true, outputPortId: 'bus_out_MOTOR_WP' },
    { id: 'THRUST_ARRAY', path: 'THRUST_ARRAY', label: 'THRUST_ARRAY', dataType: 'array', unit: 'kN', required: true, outputPortId: 'bus_out_THRUST_ARRAY' },
    { id: 'TIT_ARRAY', path: 'TIT_ARRAY', label: 'TIT_ARRAY', dataType: 'array', unit: 'K', required: true, outputPortId: 'bus_out_TIT_ARRAY' },
    { id: 'ENVELOPE', path: 'ENVELOPE', label: 'ENVELOPE', dataType: 'struct', required: false, outputPortId: 'bus_out_ENVELOPE' }
  ],
  'engine.op': [
    { id: 'V', path: 'V', label: 'V', dataType: 'number', unit: 'm/s', required: true, outputPortId: 'bus_out_V' },
    { id: 'H', path: 'H', label: 'H', dataType: 'number', unit: 'm', required: true, outputPortId: 'bus_out_H' },
    { id: 'PWG', path: 'PWG', label: 'PWG', dataType: 'array', unit: 'kW', required: true, outputPortId: 'bus_out_PWG' },
    { id: 'THRUST', path: 'THRUST', label: 'THRUST', dataType: 'number', unit: 'kN', required: false, outputPortId: 'bus_out_THRUST' },
    { id: 'COMP_WP', path: 'COMP_WP', label: 'COMP_WP', dataType: 'array', required: false, outputPortId: 'bus_out_COMP_WP' },
    { id: 'TURB_WP', path: 'TURB_WP', label: 'TURB_WP', dataType: 'array', required: false, outputPortId: 'bus_out_TURB_WP' }
  ],
  'engine.plot_artifact': [
    { id: 'function', path: 'function', label: '绘图函数', dataType: 'string', required: true, outputPortId: 'bus_out_function' },
    { id: 'output_directory', path: 'output_directory', label: '输出目录', dataType: 'string', required: true, outputPortId: 'bus_out_output_directory' },
    { id: 'files', path: 'files', label: '图片文件', dataType: 'array', required: true, outputPortId: 'bus_out_files' }
  ],
  'engine.design_inputs': [
    { id: 'flight_speed_mps', path: 'flight_speed_mps', label: 'flight_speed_mps', dataType: 'number', required: true, outputPortId: 'bus_out_flight_speed_mps' },
    { id: 'mach', path: 'mach', label: 'mach', dataType: 'number', required: true, outputPortId: 'bus_out_mach' },
    { id: 'altitude_m', path: 'altitude_m', label: 'altitude_m', dataType: 'number', required: true, outputPortId: 'bus_out_altitude_m' },
    { id: 'generator_power_kw', path: 'generator_power_kw', label: 'generator_power_kw', dataType: 'number', required: true, outputPortId: 'bus_out_generator_power_kw' }
  ],
  'engine.topology': [
    { id: 'components', path: 'components', label: 'components', dataType: 'array', required: true, outputPortId: 'bus_out_components' },
    { id: 'component_instances', path: 'component_instances', label: '部件实例', dataType: 'array', required: true, outputPortId: 'bus_out_component_instances' },
    { id: 'flow_edges', path: 'flow_edges', label: '气路连接', dataType: 'array', required: true, outputPortId: 'bus_out_flow_edges' },
    { id: 'flow_paths', path: 'flow_paths', label: '流路', dataType: 'array', required: true, outputPortId: 'bus_out_flow_paths' },
    { id: 'shaft_connections', path: 'shaft_connections', label: '轴系连接', dataType: 'array', required: true, outputPortId: 'bus_out_shaft_connections' },
    { id: 'branches', path: 'branches', label: '分支', dataType: 'array', required: true, outputPortId: 'bus_out_branches' },
    { id: 'shafts', path: 'shafts', label: 'shafts', dataType: 'array', required: true, outputPortId: 'bus_out_shafts' },
    { id: 'flow', path: 'flow', label: 'flow', dataType: 'string', required: true, outputPortId: 'bus_out_flow' },
    { id: 'shaft_count', path: 'shaft_count', label: 'shaft_count', dataType: 'number', required: true, outputPortId: 'bus_out_shaft_count' },
    { id: 'compressor_count', path: 'compressor_count', label: 'compressor_count', dataType: 'number', required: true, outputPortId: 'bus_out_compressor_count' },
    { id: 'turbine_count', path: 'turbine_count', label: 'turbine_count', dataType: 'number', required: true, outputPortId: 'bus_out_turbine_count' }
  ],
  'engine.design_result': [
    { id: 'air_mass_flow_kg_s', path: 'air_mass_flow_kg_s', label: 'air_mass_flow_kg_s', dataType: 'number', required: true, outputPortId: 'bus_out_air_mass_flow_kg_s' },
    { id: 'thrust_kn', path: 'thrust_kn', label: 'thrust_kn', dataType: 'number', required: true, outputPortId: 'bus_out_thrust_kn' },
    { id: 'generator_power_kw', path: 'generator_power_kw', label: 'generator_power_kw', dataType: 'number', required: true, outputPortId: 'bus_out_generator_power_kw' },
    { id: 'reference_power_kw', path: 'reference_power_kw', label: 'reference_power_kw', dataType: 'number', required: true, outputPortId: 'bus_out_reference_power_kw' },
    { id: 'fuel_mass_flow_kg_s', path: 'fuel_mass_flow_kg_s', label: 'fuel_mass_flow_kg_s', dataType: 'number', required: true, outputPortId: 'bus_out_fuel_mass_flow_kg_s' },
    { id: 'efficiency', path: 'efficiency', label: 'efficiency', dataType: 'number', required: true, outputPortId: 'bus_out_efficiency' },
    { id: 'turboelectric_efficiency', path: 'turboelectric_efficiency', label: 'turboelectric_efficiency', dataType: 'number', required: true, outputPortId: 'bus_out_turboelectric_efficiency' },
    { id: 'specific_fuel_consumption', path: 'specific_fuel_consumption', label: 'specific_fuel_consumption', dataType: 'number', required: true, outputPortId: 'bus_out_specific_fuel_consumption' },
    { id: 'compressor_working_points', path: 'compressor_working_points', label: 'compressor_working_points', dataType: 'array', required: true, outputPortId: 'bus_out_compressor_working_points' },
    { id: 'turbine_working_points', path: 'turbine_working_points', label: 'turbine_working_points', dataType: 'array', required: true, outputPortId: 'bus_out_turbine_working_points' },
    { id: 'turbine_inlet_temperature_k', path: 'turbine_inlet_temperature_k', label: 'turbine_inlet_temperature_k', dataType: 'array', required: true, outputPortId: 'bus_out_turbine_inlet_temperature_k' },
    { id: 'gas_property', path: 'gas_property', label: 'gas_property', dataType: 'engine.station_result', required: true, outputPortId: 'bus_out_gas_property' },
    { id: 'gas_property_outer', path: 'gas_property_outer', label: 'gas_property_outer', dataType: 'engine.station_result', required: true, outputPortId: 'bus_out_gas_property_outer' },
    { id: 'fuel_to_air_ratio', path: 'fuel_to_air_ratio', label: 'fuel_to_air_ratio', dataType: 'array', required: true, outputPortId: 'bus_out_fuel_to_air_ratio' }
  ],
  'engine.sweep_result': [
    { id: 'schema_version', path: 'schema_version', label: '版本', dataType: 'string', required: true, outputPortId: 'bus_out_schema_version' },
    { id: 'stage', path: 'stage', label: '阶段', dataType: 'string', required: true, outputPortId: 'bus_out_stage' },
    { id: 'requested_points', path: 'requested_points', label: '请求点数', dataType: 'number', required: true, outputPortId: 'bus_out_requested_points' },
    { id: 'completed_points', path: 'completed_points', label: '完成点数', dataType: 'number', required: true, outputPortId: 'bus_out_completed_points' },
    { id: 'points', path: 'points', label: 'points', dataType: 'array', required: true, outputPortId: 'bus_out_points' },
    { id: 'power_kw', path: 'power_kw', label: 'power_kw', dataType: 'array', required: true, outputPortId: 'bus_out_power_kw' },
    { id: 'speed_mps', path: 'speed_mps', label: 'speed_mps', dataType: 'array', required: true, outputPortId: 'bus_out_speed_mps' },
    { id: 'altitude_m', path: 'altitude_m', label: 'altitude_m', dataType: 'array', required: true, outputPortId: 'bus_out_altitude_m' },
    { id: 'thrust_kn', path: 'thrust_kn', label: 'thrust_kn', dataType: 'array', required: true, outputPortId: 'bus_out_thrust_kn' },
    { id: 'air_mass_flow_kg_s', path: 'air_mass_flow_kg_s', label: 'air_mass_flow_kg_s', dataType: 'array', required: true, outputPortId: 'bus_out_air_mass_flow_kg_s' },
    { id: 'turbine_inlet_temperature_k', path: 'turbine_inlet_temperature_k', label: 'turbine_inlet_temperature_k', dataType: 'array', required: true, outputPortId: 'bus_out_turbine_inlet_temperature_k' },
    { id: 'compressor_working_points', path: 'compressor_working_points', label: 'compressor_working_points', dataType: 'array', required: true, outputPortId: 'bus_out_compressor_working_points' },
    { id: 'turbine_working_points', path: 'turbine_working_points', label: 'turbine_working_points', dataType: 'array', required: true, outputPortId: 'bus_out_turbine_working_points' },
    { id: 'motor_working_points', path: 'motor_working_points', label: 'motor_working_points', dataType: 'array', required: true, outputPortId: 'bus_out_motor_working_points' },
    { id: 'converged', path: 'converged', label: 'converged', dataType: 'array', required: true, outputPortId: 'bus_out_converged' },
    { id: 'exitflag', path: 'exitflag', label: 'exitflag', dataType: 'array', required: true, outputPortId: 'bus_out_exitflag' },
    { id: 'residual_norm', path: 'residual_norm', label: 'residual_norm', dataType: 'array', required: true, outputPortId: 'bus_out_residual_norm' },
    { id: 'error', path: 'error', label: 'error', dataType: 'array', required: true, outputPortId: 'bus_out_error' }
  ],
  'engine.station_result': [
    { id: 'mass_flow_kg_s', path: 'mass_flow_kg_s', label: 'mass_flow_kg_s', dataType: 'array', required: true, outputPortId: 'bus_out_mass_flow_kg_s' },
    { id: 'fuel_air_ratio', path: 'fuel_air_ratio', label: 'fuel_air_ratio', dataType: 'array', required: true, outputPortId: 'bus_out_fuel_air_ratio' },
    { id: 'pressure_pa', path: 'pressure_pa', label: 'pressure_pa', dataType: 'array', required: true, outputPortId: 'bus_out_pressure_pa' },
    { id: 'temperature_k', path: 'temperature_k', label: 'temperature_k', dataType: 'array', required: true, outputPortId: 'bus_out_temperature_k' }
  ],
  'engine.solver_diagnostics': [
    { id: 'status', path: 'status', label: '状态', dataType: 'string', required: true, outputPortId: 'bus_out_status' },
    { id: 'stage', path: 'stage', label: '阶段', dataType: 'string', required: true, outputPortId: 'bus_out_stage' },
    { id: 'converged', path: 'converged', label: 'converged', dataType: 'boolean', required: true, outputPortId: 'bus_out_converged' },
    { id: 'exitflag', path: 'exitflag', label: 'exitflag', dataType: 'number', required: true, outputPortId: 'bus_out_exitflag' },
    { id: 'residual_norm', path: 'residual_norm', label: 'residual_norm', dataType: 'number', required: true, outputPortId: 'bus_out_residual_norm' },
    { id: 'residual', path: 'residual', label: 'residual', dataType: 'array', required: true, outputPortId: 'bus_out_residual' },
    { id: 'solver', path: 'solver', label: 'solver', dataType: 'string', required: true, outputPortId: 'bus_out_solver' },
    { id: 'message', path: 'message', label: 'message', dataType: 'string', required: true, outputPortId: 'bus_out_message' },
    { id: 'exception_identifier', path: 'exception_identifier', label: '异常标识', dataType: 'string', required: true, outputPortId: 'bus_out_exception_identifier' }
  ],
  'engine.envelope_diagnostics': [
    { id: 'status', path: 'status', label: '状态', dataType: 'string', required: true, outputPortId: 'bus_out_status' },
    { id: 'initialization', path: 'initialization', label: '初始求解', dataType: 'engine.solver_diagnostics', required: false, outputPortId: 'bus_out_initialization' },
    { id: 'power', path: 'power', label: '功率扫描', dataType: 'struct', required: false, outputPortId: 'bus_out_power' },
    { id: 'speed', path: 'speed', label: '速度扫描', dataType: 'struct', required: false, outputPortId: 'bus_out_speed' },
    { id: 'altitude', path: 'altitude', label: '高度扫描', dataType: 'struct', required: false, outputPortId: 'bus_out_altitude' }
  ],
  'engine.inspection': [
    { id: 'component_instances', path: 'component_instances', label: '部件实例', dataType: 'array', required: true, outputPortId: 'bus_out_component_instances' },
    { id: 'parameters', path: 'parameters', label: '部件参数', dataType: 'struct', required: true, outputPortId: 'bus_out_parameters' },
    { id: 'station_states', path: 'station_states', label: '站位状态', dataType: 'struct', required: true, outputPortId: 'bus_out_station_states' },
    { id: 'working_points', path: 'working_points', label: '工作点', dataType: 'struct', required: true, outputPortId: 'bus_out_working_points' }
  ],
  'engine.provenance': [
    { id: 'legacy_model', path: 'legacy_model', label: '原始模型', dataType: 'string', required: true, outputPortId: 'bus_out_legacy_model' },
    { id: 'compatibility_mode', path: 'compatibility_mode', label: '兼容模式', dataType: 'string', required: true, outputPortId: 'bus_out_compatibility_mode' },
    { id: 'solver', path: 'solver', label: '求解器', dataType: 'string', required: true, outputPortId: 'bus_out_solver' },
    { id: 'package_version', path: 'package_version', label: '包版本', dataType: 'string', required: true, outputPortId: 'bus_out_package_version' }
  ]
}

export const busFieldsForType = (type: unknown): BusField[] => (
  cloneBusFields(BUS_STRUCTURE_DEFINITIONS[String(type || '')])
)

export const isBusComponentId = (value: unknown) => (
  value === BUS_CREATOR_ID || value === BUS_SELECTOR_ID
)

export const isBusNodeKind = (value: unknown) => (
  value === 'busCreator' || value === 'busSelector'
)

export const validBusPath = (value: unknown) => (
  typeof value === 'string'
  && /^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)*$/.test(value)
)

export const normalizeSignalName = (value: unknown, fallback = 'signal') => {
  let name = String(value || '').trim().replace(/[^A-Za-z0-9_]/g, '_')
  if (!name) name = fallback
  if (!/^[A-Za-z_]/.test(name)) name = `signal_${name}`
  return name
}

export const nextSignalName = (fields: BusField[], preferredIndex?: number) => {
  const used = new Set(fields.map((field) => String(field.label || field.path || '').toLowerCase()))
  let index = Math.max(1, preferredIndex || 1)
  while (used.has(`signal${index}`.toLowerCase())) index += 1
  return `signal${index}`
}

export const cloneBusFields = (fields: unknown): BusField[] => {
  if (!Array.isArray(fields)) return []
  return fields
    .filter((field): field is BusField => Boolean(field && typeof field === 'object'))
    .map((field: BusField, index) => ({
      id: String(field.id || `field_${Date.now()}_${index}`),
      path: String(field.path || field.label || `field_${index + 1}`),
      label: String(field.label || field.path || `signal${index + 1}`),
      nameMode: (field.nameMode === 'manual' ? 'manual' : 'auto') as 'auto' | 'manual',
      sourceName: field.sourceName ? String(field.sourceName) : undefined,
      dataType: String(field.dataType || 'unknown'),
      shape: Array.isArray(field.shape) ? field.shape.map(Number).filter(Number.isFinite) : [],
      unit: field.unit ? String(field.unit) : undefined,
      inferred: field.inferred === true,
      contractStatus: (field.contractStatus === 'invalid'
        ? 'invalid'
        : field.contractStatus === 'inferred' ? 'inferred' : 'pending') as 'pending' | 'inferred' | 'invalid',
      required: field.required !== false,
      defaultValue: field.defaultValue ?? undefined,
      inputPortId: String(field.inputPortId || `bus_in_${String(field.id || index)}`),
      outputPortId: String(field.outputPortId || `bus_out_${String(field.id || index)}`)
    }))
}

export const builtinBusComponents = () => ([
  {
    id: BUS_CREATOR_ID,
    name: 'Bus创建器',
    engineType: 'matlab' as const,
    executorType: 'julia-matlab-graph',
    componentKind: 'workflow' as const,
    executionKind: 'busCreator' as const,
    functionName: '',
    description: '将多个输入信号组装为结构化Bus',
    library: '公共工具',
    category: 'Bus工具',
    inputs: [],
    outputs: [{ name: 'bus', type: 'bus' }],
    resources: []
  },
  {
    id: BUS_SELECTOR_ID,
    name: 'Bus选择器',
    engineType: 'matlab' as const,
    executorType: 'julia-matlab-graph',
    componentKind: 'workflow' as const,
    executionKind: 'busSelector' as const,
    functionName: '',
    description: '从结构化Bus中选择需要输出的信号',
    library: '公共工具',
    category: 'Bus工具',
    inputs: [{ name: 'bus', type: 'bus', required: true }],
    outputs: [],
    resources: []
  }
])
