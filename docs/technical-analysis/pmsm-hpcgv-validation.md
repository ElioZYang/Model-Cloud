# PMSM 与 HPCGV 混动构型验证记录

验证日期：2026-10-15 至 2026-10-16。环境：Windows、MATLAB R2025b、Julia 1.12.5。参考发动机项目仅用于读取和数值对比，用户工程未删除。接口和使用方式见 [实施说明](pmsm-hpcgv-implementation.md)。

## 已完成的实现

1. 独立 PMSM 的设计、非设计及稳态热分析入口，与组件库共用 64 个带前缀的 MATLAB 函数；连同默认计算图、配置工作簿，共 66 个文件逐字节一致。
2. 可展开、编辑、复制和保存的 PMSM 子系统；三个计算入口分别引用内部场景，计算顺序来自实际连接。
3. Java 编译可信子图、Python 校验、Julia 会话注册、MATLAB 每次残差评估调用子图，任务结束清理状态；内部最终快照进入公开结果。
4. 第 12 个 `hpcgv turboshaft` 构型，保留原气路、匹配方程、轴控制和热边界语义；显式电机轴绑定，接入扫描与绘图。

## 数值与编辑验证

| 检查 | 验证结果 | 本地产物 |
|---|---|---|
| 原 PMSM 与组件拆分 | 5 组设计/非设计/热网络对比通过，覆盖 3 种冷却、发电及电动 | `tools/pmsm/pmsm-final-regression.log` |
| 独立 PMSM 三入口 | 通过；自由热节点残差 `2.6738e-7`，正退出状态 | `tools/pmsm/standalone-final-regression.log` |
| 参数影响 | 气隙磁密修改使机械功率变化约 `0.0162 kW` | 同上 |
| 迭代与隔离 | 连续 3 组功率调用与直接执行一致；2 实例交错调用不串用状态；清理后旧程序不可调用 | 同上 |
| 无效工况与定位 | 零功率、零流量被拒绝；设计、非设计和热入口异常包含内部组件位置 | 同上 |
| 混动设计/非设计 | 与原项目一致；残差分别为 `3.6380e-12`、`3.3307e-15`，非设计正退出 | `tools/pmsm/engine-rewired-regression.log` |
| 内部重接线影响整机 | 将冷却选择节点替换为兼容空气冷却组件，设计流量变化约 `-0.0043 kg/s`，冷却元数据同步为 1 | 同上 |

浮点对比使用 `abs(actual-reference) <= 1e-8 + 1e-6*abs(reference)`。矩阵形状、拓扑、索引及单位按契约检查；JSON 单向量无法表达行列方向，扫描回归仅对这种编码差异恢复参考向量方向。

混动匹配同时要求正求解器退出状态和最大归一化残差不超过 `1e-6`。原模型已归一化的气路残差保持原值，轴功率残差按设计功率缩放，热残差保持原单位。固定温度节点不要求温升率为零。

## 完整混动执行与原项目扫描对比

最终实际 Julia–MATLAB 运行完成 12 个外层节点，返回 24 个内部节点快照（设计 14、非设计 10），共 36 个结果节点。220 个扫描点均为正退出状态，最大归一化残差为 `1.1341006356246908e-7`。

使用原项目 `TURBOSHAFT_MAIN.m` 相同的初始化和功率/速度/高度循环执行 `20/100/100` 点基线，与实际 Julia 结果对比：

- 压气机、涡轮和电机工作点数组，推力数组及涡轮入口温度数组全部一致。
- 最终工作点的流量、轴功率、压损、气流状态、电机工作点和匹配残差一致。
- 以上比较的最大绝对差为 **0**，电机工作点数组形状为 **2×220**。

公开结果通过生产 Python 投影及 JSON Schema 检查。产物收集为设计点 1 张、功率特性 3 张、最终特性 3 张，共 7 张 PNG，包括电机图；已目视检查设计点图和最终电机图。

证据：`tools/pmsm/verification/hpcgv-validated/{result.json,public-result.json,verification-report.json,artifact-files.json}`；原项目比较为 `tools/pmsm/verification/hpcgv-full-reference.json`、`hpcgv-original-reference.mat` 和 `tools/pmsm/engine-full-reference.log`。

本次首次整图复跑曾在设计点 PNG 导出时超过现有 120 秒上限，任务按失败保存，未报告为计算成功。相同输入的独立 MATLAB 导出约 13 秒完成；无并行 MATLAB 任务的干净会话随后完成全部执行和 7 张图。没有修改图形超时或数值验收阈值；首次失败记录保留为 `hpcgv-validated/result.first-attempt.json`。目前证据表明该失败未在干净会话重现，尚不能据此确定底层图形超时原因。

