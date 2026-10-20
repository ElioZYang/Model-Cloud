# PMSM 组件子系统与 HPCGV 混动构型

## 使用入口

- 仿真库 `PMSM → PMSM项目 → 独立PMSM工程`：设计、非设计、热分析三个可编辑实例，按数据连接依次运行。
- `PMSM → PMSM子系统 → PMSM电磁热子系统`：展开后分别进入设计、非设计和热分析入口；计算组件可以重新连接、替换和封装。
- `航空发动机 → 发动机构型 → HPCGV混动涡轴发动机`：第 12 个构型，默认执行设计及 20/100/100 工况扫描和绘图。
- 独立 MATLAB 项目：`C:/Users/xiong/Documents/PMSM_Project/PMSM_moudle/run_pmsm_core.m`；显式接口为 `run_pmsm_analysis(request)`。

```matlab
request = struct('mode','design','power_kw',50,'speed_rpm',60000, ...
  'flow',struct('T',288.15,'P',101325,'WA',1,'FAR',0,'D',0,'EFFH',1));
design = run_pmsm_analysis(request);
request.mode = 'offdesign';
request.design_model = design.pmsm_params;
request.power_kw = 25; request.speed_rpm = 48000;
offdesign = run_pmsm_analysis(request);
request.mode = 'thermal'; request.design_model = offdesign.pmsm_params;
request.free_temperature_mask = [true; true];
thermal = run_pmsm_analysis(request);
```

`config_file` 可指定参数工作簿；`temperatures_C` 指定两热节点温度。温度边界顺序与原模型一致，为铁芯、绕组。不指定自由节点时执行固定温度分析；指定自由节点时求解对应温升率为零，并检查退出状态和残差。独立接口不修改当前目录或基础工作区。

外部功率为 kW、转速为 rpm；气流总温为 K、总压为 Pa、流量为 kg/s；热节点温度为摄氏度。原模型中 `performance.power/mechanical_power` 及损耗为 W；耦合输出 `PWG/PWS/PWH` 为 kW。正电功率表示发电，负值表示电动；零功率及不可行工况明确报错。

## 组件与参考模型

`tools/pmsm/sync_pmsm.py` 从只读发动机项目抽取计算依赖，将原设计代码按实际顺序拆为工况、主尺寸、绕组、磁钢、损耗性能、质量和结果组装组件；热分析拆为准备、冷却网络和出口状态组件。公式没有重新推导。

所有新计算入口使用 `mc_pmsm_` 前缀。独立项目 `shared/core` 与组件库 `PMSM/src/core` 由同一脚本生成；`provenance.json` 记录参考来源。配置工作簿和材料列按发动机版本同步。旧 PMSM 组件 ID 不提供兼容，旧工程由用户自行删除。历史代码不属于新入口的调用链。

设计入口的气隙磁密覆盖值为 0 时沿用配置，正值覆盖配置。内部数据连接决定计算顺序；缺失必需数据、类型不匹配或环路会拒绝执行。可以替换具有相同状态接口的冷却网络组件。

## 层级与执行契约

Scene 继续是通用容器，物理关系保存在工程级 `physicalAssemblies`。

- 子系统 `modelEntrypoints` 引用内部设计、非设计、热分析场景，保存和模板实例化均保留并重映射引用。
- Java 在提交时从这些场景编译可信 `modelPrograms`，将外部调用映射为 `pmsm.program.execute`；内部组件不会再成为外层一次性 DAG 节点。
- Python 对每个入口执行完整图校验、源码路径校验和资源校验。
- Julia 在任务开始注册程序；MATLAB 在每次残差评估中执行当前子图。程序拓扑只准备一次，运行输入和结果每轮更新。
- 最终子图节点快照加入结果节点集合，保留原工程节点 ID 和内部路径；任务结束清理注册表。
- 内部异常在结构化错误的 `details.modelProgram` 中保留程序 ID、计算入口、内部节点与原始异常；`originPath/sourceNodeId` 定位内部组件，外层 `nodeId` 保留调用位置。正常调用及任务结束均清理旧错误。

HPCGV PMSM 作为一个整体气路成员参与 `inlet → PMSM → duct → hpc → burn → hpt → nozzle`。`motorBindings` 显式连接电机与轴组，MATLAB 据此建立 `SHAFT_CONTROL`；普通 `SHAFT` 矩阵保持原模型含义，避免重复计入功率。轴关系属性中的“耦合轴组”可以修改绑定。

原整机平衡方程、未知量/残差顺序及 fsolve 选项保留。PMSM 返回效率、机械功率、气流温升、压损和热残差。原项目的电机工作点记录用于电机特性图。

## 可复现验证

在仓库根目录为 MATLAB 添加 `tools/pmsm` 路径后运行：

- `pmsm_reference_regression(referenceRoot, standaloneRoot)`：原模型与共享组件，涵盖三种冷却及发电、电动工况。
- `standalone_regression(standaloneRoot)`：三个独立入口、稳态收敛、参数影响、连续调用、多实例隔离及非法输入与内部错误定位。
- `engine_regression(repoRoot, referenceRoot, false)`：混动装配与原项目设计/非设计数值对比。
- `engine_full_reference_regression(repoRoot, referenceRoot)`：实际 Julia 完整扫描完成后，与原项目的 20/100/100 扫描输出逐点对比。
- `engine_existing_regression(repoRoot)`：已有 11 个构型的初始化、设计和 3/4/4 扫描对比；保留原模型同类异常记录。

后端 `mvn test` 校验全部构型黄金夹具及 PMSM 编译；前端 `npm test` 校验入口重映射、保存重载和装配；Python `pytest tests/ -q` 校验嵌套图、源码边界、资源与任务恢复。

`prepare_runner.py` 为实际 Julia–MATLAB 执行准备本地组件根目录。运行结果、生成调度代码和图片保存在被忽略的 `tools/pmsm/verification` 中。

`verify_result.py <验证目录>` 使用 Python 执行器的公开结果投影、产物收集器及公开结果 JSON Schema 审核实际运行结果。应在包含 `jsonschema` 和执行器依赖的 Python 环境运行。完整混动扫描还检查 220 点收敛记录及 design/power/final 的 1/3/3 张图片。

对实际失败结果使用 `verify_result.py <验证目录> --failure`，生成通过契约检查的 `public-error.json`，核对外层调用和内部节点定位。具体通过项与已知限制见 [验证记录](pmsm-hpcgv-validation.md)。

项目原有的 9 项前端类型错误位于路由、注册和系统管理页面，未在此任务中改动。独立 Vite 打包和本次模块测试分别验证。本次不涉及瞬态温升、任务历程或优化设计。
