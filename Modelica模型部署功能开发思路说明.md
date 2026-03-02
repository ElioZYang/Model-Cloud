# Modelica模型在线部署与仿真功能开发思路说明

## 一、需求分析

### 1.1 核心需求
1. **模型类型**：现阶段仅支持Modelica模型（.mo文件）
2. **部署功能**：在线基于已有Modelica组件进行建模、仿真运行、查看结果
3. **组件来源**：系统已上传的公开Modelica组件（MSL4.0标准库组件源码）
4. **交互方式**：拖拽式建模界面（类似OpenModelica）
5. **仿真引擎**：使用OpenModelica底层编译器进行仿真

### 1.2 功能边界
- **支持**：Modelica模型的在线建模、仿真、结果可视化
- **不支持**：其他类型模型的部署（后续可扩展）
- **组件库**：使用已上传的MSL4.0标准库组件

## 二、系统架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                        前端 (Vue 3)                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  模型部署页面 (ModelDeploy.vue) - 重构                │   │
│  │  - 组件库展示（拖拽源）                               │   │
│  │  - 画布区域（拖拽目标）                               │   │
│  │  - 属性编辑面板                                       │   │
│  │  - 仿真控制面板                                       │   │
│  │  - 结果可视化                                         │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │ HTTP/WebSocket
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   后端 API (Spring Boot)                     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  模型部署控制器 (ModelDeployController)               │   │
│  │  - 获取组件列表                                        │   │
│  │  - 保存/加载建模项目                                   │   │
│  │  - 提交仿真任务                                        │   │
│  │  - 查询仿真状态                                        │   │
│  │  - 获取仿真结果                                        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │ HTTP/消息队列
                            ▼
┌─────────────────────────────────────────────────────────────┐
│           仿真服务 (model-cloud-simulation)                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  技术栈：Python + FastAPI + Celery                   │   │
│  │                                                       │   │
│  │  ┌──────────────────────────────────────────────┐   │   │
│  │  │  API服务层 (FastAPI)                          │   │   │
│  │  │  - 接收仿真任务                                │   │   │
│  │  │  - 任务状态查询                                │   │   │
│  │  │  - 结果文件下载                                │   │   │
│  │  └──────────────────────────────────────────────┘   │   │
│  │                                                       │   │
│  │  ┌──────────────────────────────────────────────┐   │   │
│  │  │  任务队列 (Celery + Redis)                    │   │   │
│  │  │  - 异步任务处理                                │   │   │
│  │  │  - 任务优先级管理                              │   │   │
│  │  │  - 任务状态跟踪                                │   │   │
│  │  └──────────────────────────────────────────────┘   │   │
│  │                                                       │   │
│  │  ┌──────────────────────────────────────────────┐   │   │
│  │  │  OpenModelica集成层                           │   │   │
│  │  │  - Modelica模型解析                           │   │   │
│  │  │  - 模型编译 (OMCompiler)                       │   │   │
│  │  │  - 仿真执行 (OMSimulator)                      │   │   │
│  │  │  - 结果文件生成 (CSV/MAT)                     │   │   │
│  │  └──────────────────────────────────────────────┘   │   │
│  │                                                       │   │
│  │  ┌──────────────────────────────────────────────┐   │   │
│  │  │  文件管理                                      │   │   │
│  │  │  - 临时文件存储                                │   │   │
│  │  │  - 结果文件管理                                │   │   │
│  │  │  - 文件清理策略                                │   │   │
│  │  └──────────────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    外部依赖                                   │
│  - OpenModelica (OMCompiler, OMSimulator)                    │
│  - Redis (任务队列)                                          │
│  - 文件系统 (临时文件存储)                                    │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 目录结构

