# MATLAB 文件逐项对比附录

比较日期：2026-10-12。比较当前工作树与本机原项目，不以 Git HEAD 作为原模型基线。

平台目录：`C:\Users\xiong\Documents\Model-Cloud-ExtendML\model-cloud-backend\src\main\resources\static\matlab_component_source\engine`。原项目目录：`C:\Users\xiong\Documents\ENGINE+GENERATOR（demo）`。

范围：平台 engine 目录全部 .m；原项目同名检索排除 slprj 和 SimulinkRebuild。同名多份仅在文本完全相同或唯一候选时自动配对。换行规范化只处理 BOM/CRLF，不忽略注释和空白。



编码处理：原库包含 UTF-8 和 GB18030 文件；文本按 UTF-8 优先、GB18030 回退严格解码。字节一致结论直接比较原始字节，哈希不受解码影响。具体编码记录在 JSON 中。

## 全部文件清单

115 个文件：字节一致 81 个、同名内容不同 6 个、无原项目同名文件 28 个。用途描述文件职责，不代表每个文件每次都被执行。

| 平台文件 | 行数 | 比对结论 | 原文件 | 用途 | 首个函数声明 |
|---|---:|---|---|---|---|
| [src/components/AFTERBURN.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/components/AFTERBURN.m>) | 32 | 字节一致 | [AFTERBURN.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/AFTERBURN.m>) | 加力燃烧室加热 | `[ OUTPUT ] = AFTERBURN(INPUT)` |
| [src/components/BURN.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/components/BURN.m>) | 41 | 字节一致 | [BURN.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/BURN.m>) | 主燃烧室加热和油气比 | `[OUTPUT]=BURN(INPUT)` |
| [src/components/COMPRESSOR.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/components/COMPRESSOR.m>) | 74 | 字节一致 | [COMPRESSOR.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/COMPRESSOR.m>) | 压气机压升、效率、功率及工作点 | `[OUTPUT] = COMPRESSOR(INPUT)` |
| [src/components/DUCT.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/components/DUCT.m>) | 23 | 字节一致 | [DUCT.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/DUCT.m>) | 管道压损、热交换与流动传递 | `[OUTPUT]=DUCT(INPUT)` |
| [src/components/INLET.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/components/INLET.m>) | 37 | 字节一致 | [INLET.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/INLET.m>) | 进气道及环境状态 | `[OUTPUT]=INLET(INPUT)` |
| [src/components/MIXER.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/components/MIXER.m>) | 119 | 同名内容不同 | [MIXER.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/MIXER.m>) | 双流混合和混合器平衡 | `[OUTPUT]=MIXER(INPUT,INPUT1)` |
| [src/components/MOTOR.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/components/MOTOR.m>) | 111 | 字节一致 | [MOTOR.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/MOTOR.m>) | 零维电机/发电机模型 | `[OUTPUT]=MOTOR(INPUT)` |
| [src/components/NOZZLE.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/components/NOZZLE.m>) | 119 | 字节一致 | [NOZZLE.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/NOZZLE.m>) | 喷管流动及推力 | `[OUTPUT]=NOZZLE(INPUT)` |
| [src/components/TURBINE.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/components/TURBINE.m>) | 68 | 字节一致 | [TURBINE.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/TURBINE.m>) | 涡轮膨胀、效率、功率及工作点 | `[OUTPUT] = TURBINE(INPUT)` |
| [src/Input/ENGINE_SCENE_ASSEMBLY.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/ENGINE_SCENE_ASSEMBLY.m>) | 461 | 无原项目同名文件 | — | 物理 Scene 到 F/轴系/引气矩阵/部件参数 | `assembly = ENGINE_SCENE_ASSEMBLY(configuration)` |
| [src/Input/INPUT_DESIGN_PARAMETERS.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/INPUT_DESIGN_PARAMETERS.m>) | 33 | 字节一致 | [INPUT_DESIGN_PARAMETERS.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Input/INPUT_DESIGN_PARAMETERS.m>) | 原主脚本初始化入口，当前模板不直接调用 | `[DP] = INPUT_DESIGN_PARAMETERS(DP)` |
| [src/Input/INPUT_ELECTRIC.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/INPUT_ELECTRIC.m>) | 43 | 字节一致 | [INPUT_ELECTRIC.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Input/INPUT_ELECTRIC.m>) | 电机参数、材料和工作簿读取 | `[pmsm_input]=INPUT_ELECTRIC` |
| [src/Input/INPUT_TURBO.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/INPUT_TURBO.m>) | 736 | 同名内容不同 | [INPUT_TURBO.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Input/INPUT_TURBO.m>) | 原构型分支初始化，平台保留 preset 兼容入口 | `[DP]=INPUT_TURBO(DP)` |
| [src/Input/INPUT_TURBO_COMMON_HEAD.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/INPUT_TURBO_COMMON_HEAD.m>) | 10 | 无原项目同名文件 | — | 原 INPUT_TURBO 提取的公共头部 | `DP = INPUT_TURBO_COMMON_HEAD(DP)` |
| [src/Input/INPUT_TURBO_COMMON_TAIL.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/INPUT_TURBO_COMMON_TAIL.m>) | 41 | 无原项目同名文件 | — | 公共计数、矩阵、转速和功率初值 | `DP = INPUT_TURBO_COMMON_TAIL(DP, NS, NW, NF)` |
| [src/Input/INPUT_TURBO_CUSTOM.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/INPUT_TURBO_CUSTOM.m>) | 46 | 无原项目同名文件 | — | 装配参数覆盖公共初始化 | `DP = INPUT_TURBO_CUSTOM(DP, assembly)` |
| [src/Input/READ_COMPONENT.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/READ_COMPONENT.m>) | 114 | 同名内容不同 | [READ_COMPONENT.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Input/READ_COMPONENT.m>) | 压气机与涡轮图谱读取 | `脚本（无 function 声明）` |
| [src/Input/READ_MOTOR.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/READ_MOTOR.m>) | 70 | 同名内容不同 | [READ_MOTOR.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Input/READ_MOTOR.m>) | 电机图谱读取 | `脚本（无 function 声明）` |
| [src/Input/READMAP.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/READMAP.m>) | 4 | 字节一致 | [READMAP.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Input/READMAP.m>) | 图谱读取入口 | `[MAP]=READMAP(DP)` |
| [src/Mainprogram-v1/BALANCE_FUNCTION_DESIGN.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mainprogram-v1/BALANCE_FUNCTION_DESIGN.m>) | 93 | 同名内容不同 | [BALANCE_FUNCTION_DESIGN.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mainprogram-v1/BALANCE_FUNCTION_DESIGN.m>) | 设计点未知量及 fsolve 平衡求解 | `[DP,XD,diagnostics]=BALANCE_FUNCTION_DESIGN( DP,XD)` |
| [src/Mainprogram-v1/BALANCE_FUNCTION_OFFDESIGN.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mainprogram-v1/BALANCE_FUNCTION_OFFDESIGN.m>) | 86 | 同名内容不同 | [BALANCE_FUNCTION_OFFDESIGN.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mainprogram-v1/BALANCE_FUNCTION_OFFDESIGN.m>) | 非设计点未知量、fsolve、X 和 DX | `[OP,X,DX,diagnostics]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,X0)` |
| [src/Mainprogram-v1/DESIGN.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mainprogram-v1/DESIGN.m>) | 394 | 字节一致 | [DESIGN.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mainprogram-v1/DESIGN.m>) | 设计点部件链、整机状态和残差 | `[YD,DP]=DESIGN(XD,DP)` |
| [src/Mainprogram-v1/OFFDESIGN.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mainprogram-v1/OFFDESIGN.m>) | 518 | 字节一致 | [OFFDESIGN.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mainprogram-v1/OFFDESIGN.m>) | 非设计点部件链、工作点和残差 | `[YO,OP]=OFFDESIGN(XO,DP,OP)` |
| [src/Map Collection/COMPRESSOR/COMPRESSOR_EXTENSION.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Map Collection/COMPRESSOR/COMPRESSOR_EXTENSION.m>) | 154 | 字节一致 | [COMPRESSOR_EXTENSION.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Map Collection/COMPRESSOR/COMPRESSOR_EXTENSION.m>) | 图谱表格转换/拟合/外推预处理辅助：COMPRESSOR_EXTENSION | `脚本（无 function 声明）` |
| [src/Map Collection/COMPRESSOR/COMPRESSOR_NN.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Map Collection/COMPRESSOR/COMPRESSOR_NN.m>) | 33 | 字节一致 | [COMPRESSOR_NN.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Map Collection/COMPRESSOR/COMPRESSOR_NN.m>) | 图谱表格转换/拟合/外推预处理辅助：COMPRESSOR_NN | `脚本（无 function 声明）` |
| [src/Map Collection/COMPRESSOR/MAP2TABLE_C.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Map Collection/COMPRESSOR/MAP2TABLE_C.m>) | 58 | 字节一致 | [MAP2TABLE_C.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Map Collection/COMPRESSOR/MAP2TABLE_C.m>) | 图谱表格转换/拟合/外推预处理辅助：MAP2TABLE_C | `脚本（无 function 声明）` |
| [src/Map Collection/MAP2TABLE_C.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Map Collection/MAP2TABLE_C.m>) | 58 | 字节一致 | [MAP2TABLE_C.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Map Collection/MAP2TABLE_C.m>) | 图谱表格转换/拟合/外推预处理辅助：MAP2TABLE_C | `脚本（无 function 声明）` |
| [src/Map Collection/MAP2TABLE_M.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Map Collection/MAP2TABLE_M.m>) | 58 | 字节一致 | [MAP2TABLE_M.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Map Collection/MAP2TABLE_M.m>) | 图谱表格转换/拟合/外推预处理辅助：MAP2TABLE_M | `脚本（无 function 声明）` |
| [src/Map Collection/MAP2TABLE_P.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Map Collection/MAP2TABLE_P.m>) | 58 | 字节一致 | [MAP2TABLE_P.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Map Collection/MAP2TABLE_P.m>) | 图谱表格转换/拟合/外推预处理辅助：MAP2TABLE_P | `脚本（无 function 声明）` |
| [src/Map Collection/MAP2TABLE_T.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Map Collection/MAP2TABLE_T.m>) | 58 | 字节一致 | [MAP2TABLE_T.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Map Collection/MAP2TABLE_T.m>) | 图谱表格转换/拟合/外推预处理辅助：MAP2TABLE_T | `脚本（无 function 声明）` |
| [src/Map Collection/MOTOR/MAP2TABLE_M.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Map Collection/MOTOR/MAP2TABLE_M.m>) | 47 | 字节一致 | [MAP2TABLE_M.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Map Collection/MOTOR/MAP2TABLE_M.m>) | 图谱表格转换/拟合/外推预处理辅助：MAP2TABLE_M | `脚本（无 function 声明）` |
| [src/Map Collection/PROPELLER/MAP2TABLE_P.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Map Collection/PROPELLER/MAP2TABLE_P.m>) | 54 | 字节一致 | [MAP2TABLE_P.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Map Collection/PROPELLER/MAP2TABLE_P.m>) | 图谱表格转换/拟合/外推预处理辅助：MAP2TABLE_P | `脚本（无 function 声明）` |
| [src/Map Collection/TURBINE/MAP2TABLE_T.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Map Collection/TURBINE/MAP2TABLE_T.m>) | 64 | 字节一致 | [MAP2TABLE_T.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Map Collection/TURBINE/MAP2TABLE_T.m>) | 图谱表格转换/拟合/外推预处理辅助：MAP2TABLE_T | `脚本（无 function 声明）` |
| [src/Map Collection/TURBINE/TURBINE_EXTENSION.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Map Collection/TURBINE/TURBINE_EXTENSION.m>) | 197 | 字节一致 | [TURBINE_EXTENSION.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Map Collection/TURBINE/TURBINE_EXTENSION.m>) | 图谱表格转换/拟合/外推预处理辅助：TURBINE_EXTENSION | `脚本（无 function 声明）` |
| [src/Map Collection/TURBINE/TURBINE_NN.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Map Collection/TURBINE/TURBINE_NN.m>) | 41 | 字节一致 | [TURBINE_NN.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Map Collection/TURBINE/TURBINE_NN.m>) | 图谱表格转换/拟合/外推预处理辅助：TURBINE_NN | `脚本（无 function 声明）` |
| [src/Map Collection/TURBINE/TURBINE_WRITE.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Map Collection/TURBINE/TURBINE_WRITE.m>) | 41 | 字节一致 | [TURBINE_WRITE.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Map Collection/TURBINE/TURBINE_WRITE.m>) | 图谱表格转换/拟合/外推预处理辅助：TURBINE_WRITE | `脚本（无 function 声明）` |
| [src/Mapping/DRAW_MAP_MISSION.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/DRAW_MAP_MISSION.m>) | 66 | 字节一致 | [DRAW_MAP_MISSION.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/DRAW_MAP_MISSION.m>) | 原扫描图谱/工作点绘图和 PNG 输出 | `DRAW_MAP_MISSION(MISSION)` |
| [src/Mapping/GENERATOR_MAP.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/GENERATOR_MAP.m>) | 75 | 字节一致 | [GENERATOR_MAP.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/GENERATOR_MAP.m>) | 模型内部辅助函数：GENERATOR_MAP | `[MAP]=GENERATOR_MAP(DP,MAP)` |
| [src/Mapping/GET_PROP_MAP.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/GET_PROP_MAP.m>) | 43 | 字节一致 | [GET_PROP_MAP.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/GET_PROP_MAP.m>) | INPUT DESIGN PARAMETERS | `脚本（无 function 声明）` |
| [src/Mapping/MAP_1.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/MAP_1.m>) | 100 | 字节一致 | [MAP_1.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/MAP_1.m>) | 生成第一类MAP图 | `脚本（无 function 声明）` |
| [src/Mapping/MAP_2.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/MAP_2.m>) | 42 | 字节一致 | [MAP_2.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/MAP_2.m>) | 生成第二类MAP图 | `脚本（无 function 声明）` |
| [src/Mapping/MAP_3.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/MAP_3.m>) | 37 | 字节一致 | [MAP_3.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/MAP_3.m>) | 生成第三类MAP图 | `脚本（无 function 声明）` |
| [src/Mapping/MAP_4.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/MAP_4.m>) | 18 | 字节一致 | [MAP_4.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/MAP_4.m>) | 生成第四类MAP图 | `脚本（无 function 声明）` |
| [src/Mapping/MAP_EXTENSION.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/MAP_EXTENSION.m>) | 50 | 字节一致 | [MAP_EXTENSION.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/MAP_EXTENSION.m>) | 对已有压气机MAP图进行扩展 | `[MAP]=MAP_EXTENSION(MAP)` |
| [src/Mapping/MAP_RESET.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/MAP_RESET.m>) | 15 | 字节一致 | [MAP_RESET.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/MAP_RESET.m>) | 计算MAP对应的焓变 | `[MAP]=MAP_RESET(MAP)` |
| [src/Mapping/MAP_SCALING.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/MAP_SCALING.m>) | 46 | 字节一致 | [MAP_SCALING.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/MAP_SCALING.m>) | 由已知压气机MAP图缩放得到新MAP图（KURKZE-PROPULSION AND POWER） | `[MAP1]=MAP_SCALING(MAP0,PR1)` |
| [src/Mapping/MAPPING.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/MAPPING.m>) | 184 | 字节一致 | [MAPPING.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/MAPPING.m>) | UNTITLED3 此处显示有关此函数的摘要 | `[ O ] = MAPPING(mode,MAP,X,Y,PRC0)` |
| [src/Mapping/plotComponentMap.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/plotComponentMap.m>) | 86 | 字节一致 | [plotComponentMap.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/plotComponentMap.m>) | 模型内部辅助函数：plotComponentMap | `plotComponentMap(map,effScale,varargin)` |
| [src/Mapping/PLOTFLOW.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/PLOTFLOW.m>) | 40 | 字节一致 | [PLOTFLOW.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mainprogram-v1/PLOTFLOW.m>) | 原设计点气路绘图和 PNG 输出 | `PLOTFLOW(INPUT)` |
| [src/Mapping/plotMotorMap.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/plotMotorMap.m>) | 55 | 字节一致 | [plotMotorMap.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/plotMotorMap.m>) | Create figure | `plotMotorMap(map,effScale,varargin)` |
| [src/Mapping/RESHAPEMAP.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/RESHAPEMAP.m>) | 143 | 字节一致 | [RESHAPEMAP.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/RESHAPEMAP.m>) | % 1、读取原始MAP | `[DP]=RESHAPEMAP(DP)` |
| [src/Mapping/SAVEMAP.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/SAVEMAP.m>) | 7 | 字节一致 | [SAVEMAP.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/SAVEMAP.m>) | 模型内部辅助函数：SAVEMAP | `脚本（无 function 声明）` |
| [src/Mapping/TURBO_GENERATOR_MAP.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mapping/TURBO_GENERATOR_MAP.m>) | 75 | 字节一致 | [TURBO_GENERATOR_MAP.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mapping/TURBO_GENERATOR_MAP.m>) | 模型内部辅助函数：TURBO_GENERATOR_MAP | `[MAP]=TURBO_GENERATOR_MAP(DP,MAP)` |
| [src/Mathematics-v1/EFS.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mathematics-v1/EFS.m>) | 42 | 字节一致 | [EFS.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mathematics-v1/EFS.m>) | Equilibrium Functions Solver | `R=EFS(X)` |
| [src/Mathematics-v1/MC.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mathematics-v1/MC.m>) | 39 | 字节一致 | [MC.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mathematics-v1/MC.m>) | 单纯形法求解工作点 | `stop = END(~, optimValues, ~)` |
| [src/Mathematics-v1/NIFS.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mathematics-v1/NIFS.m>) | 55 | 字节一致 | [NIFS.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Mathematics-v1/NIFS.m>) | 牛顿迭代法方程求解器 | `[X,k,I,E] = NIFS(F,x0,el,MAX,DX)` |
| [src/tests/component_engine_backend_scene_tests.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/tests/component_engine_backend_scene_tests.m>) | 443 | 无原项目同名文件 | — | COMPONENT_ENGINE_BACKEND_SCENE_TESTS Exercise the backend assembly shape. | `report = component_engine_backend_scene_tests(include_plot_regression, include_numerical_regression)` |
| [src/tests/component_engine_entry_tests.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/tests/component_engine_entry_tests.m>) | 53 | 无原项目同名文件 | — | COMPONENT_ENGINE_ENTRY_TESTS Check the three-stage engine entry contract. | `report = component_engine_entry_tests()` |
| [src/tests/engine_compatibility_smoke.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/tests/engine_compatibility_smoke.m>) | 41 | 无原项目同名文件 | — | ENGINE_COMPATIBILITY_SMOKE Compare packaged design points with the demo. | `report = engine_compatibility_smoke(reference_root)` |
| [src/tests/engine_full_scan_regression.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/tests/engine_full_scan_regression.m>) | 50 | 无原项目同名文件 | — | ENGINE_FULL_SCAN_REGRESSION Compare the default 20/100/100 mission arrays. | `report = engine_full_scan_regression(reference_root)` |
| [src/tests/engine_legacy_baseline.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/tests/engine_legacy_baseline.m>) | 90 | 无原项目同名文件 | — | ENGINE_LEGACY_BASELINE Capture the reference TURBOSHAFT_MAIN state machine. | `baseline = engine_legacy_baseline(reference_root, configuration, n_power, n_speed, n_altitude)` |
| [src/tests/engine_physical_scene_v1_regression.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/tests/engine_physical_scene_v1_regression.m>) | 138 | 无原项目同名文件 | — | ENGINE_PHYSICAL_SCENE_V1_REGRESSION V1 装配契约 vs 预设构型 回归。 | `report = engine_physical_scene_v1_regression()` |
| [src/tests/engine_plot_image_regression.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/tests/engine_plot_image_regression.m>) | 75 | 无原项目同名文件 | — | ENGINE_PLOT_IMAGE_REGRESSION Compare wrapper PNGs with original plot calls. | `report = engine_plot_image_regression(reference_root)` |
| [src/Thermodynamics-v1/AE.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/AE.m>) | 11 | 字节一致 | [AE.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/AE.m>) | 根据温度,油气比与相对湿度计算气体绝热指数 | `[ K ] = AE(T,FAR,D)` |
| [src/Thermodynamics-v1/AFP.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/AFP.m>) | 13 | 字节一致 | [AFP.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/AFP.m>) | 计算压力气动函数 | `[ PL ] = AFP( VC,K )` |
| [src/Thermodynamics-v1/AFT.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/AFT.m>) | 13 | 字节一致 | [AFT.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/AFT.m>) | 计算温度气动函数 | `[ TL ] = AFT( VC,K )` |
| [src/Thermodynamics-v1/AIRFLOW_ESTIMATE.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/AIRFLOW_ESTIMATE.m>) | 38 | 字节一致 | [AIRFLOW_ESTIMATE.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/AIRFLOW_ESTIMATE.m>) | 计算满足推力需求的空气流量 | `[OUTPUT]=AIRFLOW_ESTIMATE(INPUT)` |
| [src/Thermodynamics-v1/ASP.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/ASP.m>) | 35 | 字节一致 | [ASP.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/ASP.m>) | 计算大气静温与静压 | `[ Ts,Ps,rhos,sv,mu ] = ASP( H,DT,QP)` |
| [src/Thermodynamics-v1/CFD_NOZZLE.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/CFD_NOZZLE.m>) | 103 | 字节一致 | [CFD_NOZZLE.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/CFD_NOZZLE.m>) | 亚声速-超声速等熵喷管流动 非守恒型麦考马克方法数值求解 | `脚本（无 function 声明）` |
| [src/Thermodynamics-v1/COMP_OPT.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/COMP_OPT.m>) | 6 | 字节一致 | [COMP_OPT.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/COMP_OPT.m>) | 模型内部辅助函数：COMP_OPT | `[pr_optimal]=COMP_OPT(T0,T4,KP)` |
| [src/Thermodynamics-v1/CPSH.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/CPSH.m>) | 34 | 字节一致 | [CPSH.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/CPSH.m>) | 根据温度、油气比与绝对湿度计算气体的定压比热 | `[ Cp ] = CPSH(T,FAR)` |
| [src/Thermodynamics-v1/DEP_FAN.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/DEP_FAN.m>) | 69 | 字节一致 | [DEP_FAN.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/DEP_FAN.m>) | 涵道风扇模块 | `[OUTPUT]=DEP_FAN(INPUT)` |
| [src/Thermodynamics-v1/DUCTED_FAN.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/DUCTED_FAN.m>) | 21 | 字节一致 | [DUCTED_FAN.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/DUCTED_FAN.m>) | 模型内部辅助函数：DUCTED_FAN | `[OUTPUT]=DUCTED_FAN(INPUT)` |
| [src/Thermodynamics-v1/E.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/E.m>) | 29 | 字节一致 | [E.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/E.m>) | 根据温度、压力、油气比与绝对湿度计算气体熵 | `[ S ] = E( T,P,FAR ,D)` |
| [src/Thermodynamics-v1/FAN.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/FAN.m>) | 42 | 字节一致 | [FAN.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/FAN.m>) | OUTPUT=INPUT; | `[OUTPUT]=FAN(INPUT)` |
| [src/Thermodynamics-v1/FARAB.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/FARAB.m>) | 19 | 字节一致 | [FARAB.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/FARAB.m>) | 根据加力燃烧室进出口温度、燃烧效率与燃油热值利用等温焓差计算加力燃烧室燃油对应的油气比 | `[ far ] = FARAB( T_in,T_out,far_in,eb,hf)` |
| [src/Thermodynamics-v1/FARC.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/FARC.m>) | 15 | 字节一致 | [FARC.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/FARC.m>) | 根据燃烧室进出口温度、燃烧效率与燃油热值利用等温焓差计算油气比 | `[ FAR ] = FARC( T1,T2,Eb,Hu)` |
| [src/Thermodynamics-v1/FC.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/FC.m>) | 13 | 字节一致 | [FC.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/FC.m>) | 根据气体速度系数、绝热指数、油气比和绝对湿度计算气体流量函数K*q(VC) | `[ Q ] = FC( VC,K,FAR,D )` |
| [src/Thermodynamics-v1/GC.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/GC.m>) | 13 | 字节一致 | [GC.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/GC.m>) | 根据油气比计算气体常数 | `[ R ] = GC( far,d )` |
| [src/Thermodynamics-v1/IF.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/IF.m>) | 15 | 字节一致 | [IF.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/IF.m>) | 根据气体流量、速度系数、绝热指数、温度、油气比和绝对湿度计算气体冲量函数 | `[ I ] = IF( W,K,VC,T,FAR )` |
| [src/Thermodynamics-v1/LAMBDA.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/LAMBDA.m>) | 8 | 字节一致 | [LAMBDA.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/LAMBDA.m>) | 模型内部辅助函数：LAMBDA | `[O]=LAMBDA(I,K,mode)` |
| [src/Thermodynamics-v1/MACH_NUMBER.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/MACH_NUMBER.m>) | 30 | 字节一致 | [MACH_NUMBER.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/MACH_NUMBER.m>) | 已知截面积、空气流量、总温、总压、油气比、湿度，求马赫数，气体比热比，气体速度 | `[M,K,V]=MACH_NUMBER(A,W,T,P,FAR,D)` |
| [src/Thermodynamics-v1/MM.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/MM.m>) | 9 | 字节一致 | [MM.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/MM.m>) | 根据油气比计算气体摩尔质量 | `[ M ] = MM( far )` |
| [src/Thermodynamics-v1/MU.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/MU.m>) | 3 | 字节一致 | [MU.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/MU.m>) | 模型内部辅助函数：MU | `[mu]=MU(Ts)` |
| [src/Thermodynamics-v1/PRO.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/PRO.m>) | 27 | 字节一致 | [PRO.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/PRO.m>) | obj=1，比焓 | `PROPERTY=PRO(T,obj,fun)` |
| [src/Thermodynamics-v1/QF.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/QF.m>) | 4 | 字节一致 | [QF.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/QF.m>) | 流函数 | `[Q] = QF(VC,K)` |
| [src/Thermodynamics-v1/SE.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/SE.m>) | 22 | 字节一致 | [SE.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/SE.m>) | 根据气体温度、油气比与绝对湿度计算比焓 | `[ h ] = SE( T,far )` |
| [src/Thermodynamics-v1/STAGNATION_CAL.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/STAGNATION_CAL.m>) | 10 | 字节一致 | [STAGNATION_CAL.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/STAGNATION_CAL.m>) | calculate mach via velocity | `[Ps,Ts,P0,T0]=STAGNATION_CAL(H,V,M,DT,QP)` |
| [src/Thermodynamics-v1/SV.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/SV.m>) | 10 | 字节一致 | [SV.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/SV.m>) | 计算声速 | `[ V ] = SV(Ts,FAR,D)` |
| [src/Thermodynamics-v1/TAB.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/TAB.m>) | 15 | 字节一致 | [TAB.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/TAB.m>) | 根据气体速度系数、绝热指数、油气比和绝对湿度计算气体流量函数K*q(VC) | `[ T ] = TAB( T_in,farab,far_in,eb,hf)` |
| [src/Thermodynamics-v1/TEMP.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/TEMP.m>) | 17 | 字节一致 | [TEMP.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/TEMP.m>) | 根据气体比焓、油气比和绝对湿度计算气体温度 | `[ T ] = TEMP( h,far )` |
| [src/Thermodynamics-v1/TOTAL_PRESSURE.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/TOTAL_PRESSURE.m>) | 4 | 字节一致 | [TOTAL_PRESSURE.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/TOTAL_PRESSURE.m>) | 模型内部辅助函数：TOTAL_PRESSURE | `[O]=TOTAL_PRESSURE(M,K)` |
| [src/Thermodynamics-v1/TOTAL_TEMP.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/TOTAL_TEMP.m>) | 3 | 字节一致 | [TOTAL_TEMP.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/TOTAL_TEMP.m>) | 模型内部辅助函数：TOTAL_TEMP | `[O]=TOTAL_TEMP(M,K)` |
| [src/Thermodynamics-v1/TP.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/TP.m>) | 28 | 字节一致 | [TP.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/TP.m>) | 根据温度、熵、油气比计算气体总压力 | `[ P ] = TP( T,S,FAR)` |
| [src/Thermodynamics-v1/TPE.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/TPE.m>) | 27 | 字节一致 | [TPE.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/TPE.m>) | 根据焓降，效率，进口温度与压力考虑变比热影响计算膨胀过程 | `[ T2,P2] = TPE( DHs,Es,T1,P1,FAR )` |
| [src/Thermodynamics-v1/TT.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/TT.m>) | 24 | 字节一致 | [TT.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/TT.m>) | 根据气体比焓、油气比和绝对湿度计算气体温度 | `[ T1 ] = TT( Hs,FAR )` |
| [src/Thermodynamics-v1/TURBINE_ITERATION.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/TURBINE_ITERATION.m>) | 27 | 字节一致 | [TURBINE_ITERATION.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/TURBINE_ITERATION.m>) | if DP.PRT(NT)==0 | `脚本（无 function 声明）` |
| [src/Thermodynamics-v1/VC.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Thermodynamics-v1/VC.m>) | 27 | 字节一致 | [VC.m](<C:/Users/xiong/Documents/ENGINE+GENERATOR（demo）/Thermodynamics-v1/VC.m>) | 根据绝热指数、油气比、面积等计算气体速度系数 | `[ VC ] = VC( K,FAR,A,Pt,Tt,W,D)` |
| [src/workflows/component_engine_apply_design_conditions.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_apply_design_conditions.m>) | 12 | 无原项目同名文件 | — | COMPONENT_ENGINE_APPLY_DESIGN_CONDITIONS Apply explicit design targets. | `DP = component_engine_apply_design_conditions(DP, thrust, WA, PWG)` |
| [src/workflows/component_engine_envelope_altitude.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_envelope_altitude.m>) | 23 | 无原项目同名文件 | — | COMPONENT_ENGINE_ENVELOPE_ALTITUDE Run the legacy decreasing-height scan. | `scan_state = component_engine_envelope_altitude(scan_state, altitude_points)` |
| [src/workflows/component_engine_envelope_append_point.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_envelope_append_point.m>) | 8 | 无原项目同名文件 | — | COMPONENT_ENGINE_ENVELOPE_APPEND_POINT Append raw OP fields exactly. | `scan_state = component_engine_envelope_append_point(scan_state, OP)` |
| [src/workflows/component_engine_envelope_finalize.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_envelope_finalize.m>) | 17 | 无原项目同名文件 | — | COMPONENT_ENGINE_ENVELOPE_FINALIZE Return the original envelope outputs. | `[MISSION, THRUST_ARRAY, TIT_ARRAY, COMP_WP, TURB_WP, MOTOR_WP, OP, X0, DX] = component_engine_envelope_finalize(scan_state)` |
| [src/workflows/component_engine_envelope_initialize.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_envelope_initialize.m>) | 24 | 无原项目同名文件 | — | COMPONENT_ENGINE_ENVELOPE_INITIALIZE Initialize the legacy envelope scan. | `scan_state = component_engine_envelope_initialize(DP)` |
| [src/workflows/component_engine_envelope_mission.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_envelope_mission.m>) | 7 | 无原项目同名文件 | — | COMPONENT_ENGINE_ENVELOPE_MISSION Build the legacy MISSION structure. | `MISSION = component_engine_envelope_mission(scan_state)` |
| [src/workflows/component_engine_envelope_power.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_envelope_power.m>) | 25 | 无原项目同名文件 | — | COMPONENT_ENGINE_ENVELOPE_POWER Run the legacy decreasing-power scan. | `[scan_state, MISSION_power] = component_engine_envelope_power(scan_state, power_points)` |
| [src/workflows/component_engine_envelope_scope.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_envelope_scope.m>) | 14 | 无原项目同名文件 | — | COMPONENT_ENGINE_ENVELOPE_SCOPE Isolate the engine runtime for one stage. | `cleanup = component_engine_envelope_scope()` |
| [src/workflows/component_engine_envelope_speed.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_envelope_speed.m>) | 23 | 无原项目同名文件 | — | COMPONENT_ENGINE_ENVELOPE_SPEED Run the legacy decreasing-speed scan. | `scan_state = component_engine_envelope_speed(scan_state, speed_points)` |
| [src/workflows/component_engine_envelope_speed_initialize.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_envelope_speed_initialize.m>) | 17 | 无原项目同名文件 | — | COMPONENT_ENGINE_ENVELOPE_SPEED_INITIALIZE Reset before the speed scan. | `scan_state = component_engine_envelope_speed_initialize(scan_state)` |
| [src/workflows/component_engine_envelope_validate_count.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_envelope_validate_count.m>) | 7 | 无原项目同名文件 | — | COMPONENT_ENGINE_ENVELOPE_VALIDATE_COUNT Validate a scan point count. | `component_engine_envelope_validate_count(value, name)` |
| [src/workflows/component_engine_envelope_validate_state.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_envelope_validate_state.m>) | 11 | 无原项目同名文件 | — | COMPONENT_ENGINE_ENVELOPE_VALIDATE_STATE Validate a scan_state chain value. | `component_engine_envelope_validate_state(scan_state)` |
| [src/workflows/component_engine_initialize_configuration.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_initialize_configuration.m>) | 203 | 无原项目同名文件 | — | COMPONENT_ENGINE_INITIALIZE_CONFIGURATION Build the physical DP structure. | `DP = component_engine_initialize_configuration(assembly_json, V, M, H)` |
| [src/workflows/component_engine_plot_flow.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_plot_flow.m>) | 83 | 无原项目同名文件 | — | COMPONENT_ENGINE_PLOT_FLOW Call the original PLOTFLOW and collect its PNG. | `result = component_engine_plot_flow(DP, output_directory, phase)` |
| [src/workflows/component_engine_plot_map_mission.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_plot_map_mission.m>) | 97 | 无原项目同名文件 | — | COMPONENT_ENGINE_PLOT_MAP_MISSION Call original DRAW_MAP_MISSION. | `result = component_engine_plot_map_mission(MISSION, output_directory, phase)` |
| [src/workflows/component_engine_solve_design_point.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_engine_solve_design_point.m>) | 15 | 无原项目同名文件 | — | COMPONENT_ENGINE_SOLVE_DESIGN_POINT Preserve the legacy design solve. | `[DP, XD] = component_engine_solve_design_point(DP)` |
| [src/workflows/component_run_engine_envelope.m](<C:/Users/xiong/Documents/Model-Cloud-ExtendML/model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/workflows/component_run_engine_envelope.m>) | 18 | 无原项目同名文件 | — | COMPONENT_RUN_ENGINE_ENVELOPE Run the legacy envelope through thin stages. | `[MISSION, THRUST_ARRAY, TIT_ARRAY, COMP_WP, TURB_WP, MOTOR_WP, OP, X0, DX] = component_run_engine_envelope(DP, power_points, speed_points, altitude_points)` |

