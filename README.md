# Model Cloud 项目配置与启动

本文按当前 Windows 本地开发配置说明环境准备、连接配置与启动方法。Docker 运行 MySQL、Redis、MongoDB 和 Gitea；Java 后端、Vue 前端、FastAPI、Julia 和 MATLAB 直接运行。

## 1. 环境与端口

| 环境 | 当前配置或版本                          |
| --- |-----------------------------------------|
| Java | 项目编译目标 JDK 17                     |
| Maven | 3.9.16                                  |
| Node.js | 24.16.0，前端使用 npm              |
| Python | 3.12.10      |
| Julia | 1.12.5，需安装 JSON3、MATLAB 包    |
| MATLAB | R2025b |
| OpenModelica | 1.27.0，运行 Modelica 仿真时需要   |
| Docker | 用于运行下面四个基础服务                |

| 服务 | 访问地址 | 当前容器及容器内端口 |
| --- | --- | --- |
| MySQL 8.0 | `localhost:3307`，数据库 `model_cloud` | `model-cloud-mysql`，3306 |
| Redis 7 | `localhost:6379`，默认无密码 | `model-cloud-redis`，6379 |
| MongoDB 6 | `localhost:27017`，数据库 `model_cloud` | `model-cloud-mongodb`，27017 |
| Gitea | `http://localhost:3000`，SSH 端口 2222 | `model-cloud-gitea`，HTTP 3000 / SSH 22 |
| Java 后端 | `http://localhost:8080/api` | 独立进程 |
| FastAPI | `http://localhost:8000` | 独立进程 |
| Vue 前端 | `http://localhost:5173` | 独立进程 |

下文命令使用 PowerShell。各应用的相对路径依赖工作目录，请分别进入对应模块再启动。

## 2. 基础服务与数据库初始化

### 启动现有容器

先启动 Docker Desktop。当前电脑已有上述容器时执行：

```powershell
docker start model-cloud-mysql model-cloud-redis model-cloud-mongodb model-cloud-gitea
```

新电脑需自行安装基础服务或创建对应容器，按上表映射端口，并配置持久化数据目录或数据卷。数据库账号、密码和 Gitea Token 应与后端配置一致。

### MySQL 初始化

初始化脚本位于仓库根目录：`database_full_init.sql`，包含 `model_cloud` 数据库、业务表、基础角色、`admin` 账号和触发器。

首次建立空数据库时，可通过数据库管理工具执行整个脚本；也可在仓库根目录使用 MySQL 客户端：

```powershell
mysql -h 127.0.0.1 -P 3307 -u root -p --default-character-set=utf8mb4
```

输入数据库密码后，在 MySQL 客户端执行。相对路径以启动客户端时的仓库根目录为基准：

```sql
SOURCE ./database_full_init.sql;
```

脚本会删除并重建部分标签基础数据，已有业务数据库不要直接重复初始化；迁移已有数据时使用数据库备份恢复。

SQL 中 `admin` 的密码保存为 BCrypt 哈希，没有注明明文初始密码。平台登录密码与 MySQL、MongoDB、Gitea 的连接密码分别管理。

### MongoDB、Redis 与 Gitea

初始化脚本位于 `scripts/init/`，在基础服务已启动后手动执行。以下命令均在仓库根目录运行，不安装服务，也不改写项目 YAML 配置。

#### MongoDB

当前使用 `admin` 用户，通过 `admin` 认证库访问 `model_cloud`。新建 MongoDB 容器时，先通过 `MONGO_INITDB_ROOT_USERNAME=admin` 和 `MONGO_INITDB_ROOT_PASSWORD` 设置管理员，密码与 `application-dev.yml` 中的连接 URI 保持一致；这些容器环境变量只在空数据目录首次初始化时生效。

将脚本复制到现有容器并执行，命令会提示输入 MongoDB 密码：

```powershell
docker cp ./scripts/init/mongodb.js model-cloud-mongodb:/tmp/model-cloud-mongodb-init.js
docker exec -it model-cloud-mongodb mongosh model_cloud --username admin --authenticationDatabase admin --file /tmp/model-cloud-mongodb-init.js
```

脚本依据后端实体创建以下集合，已有集合和文档保留：

