# 航空发动机完整构型与递归子系统说明

## 1. 层级与运行边界

第一层是完整构型节点。进入构型后的第二层为：

```text
构型设计点模型 → 包线扫描 → 绘制特性图
```

设计点、扫描、绘图分别可进入第三层。设计点第三层为：

```text
物理构型 → 设计条件设置 → 设计点平衡求解
```

扫描第三层保留非设计点初始化、功率扫描、速度前重置、速度扫描、高度扫描和原始结果汇总；绘图第三层保留设计点温压图、功率扫描后部件图和完整扫描后部件图。物理构型还能进入第四层 physical Scene，编辑部件、气路、轴系和引气连接。工作流 Scene 递归展开为 MATLAB DAG；physical Scene 汇总为 `assembly_json`。平台不把物理闭环转为 DAG，`fsolve` 仍封装在原设计／非设计平衡函数内。

用户可自由编辑和保存连接。运行时只检查可信组件、节点和端口存在、工作流输入单来源、
展开后的 DAG、资源安全与递归 Scene 引用环；不增加气路守恒、单位或物理合理性判断。

## 2. 工程数据

工程使用 `MatlabProjectV2`：根对象保存 `schemaVersion=2`、`rootSceneId` 和 `scenes`。
每个 Scene 独立保存节点、边、边界端口、viewport 和可选构型级默认参数。复合节点用
`childSceneId` 指向内部 Scene。边界端口的 `mapping.childNodeId/childHandle` 描述父子
端口映射。

模板实例化会深复制全部 Scene、节点、边和边界映射 ID。选区封装把内部节点移入新
Scene，为跨边界连接生成 In/Out 端口；解封装按映射恢复。个人子系统只存在当前
工程 `projectData`，没有个人模型库、数据库表或跨工程接口。

旧平铺工程不自动迁移。前端保留其节点和边并标为不可解析。已保存的 V2 仅设计点构型按内部 Scene 内容识别，提供显式升级为完整构型操作，保留用户已编辑的设计点和物理 Scene。

## 3. 物理装配契约

部件实例至少携带 `legacyName`、`legacyOrder` 和 `assemblyDefaults`。`flow` 连线经稳定拓扑排序生成 `DP.F`；混排涡扇的旁路优先次序与原源码一致，`legacyOrder` 只作为同层节点的稳定排序依据。连接关系还包括 `shaft` 和 `bleed`，分别生成 `DP.SHAFT`、`DP.EXT`、`NS`、`NW`；连接器自身不进入 `DP.F`。不能线性化的气路在运行装配时明确报错，编辑时不限制自由连线。

`F、SHAFT、EXT、WA_extraction` 在 JSON 中携带显式 MATLAB 类型与 shape，保持行列
方向。部件参数按 `assemblyDefaults → values → parameters` 覆盖，再由 MATLAB 薄入口
按源码中同类部件顺序组装。缺失字段不从相似构型补值，由原 MATLAB 调用自然失败。

三套预置物理顺序来自 `INPUT_TURBO`：

- ducted fan：`inlet, lpc, nozzle`
- turboshaft：`inlet, duct, hpc, burn, hpt, nozzle`
- mixed turbofan：`inlet, duct, fan, outer duct, hpc, burn, hpt, mixer, afterburn, nozzle`

`afterburn` 在 `reheat=0` 时仍保留。构型装配只决定输入 `DP`，不改写 `DESIGN/OFFDESIGN` 中的公式、未知量、残差或迭代行为。

## 4. MATLAB 接口

```matlab
DP = component_engine_initialize_configuration(assembly_json, V, M, H)
DP = component_engine_apply_design_conditions(DP, thrust, WA, PWG)
[DP, XD] = component_engine_solve_design_point(DP)

[MISSION, THRUST_ARRAY, TIT_ARRAY, COMP_WP, TURB_WP, MOTOR_WP, OP, X0, DX] = ...
    component_run_engine_envelope(DP, power_points, speed_points, altitude_points)

scan_state = component_engine_envelope_initialize(DP)
[scan_state, MISSION_power] = component_engine_envelope_power(scan_state, power_points)
scan_state = component_engine_envelope_speed_initialize(scan_state)
scan_state = component_engine_envelope_speed(scan_state, speed_points)
scan_state = component_engine_envelope_altitude(scan_state, altitude_points)
[MISSION, THRUST_ARRAY, TIT_ARRAY, COMP_WP, TURB_WP, MOTOR_WP, OP, X0, DX] = ...
    component_engine_envelope_finalize(scan_state)
```

初始化保留 `INPUT_TURBO` 固定分支入口，并通过 `INPUT_TURBO_CUSTOM` 接受工程装配。
公共头、公共尾的赋值顺序保持原源码。设计求解不改未知量、残差、初值和 `fsolve`
条件。包线扫描在功率段后重置一次，速度段逐点降速，高度段沿用速度末态逐点降高；
正常返回的不收敛结果继续，MATLAB 异常在原位置终止。

扫描第三层各入口传递原始 `OP、X0、DX、MAP` 和累计数组，功率段额外保留 `MISSION_power`；最终输出继续保持原始 `MISSION` 和各数组。结果在同一 MATLAB 会话内以原结构体传递。JSON 仅用于浏览，数组保持整体，非有限值保留坐标并显示为空值。节点结果和错误携带 `originPath/sourceNodeId`。

## 5. 绘图与依赖

`component_engine_plot_flow(DP)` 调用原 `PLOTFLOW`；`component_engine_plot_map_mission(MISSION)` 在功率段和完整扫描结束后分别调用原 `DRAW_MAP_MISSION`。包装器使用不可见图窗，将原函数实际生成的 PNG 写入任务内独立阶段目录，仅关闭本次图窗，并恢复工作目录、MATLAB 路径和修改过的图形默认值。结果 JSON 只含图片清单与任务图片 ID；后端校验任务归属后代理查看和下载，不暴露仿真机路径。

`Thermodynamics-v1`、`Mathematics-v1`、`Mapping`、`Map Collection` 及 Excel 图谱全部是
内部运行依赖。后续拆分只在原项目存在稳定函数边界时增加部件入口，不把基础计算函数
注册为组件。

## 6. 后续扩展边界

后续可以开放独立设计点、单个非设计点和不同扫描任务；构型层继续使用同一 physical
Scene/assembly 契约；部件层从 `DESIGN/OFFDESIGN` 的真实输入组装位置提取薄入口。
任何扩展都应保持 `DP/XD/OP/X0/DX/MISSION` 原值、数组方向、异常停止点以及原求解顺序。