## 已有 11 构型兼容性

黄金夹具均通过。数值回归比较预设入口与装配入口的初始化、设计和功率/速度/高度 `3/4/4` 点扫描：

- 9 个构型完成扫描并保持一致：两轴混排、两轴分排、两轴涡轴、三轴混排、三轴分排、CFM56、涵道风扇、自由涡轮涡轴、普通涡轴。
- `mixed-turbofan` 在扫描期间两条路径均触发 `MATLAB:fzero:ValueAtInitGuessComplexOrNotFinite`。
- `separated-turbofan` 在设计点两条路径均触发相同异常。

因此这里的 11 构型兼容性通过，包含上述两个既有异常的行为一致性，不表示 11 个构型均数值收敛。未调整原公式来隐藏异常。详细记录为 `tools/pmsm/verification/existing-engines.json` 及 `existing-engines*.log`。前 9 项记录中的空设计残差表示该次检查点未保存这个数值，不表示残差为零。

## 工程检查

| 检查 | 结果 |
|---|---|
| Java 编译与测试 | 26 项通过，包括全部 12 个构型黄金夹具、PMSM 编译和连接检查 |
| Python 执行器与契约 | 77 项通过，1 项既有 Pydantic 弃用警告 |
| 前端单元测试 | 65 项通过 |
| Vite 生产打包 | 通过，有既有大包提示 |
| 前端完整类型检查 | 存在原有 9 项错误，位于 `router/index.ts`、`Register.vue`、`Profile.vue`、`UserList.vue`，本次未新增 |

完整 `npm run build` 仍会被上述类型错误阻止；独立 Vite 打包成功不能替代完整类型检查通过。浏览器中的手工操作验收尚未执行，层级复制、入口重映射、保存重载和边界端口由自动化测试覆盖。

独立 PMSM 工程的最终 Julia 执行包含 6 个外层节点和 30 个内部节点快照，三种入口均完成，共 36 个结果节点；公开结果契约通过。错误处理补充后再次正向执行通过，见 `tools/pmsm/verification/standalone-final/verification-report.json`。

任务按现有默认 `MATLAB_MAX_CONCURRENT_TASKS=1` 会话保护运行；已验证实例交错调用、正常调用清除旧错误及任务注册表清理。直接启动 CLI 的检查中出现过 MATLAB.jl 初始化辅助变量缺失，顺序启动也曾复现。路径初始化和子图注册现已复用执行节点的完成标记与异常检查机制，并将准备失败标记为 `prepare`；修复后顺序正向和负向执行通过。并行多 MATLAB 会话不属于本次已通过场景，没有放宽服务并发设置。

## 结构化错误验证

实际 Julia–MATLAB 负向执行以及生产 Python 错误投影、JSON Schema 检查均通过：

- 非设计输入零功率：外层调用为 `root__offdesign_motor`，内部定位到 `offdesign_instance_offdesign_begin_offdesign`，保留入口 `offdesign` 和原始 `PMSM:InvalidPower`。见 `tools/pmsm/verification/standalone-failure/{result.json,public-error.json,verification-report.json}`。
- 配置阶段零功率：仍定位外层 `configuration`，未串用旧的内部错误。见 `tools/pmsm/verification/configuration-failure/verification-report.json`。
- MATLAB 回归覆盖三个入口的错误上下文、正常调用清除旧错误以及注册表清理。负向检查还发现并修复了 Julia 错误分支读取 `try` 内局部变量的问题。

以上错误上下文和初始化改动未修改计算公式；完整 220 点数值基线保留，后续补跑独立三入口正向与实际负向链路。

## 复现与启用

先运行后端编译测试生成可信图，再使用 `prepare_runner.py` 设置本机组件根目录，最后在独立验证目录运行 `julia/run_matlab_graph.jl`。该目录同时保存 `graph.json`、`generated_workflow.jl`、`result.json` 及图片；`verify_result.py` 生成公开结果及产物清单校验记录。

独立 MATLAB 项目直接运行 `run_pmsm_core.m`。前后端使用更新后的构建启动；后端组件目录在进程内缓存，已有服务需重启后才能加载新目录。本次未替用户重启服务、部署或提交 Git。

不包含旧 PMSM 工程兼容、瞬态温升、任务历程及优化设计。验证目录和日志被 Git 忽略，源代码、夹具、验证脚本及本文档保留在工作区。