```
model-cloud/
├── model-cloud-backend/          # 现有后端（Java Spring Boot）
├── model-cloud-frontend/          # 现有前端（Vue 3）
└── model-cloud-simulation/        # 新建仿真服务（Python）
    ├── README.md
    ├── requirements.txt
    ├── .env.example
    ├── app/
    │   ├── __init__.py
    │   ├── main.py                 # FastAPI应用入口
    │   ├── config.py               # 配置文件
    │   ├── api/
    │   │   ├── __init__.py
    │   │   ├── simulation.py      # 仿真相关API
    │   │   └── components.py       # 组件相关API
    │   ├── services/
    │   │   ├── __init__.py
    │   │   ├── modelica_service.py    # Modelica模型处理服务
    │   │   ├── simulation_service.py   # 仿真执行服务
    │   │   └── file_service.py        # 文件管理服务
    │   ├── tasks/
    │   │   ├── __init__.py
    │   │   └── simulation_tasks.py    # Celery任务定义
    │   ├── models/
    │   │   ├── __init__.py
    │   │   ├── simulation.py          # 数据模型
    │   │   └── component.py
    │   └── utils/
    │       ├── __init__.py
    │       ├── modelica_parser.py     # Modelica文件解析工具
    │       └── result_processor.py    # 结果处理工具
    ├── tests/                        # 测试文件
    ├── scripts/                       # 脚本文件
    │   ├── setup_openmodelica.sh      # OpenModelica安装脚本
    │   └── cleanup_temp_files.sh      # 临时文件清理脚本
    └── docker/
        ├── Dockerfile
        └── docker-compose.yml
```

## 三、技术选型与理由

### 3.1 仿真服务技术栈

#### 3.1.1 Python + FastAPI
**理由**：
- **OpenModelica集成**：Python有较好的OpenModelica绑定库（如pyfmi、OMPython）
- **科学计算生态**：NumPy、SciPy、Matplotlib等库便于结果处理
- **开发效率**：Python语法简洁，适合快速开发
- **异步支持**：FastAPI原生支持异步，性能优秀

#### 3.1.2 Celery + Redis
**理由**：
- **异步任务**：仿真任务耗时较长，需要异步处理
- **任务队列**：支持任务优先级、重试机制
- **可扩展性**：可以横向扩展worker节点
- **状态跟踪**：实时查询任务执行状态

#### 3.1.3 OpenModelica
**理由**：
- **开源免费**：符合项目要求
- **标准支持**：支持Modelica标准库（MSL）
- **命令行工具**：OMCompiler和OMSimulator可以通过命令行调用
- **结果格式**：支持CSV、MAT等格式输出

### 3.2 前端技术增强

#### 3.2.1 拖拽式建模库
**推荐方案**：
- **选项1**：`vue-draggable-plus` + `@vue-flow/core`（推荐）
  - 基于Vue 3，支持节点拖拽、连线
  - 性能好，文档完善
- **选项2**：`jointjs` + Vue封装
  - 功能强大，但体积较大
- **选项3**：自研基于Canvas/SVG
  - 完全可控，但开发工作量大

**最终选择**：`vue-draggable-plus` + `@vue-flow/core`
- 轻量级，易于集成
- 支持自定义节点样式
- 良好的TypeScript支持

#### 3.2.2 图表可视化
**推荐方案**：
- **ECharts**（推荐）：功能强大，支持多种图表类型
- **Chart.js**：轻量级，但功能相对简单
- **D3.js**：最灵活，但学习曲线陡

**最终选择**：ECharts
- 支持时间序列图、散点图等
- 良好的交互体验
- 与Element Plus兼容性好

## 四、核心功能设计

### 4.1 前端功能模块

#### 4.1.1 组件库面板
**功能**：
- 展示所有公开的Modelica组件（从后端获取）
- 按类别分组显示（电阻、电源、电容等）
- 支持搜索过滤
- 组件可拖拽到画布

**实现要点**：
```vue
<template>
  <div class="component-panel">
    <el-input v-model="searchKeyword" placeholder="搜索组件" />
    <el-tree :data="componentTree" :props="treeProps">
      <template #default="{ node, data }">
        <div class="component-item" draggable @dragstart="handleDragStart($event, data)">
          <el-icon><Component /></el-icon>
          <span>{{ data.name }}</span>
        </div>
      </template>
    </el-tree>
  </div>
</template>
```

#### 4.1.2 建模画布
**功能**：
- 接收拖拽的组件，创建节点
- 支持节点之间的连线（表示连接关系）
- 支持节点移动、删除
- 支持画布缩放、平移

