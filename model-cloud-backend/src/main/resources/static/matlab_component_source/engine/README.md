# 航空发动机完整构型运行包

模型库提供 `ducted fan`、`turboshaft` 和 `mixed turbofan` 三个完整构型。拖入画布后，每个构型都是一个可运行的递归子系统：

```text
完整构型
└─ 构型设计点模型 → 包线扫描 → 绘制特性图
   ├─ 设计点：物理构型 → 设计条件设置 → 设计点平衡求解
   ├─ 扫描：非设计点初始化 → 功率 → 速度前重置 → 速度 → 高度 → 汇总
   └─ 绘图：设计点 PLOTFLOW、功率后 DRAW_MAP_MISSION、完整扫描后 DRAW_MAP_MISSION
```

物理构型 Scene 保存部件参数及 `flow`、`shaft`、`bleed` 连线。前端模型库的三个物理模板由对应完整构型的 physical Scene 即时派生，共用一份参数来源；拖入物理画布会深复制部件和连线，提交运行时仍使用原有可信部件 ID。预置模板与用户手工搭建的物理 Scene 使用同一种 `assembly_json` 契约，均可接入设计点模型。用户子系统只保存在当前工程的 `projectData` 中。

运行时先由气路连线确定 `DP.F`；同层分支按原源码顺序排列，`legacyOrder` 仅用于稳定排序。轴和引气连线生成 `DP.SHAFT`、`DP.EXT`。物理 Scene 作为装配数据传入 MATLAB，不展开为逐部件计算 DAG。设计点和非设计点平衡仍调用原 `BALANCE_FUNCTION_DESIGN/DESIGN`、`BALANCE_FUNCTION_OFFDESIGN/OFFDESIGN` 链路，不改变求解公式和状态推进。

设计点公开原始 `DP、XD`。扫描公开原始 `MISSION`、推力、TIT、部件工作点和最终 `OP、X0、DX`；功率段结束时的 `MISSION_power` 用于复现原主脚本第一次部件特性图。绘图薄入口直接调用随包提供的原 `PLOTFLOW` 和 `DRAW_MAP_MISSION`，将实际 PNG 作为任务图片交付。结果页的数组图表是数值浏览能力，与这些 MATLAB 原图分别显示。

`Thermodynamics-v1`、`Mathematics-v1`、`Mapping`、`Map Collection` 与 Excel 图谱是包内依赖，不单独注册为基础计算组件。接口和回归边界见 [ARCHITECTURE_ROADMAP.md](ARCHITECTURE_ROADMAP.md)。
