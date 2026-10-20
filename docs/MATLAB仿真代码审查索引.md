# MATLAB 仿真代码审查索引

## 1. 文档范围

本文汇总当前项目中从“前端 MATLAB 建模页面”到“MATLAB 函数实际执行、结果返回和图片下载”的代码。代码分为两类：

- **通用 MATLAB 平台代码**：组件目录、递归 Scene、工程保存、可信图构建、任务提交、Julia/MATLAB 图执行、结果展示。
- **领域运行包**：航空发动机 `engine` 和永磁同步电机 `PMSM` 的 MATLAB 源码、图谱、Excel 输入及薄适配入口。

原始航空发动机项目 `C:\Users\xiong\Documents\ENGINE+GENERATOR（demo）` 是数值语义基准，不是平台运行时目录。平台实际执行的是后端资源目录中的自包含副本。

## 2. 一次 MATLAB 计算的完整调用链

```text
MatlabModelDeploy.vue
  ├─ 编辑 MatlabProjectV2（递归 workflow/physical Scene）
  ├─ buildExecutionPayload()
  └─ useMatlabExecution.handleStartCalculation()
       ↓ POST /business/model-deploy/simulation/submit
ModelDeployController
       ↓
ModelDeployServiceImpl.submitSimulation()
  ├─ RecursiveExecutionGraphExpander.expand()
  ├─ buildTrustedMatlabGraph()
  ├─ materializeMatlabResources()
  ├─ 写入 bs_simulation_task
  └─ POST 仿真服务 /api/v1/simulation/submit
       ↓
model-cloud-simulation/app/main.py
  └─ _execute_task()
       ↓
JuliaMatlabGraphExecutor.execute()
  ├─ 校验可信图和 MATLAB 源文件
  ├─ 准备任务资源与 trusted_graph.json
  └─ 启动 Julia run_matlab_graph.jl
       ↓
run_matlab_graph.jl
  ├─ 打开同一个 MATLAB Engine 会话
  ├─ 按 executionOrder 调用每个 MATLAB 函数
  ├─ 在 MATLAB 工作区传递 DP、OP、MISSION 等原始结构体
  └─ jsonencode 最终节点输出
       ↓
Python artifacts.py
  ├─ 收集 PLOTFLOW / DRAW_MAP_MISSION 生成的 PNG
  ├─ 创建任务内 artifact 清单
  └─ 从公开结果中移除绝对路径
       ↓
Spring Boot 轮询仿真服务并同步任务记录
       ↓
useMatlabExecution 轮询状态
       ↓
MatlabResultsDialog 展示结构体、数组、图表和 MATLAB 原图
```

## 3. 前端代码

根目录：`model-cloud-frontend/src`

### 3.1 页面、路由和 API

| 文件 | 功能 |
| --- | --- |
| `views/business/MatlabModelDeploy.vue` | MATLAB 建模主页面。当前仍直接管理组件目录、Vue Flow、递归 Scene、模板实例化、封装/解封装、物理关系、工程保存、执行请求构造和多个弹窗，是前端最主要的审查入口。 |
| `api/matlab-model-deploy.ts` | 当前 MATLAB 专用 API 和 TypeScript DTO：组件目录、配置工作簿、任务提交、状态查询、图片产物下载。 |
| `api/model-deploy.ts` | Modelica/MATLAB 共用的旧/通用工程与仿真 API 类型，审查时注意不要和 MATLAB 专用 API 混淆。 |
| `router/index.ts` | 注册 MATLAB 在线建模页面路由。 |
| `layouts/MainLayout.vue` | 左侧导航中的 MATLAB 在线建模入口。 |

### 3.2 画布节点和连线组件

| 文件 | 功能 |
| --- | --- |
| `components/model/MatlabComponentNode.vue` | 普通 MATLAB 函数节点和物理部件节点；显示输入输出端口，并根据物理透视暴露 flow/shaft/bleed 操作点。 |
| `components/model/MatlabCompositeNode.vue` | 可双击进入的复合节点，关联 `childSceneId`。 |
| `components/model/MatlabBusNode.vue` | Bus Creator/Selector 节点外观。 |
| `components/model/MatlabBusEditor.vue` | 编辑 Bus 字段和选择路径。 |
| `components/model/MatlabElkEdge.vue` | ELK 计算后的正交连线路径。 |
| `components/model/MatlabBranchedEdge.vue` | 分支/合束连接的显示。 |
| `components/model/MatlabNodeResizeHandles.vue` | 节点尺寸调整和尺寸状态。 |
| `components/model/MatlabPhysicalLensToolbar.vue` | 总览、气路、轴系和引气透视切换。 |
| `components/model/MatlabPhysicalProperties.vue` | 随物理透视变化的部件、关系边、轴组和引气组属性编辑。 |