**数据模型**：
```typescript
interface ModelicaNode {
  id: string
  type: string  // 组件类型，如 'Resistor', 'VoltageSource'
  position: { x: number, y: number }
  properties: Record<string, any>  // 组件参数
  ports: {
    input: string[]  // 输入端口
    output: string[] // 输出端口
  }
}

interface ModelicaEdge {
  id: string
  source: string  // 源节点ID
  target: string  // 目标节点ID
  sourcePort: string  // 源端口
  targetPort: string  // 目标端口
}

interface ModelingProject {
  nodes: ModelicaNode[]
  edges: ModelicaEdge[]
  name: string
  description?: string
}
```

**实现要点**：
- 使用`@vue-flow/core`构建画布
- 自定义节点组件，显示组件图标和名称
- 实现连线逻辑，验证连接有效性
- 保存项目到后端（JSON格式）

#### 4.1.3 属性编辑面板
**功能**：
- 选中节点后，显示该组件的可编辑属性
- 根据组件类型动态生成表单
- 实时更新节点属性

**实现要点**：
- 从组件元数据获取属性定义
- 使用Element Plus的`el-form`动态生成表单
- 属性变更时更新节点数据

#### 4.1.4 仿真控制面板
**功能**：
- 配置仿真参数（时长、步长、求解器等）
- 启动/暂停/停止仿真
- 显示仿真进度
- 查看仿真日志

**实现要点**：
- 通过WebSocket或轮询获取仿真状态
- 使用`el-progress`显示进度
- 日志实时滚动显示

#### 4.1.5 结果可视化
**功能**：
- 图表展示仿真结果（时间序列图）
- 支持多变量对比
- 支持图表缩放、导出

**实现要点**：
- 使用ECharts绘制时间序列图
- 从后端获取CSV格式的结果数据
- 支持数据筛选、变量选择

### 4.2 后端API设计

#### 4.2.1 模型部署控制器（Java）
**新增接口**：

```java
@RestController
@RequestMapping("/business/model-deploy")
public class ModelDeployController {
    
    /**
     * 获取可用于建模的组件列表（公开的Modelica组件）
     */
    @GetMapping("/components")
    public Result<List<ComponentDTO>> getComponents(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String keyword) {
        // 查询公开的Modelica组件
        // 解析.mo文件，提取组件元数据（名称、参数、端口等）
    }
    
    /**
     * 获取组件详情（包括参数定义、端口定义等）
     */
    @GetMapping("/components/{componentId}")
    public Result<ComponentDetailDTO> getComponentDetail(@PathVariable Long componentId) {
        // 解析.mo文件，提取完整的组件定义
    }
    
    /**
     * 保存建模项目
     */
    @PostMapping("/projects")
    public Result<Long> saveProject(@RequestBody ModelingProjectDTO project) {
        // 保存到数据库或MongoDB
    }
    
    /**
     * 加载建模项目
     */
    @GetMapping("/projects/{projectId}")
    public Result<ModelingProjectDTO> getProject(@PathVariable Long projectId) {
        // 从数据库加载
    }
    
    /**
     * 提交仿真任务
     */
    @PostMapping("/simulation/submit")
    public Result<SimulationTaskDTO> submitSimulation(@RequestBody SimulationRequest request) {
        // 生成Modelica模型文件
        // 调用仿真服务API
        // 返回任务ID
    }
    
    /**
     * 查询仿真任务状态
     */
    @GetMapping("/simulation/{taskId}/status")
    public Result<SimulationStatusDTO> getSimulationStatus(@PathVariable String taskId) {
        // 调用仿真服务API查询状态
    }
    
    /**
     * 获取仿真结果
     */
    @GetMapping("/simulation/{taskId}/result")
    public Result<SimulationResultDTO> getSimulationResult(@PathVariable String taskId) {
        // 调用仿真服务API获取结果
    }
}
```

#### 4.2.2 数据模型设计

**数据库表设计**（MySQL）：
```sql
-- 建模项目表
CREATE TABLE `bs_modeling_project` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `name` VARCHAR(200) NOT NULL,
  `description` TEXT,
  `project_data` JSON NOT NULL COMMENT '项目数据（节点、连线等）',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_del` INT DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 仿真任务表
CREATE TABLE `bs_simulation_task` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `project_id` BIGINT,
  `task_id` VARCHAR(100) NOT NULL COMMENT '仿真服务返回的任务ID',
  `status` VARCHAR(50) NOT NULL COMMENT 'pending/running/completed/failed',
  `simulation_params` JSON COMMENT '仿真参数',
  `result_file_url` VARCHAR(500),
  `error_message` TEXT,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_id` (`task_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 4.3 仿真服务设计

