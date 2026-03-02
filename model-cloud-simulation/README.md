# Model Cloud Simulation Service

Modelica模型仿真服务，提供在线建模和仿真功能。

## 技术栈

- **FastAPI**: Web框架
- **Celery**: 异步任务队列
- **Redis**: 消息代理
- **OpenModelica**: Modelica模型编译和仿真

## 环境要求

- Python 3.10+
- Redis 6.0+
- OpenModelica 1.19+

## 安装步骤

### 1. 安装Python依赖

```bash
pip install -r requirements.txt
```

### 2. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 文件，配置相关参数
```

### 3. 安装OpenModelica

**Linux:**
```bash
# 使用包管理器安装
sudo apt-get install openmodelica
# 或从官网下载安装包
```

**Windows:**
从 [OpenModelica官网](https://openmodelica.org/download/download-windows) 下载安装包并安装。

**验证安装:**
```bash
omc --version
```

### 4. 启动Redis

```bash
redis-server
```

### 5. 启动服务

**开发环境:**
```bash
# 启动API服务
uvicorn app.main:app --reload --port 8000

# 启动Celery Worker（新终端）
celery -A app.tasks.simulation_tasks worker --loglevel=info
```

**生产环境:**
```bash
# 使用Docker Compose
docker-compose up -d
```

## API文档

启动服务后，访问：
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 项目结构

```
model-cloud-simulation/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI应用入口
│   ├── config.py            # 配置文件
│   ├── api/                 # API路由
│   ├── services/            # 业务服务
│   ├── tasks/               # Celery任务
│   ├── models/              # 数据模型
│   └── utils/               # 工具函数
├── tests/                   # 测试文件
├── scripts/                 # 脚本文件
├── requirements.txt         # Python依赖
├── .env.example             # 环境变量示例
└── README.md                # 本文档
```

## 开发说明

### 添加新的API接口

1. 在 `app/api/` 目录下创建或修改路由文件
2. 在 `app/main.py` 中注册路由
3. 编写相应的服务逻辑

### 添加新的Celery任务

1. 在 `app/tasks/` 目录下定义任务
2. 在服务中调用任务
3. 使用 `task_id` 跟踪任务状态

## 故障排查

### OpenModelica命令找不到

确保OpenModelica已正确安装，并在环境变量中配置 `OMC_PATH`。

### Redis连接失败

检查Redis服务是否启动，以及 `REDIS_URL` 配置是否正确。

### 任务执行失败

查看Celery Worker日志，检查OpenModelica是否正确安装和配置。

## 许可证

与主项目保持一致。