### 3.3 结果组件

| 文件 | 功能 |
| --- | --- |
| `components/model/MatlabResultsDialog.vue` | 结果弹窗总容器；目前同时负责结果树、ECharts、数组选择、侧栏拖动、图片预览和导出。 |
| `components/model/MatlabResultStructureTable.vue` | 递归展示 MATLAB 结构体、数组和字段类型。 |
| `components/model/MatlabArrayTable.vue` | 矩阵、高维/非规则数组的分页表格和 CSV 导出。 |

### 3.4 Composable

| 文件 | 功能 |
| --- | --- |
| `composables/useMatlabExecution.ts` | 提交任务、保存提交时节点快照、轮询状态、处理成功或失败。 |
| `composables/useMatlabResults.ts` | 保存原始任务结果、节点/端口选择、数组和图片分组等结果状态。 |
| `composables/useMatlabProject.ts` | 工程列表、打开、保存和删除相关状态。 |
| `composables/useMatlabConfigWorkbook.ts` | PMSM Excel 配置预览、上传和绑定。 |
| `composables/useMatlabCanvasLayout.ts` | 将页面 Scene、Vue Flow 实例和 ELK 布局协调起来。 |
| `composables/useMatlabElkLayout.ts` | 构建 ELK 图、估算节点尺寸、全量布局和仅连线路由；包含异步请求失效与超时处理。 |
| `composables/useMatlabPhysicalLens.ts` | 向节点和边注入当前 physical Scene 透视，决定关系高亮和可编辑性。 |

### 3.5 数据工具

| 文件 | 功能 |
| --- | --- |
| `utils/matlabProjectData.ts` | `MatlabProjectV2`、Scene、边界端口、关系组类型，以及工程序列化/反序列化。 |
| `utils/matlabPhysicalRelations.ts` | 计算轴组/引气组成员、生成新组、按顺序读取组。 |
| `utils/matlabBus.ts` | Bus 类型树、字段规范化、Bus Creator/Selector 内置组件定义。 |
| `utils/matlabResultData.ts` | 结果结构遍历、数组维度识别、单位推断、高维数组曲线拆行、CSV 坐标展开和结果 DTO。 |

### 3.6 前端应重点审查的问题

- `MatlabModelDeploy.vue` 中 `nodes/edges` 与 `sceneStore` 同时保存图状态，并通过深度监听同步。
- 模板复制、ID 重映射、封装/解封装和执行请求构造仍位于页面中。
- `useMatlabExecution` 通过较大的依赖对象反向访问页面状态。
- `MatlabResultsDialog.vue` 同时承担状态、数据转换和视图生命周期。
- 前端当前没有针对 Scene 命令和执行请求转换的自动化测试。

## 4. Spring Boot 后端代码

根目录：`model-cloud-backend/src/main/java/com/modelcloud/modules/business`

### 4.1 HTTP 接口

| 文件 | 功能 |
| --- | --- |
| `controller/ModelDeployController.java` | 组件目录、MATLAB 配置、工程 CRUD、任务提交/查询、图片下载的 HTTP 控制器。MATLAB 相关接口统一位于 `/business/model-deploy` 下。 |
| `service/ModelDeployService.java` | 组件、工程和仿真任务服务接口。 |
| `service/MatlabConfigService.java` | PMSM 配置 Excel 模板、Schema、上传校验、用户配置和任务快照物化。 |

主要接口：

```text
GET    /matlab/components
GET    /matlab/config-template
GET    /matlab/config-schema
POST   /matlab/configs
GET    /matlab/configs/my
GET    /matlab/configs/{configId}
DELETE /matlab/configs/{configId}
POST   /projects
PUT    /projects/{projectId}
GET    /projects/{projectId}
POST   /simulation/submit
GET    /simulation/{taskId}/status
GET    /simulation/{taskId}/artifacts/{artifactId}
```