#### 4.3.1 API接口（FastAPI）

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, List

app = FastAPI(title="Modelica Simulation Service")

class SimulationRequest(BaseModel):
    """仿真请求"""
    model_code: str  # Modelica模型代码
    simulation_params: dict  # 仿真参数
    user_id: int

class SimulationResponse(BaseModel):
    """仿真响应"""
    task_id: str
    status: str

@app.post("/api/v1/simulation/submit")
async def submit_simulation(request: SimulationRequest):
    """提交仿真任务"""
    # 验证模型代码
    # 创建Celery任务
    # 返回任务ID
    pass

@app.get("/api/v1/simulation/{task_id}/status")
async def get_simulation_status(task_id: str):
    """查询仿真状态"""
    # 从Celery查询任务状态
    pass

@app.get("/api/v1/simulation/{task_id}/result")
async def get_simulation_result(task_id: str):
    """获取仿真结果"""
    # 返回结果文件路径或数据
    pass
```

#### 4.3.2 Celery任务定义

```python
from celery import Celery
from app.services.modelica_service import ModelicaService
from app.services.simulation_service import SimulationService

celery_app = Celery('simulation', broker='redis://localhost:6379/0')

@celery_app.task(bind=True)
def run_simulation(self, model_code: str, simulation_params: dict, task_id: str):
    """执行仿真任务"""
    try:
        # 1. 保存模型代码到临时文件
        model_file = save_model_to_file(model_code, task_id)
        
        # 2. 编译Modelica模型
        compiled_model = ModelicaService.compile_model(model_file)
        
        # 3. 执行仿真
        result_file = SimulationService.run_simulation(
            compiled_model, 
            simulation_params
        )
        
        # 4. 处理结果文件
        processed_result = process_result_file(result_file)
        
        # 5. 更新任务状态
        update_task_status(task_id, 'completed', processed_result)
        
        return {'status': 'success', 'result': processed_result}
    except Exception as e:
        update_task_status(task_id, 'failed', str(e))
        raise
```

#### 4.3.3 OpenModelica集成

```python
import subprocess
import os
from pathlib import Path

class ModelicaService:
    """Modelica模型处理服务"""
    
    def __init__(self):
        self.omc_path = os.getenv('OMC_PATH', '/usr/bin/omc')
        self.temp_dir = Path('/tmp/modelica_simulations')
        self.temp_dir.mkdir(exist_ok=True)
    
    def compile_model(self, model_file: Path) -> Path:
        """编译Modelica模型"""
        # 使用OMCompiler编译模型
        cmd = [
            self.omc_path,
            '+simCodeTarget=Cpp',
            model_file
        ]
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            cwd=self.temp_dir
        )
        if result.returncode != 0:
            raise Exception(f"编译失败: {result.stderr}")
        
        # 返回编译后的模型文件路径
        return self.temp_dir / f"{model_file.stem}_executable"
    
    def run_simulation(
        self, 
        compiled_model: Path, 
        params: dict
    ) -> Path:
        """执行仿真"""
        # 使用OMSimulator执行仿真
        result_file = self.temp_dir / f"{compiled_model.stem}_result.csv"
        
        cmd = [
            'omc',
            '--simulation',
            f'--startTime={params.get("startTime", 0)}',
            f'--stopTime={params.get("stopTime", 1)}',
            f'--stepSize={params.get("stepSize", 0.01)}',
            f'--solver={params.get("solver", "dassl")}',
            f'--resultFile={result_file}',
            str(compiled_model)
        ]
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            cwd=self.temp_dir
        )
        
        if result.returncode != 0:
            raise Exception(f"仿真失败: {result.stderr}")
        
        return result_file
