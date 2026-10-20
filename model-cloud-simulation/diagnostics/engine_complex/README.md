# 分排涡扇复数诊断

本工具复现任务 `7a02bbd350d14cb9a1f9552403299482` 的数值阶段：
`separated turbofan`，V/M/H=60/0/3000，THRUST/WA/PWG=0/0/0，扫描20/100/100。
另外只计算一次98 kN设计点对照。图形绘制不参与数值诊断，不重跑图片。

`prepare.py` 从当前工作树复制原项目和平台求解函数，增加返回值及现场记录；
不修改原始文件。`prepare_replay.py` 复制 DESIGN/OFFDESIGN 并记录部件返回及
等效喷速表达式。计算现场保存为MAT文件，JSONL仅含可编码的诊断元数据。
首次异常不会终止扫描；原生异常会保存最后阶段并停止对应路径。

使用新的输出目录，避免覆盖历史现场。在项目根目录执行：

```powershell
$out = Join-Path (Get-Location) 'model-cloud-backend/target/complex-diagnostic-new-run'
$platform = Join-Path (Get-Location) 'model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src'
$original = 'C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）'
$task = 'C:/Users/xiong/AppData/Local/ModelCloud/runtime/matlab_simulations/7a02bbd350d14cb9a1f9552403299482'
python model-cloud-simulation/diagnostics/engine_complex/prepare.py --original $original --platform $platform --task $task --output $out
$env:MC_DIAG_OUTPUT = $out
$env:ENGINE_DEMO_ROOT = $original
$env:ENGINE_PLATFORM_ROOT = $platform
$env:MC_DIAG_SIDE = ''
# MATLAB_PREFDIR可设置为一个可写目录。
matlab -batch "addpath('model-cloud-simulation/diagnostics/engine_complex'); run_diagnostic"
python model-cloud-simulation/diagnostics/engine_complex/prepare_replay.py --source $platform --output "$out/trace"
matlab -batch "addpath('model-cloud-simulation/diagnostics/engine_complex'); replay_and_compare; summarize_diagnostic"
```

`MC_DIAG_SIDE=original` 或 `platform` 可只运行一侧。使用MATLAB Engine调用时，
需在MATLAB会话中用`setenv`明确设置上述路径；Windows COM启动的MATLAB不一定继承调用者环境。
全部阶段完成后可调用`replay_and_compare(true)`，只重新比较快照，不重跑模型。

输出包括每阶段MAT现场、`progress.jsonl`、部件和表达式重放记录、
`comparison.json`、`summary.json`。比较覆盖字段、数值类型、数组形状、复数标记、
NaN/Inf位置及有限值容差`1e-8 + 1e-6*abs(expected)`。
正exitflag或小残差不能证明空气流量等状态符合物理意义。
