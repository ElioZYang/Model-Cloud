# 航空发动机 MATLAB 建模与执行链架构（重构后）

> 2026-10-08 V3 续作：Scene 是通用容器，物理装配属于工程级 physicalAssemblies。历史分阶段报告记录当时状态；当前验证及交接见根目录 HANDOFF.md。

## 1. 四层数据流

```text
┌─────────────────────────────────────────────────────────────────────┐
│ 前端编辑器 (model-cloud-frontend)                                     │
│  MatlabModelDeploy.vue（页面组合）                                    │
│    ├── useMatlabEditorStore   ← 唯一 Scene 图状态源（scenes/active/  │
│    │                            viewport/layoutRevision，Pinia）      │
│    ├── domain/projectCodec    ← V3 工程序列化/解析，V2 显式导入         │
│    ├── domain/sceneCommands   ← 封装/解封装/边界重连（纯函数）          │
│    ├── domain/templateInstantiation ← 模板实例化 ID 深复制（纯函数）    │
│    ├── infrastructure/executionPayloadCompiler ← 提交负载编译（纯函数） │
│    └── components/MatlabBreadcrumb / MatlabCatalogPanel /            │
│        MatlabArtifactGallery                                         │
│  composables: TemplateOperations / ProjectUpgrade /               │
│    SubsystemNavigation / PhysicalAssemblyEditor / SubmissionValidation │
└──────────────┬──────────────────────────────────────────────────────┘
               │ projectData (matlab-project-v3)        │ 执行请求
               ▼                                        ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 后端 (model-cloud-backend, /business/model-deploy)                    │
│  ModelDeployServiceImpl（目录/工程CRUD/任务/资源/图片代理）             │
│    ├── MatlabHierarchyCompiler    ← 递归展开通用 subsystem、           │
│    │            边界端口重写、originPath、publicOutputs、Scene 环检测   │
│    ├── EngineAssemblyCompiler ← 工程物理装配与可信部件能力校验，        │
│    │            产出 EnginePhysicalSceneV1（不计算发动机语义）          │
│    └── MatlabTrustedGraphCompiler ← 受信校验：目录ID/白名单/端口/      │
│                 单输入单来源/必需输入/拓扑排序+环拒绝                    │
└──────────────┬──────────────────────────────────────────────────────┘
               │ trusted graph (matlab-execution-graph-v1)
               ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 仿真执行器 (model-cloud-simulation, :8000)                            │
│  main.py 任务生命周期 │ julia_matlab_graph_executor.py                │
│    ├── schemaVersion 校验（2 / matlab.execution.v1）                  │
│    ├── MatlabSessionCoordinator（并发可配，默认 1 串行）               │
│    ├── 结构化错误 structuredError（stage/originPath/identifier…）      │
│    └── nonFinitePaths 投影（NaN/Inf→null，记录路径，不替换为零）        │
│  julia/run_matlab_graph.jl：一张图一个 MATLAB 会话，                   │
│    按 executionOrder 执行，图内传原始变量，仅最终输出 JSON 编码          │
└──────────────┬──────────────────────────────────────────────────────┘
               ▼
┌─────────────────────────────────────────────────────────────────────┐
│ MATLAB 原模型 (static/matlab_component_source/engine)                 │
│  ENGINE_SCENE_ASSEMBLY  ← 物理 Scene→DP 的唯一发动机语义实现           │
│    （flow→F 拓扑排序(bypass 优先)、shaft/bleed 组→SHAFT/EXT/NS/NW、    │
│      组件值→TPR/EFFC/…、WA_extraction、assemblyDefaults）             │
│  原计算入口：initialize_configuration / apply_design_conditions /     │
│              solve_design_point → BALANCE_FUNCTION_DESIGN/DESIGN …    │
│  原绘图：PLOTFLOW / DRAW_MAP_MISSION（包装器收集 design/power/final）   │
└─────────────────────────────────────────────────────────────────────┘
```

## 2. 版本化契约（contracts/matlab/）