## 同名不同文件的完整文本差异

差异左侧为原项目，右侧为模型库。以下是文本差异证据，不自动等同于数值结果差异。

### model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/components/MIXER.m

```diff
--- C:\Users\xiong\Documents\ENGINE+GENERATOR（demo）\Thermodynamics-v1\MIXER.m
+++ model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/components/MIXER.m
@@ -90,7 +90,8 @@
 DW=real(DW);
 DW=min(DW,999);
 DW=max(DW,-999);
-disp(DW)
+% Suppress the legacy iterative debug output; top-level workflow nodes must
+% remain quiet and return diagnostics through their structured result.
 end
 function[DW,DPs,P2]=MIXER_BALANCE_OFFDESIGN(M2)
 % Initial Guestimate
```

### model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/INPUT_TURBO.m

```diff
--- C:\Users\xiong\Documents\ENGINE+GENERATOR（demo）\Input\INPUT_TURBO.m
+++ model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/INPUT_TURBO.m
@@ -1,9 +1,5 @@
 function[DP]=INPUT_TURBO(DP)
-DP.PRC_outerfan=1;% 外部风扇压比
-DP.flow="mixed";% 混排/分排（对于涡扇发动机）
-DP.BYPASS_RATIO=0;% 涵道比（对于涡扇发动机）
-DP.reheat=0;% 是否打开加力燃烧室
-DP.SHAFT_CONTROL=1;
+DP=INPUT_TURBO_COMMON_HEAD(DP);
 switch DP.type
     case "ducted fan"
         %% 涵道风扇
@@ -737,42 +733,4 @@
         DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0;
         DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0;
 end
-% 引气属性
-DP.SECOND_FLOW=zeros(4,NF);
-DP.PRESSURE_RATIO=prod(DP.PRC);
-DP.STRUCTURE=[DP.F;DP.SHAFT;DP.WA_extraction]; 
-% 基本参数
-NN = sum(strcmpi(DP.F, "nozzle") | strcmpi(DP.F, "fan"));
-NC = sum(strcmpi(DP.F, "lpc") | strcmpi(DP.F, "ipc") | strcmpi(DP.F, "hpc") | strcmpi(DP.F, "fan"));
-NT = sum(strcmpi(DP.F, "lpt") | strcmpi(DP.F, "ipt") | strcmpi(DP.F, "hpt"));
-NB = sum(strcmpi(DP.F, "burn") | strcmpi(DP.F, "afterburn"));
-NBY = sum(strcmpi(DP.F, "fan"));
-NM = sum(strcmpi(DP.F, "pmsm 0d"))+sum(strcmpi(DP.F, "hpcgv pmsm"));
-NM1 = sum(strcmpi(DP.F, "hpcgv pmsm"));
-DP.PWG=zeros(NS,1);
-DP.Q=zeros(1,NF);% 热量增加值
-DP.N_ref=ones(NS,1);% 用于非设计点计算
-DP.dN_partial=zeros(NS,1);
-DP.N=1E4*ones(NS,1);% 转速
-DP.J=2*ones(NS,1);
-DP.T_REQ=-1;
-DP.NS=NS;
-DP.NW=NW;
-DP.NN=NN;
-DP.NC=NC;
-DP.NT=NT;
-DP.NB=NB;
-DP.NBY=NBY;
-DP.NF=NF;
-DP.NM=NM;
-DP.NM1=NM1;
-DP.EFF_heat_exchange=ones(NM,1);
-DP.COMP_WP=ones(2*NC,1);
-DP.TURB_WP=ones(2*NT,1);
-DP.N_REF=ones(NS,1);
-% 涡轴发动机排气马赫数
-DP.M_ext=0.03;
-% 混合器出口马赫数
-if(sum(strcmpi(DP.F,"mixer")))
-    DP.M_mixed=0.5;
-end
+DP=INPUT_TURBO_COMMON_TAIL(DP,NS,NW,NF);
```