- `bs_model_params`：模型参数。
- `bs_component_parse_meta`：组件解析元数据，使用类名作为 `_id`。
- `bs_component_parse_meta_omc`：OMC 组件解析元数据，使用类名作为 `_id`。

集合的 `_id` 索引由 MongoDB 自动创建；脚本不填入示例模型、虚构解析结果或额外唯一约束。业务数据由后续模型上传、解析流程写入。若使用独立安装的 MongoDB，也可用 `mongosh` 连接后执行 `load("./scripts/init/mongodb.js")`。

#### Redis

当前连接 `localhost:6379/0`，开发配置未设置密码。执行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/init/redis.ps1
```

当前入口只需运行时生成的验证码缓存，无需预填固定键。脚本检查 PING、读写和过期时间，使用随机命名、30 秒过期的临时键，检查后删除该键，不清空已有缓存。默认使用 `model-cloud-redis` 容器和 0 号库，可通过 `-ContainerName`、`-Database` 指定。

如果 Redis 启用了密码，在执行前通过环境变量 `REDISCLI_AUTH` 提供认证信息，同时修改后端 Redis 密码配置。

#### Gitea

先在 `http://localhost:3000` 完成 Gitea 自身的首次安装，然后执行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/init/gitea.ps1
```

脚本默认连接 `model-cloud-gitea` 容器、`http://localhost:3000`，执行以下初始化：

1. 服务账号 `modelcloud` 不存在时创建，并交互输入新账号密码；账号已存在时保留原密码和权限。
2. 生成具有 `write:repository,read:user` 权限的 Token，保存到 `scripts/init/gitea.local`；该文件由现有 `*.local` Git 忽略规则排除。再次执行时复用并验证该文件中的 Token，不重复生成。
3. 创建默认封面所需的公开 `imgs` 仓库，默认分支为 `main`；已有仓库和文件保留。

项目没有附带默认封面 PNG。需要初始化封面时，提供自己的图片路径：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/init/gitea.ps1 -CoverImage ./cover.png
```

脚本只在文件不存在时上传为 `imgs/default-cover-img.png`，不会替换已有封面。如果已有 `imgs` 仓库的默认分支不是 `main`，需先手动核对分支；脚本不会替你更改分支。

打开生成的 `gitea.local`，将 `username`、`token` 分别设置为后端进程的 `GITEA_USERNAME`、`GITEA_TOKEN` 环境变量，并将账号实际密码设置为 `GITEA_PASSWORD`；`url` 对应 `application.yml` 的 `model-cloud.gitea.url`。该连接文件包含 Token，应保留供重复执行使用，不要提交或公开；Token 失效时需手动更新或另存旧文件后重新生成。

可通过 `-ContainerName`、`-GiteaUrl`、`-Username`、`-Email`、`-ConnectionFile` 覆盖默认参数。业务用户的 `models-<用户名>` 仓库由后端首次上传时创建，无需批量预建。

上述脚本用于准备新环境，不恢复旧业务数据。迁移旧模型及仓库时，还需恢复对应数据库、Gitea 数据和上传文件。

## 3. Java 后端配置

配置文件位于 `model-cloud-backend/src/main/resources/`：

- `application.yml`：通用设置，默认启用 `dev`。
- `application-dev.yml`：开发环境数据库连接，覆盖通用文件中的同名设置。
- `application-prod.yml`：生产环境配置，不用于本文的本地启动。

### 开发环境连接

在 `application-dev.yml` 中核对：

| 配置项 | 当前连接设置 |
| --- | --- |
| `spring.datasource.url` | `jdbc:mysql://localhost:3307/model_cloud?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true` |
| `spring.datasource.username` | `${DB_USERNAME:root}` |
| `spring.datasource.password` | `${DB_PASSWORD}`，通过环境变量提供 |
| `spring.data.redis.host` / `port` | `localhost` / `6379` |
| `spring.data.mongodb.uri` | `${MONGODB_URI}`，完整连接串通过环境变量提供 |
| `spring.data.mongodb.database` | `model_cloud` |

凭据通过下文的环境变量提供；修改通用文件中的连接配置时，还要核对开发文件的覆盖值。

### Gitea、文件与仿真连接

在 `application.yml` 中核对连接配置，并按下表将上传目录和任务目录改为相对路径：