### 4.2 核心服务

| 文件 | 功能 |
| --- | --- |
| `service/impl/ModelDeployServiceImpl.java` | 当前后端总服务。加载 PMSM/发动机组件目录，校验组件定义，构建可信 MATLAB 执行图，校验端口/Bus/资源/输入值，物化资源，保存工程和任务，调用仿真服务并同步状态，代理图片下载。也包含大量 Modelica 逻辑。 |
| `service/impl/RecursiveExecutionGraphExpander.java` | 递归展开 workflow Scene；处理复合节点边界端口；展平 physical Scene；生成初始化节点的 `assembly_json`；生成稳定执行 ID、`originPath` 和公开输出；目前还在 Java 中生成部分 `F/SHAFT/EXT` 语义。 |

### 4.3 数据对象和持久化

| 文件 | 功能 |
| --- | --- |
| `model/dto/MatlabComponentVO.java` | 组件目录 DTO，包括端口、资源、调用参数/返回值、模板、构型默认值。 |
| `model/dto/MatlabConfigVO.java` | 用户 PMSM 配置记录 DTO。 |
| `model/request/SimulationRequest.java` | 仿真提交请求；MATLAB 使用 `engineType=matlab` 和 `executionPayload`。 |
| `model/domain/BsModelingProject.java` | 工程实体，MATLAB 递归工程保存在 `projectData`。 |
| `model/domain/BsSimulationTask.java` | 数据库任务实体，保存任务 ID、状态、执行图、结果和错误。 |
| `model/domain/BsMatlabConfig.java` | 用户上传的 MATLAB/PMSM 工作簿配置实体。 |
| `mapper/BsMatlabConfigMapper.java` | MATLAB 配置表访问。 |
| `service/impl/BsModelServiceImpl.java` | 模型业务的外围逻辑；包含 MATLAB 项目类型相关判断，但不是 MATLAB 图执行核心。 |
| `common/config/SecurityConfig.java` | 放行/保护相关 API 的安全配置，影响前端能否加载组件或下载结果。 |

### 4.4 组件目录资源

| 文件 | 功能 |
| --- | --- |
| `src/main/resources/matlab-components/engine-components.json` | 发动机物理部件、三个完整构型、设计点/扫描/绘图阶段、端口、调用契约和嵌套 Scene 模板。 |
| `src/main/resources/matlab-components/pmsm-components.json` | PMSM 组件目录和调用契约。 |
| `src/main/resources/matlab-components/pmsm-config-schema.json` | PMSM Excel 工作簿结构和必需变量。 |

## 5. 仿真服务与 Julia/MATLAB 执行器

根目录：`model-cloud-simulation`

| 文件 | 功能 |
| --- | --- |
| `app/main.py` | FastAPI 服务；创建内存任务、后台执行、状态查询和图片下载。按 `engineType` 分流 OpenModelica 与 MATLAB。 |
| `app/config.py` | Julia、MATLAB 组件根目录、任务目录、超时和并发等环境配置。 |
| `app/executors/julia_matlab_graph_executor.py` | Python 侧可信图执行协调器：再次校验节点/端口/Bus/invocation，检查源码路径，校验任务资源哈希，写图文件，串行调用 Julia，解析结果和结构化错误。 |
| `julia/run_matlab_graph.jl` | 真正的 MATLAB 图运行器。生成 Julia 执行代码；同一会话执行全部 MATLAB 节点；创建 Bus；保存 MATLAB 变量引用；序列化节点输出；捕获 MATLAB identifier、报告和失败节点。 |
| `app/artifacts.py` | 仅从受信绘图包装器输出中发现 PNG，将图片复制到任务级目录，生成不可猜测 artifact ID，并删除公开结果中的绝对路径。 |

执行器关键对象：

```text
GraphExecutionError        Python 结构化执行错误
JuliaMatlabGraphExecutor   Python 执行入口
MatlabValueRef             Julia 中的 MATLAB 工作区表达式引用
GraphRuntime               Julia 图运行时状态
matlab_eval_checked        对每条 MATLAB 命令包裹 try/catch 与完成哨兵
execute_node!              调用普通 MATLAB 函数
execute_bus_creator!       在 MATLAB 中创建结构体
execute_bus_selector!      选择结构体字段
execute_graph              打开会话、执行整图、投影输出和错误
```