### model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/READ_COMPONENT.m

```diff
--- C:\Users\xiong\Documents\ENGINE+GENERATOR（demo）\Input\READ_COMPONENT.m
+++ model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/READ_COMPONENT.m
@@ -37,7 +37,8 @@
         end
         basicmap=C_in.basicmap;
         C_in.component=DP.F(nf);
-        COMP=xlsread(".\Map Collection\COMPRESSOR\COMPRESSOR.xlsx",basicmap);
+        COMP=readmatrix(".\Map Collection\COMPRESSOR\COMPRESSOR.xlsx", ...
+            "Sheet", basicmap);
         MAP.COMPRESSOR(nc).C_in=C_in;
         ncol=C_in.ncol;nrow=C_in.nrow;
         maxeff=C_in.maxeff;n_design=C_in.n_design;
@@ -81,7 +82,8 @@
         end
         basicmap=T_in.basicmap;
         T_in.component=DP.F(nf);
-        TURB=xlsread(".\Map Collection\TURBINE\TURBINE.xlsx",basicmap);
+        TURB=readmatrix(".\Map Collection\TURBINE\TURBINE.xlsx", ...
+            "Sheet", basicmap);
         MAP.TURBINE(nt).T_in=T_in;
         ncol=T_in.ncol;nrow=T_in.nrow;
         maxeff=T_in.maxeff;n_design=T_in.n_design;
```