| Schema | 用途 | 生产者 → 消费者 |
|---|---|---|
| matlab-project-v3 | 工程持久化格式（schemaVersion=3，通用 Scene + physicalAssemblies） | 前端 → 现有 projectData → 前端 |
| matlab-execution-graph-v1 | 受信执行图，固定 schemaVersion='matlab.execution.v1'（Python 拒绝缺失/其他版本） | 后端编译器 → Python 执行器 |
| engine-physical-scene-v1 | 纯物理装配（Java 只展开，不推导 F/SHAFT/EXT） | Java 展开器 → MATLAB ENGINE_SCENE_ASSEMBLY |
| matlab-public-result-v1 | 公开结果，固定 schemaVersion+status；成功带 nonFinitePaths，失败带结构化 error（前端 MatlabFailureDialog 展示） | 执行器 → 后端 → 前端 |

黄金夹具：`contracts/matlab/fixtures/engine/`（三构型工程文档+展开图，
由 `EngineGoldenFixtureTest -Dgolden.update=true` 生成并逐字节校验）。

## 3. 关键不变式

1. Scene 图数据只有 useMatlabEditorStore 一份；画布经可写 computed 透传，无深度监听同步。
2. Java 不解释发动机语义；物理 Scene→DP 唯一实现在 MATLAB `ENGINE_SCENE_ASSEMBLY`。
3. 只有通用子系统；物理能力来自可信目录。装配关系独立存储，不进入数据 DAG。
4. `nodeKind`（工程节点）/`componentKind`（目录组件）/`executionKind`（执行节点）不再混用同一字段。
5. MATLAB 热力公式、未知量/残差顺序、fsolve 初值/选项、扫描状态机、绘图行为不因本重构改变。
6. Bus Creator/Selector、PMSM、普通 MATLAB 工作流路径不受影响。

## 4. 组件目录（matlab-components/engine/）

发动机组件按单项定义存为 JSON 文件，位于 `physical/`、`stages/`、`workflows/` 和 `configurations/`。每个构型文件同时保存模型库信息及完整 `templateDefinition`，无需加载外部工程资源。

| 目录 | 内容 |
|---|---|
| `physical/` | 15 个 `engine.gas-path.*` 气路物理部件定义 |
| `stages/` | 11 个 `engine.stage.*` 和 `engine.plot.*` 执行组件定义 |
| `workflows/` | 4 个设计点、工况扫描和绘图构件入口 |
| `configurations/` | 9 个完整构型定义，包含模型库信息、公开接口和完整画布场景 |

Bus Creator/Selector 为后端内置组件（`MatlabTrustedGraphCompiler.buildBuiltinBusComponent`）。PMSM 目录继续使用原数组文件；发动机目录由 `MatlabEngineCatalogReader` 按序聚合。服务加载后继续执行重复 ID 拒绝及 sourceRelativePath 存在性校验。

## 5. 测试与回归入口

```text
前端:   npm test -- --reporter=dot # domain/store/compiler/结构化错误与递归关系
       npx vue-tsc --noEmit      # 基线 9 个既有错误（非触及模块）
       npx vite build
后端:   mvn test                  # 装配可信校验及黄金夹具逐字节对比
Python: py -m pytest tests/ -q    # 契约/协议/artifacts
MATLAB: engine_physical_scene_v1_regression   # 三构型 V1 vs 预设
        component_engine_entry_tests              # 入口契约
        component_engine_backend_scene_tests      # 场景全链路（含绘图）
```

V3 物理关系显示由 `domain/physicalView.ts` 投影，不写回 `dataEdges`。递归封装沿每层
`kind=flow/shaft/bleed` 边界解析到稳定的叶部件 ID，装配归属不变。
`MatlabAssemblyPanel.vue` 提供多装配选择、成员管理和显式初始化绑定；普通 PMSM 子系统无这些工具。

V3 关系组成员适配为现有 V1 的锚点及组内关系边，供未修改的 MATLAB 装配函数读取。
后端不计算 F/SHAFT/EXT。三个完整模板直接为 V3；`fixtures/engine/*.project-v2.json`
仅保留历史文件名，其内容已经是 V3。执行请求仍保留历史 schemaVersion=2，保存工程与执行图是不同契约。