## 6. 航空发动机 MATLAB 运行包

根目录：

```text
model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src
```

该目录当前约有 114 个 `.m` 文件和 131 个图谱/Excel/MAT 等数据文件。

### 6.1 平台薄入口：`workflows`

| 文件 | 功能 |
| --- | --- |
| `component_engine_initialize_configuration.m` | 解码 preset 或 `assembly_json`，初始化飞行条件，调用固定构型或自定义构型初始化，加载电机输入和 MAP。 |
| `component_engine_apply_design_conditions.m` | 按原主脚本顺序覆盖 `THRUST`、`WA`、`PWG`。 |
| `component_engine_solve_design_point.m` | 调用 `BALANCE_FUNCTION_DESIGN(DP,0)`，输出原始 `DP/XD`。 |
| `component_run_engine_envelope.m` | 兼容的一体化包线入口，组合下面的扫描阶段。 |
| `component_engine_envelope_initialize.m` | 从设计点生成 `OP`，完成首次非设计点初始化，建立扫描状态。 |
| `component_engine_envelope_power.m` | 按设计后 `DP.PWG` 执行降功率扫描并保留 `MISSION_power`。 |
| `component_engine_envelope_speed_initialize.m` | 功率段结束后按原脚本重置 `OP/X0`。 |
| `component_engine_envelope_speed.m` | 从设计速度减去一个步长开始执行降速度扫描。 |
| `component_engine_envelope_altitude.m` | 不重置速度末态，继续执行降高度扫描。 |
| `component_engine_envelope_append_point.m` | 把当前 `OP` 的原始输出追加到累计数组。 |
| `component_engine_envelope_mission.m` | 从扫描状态构造原项目 `MISSION` 结构体。 |
| `component_engine_envelope_finalize.m` | 输出 `MISSION`、推力、TIT、工作点及最终 `OP/X0/DX`。 |
| `component_engine_envelope_scope.m` | 保存并恢复 MATLAB 当前目录、路径和图形环境。 |
| `component_engine_envelope_validate_count.m` | 校验扫描点数是合法正整数。 |
| `component_engine_envelope_validate_state.m` | 校验阶段间传入的扫描状态字段。 |
| `component_engine_plot_flow.m` | 调用原 `PLOTFLOW`，使用不可见图窗保存设计点气路 PNG。 |
| `component_engine_plot_map_mission.m` | 调用原 `DRAW_MAP_MISSION`，保存功率后或最终特性图。 |

### 6.2 构型输入：`Input`

| 文件 | 功能 |
| --- | --- |
| `INPUT_DESIGN_PARAMETERS.m` | 原设计条件总入口，建立 DP 并按原次序加载发动机、电机和图谱。 |
| `INPUT_TURBO.m` | 原固定构型 switch，是 ducted fan、turboshaft、mixed turbofan 默认参数的数值基准。 |
| `INPUT_TURBO_COMMON_HEAD.m` | 从 `INPUT_TURBO` 提取的公共初始化头。 |
| `INPUT_TURBO_COMMON_TAIL.m` | 从 `INPUT_TURBO` 提取的公共初始化尾，保持计数、数组和默认值覆盖顺序。 |
| `INPUT_TURBO_CUSTOM.m` | 把用户物理 Scene 生成的 DP 风格 assembly 合并进公共初始化链。 |
| `ENGINE_SCENE_ASSEMBLY.m` | 将物理 Scene 的 flow、shaft、bleed、关系组和部件参数转换为 `F/SHAFT/EXT/WA_extraction` 等 DP 字段。 |
| `INPUT_ELECTRIC.m` | 读取 PMSM Excel，生成电机设计输入。 |
| `READMAP.m` | 按 `DP.F` 和构型读取、重置、缩放部件图谱。 |
| `READ_COMPONENT.m` | 旧式部件图谱/参数读取脚本。 |
| `READ_MOTOR.m` | 电机图谱读取脚本。 |
| `Component Map Input.xlsx` | 发动机部件与图谱配置数据。 |
| `pmsm input.xlsx` | 发动机初始化链使用的默认 PMSM 数据。 |

### 6.3 整机平衡核心：`Mainprogram-v1`