### model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/READ_MOTOR.m

```diff
--- C:\Users\xiong\Documents\ENGINE+GENERATOR（demo）\Input\READ_MOTOR.m
+++ model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Input/READ_MOTOR.m
@@ -10,7 +10,8 @@
         nrow=M_in.nrow;
         ncol=M_in.ncol;
         component=M_in.component;
-        MOTOR=xlsread(".\Map Collection\MOTOR\MOTOR.xlsx",basicmap);
+        MOTOR=readmatrix(".\Map Collection\MOTOR\MOTOR.xlsx", ...
+            "Sheet", basicmap);
         NCOR=MOTOR(1,2:1+ncol);
         R=MOTOR(2:1+nrow,1);
         WCOR=MOTOR(2:1+nrow,2:1+ncol);
```

### model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mainprogram-v1/BALANCE_FUNCTION_DESIGN.m

```diff
--- C:\Users\xiong\Documents\ENGINE+GENERATOR（demo）\Mainprogram-v1\BALANCE_FUNCTION_DESIGN.m
+++ model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mainprogram-v1/BALANCE_FUNCTION_DESIGN.m
@@ -1,4 +1,4 @@
-function[DP,XD]=BALANCE_FUNCTION_DESIGN( ...
+function[DP,XD,diagnostics]=BALANCE_FUNCTION_DESIGN( ...
     DP,XD)
 % 建立并求解非设计点的平衡方程
 % 平衡方程的个数不一定为NC+NT+NS;
@@ -7,8 +7,14 @@
 if dot(XD,XD)==0 %需要初始化
     % DP_pre=ENGINE_PREDESIGN(DP);
     DP_pre=ones(1+DP.NT,1);
-    XD=[DP_pre;DP.pmsm_input(1).temperature_limit*ones(DP.NH*DP.NM1,1)];
+    if DP.NH*DP.NM1 > 0
+        XD=[DP_pre;DP.pmsm_input(1).temperature_limit*ones(DP.NH*DP.NM1,1)];
+    else
+        XD=DP_pre;
+    end
 end
+diagnostics=struct('converged',true,'exitflag',1,'residual_norm',0, ...
+    'fval',[],'message','设计点求解完成');
 LM=[];
 if min([DP.WA,DP.PRT])<=0
     if DP.WA<=0 %对推力有要求
@@ -33,11 +39,28 @@
     end
     % [YD]=DESIGN(XD(LM),DP);
     options = optimoptions('fsolve', 'Display', 'off');
-    XD(LM)=fsolve(@(x) DESIGN(x,DP),XD(LM),options);
+    if ~isempty(LM)
+        [XD(LM),fval,exitflag,output]=fsolve(@(x) DESIGN(x,DP),XD(LM),options);
+        diagnostics.exitflag=exitflag;
+        diagnostics.fval=fval;
+        if isstruct(output) && isfield(output,'message')
+            diagnostics.message=output.message;
+        end
+    end
 end
 % X=NIFS(fun,X0,1E-3,1000,1E-6);
 [YD,DP]=DESIGN(XD(LM),DP);
 DP.YD=YD;
+if isempty(YD)
+    diagnostics.residual_norm=0;
+else
+    residual=double(YD(:));
+    diagnostics.residual_norm=norm(residual,inf);
+end
+finite_result=isempty(YD) || all(isfinite(double(YD(:)))) ...
+    && isfinite(diagnostics.residual_norm);
+diagnostics.converged=finite_result && (diagnostics.exitflag>0 ...
+    || diagnostics.residual_norm<=1e-3);
 dis=DP.display;
 if dis==1
 disp("--------------")
@@ -61,6 +84,10 @@
 disp("计算误差")
 disp(YD)
 end
+% Keep the adapter non-interactive.  The original demo printed a separator
+% unconditionally even when display was disabled.
 % disp(DP.pmsm_parameters.performance)
-disp("--------------")
+if dis == 1
+    disp("--------------")
 end
+end
```