| 配置项 | 设置说明 |
| --- | --- |
| `server.port` | `8080` |
| `server.servlet.context-path` | `/api` |
| `model-cloud.gitea.url` | `http://localhost:3000` |
| `model-cloud.gitea.username` | `${GITEA_USERNAME:modelcloud}`，与 Token 所属账号一致 |
| `model-cloud.gitea.password` | `${GITEA_PASSWORD}` |
| `model-cloud.gitea.token` | `${GITEA_TOKEN}` |
| `model-cloud.jwt.secret` | `${JWT_SECRET}`，填写至少 32 字节的随机签名密钥 |
| `model-cloud.upload.windows-path` | 配置为 `../runtime/uploads/` |
| `model-cloud.simulation.base-url` | `http://localhost:8000/api/v1/simulation` |
| `model-cloud.matlab-config.simulation-task-root` | 配置为 `${MATLAB_TASK_WORK_DIR:../runtime/matlab_simulations/}`，默认与 FastAPI 使用同一任务目录，并保留环境变量覆盖方式 |

以上相对路径以 `model-cloud-backend` 为工作目录，实际对应仓库根目录下的 `runtime/uploads/` 和 `runtime/matlab_simulations/`。需要沿用原有任务目录时，也可在启动 Java 进程前设置环境变量 `MATLAB_TASK_WORK_DIR`，并同步修改 FastAPI 的同名配置。

这些路径需要手动填写到配置文件；这里只给出配置方法。当前开发配置直接来自 YAML；Java 不会自动加载根目录 `.env`。

### 通过环境变量提供连接凭据

提交副本的通用、开发和生产 YAML 均从环境变量读取凭据，不包含可用的默认密码、Token 或 JWT 密钥。启动后端前，在同一个 PowerShell 终端中填写：

```powershell
$env:DB_USERNAME = 'root'
$env:DB_PASSWORD = '<MySQL密码>'
$env:MONGODB_URI = 'mongodb://admin:<MongoDB密码>@localhost:27017/model_cloud?authSource=admin'
$env:GITEA_USERNAME = 'modelcloud'
$env:GITEA_PASSWORD = '<Gitea账号密码>'
$env:GITEA_TOKEN = '<Gitea访问Token>'
$env:JWT_SECRET = '<至少32字节的随机签名密钥>'
```

将尖括号中的占位内容替换为自己的值；URI 中的账号密码含特殊字符时需进行 URL 编码。缺少必需变量时后端不会使用旧电脑的凭据启动。若需要为生产环境 Redis 设置密码，可另设 `REDIS_PASSWORD`；默认开发配置仍连接无密码的 Redis。

变量只对当前终端及其子进程生效，随后在此终端启动 Java。使用 IDE 时在后端运行配置的环境变量中填写相同项目。FastAPI 的 `.env` 配置仍按下文单独设置，Java 不自动读取它。

### 启动后端

在仓库根目录打开一个终端：

```powershell
cd model-cloud-backend
mvn.cmd spring-boot:run
```

默认加载 `dev`，监听 8080。保持该终端运行。

## 4. FastAPI 与 Python 配置

### 手动安装 Python 依赖

自行准备 Python 3.12，并在终端或 IDE 中选定解释器。依赖清单为 `model-cloud-simulation/requirements.txt`：

```powershell
cd model-cloud-simulation
python -m pip install -r requirements.txt
```

依赖包括 FastAPI、Uvicorn、Pydantic、NumPy、pandas 等；Julia、MATLAB 和 OpenModelica 需要另外安装。项目不提供 Python 自动配置或安装脚本。

### 环境文件

在 `model-cloud-simulation` 目录手动创建或编辑 `.env`。现有文件可继续使用，迁移时根据新电脑路径调整。示例：

```dotenv
JULIA_PATH=julia
JULIA_PROJECT_PATH=
JULIA_MATLAB_RUNNER_PATH=./julia/run_matlab_graph.jl
MATLAB_COMPONENT_ROOT=../model-cloud-backend/src/main/resources/static/matlab_component_source
MATLAB_TASK_WORK_DIR=../runtime/matlab_simulations
MATLAB_TASK_TIMEOUT=3600
MATLAB_MAX_CONCURRENT_TASKS=1
BACKEND_API_URL=http://localhost:8080/api
OMC_PATH=omc
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
```

