"""
FastAPI应用入口
"""
import asyncio
import os
import subprocess
import sys
import uuid
from datetime import datetime
from threading import Lock
from typing import Any, Dict, Optional

import pandas as pd
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from loguru import logger
from pydantic import BaseModel, Field

from app.config import settings

# 配置日志
logger.remove()
logger.add(
    sys.stdout,
    format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>",
    level=settings.LOG_LEVEL
)

# 创建FastAPI应用
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Modelica模型仿真服务",
    docs_url="/docs",
    redoc_url="/redoc"
)

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.get_cors_origins_list(),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 内存任务表（MVP阶段）
TASKS: Dict[str, Dict[str, Any]] = {}
TASKS_LOCK = Lock()


class SimulationParams(BaseModel):
    startTime: float = 0.0
    stopTime: float = 10.0
    stepSize: float = 0.01
    solver: str = "dassl"
    inputParams: Dict[str, Any] = Field(default_factory=dict)


class SubmitSimulationRequest(BaseModel):
    taskId: Optional[str] = None
    modelCode: str
    simulationParams: SimulationParams = Field(default_factory=SimulationParams)


def _set_task(task_id: str, **kwargs: Any) -> None:
    with TASKS_LOCK:
        task = TASKS.get(task_id, {})
        task.update(kwargs)
        TASKS[task_id] = task


def _get_task(task_id: str) -> Optional[Dict[str, Any]]:
    with TASKS_LOCK:
        task = TASKS.get(task_id)
        if task is None:
            return None
        return dict(task)


def _build_mos_script(model_name: str, work_dir: str, params: SimulationParams) -> str:
    intervals = max(2, int((params.stopTime - params.startTime) / max(params.stepSize, 1e-6)))
    work_dir_unix = work_dir.replace("\\", "/")
    model_file = os.path.join(work_dir, "GeneratedModel.mo").replace("\\", "/")
    return "\n".join(
        [
            f'cd("{work_dir_unix}");',
            "loadModel(Modelica);",
            f'loadFile("{model_file}");',
            (
                f'simulate({model_name}, startTime={params.startTime}, stopTime={params.stopTime}, '
                f'numberOfIntervals={intervals}, method="{params.solver}", outputFormat="csv");'
            ),
            "getErrorString();",
        ]
    )


def _extract_model_name(model_code: str) -> str:
    for line in model_code.splitlines():
        stripped = line.strip()
        if stripped.startswith("model "):
            parts = stripped.split()
            if len(parts) >= 2:
                return parts[1].replace(";", "")
    return "GeneratedModel"


def _run_openmodelica(task_id: str, request: SubmitSimulationRequest) -> Dict[str, Any]:
    work_dir = os.path.abspath(os.path.join(settings.OMC_WORK_DIR, task_id))
    os.makedirs(work_dir, exist_ok=True)
    os.makedirs(os.path.abspath(settings.RESULT_DIR), exist_ok=True)

    model_code = request.modelCode
    model_name = _extract_model_name(model_code)
    model_path = os.path.join(work_dir, "GeneratedModel.mo")
    mos_path = os.path.join(work_dir, "simulate.mos")

    with open(model_path, "w", encoding="utf-8") as f:
        f.write(model_code)

    mos_script = _build_mos_script(model_name, work_dir, request.simulationParams)
    with open(mos_path, "w", encoding="utf-8") as f:
        f.write(mos_script)

    cmd = [settings.OMC_PATH, mos_path]
    logger.info("开始执行OpenModelica任务: taskId={}, cmd={}", task_id, " ".join(cmd))
    process = subprocess.run(
        cmd,
        cwd=work_dir,
        capture_output=True,
        text=True,
        timeout=settings.TASK_TIMEOUT,
        encoding="utf-8",
        errors="ignore",
    )

    stdout = process.stdout or ""
    stderr = process.stderr or ""
    if process.returncode != 0:
        raise RuntimeError(f"omc执行失败(returnCode={process.returncode}) stderr={stderr[:1000]}")

    csv_path = os.path.join(work_dir, f"{model_name}_res.csv")
    if not os.path.exists(csv_path):
        raise RuntimeError(f"未找到仿真结果文件: {csv_path}. stdout={stdout[-1000:]}")

    df = pd.read_csv(csv_path)
    if "time" not in df.columns and len(df.columns) > 0:
        # OpenModelica正常会生成time列，这里做兜底保证前端图表可用
        df.rename(columns={df.columns[0]: "time"}, inplace=True)

    max_points = 1000
    if len(df) > max_points:
        step = max(1, len(df) // max_points)
        df = df.iloc[::step, :].reset_index(drop=True)

    time_values = df["time"].tolist() if "time" in df.columns else list(range(len(df)))
    variables: Dict[str, Any] = {}
    available = []
    for col in df.columns:
        if col == "time":
            continue
        available.append(col)
        variables[col] = df[col].tolist()

    result_data = {
        "time": time_values,
        "variables": variables,
        "availableVariables": available,
        "pointCount": len(time_values),
    }

    output_csv = os.path.abspath(os.path.join(settings.RESULT_DIR, f"{task_id}.csv"))
    df.to_csv(output_csv, index=False)
    return {
        "resultData": result_data,
        "resultFileUrl": output_csv,
    }


async def _execute_task(task_id: str, request: SubmitSimulationRequest) -> None:
    _set_task(task_id, status="running", progress=20, startTime=datetime.now().isoformat(), errorMessage=None)
    try:
        result = await asyncio.to_thread(_run_openmodelica, task_id, request)
        _set_task(
            task_id,
            status="completed",
            progress=100,
            endTime=datetime.now().isoformat(),
            resultData=result.get("resultData"),
            resultFileUrl=result.get("resultFileUrl"),
        )
    except Exception as e:
        logger.exception("仿真任务失败 taskId={}", task_id)
        _set_task(
            task_id,
            status="failed",
            progress=100,
            endTime=datetime.now().isoformat(),
            errorMessage=str(e),
        )


@app.get("/")
async def root():
    """根路径"""
    return {
        "name": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "running"
    }


@app.get("/health")
async def health_check():
    """健康检查"""
    return {
        "status": "healthy",
        "service": settings.APP_NAME
    }


@app.post("/api/v1/simulation/submit")
async def submit_simulation(request: SubmitSimulationRequest):
    """提交仿真任务并异步执行"""
    task_id = request.taskId or uuid.uuid4().hex
    _set_task(
        task_id,
        taskId=task_id,
        status="pending",
        progress=0,
        createTime=datetime.now().isoformat(),
        resultData=None,
        resultFileUrl=None,
        errorMessage=None,
    )
    asyncio.create_task(_execute_task(task_id, request))
    return {
        "taskId": task_id,
        "status": "pending",
        "message": "仿真任务已提交",
    }


@app.get("/api/v1/simulation/tasks/{task_id}")
async def get_simulation_task(task_id: str):
    """查询仿真任务状态"""
    task = _get_task(task_id)
    if task is None:
        raise HTTPException(status_code=404, detail="任务不存在")
    return task


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.API_HOST,
        port=settings.API_PORT,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower()
    )