```

## 五、关键技术实现

### 5.1 Modelica模型生成

#### 5.1.1 从画布数据生成Modelica代码

**流程**：
1. 遍历画布中的节点，为每个节点生成对应的Modelica组件实例
2. 根据连线关系，生成连接语句（connect）
3. 生成模型类定义（model/class）
4. 添加必要的导入语句（import）

**示例**：
```python
def generate_modelica_code(project: ModelingProject) -> str:
    """从建模项目生成Modelica代码"""
    code_lines = []
    
    # 1. 导入语句
    code_lines.append("model GeneratedModel")
    code_lines.append("  // 导入标准库")
    code_lines.append("  import Modelica.Electrical.Analog.Basic.*;")
    code_lines.append("")
    
    # 2. 组件实例声明
    for node in project.nodes:
        component_type = get_component_type(node.type)
        code_lines.append(f"  {component_type} {node.id}({format_parameters(node.properties)});")
    
    code_lines.append("")
    
    # 3. 连接语句
    code_lines.append("equation")
    for edge in project.edges:
        source_port = f"{edge.source}.{edge.sourcePort}"
        target_port = f"{edge.target}.{edge.targetPort}"
        code_lines.append(f"  connect({source_port}, {target_port});")
    
    code_lines.append("end GeneratedModel;")
    
    return "\n".join(code_lines)
```

### 5.2 组件元数据提取

#### 5.2.1 解析.mo文件提取组件信息

**实现思路**：
- 使用正则表达式或ANTLR解析Modelica语法
- 提取类名、参数、端口等信息
- 缓存解析结果，避免重复解析

**示例**：
```python
import re
from typing import Dict, List

class ModelicaParser:
    """Modelica文件解析器"""
    
    def parse_component(self, mo_file_content: str) -> Dict:
        """解析组件定义"""
        component = {
            'name': None,
            'parameters': [],
            'ports': {
                'input': [],
                'output': []
            }
        }
        
        # 提取类名
        class_match = re.search(r'class\s+(\w+)', mo_file_content)
        if class_match:
            component['name'] = class_match.group(1)
        
        # 提取参数
        parameter_matches = re.findall(
            r'parameter\s+(\w+)\s+(\w+)\s*=\s*([^;]+)',
            mo_file_content
        )
        for match in parameter_matches:
            component['parameters'].append({
                'type': match[0],
                'name': match[1],
                'default': match[2].strip()
            })
        
        # 提取端口（Modelica中的connector）
        connector_matches = re.findall(
            r'(\w+)\s+(\w+)\s*;',
            mo_file_content
        )
        # 根据connector类型判断是输入还是输出
        # ...
        
        return component
```

### 5.3 结果数据处理

#### 5.3.1 CSV结果文件解析

```python
import pandas as pd
import json

def process_simulation_result(csv_file: Path) -> dict:
    """处理仿真结果CSV文件"""
    # 读取CSV文件
    df = pd.read_csv(csv_file)
    
    # 提取时间列
    time_column = df.columns[0]  # 通常是第一列
    time_data = df[time_column].tolist()
    
    # 提取变量数据
    variables = {}
    for col in df.columns[1:]:  # 跳过时间列
        variables[col] = df[col].tolist()
    
    return {
        'time': time_data,
        'variables': variables,
        'metadata': {
            'data_points': len(time_data),
            'variables_count': len(variables)
        }
    }