### model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mainprogram-v1/BALANCE_FUNCTION_OFFDESIGN.m

```diff
--- C:\Users\xiong\Documents\ENGINE+GENERATOR（demo）\Mainprogram-v1\BALANCE_FUNCTION_OFFDESIGN.m
+++ model-cloud-backend/src/main/resources/static/matlab_component_source/engine/src/Mainprogram-v1/BALANCE_FUNCTION_OFFDESIGN.m
@@ -1,4 +1,4 @@
-function[OP,X,DX]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,X0)
+function[OP,X,DX,diagnostics]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,X0)
 % 建立并求解非设计点的平衡方程
 % 平衡方程的个数不一定为NC+NT+NS;
 % 例如，如果对轴功率输出无严格要求，则方程个数为NC+NT，每个轴的转速为给定变量
@@ -57,11 +57,28 @@
 X=X0;
 options = optimoptions('fsolve', 'Display', 'off');
 % Y=OFFDESIGN(X(LM),DP,OP);
-X(LM)=fsolve(fun,X(LM),options);
+if isempty(LM)
+    fval=[];
+    exitflag=1;
+    output=struct('message','无非设计点未知量');
+else
+    [X(LM),fval,exitflag,output]=fsolve(fun,X(LM),options);
+end
 X=real(X);
 DX=X-X0;
-[~,OP]=OFFDESIGN(X(LM),DP,OP);
+[YOFF,OP]=OFFDESIGN(X(LM),DP,OP);
 OP.XO=X;OP.LM=LM;
+if isempty(YOFF)
+    residual_norm=0;
+else
+    residual_norm=norm(double(YOFF(:)),inf);
+end
+finite_result=all(isfinite(double(X(:)))) && (isempty(YOFF) ...
+    || all(isfinite(double(YOFF(:))))) && isfinite(residual_norm);
+diagnostics=struct('converged',finite_result && (exitflag>0 ...
+    || residual_norm<=1e-3),'exitflag',exitflag, ...
+    'residual_norm',residual_norm,'fval',fval,'message','');
+if isstruct(output) && isfield(output,'message'), diagnostics.message=output.message; end
 dis=OP.display;
 if dis==1
 SOLUTION_VISUALIZE(OP);
```