| 文件 | 功能 |
| --- | --- |
| `BALANCE_FUNCTION_DESIGN.m` | 根据构型建立设计点未知量、初值和残差，调用 `fsolve`，记录诊断，最终调用 `DESIGN`。 |
| `DESIGN.m` | 按 `DP.F` 顺序执行部件，计算设计点气路状态、功率、推力和残差 `YD`。 |
| `BALANCE_FUNCTION_OFFDESIGN.m` | 建立非设计点未知量和残差，调用 `fsolve` 并更新 `OP/X/DX`。 |
| `OFFDESIGN.m` | 非设计点部件顺序计算，输出 `YO`、工作点、推力、功率和热状态。 |

这四个文件是数值语义审查的最高优先级。平台的 Scene 和 DAG 只负责准备输入和调度，真正的发动机闭环迭代仍在这里。

### 6.4 热力部件：`components`

| 文件 | 功能 |
| --- | --- |
| `INLET.m` | 进气道总温总压和速度状态。 |
| `DUCT.m` | 管道总压损失。 |
| `COMPRESSOR.m` | 压气机/风扇压缩过程、效率和轴功。 |
| `BURN.m` | 主燃烧室燃油空气比和出口状态。 |
| `TURBINE.m` | 涡轮膨胀、效率和轴功。 |
| `MIXER.m` | 内外涵质量、能量和压力混合。 |
| `AFTERBURN.m` | 加力燃烧室燃油比和出口状态。 |
| `NOZZLE.m` | 喷管流动与推力。 |
| `MOTOR.m` | 电机/发电机旧接口脚本；主要电机设计功能位于 PMSM 包。 |

### 6.5 图谱：`Mapping`

| 文件组 | 功能 |
| --- | --- |
| `MAPPING.m` | 图谱插值统一入口。 |
| `MAP_1.m`～`MAP_4.m` | 不同种类部件图谱的生成/插值脚本。 |
| `MAP_RESET.m`、`MAP_SCALING.m`、`MAP_EXTENSION.m`、`RESHAPEMAP.m` | 图谱焓变重算、缩放、扩展和整形。 |
| `GENERATOR_MAP.m`、`TURBO_GENERATOR_MAP.m`、`GET_PROP_MAP.m` | 电机、涡轮发电机和螺旋桨图谱处理。 |
| `plotComponentMap.m`、`plotMotorMap.m` | 单个部件和电机图谱绘制。 |
| `PLOTFLOW.m` | 设计点气路温压状态绘图。 |
| `DRAW_MAP_MISSION.m` | 根据 `MISSION` 绘制扫描过程的部件工作线。 |
| `SAVEMAP.m` | 旧式图谱保存脚本。 |

### 6.6 热物性和局部计算：`Thermodynamics-v1`

这些文件是原项目内部依赖，不是模型库组件：

| 文件 | 功能 |
| --- | --- |
| `AE.m` | 气体绝热指数。 |
| `CPSH.m` | 定压比热。 |
| `GC.m` | 气体常数。 |
| `MM.m` | 摩尔质量。 |
| `SE.m`、`E.m` | 比焓/熵等热力状态量。 |
| `TEMP.m`、`TT.m`、`TP.m` | 状态量反算温度或压力。 |
| `ASP.m` | 标准大气静态参数。 |
| `STAGNATION_CAL.m` | 飞行静态量与总参数换算。 |
| `TOTAL_PRESSURE.m`、`TOTAL_TEMP.m` | 马赫数相关总静参数比。 |
| `AFP.m`、`AFT.m` | 速度系数对应压力/温度函数。 |
| `FC.m`、`QF.m` | 流量函数。 |
| `IF.m`、`SV.m`、`VC.m`、`LAMBDA.m`、`MACH_NUMBER.m` | 流速、速度系数、马赫数和流量关系。 |
| `FARC.m`、`FARAB.m`、`TAB.m` | 主燃烧室/加力燃烧室燃油比和温度关系。 |
| `TPE.m` | 考虑变比热的压缩/膨胀过程。 |
| `MU.m` | 动力黏度。 |
| `PRO.m` | 热物性统一查询入口。 |
| `AIRFLOW_ESTIMATE.m` | 按推力估算空气流量。 |
| `COMP_OPT.m` | 压气机最优压比估计。 |
| `CFD_NOZZLE.m` | 一维喷管 CFD 辅助计算。 |
| `DUCTED_FAN.m`、`DEP_FAN.m`、`FAN.m` | 原项目遗留涵道风扇/风扇计算路径；当前整机严格路径不应以它们替代通用平衡链。 |
| `TURBINE_ITERATION.m` | 涡轮参数迭代辅助脚本。 |

