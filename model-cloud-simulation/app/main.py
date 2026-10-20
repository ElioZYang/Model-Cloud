"""
FastAPI应用入口
"""
import asyncio
import hashlib
import json
import os
import subprocess
import sys
import uuid
from datetime import datetime
from pathlib import Path, PurePath
from threading import Lock
from typing import Any, Dict, Optional

import pandas as pd
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from loguru import logger
from pydantic import BaseModel, Field, model_validator

from app.config import settings
from app.artifacts import collect_artifacts, project_result_data
from app.task_state import load_task, save_task, task_directory
from app.executors.julia_matlab_graph_executor import (
    GraphExecutionError,
    JuliaMatlabGraphExecutor,
)

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
    description="Modelica仿真与MATLAB函数计算服务",
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
    engineType: str = "modelica"
    modelCode: Optional[str] = None
    executionPayload: Optional[Dict[str, Any]] = None
    simulationParams: Optional[SimulationParams] = None

    @model_validator(mode="after")
    def validate_engine_payload(self):
        engine_type = (self.engineType or "modelica").lower()
        if engine_type == "modelica" and not (self.modelCode or "").strip():
            raise ValueError("Modelica任务必须提供modelCode")
        if engine_type == "matlab" and self.executionPayload is None:
            raise ValueError("MATLAB任务必须提供executionPayload")
        if engine_type not in {"modelica", "matlab"}:
            raise ValueError(f"不支持的执行引擎: {self.engineType}")
        self.engineType = engine_type
        return self


JULIA_MATLAB_EXECUTOR = JuliaMatlabGraphExecutor()


def _collect_matlab_artifacts(task_id: str, result: Dict[str, Any]) -> list[dict[str, str]]:
    """Build a task-scoped, path-free manifest for PNGs created by MATLAB."""
    task_root = (Path(settings.MATLAB_TASK_WORK_DIR).resolve() / task_id).resolve()
    manifest, artifact_files = collect_artifacts(task_id, result, task_root)
    with TASKS_LOCK:
        task = TASKS.get(task_id)
        if task is not None:
            task["artifacts"] = manifest
            task["artifactFiles"] = artifact_files
    return manifest


def _set_task(task_id: str, **kwargs: Any) -> None:
    with TASKS_LOCK:
        task = TASKS.get(task_id, {})
        task.update(kwargs)
        TASKS[task_id] = task
        save_task(Path(settings.MATLAB_TASK_WORK_DIR), task_id, task)