- 组件源码、运行脚本和任务目录的相对路径均以 `model-cloud-simulation` 为工作目录，复制或迁移整个仓库时无需改动这些相对路径。
- 将 Julia 和 OpenModelica 的可执行文件目录加入操作系统的 PATH；不使用 PATH 时，在此 `.env` 中将 `JULIA_PATH`、`OMC_PATH` 分别填写为实际的可执行文件路径，Windows 路径可使用 `/`。
- `JULIA_PROJECT_PATH` 留空时使用 Julia 默认环境；设置时，JSON3 和 MATLAB 包应安装在指定环境中。
- `MATLAB_TASK_WORK_DIR` 必须与 Java 的任务目录指向同一目录。按本文分别从两个模块目录启动时，两处的 `../runtime/matlab_simulations` 均对应仓库根目录下的同一目录。若改为自定义目录，需同步修改 Java 配置和此 `.env`。
- 当前并发默认为 1；如另设 `MATLAB_MAX_CONCURRENT_SESSIONS` 为正整数，该值优先于 `MATLAB_MAX_CONCURRENT_TASKS`。

FastAPI 从当前工作目录读取 `.env`，因此启动时应位于 `model-cloud-simulation`。真实 `.env` 不提交 GitHub。

### Julia 与 MATLAB

安装并激活 MATLAB，准备模型所需工具箱。使用 `JULIA_PATH` 对应的 Julia，在 Julia 终端手动安装依赖：

```julia
using Pkg
Pkg.add(["JSON3", "MATLAB"])
```

如安装多套 MATLAB，需要明确指定版本时，在操作系统环境变量 `MATLAB_ROOT` 中填写所需版本的 MATLAB 安装根目录（包含 `bin`、`extern` 的目录，而非 `matlab.exe` 路径），重新打开 Julia 后在同一环境中执行：

```julia
using Pkg
Pkg.build("MATLAB")
```

Windows 下 MATLAB.jl 依赖 MATLAB 的 COM 注册。若启动 Engine 时出现注册错误，可按所安装 MATLAB.jl 的说明，在管理员 MATLAB 命令窗口执行 `!matlab -regserver`，关闭 MATLAB 后重启 Julia/FastAPI。

当前调用链为 FastAPI → Julia → MATLAB.jl → MATLAB。Python requirements 不包含 `matlabengine`，当前链路也不要求单独安装该 Python 包。

### OpenModelica

运行 Modelica 仿真时，安装 OpenModelica，并将 `.env` 的 `OMC_PATH` 指向 `omc.exe`。只使用 MATLAB 仿真时无需启动 OpenModelica 服务。

### 启动 FastAPI

在 `model-cloud-simulation` 目录，使用已安装依赖的解释器执行：

```powershell
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

当前 `app.main:app` 直接调度异步仿真任务，无需额外启动 Celery worker。

## 5. 前端配置与启动

在仓库根目录另开一个终端：

```powershell
cd model-cloud-frontend
npm.cmd ci
npm.cmd run dev
```

`npm ci` 使用仓库现有 `package-lock.json` 安装依赖。已有依赖且清单未变化时，可直接执行 `npm.cmd run dev`。

前端配置位于 `model-cloud-frontend/vite.config.ts`：

- 默认开发端口为 5173。
- 浏览器请求 `/api`，Vite 默认代理到 `http://localhost:8080`。
- 后端地址变化时，可在前端目录的 `.env.development.local` 中手动设置 `VITE_API_PROXY_TARGET=http://localhost:8080`，然后重启前端。

按当前跨域配置，使用 `http://localhost:5173` 访问前端。

## 6. 启动顺序与访问地址

1. 启动 MySQL、Redis、MongoDB 和 Gitea；新环境完成 MySQL 初始化及账号配置。
2. 启动 Java 后端，端口 8080。
3. 启动 FastAPI，端口 8000。
4. 启动前端，端口 5173。

| 用途 | 地址 |
| --- | --- |
| 前端页面 | http://localhost:5173 |
| 后端 API 前缀 | http://localhost:8080/api |
| FastAPI 文档 | http://localhost:8000/docs |
| FastAPI 健康接口 | http://localhost:8000/health |
| Gitea 页面 | http://localhost:3000 |

健康接口正常只说明 FastAPI 已启动；MATLAB / Modelica 仿真仍需相应引擎、工具箱、路径与授权可用。
