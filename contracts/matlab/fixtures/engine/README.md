# 发动机 V3 工程与执行图夹具

由 `EngineGoldenFixtureTest` 在 `-Dgolden.update=true` 时生成：
每个文件是 `matlab-components/engine/` 分片目录中对应构型
templateDefinition 的规范化 JSON 或其递归展开结果。

- `<构型>.project-v2.json`：V3 工程文档（schemaVersion=3，通用 Scene
  与 project-level physicalAssemblies）。文件名保留历史名称以保持测试入口路径稳定。
- `<构型>.expanded-graph.json`：`RecursiveExecutionGraphExpander.expand`
  的输出（展开后节点/边/publicOutputs），即可信校验与提交仿真前的
  执行图样本。
- `<构型>.trusted-graph.json`：生产请求字段过滤后，经可信目录校验的执行图。

MATLAB 数值基线不在本目录生成：初始化、设计点与工况扫描回归
由 `engine/src/tests/component_engine_backend_scene_tests.m`、
`component_engine_entry_tests.m` 与 `engine_legacy_baseline.m`
在 MATLAB 环境中单独运行对比。本目录只验证工程模板和执行图，
不代表数值求解已经收敛。

常规测试运行会重新展开并逐字节对比这些文件；若测试失败，说明展开
或物理装配管线发生了漂移，需要明确决策后运行 `-Dgolden.update=true`
重新生成。