def _get_task(task_id: str) -> Optional[Dict[str, Any]]:
    with TASKS_LOCK:
        task = TASKS.get(task_id)
        if task is not None:
            return dict(task)
    # Reloads discard the process-local table, but never the task's original data.
    try:
        root = Path(settings.MATLAB_TASK_WORK_DIR)
        directory = task_directory(root, task_id)
        task = load_task(root, task_id)
        if task and task.get("status") in {"completed", "failed", "cancelled"}:
            with TASKS_LOCK:
                TASKS[task_id] = task
            return dict(task)
        result_path = directory / "result.json"
        code_path = directory / "generated_workflow.jl"
        if result_path.is_file() and code_path.is_file():
            raw = json.loads(result_path.read_text(encoding="utf-8"))
            if isinstance(raw, dict) and raw.get("success") is True:
                result = JULIA_MATLAB_EXECUTOR.completed_result(raw, code_path.read_text(encoding="utf-8"))
                _set_task(task_id, taskId=task_id, status="completed", progress=100,
                          engineType="matlab", resultFileUrl=None)
                artifacts = _collect_matlab_artifacts(task_id, result)
                public = project_result_data(result["resultData"], artifacts)
                public["artifacts"] = artifacts
                _set_task(task_id, resultData=public)
                with TASKS_LOCK:
                    return dict(TASKS[task_id])
        if task:
            task.update(status="failed", progress=100,
                        errorMessage="仿真服务重启，任务已中断；请重新提交")
            _set_task(task_id, **task)
            with TASKS_LOCK:
                return dict(TASKS[task_id])
    except (ValueError, OSError) as exc:
        logger.warning("读取任务状态失败 taskId={}: {}", task_id, exc)
    return None


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

    model_code = request.modelCode or ""
    simulation_params = request.simulationParams or SimulationParams()
    model_name = _extract_model_name(model_code)
    model_path = os.path.join(work_dir, "GeneratedModel.mo")
    mos_path = os.path.join(work_dir, "simulate.mos")

    with open(model_path, "w", encoding="utf-8") as f:
        f.write(model_code)

    mos_script = _build_mos_script(model_name, work_dir, simulation_params)
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
        if request.engineType == "matlab":
            execution_payload = request.executionPayload or {}
            result = await asyncio.to_thread(
                JULIA_MATLAB_EXECUTOR.execute,
                task_id,
                execution_payload,
            )
        else:
            result = await asyncio.to_thread(_run_openmodelica, task_id, request)
        if request.engineType == "matlab":
            # Keep graph outputs for the result view, while exposing only the
            # path-free artifact manifest to clients.
            artifacts = _collect_matlab_artifacts(task_id, result)
            result_data = result.get("resultData")
            if isinstance(result_data, dict):
                result["resultData"] = project_result_data(result_data, artifacts)
                result_data = result["resultData"]
                result_data["artifacts"] = artifacts
        _set_task(
            task_id,
            status="completed",
            progress=100,
            endTime=datetime.now().isoformat(),
            resultData=result.get("resultData"),
            resultFileUrl=result.get("resultFileUrl"),
        )
    except GraphExecutionError as e:
        logger.exception("仿真任务失败 taskId={}", task_id)
        # matlab-public-result-v1：失败投影固定携带版本与状态，
        # 结构化错误放入 error 字段（后端对 errorDetail 原样透传）。
        _set_task(
            task_id,
            status="failed",
            progress=100,
            endTime=datetime.now().isoformat(),
            errorMessage=str(e),
            errorDetail={
                "schemaVersion": "matlab.public-result.v1",
                "status": "failed",
                "error": e.structured(),
            },
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
    try:
        task_directory(Path(settings.MATLAB_TASK_WORK_DIR), task_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="任务ID不合法")
    _set_task(
        task_id,
        taskId=task_id,
        status="pending",
        progress=0,
        createTime=datetime.now().isoformat(),
        resultData=None,
        resultFileUrl=None,
        errorMessage=None,
        artifacts=[],
        artifactFiles={},
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
    # The relative-path registry is an internal capability for the binary
    # endpoint and must never be serialized in the status response.
    task.pop("artifactFiles", None)
    return task


@app.get("/api/v1/simulation/tasks/{task_id}/artifacts/{artifact_id}")
async def get_simulation_artifact(task_id: str, artifact_id: str):
    """Serve a previously indexed PNG without accepting a filesystem path."""
    task = _get_task(task_id)
    if task is None:
        raise HTTPException(status_code=404, detail="任务不存在")
    artifact_files = task.get("artifactFiles")
    if not isinstance(artifact_files, dict) or artifact_id not in artifact_files:
        raise HTTPException(status_code=404, detail="图片产物不存在")
    relative_path = artifact_files[artifact_id].get("relativePath")
    if (not isinstance(relative_path, str)
            or not relative_path.lower().endswith(".png")
            or not relative_path.replace("\\", "/").startswith("plots/")):
        raise HTTPException(status_code=404, detail="图片产物不存在")
    task_root = (Path(settings.MATLAB_TASK_WORK_DIR).resolve() / task_id).resolve()
    candidate = (task_root / PurePath(relative_path)).resolve()
    try:
        candidate.relative_to(task_root)
    except ValueError:
        raise HTTPException(status_code=404, detail="图片产物不存在")
    if not candidate.is_file():
        raise HTTPException(status_code=404, detail="图片产物不存在")
    return FileResponse(candidate, media_type="image/png")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.API_HOST,
        port=settings.API_PORT,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower()
    )