```

## 六、开发计划

### 6.1 第一阶段：基础框架搭建（1-2周）

**目标**：搭建仿真服务基础框架

**任务**：
1. 创建`model-cloud-simulation`目录结构
2. 配置Python环境（FastAPI、Celery、Redis）
3. 实现基础的API接口（占位实现）
4. 配置OpenModelica环境
5. 编写Docker配置（可选）

**交付物**：
- 可运行的仿真服务（基础框架）
- API文档
- 环境配置文档

### 6.2 第二阶段：Modelica集成（2-3周）

**目标**：实现OpenModelica的集成

**任务**：
1. 实现Modelica文件解析器
2. 实现模型编译功能
3. 实现仿真执行功能
4. 实现结果文件处理
5. 编写单元测试

**交付物**：
- 完整的Modelica集成服务
- 测试用例
- 使用文档

### 6.3 第三阶段：后端API开发（1-2周）

**目标**：扩展Java后端，支持建模和仿真

**任务**：
1. 创建数据库表
2. 实现组件列表API
3. 实现项目保存/加载API
4. 实现仿真任务提交API
5. 实现与仿真服务的通信

**交付物**：
- 完整的后端API
- API文档
- 数据库迁移脚本

### 6.4 第四阶段：前端建模界面（3-4周）

**目标**：实现拖拽式建模界面

**任务**：
1. 集成拖拽库（vue-draggable-plus + @vue-flow/core）
2. 实现组件库面板
3. 实现建模画布
4. 实现属性编辑面板
5. 实现项目保存/加载功能
6. 实现模型代码生成（前端预览）

**交付物**：
- 完整的建模界面
- 用户操作文档

### 6.5 第五阶段：仿真功能集成（2-3周）

**目标**：集成仿真功能到前端

**任务**：
1. 实现仿真参数配置界面
2. 实现仿真任务提交
3. 实现仿真状态查询（WebSocket或轮询）
4. 实现仿真日志显示
5. 实现结果可视化（ECharts）

**交付物**：
- 完整的仿真功能
- 结果可视化界面

### 6.6 第六阶段：测试与优化（2周）

**目标**：测试、优化、文档

**任务**：
1. 端到端测试
2. 性能优化
3. 错误处理完善
4. 用户文档编写
5. 部署文档编写

**交付物**：
- 测试报告
- 用户手册
- 部署文档

## 七、技术难点与解决方案

### 7.1 Modelica语法解析

**难点**：Modelica语法复杂，完整解析需要完整的语法分析器

**解决方案**：
- **阶段1**：使用正则表达式提取关键信息（类名、参数、端口）
- **阶段2**：使用ANTLR生成Modelica语法解析器（如果需要完整解析）
- **阶段3**：考虑使用现有的Modelica解析库（如pyfmi中的部分功能）

### 7.2 组件连接验证

**难点**：需要验证组件之间的连接是否合法（类型匹配、端口匹配）

**解决方案**：
- 从.mo文件中提取connector定义
- 建立类型系统，验证连接兼容性
- 前端实时验证，后端二次验证

### 7.3 仿真任务管理

**难点**：长时间运行的仿真任务，需要状态跟踪、错误处理、资源清理

**解决方案**：
- 使用Celery的任务状态机制
- 实现任务超时机制
- 定期清理临时文件
- 实现任务重试机制

### 7.4 大文件处理

**难点**：仿真结果文件可能很大，直接传输效率低

**解决方案**：
- 结果文件存储在文件系统，返回文件URL
- 支持分块下载
- 支持结果数据的分页查询
- 考虑使用对象存储（如MinIO）

## 八、部署方案

### 8.1 开发环境

**仿真服务**：
```bash
# 1. 安装Python依赖
cd model-cloud-simulation
pip install -r requirements.txt

# 2. 启动Redis
redis-server

# 3. 启动Celery Worker
celery -A app.tasks.simulation_tasks worker --loglevel=info

# 4. 启动FastAPI服务
uvicorn app.main:app --reload --port 8000
```

### 8.2 生产环境

**Docker部署**（推荐）：
```yaml
# docker-compose.yml
version: '3.8'
services:
  simulation-api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - REDIS_URL=redis://redis:6379/0
      - OMC_PATH=/usr/bin/omc
    depends_on:
      - redis
  
  simulation-worker:
    build: .
    command: celery -A app.tasks.simulation_tasks worker --loglevel=info
    environment:
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - redis
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
```

## 九、扩展性考虑

### 9.1 支持更多模型类型

**设计**：
- 抽象出`ModelService`接口
- 为不同模型类型实现不同的Service
- 前端通过模型类型选择对应的建模界面

### 9.2 分布式仿真

**设计**：
- 使用Celery的分布式特性
- 支持多Worker节点
- 实现负载均衡

### 9.3 结果缓存

**设计**：
- 相同参数的仿真结果可以缓存
- 使用Redis缓存结果元数据
- 结果文件存储在对象存储中

## 十、总结

本开发方案采用前后端分离 + 独立仿真服务的架构，通过拖拽式建模界面、OpenModelica集成、异步任务处理等技术，实现Modelica模型的在线建模和仿真功能。方案具有良好的可扩展性，后续可以支持更多模型类型和功能增强。

**关键成功因素**：
1. OpenModelica环境的正确配置
2. Modelica语法解析的准确性
3. 前后端数据模型的一致性
4. 仿真任务的可靠执行
5. 良好的用户体验（拖拽、可视化）

**风险控制**：
1. 充分测试OpenModelica集成
2. 完善的错误处理和日志记录
3. 资源限制和清理机制
4. 用户操作引导和帮助文档