### 6.7 数学函数：`Mathematics-v1`

| 文件 | 功能 |
| --- | --- |
| `EFS.m` | 平衡方程求解辅助。 |
| `NIFS.m` | 牛顿迭代类非线性求解器。 |
| `MC.m` | 原项目数学辅助脚本。 |

### 6.8 图谱和数据文件：`Map Collection`

该目录含压气机、涡轮、电机、螺旋桨和涡轮发电机的 `.MAP/.EMAP/.txt/.xlsx/.mat` 数据，以及 13 个图谱预处理 `.m` 文件。重点子目录：

```text
COMPRESSOR
TURBINE
MOTOR
PMSM
PROPELLER
TURBO GENERATOR
```

这些文件是 `READMAP`、`MAPPING` 和部件计算的运行资源，不能仅审查 `.m` 文件而忽略它们的索引、单位和数组方向。

## 7. PMSM MATLAB 运行包

根目录：

```text
model-cloud-backend/src/main/resources/static/matlab_component_source/PMSM
```

该包有 49 个 `.m` 文件和 1 个默认 Excel 输入，属于通用 MATLAB 平台的另一套领域组件，也是发动机 `INPUT_ELECTRIC` 的重要回归对象。

### 7.1 对外模块入口

| 文件 | 功能 |
| --- | --- |
| `src/module/component_motor_configuration.m` | 读取并封装电机设计配置。 |
| `src/module/component_dimensions_electromagnetic.m` | 电机主要尺寸、电磁和绕组设计。 |
| `src/module/component_losses_performance.m` | 损耗和性能计算。 |
| `src/module/component_mass_cooling.m` | 质量和冷却结构计算。 |
| `src/module/component_create_motor_model.m` | 把设计结果封装为可复用电机模型。 |
| `src/module/component_calculate_rectangular_duct_h.m` | 矩形冷却流道换热系数标量入口。 |
| `src/module/PMSM_design.m` | PMSM 整体设计。 |
| `src/module/PMSM_off_design.m` | PMSM 非设计点性能。 |
| `src/module/PMSM_thermal_network.m` | PMSM 热网络。 |
| `src/io/INPUT_ELECTRIC.m` | 从默认或任务 Excel 快照构造 PMSM 输入。 |

### 7.2 内部组件

`src/components` 包含：

- 尺寸与绕组：`calculate_main_dimensions`、`calculate_pm_thickness`、`calculate_rotor_magnet_design`、`calculate_slot_geometry_new`、`calculate_stator_winding_design`、`calculate_wire_diameter`。
- 损耗：`calculate_annular_cascade_loss`、`calculate_copper_resistance`、`calculate_extra_losses`、`calculate_iron_losses`、`calculate_magnet_losses`、`calculate_total_losses`、`calculate_windage_losses`。
- 质量与性能：`calculate_motor_mass`、`calculate_design_performance`、`assemble_design_result`、`prepare_design_operating`。
- 热网络：`build_thermal_network_air`、`build_thermal_network_hpcgv`、`build_thermal_network_liquid`、`thermal_balance_solver`、`simplify_thermal_network`。
- 热阻与换热：`calculate_rectangular_duct_h`、`conv_stator_end`、`Nu_airgap`、`Nu_cgv`、`R_heatpipe`、`Rr_cyn`、`Rt_cyn`、`Rx_cyn`。
- 材料与气体属性：`get_prop`、`get_pmsm_geometry`、`copper_heat_capacity`、`steel_heat_capacity`、`AE`、`CPSH`、`GC`、`MU`、`SV`。

发动机包和 PMSM 包中同时存在 `AE/GC/MU/SV/INPUT_ELECTRIC` 等名称，审查路径管理时必须检查同名函数污染。

## 8. 测试代码

### 8.1 后端

