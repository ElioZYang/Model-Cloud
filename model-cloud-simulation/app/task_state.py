"""Task-local status snapshots survive development server reloads."""
import json
import re
from pathlib import Path
from typing import Any


def task_directory(root: Path, task_id: str) -> Path:
    if not re.fullmatch(r"[A-Za-z0-9_-]{1,128}", task_id):
        raise ValueError("Invalid task ID")
    return root.resolve() / task_id


def save_task(root: Path, task_id: str, task: dict[str, Any]) -> None:
    directory = task_directory(root, task_id)
    directory.mkdir(parents=True, exist_ok=True)
    pending = directory / "task_status.tmp"
    pending.write_text(json.dumps(task, ensure_ascii=False), encoding="utf-8")
    pending.replace(directory / "task_status.json")


def load_task(root: Path, task_id: str) -> dict[str, Any] | None:
    directory = task_directory(root, task_id)
    path = directory / "task_status.json"
    if not path.is_file():
        return None
    task = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(task, dict) or task.get("taskId") != task_id:
        raise ValueError("Invalid task status snapshot")
    return task