| 文件 | 功能 |
| --- | --- |
| `RecursiveExecutionGraphExpanderTest.java` | 递归 Scene、边界端口、物理装配、异常和公开输出测试。 |
| `MatlabCatalogLoadTest.java` | 组件目录 JSON、源文件和资源路径检查。 |
| `EngineGoldenFixtureTest.java` | 发动机构型/装配黄金数据测试。 |

### 8.2 仿真服务

| 文件 | 功能 |
| --- | --- |
| `tests/test_engine_contract.py` | 发动机可信图、调用协议和执行器契约。 |
| `tests/test_artifacts.py` | MATLAB PNG 索引、路径隔离、公开投影和 artifact ID。 |

### 8.3 MATLAB

| 文件 | 功能 |
| --- | --- |
| `component_engine_entry_tests.m` | 初始化、条件设置和设计点三阶段入口。 |
| `component_engine_backend_scene_tests.m` | 后端物理 Scene/assembly 的形状和字段。 |
| `engine_compatibility_smoke.m` | 平台包与原项目设计点对比。 |
| `engine_legacy_baseline.m` | 从原 `TURBOSHAFT_MAIN` 捕获统一基线。 |
| `engine_full_scan_regression.m` | 默认 `20/100/100` 扫描回归。 |
| `engine_plot_image_regression.m` | 包装器图片与原绘图调用比较。 |

前端目前没有对应测试文件，这是审查和重构的明显缺口。

## 9. 原始参考项目

原项目审查起点：

```text
C:\Users\xiong\Documents\ENGINE+GENERATOR（demo）\TURBOSHAFT_MAIN.m
```

主要基准链：

```text
TURBOSHAFT_MAIN
  → INPUT_DESIGN_PARAMETERS
  → INPUT_TURBO
  → INPUT_ELECTRIC
  → READMAP
  → BALANCE_FUNCTION_DESIGN
  → DESIGN
  → BALANCE_FUNCTION_OFFDESIGN
  → OFFDESIGN
  → PLOTFLOW / DRAW_MAP_MISSION
```

原项目还包含完整任务、预设计、PMSM、SimulinkRebuild 和大量实验脚本。平台首批发动机功能只以以上稳态设计点、包线扫描和绘图链为数值基准。

## 10. 推荐审查顺序

建议按照数据实际流动顺序阅读：

1. `engine-components.json`：理解模型库中声明了什么。
2. `matlabProjectData.ts`：理解工程如何保存递归 Scene。
3. `MatlabModelDeploy.vue`：理解模板如何实例化以及执行请求如何生成。
4. `RecursiveExecutionGraphExpander.java`：理解层级图如何扁平化。
5. `ModelDeployServiceImpl.buildTrustedMatlabGraph`：理解后端如何建立可信执行图。
6. `julia_matlab_graph_executor.py`：理解仿真服务的二次校验和进程调用。
7. `run_matlab_graph.jl`：理解 MATLAB 函数如何在同一会话中执行和传值。
8. `component_engine_initialize_configuration.m` 和 `ENGINE_SCENE_ASSEMBLY.m`：理解画布物理关系如何变成 DP。
9. `INPUT_TURBO.m`：核对三个构型的原始默认参数。
10. `BALANCE_FUNCTION_DESIGN/DESIGN`：审查设计点未知量与残差。
11. `BALANCE_FUNCTION_OFFDESIGN/OFFDESIGN`：审查非设计点平衡。
12. `component_engine_envelope_*`：核对功率、速度和高度状态机。
13. `PLOTFLOW`、`DRAW_MAP_MISSION` 和 `artifacts.py`：理解原图生成与交付。
14. `useMatlabResults`、`matlabResultData`、`MatlabResultsDialog`：理解结果在前端如何展示。

## 11. 当前最重要的架构交叉点

审查时优先关注四处重复或耦合：

1. **图状态重复**：页面 `nodes/edges` 与 `sceneStore`。
2. **物理装配重复**：Java `populateAssemblyTopology` 与 MATLAB `ENGINE_SCENE_ASSEMBLY`。
3. **执行图校验重复**：Java `buildTrustedMatlabGraph` 与 Python `_validate_payload`。
4. **结果职责堆积**：`MatlabResultsDialog.vue` 同时处理数据、状态、图表和导出。

这些位置也是后续重构最容易改变行为的区域，阅读时应结合现有测试和三个构型的实际执行请求一起核对。
