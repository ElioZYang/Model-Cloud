"""Task-scoped MATLAB image artifact indexing."""

from __future__ import annotations

import hashlib
import re
import shutil
import tempfile
import copy
from pathlib import Path
from typing import Any


def _walk_png_references(value: Any, *, node_id: str = "", function_name: str = "",
                         phase: str = "", allow_path: bool = False) -> list[dict[str, str]]:
    references: list[dict[str, str]] = []
    if isinstance(value, dict):
        next_phase = str(value.get("phase") or phase or "").strip()
        next_function = str(value.get("source") or value.get("function")
                            or function_name or "").strip()
        next_node = str(value.get("sourceNodeId") or node_id or "").strip()
        for key, child in value.items():
            # Only MATLAB plot wrapper file lists are capabilities. Other
            # string outputs are ordinary model data, even if they end in png.
            if key in {"files", "file"}:
                references.extend(_walk_png_references(
                    child, node_id=next_node, function_name=next_function,
                    phase=next_phase, allow_path=True
                ))
            elif allow_path and key == "path":
                references.extend(_walk_png_references(
                    child, node_id=next_node, function_name=next_function,
                    phase=next_phase, allow_path=True
                ))
        return references
    if isinstance(value, list):
        for child in value:
            references.extend(_walk_png_references(
                child, node_id=node_id, function_name=function_name,
                phase=phase, allow_path=allow_path
            ))
        return references
    if isinstance(value, str) and value.lower().endswith(".png"):
        references.append({"path": value, "nodeId": node_id,
                           "function": function_name, "phase": phase})
    return references


def _phase_for_artifact(relative_name: str, reference: dict[str, str]) -> str:
    explicit = str(reference.get("phase") or "").strip()
    if explicit:
        return explicit
    lower = relative_name.lower()
    for name in ("design", "power", "final", "speed", "altitude", "mission"):
        if name in lower:
            return name
    function_name = str(reference.get("function") or "").strip()
    if function_name == "component_engine_plot_flow":
        return "design"
    if function_name == "component_engine_plot_map_mission":
        return "mission"
    return str(reference.get("nodeId") or "matlab")


def collect_artifacts(task_id: str, result: dict[str, Any], task_root: Path) -> tuple[
    list[dict[str, str]], dict[str, dict[str, str]]
]:
    """Return public metadata and private relative paths for PNG outputs."""
    task_root = task_root.resolve()
    if not task_root.is_dir():
        return [], {}
    result_data = result.get("resultData") if isinstance(result, dict) else None
    references: list[dict[str, str]] = []
    if isinstance(result_data, dict) and isinstance(result_data.get("nodeResults"), dict):
        for node_id, node_result in result_data["nodeResults"].items():
            if not isinstance(node_result, dict):
                continue
            function_name = str(node_result.get("functionName") or "")
            if function_name not in {"component_engine_plot_flow", "component_engine_plot_map_mission"}:
                continue
            outputs = node_result.get("outputs")
            if not isinstance(outputs, dict) or not isinstance(outputs.get("plot_result"), dict):
                continue
            references.extend(_walk_png_references(
                outputs["plot_result"],
                node_id=str(node_result.get("sourceNodeId") or node_id),
                function_name=function_name,
                phase=str(node_result.get("phase") or ""),
            ))
    by_path: dict[str, dict[str, str]] = {}
    source_files: dict[str, Path] = {}
    allowed_external_root = Path(tempfile.gettempdir()).resolve()
    for reference in references:
        try:
            candidate = Path(reference["path"]).expanduser().resolve()
            if not candidate.is_file() or candidate.suffix.lower() != ".png":
                continue
            try:
                relative = candidate.relative_to(task_root).as_posix()
            except ValueError:
                # Plot wrappers use tempname(tempdir) by default. Only the OS
                # temp root is accepted for this external source case.
                candidate.relative_to(allowed_external_root)
                relative = "external/" + candidate.name
        except (OSError, RuntimeError, ValueError):
            continue
        by_path[relative] = reference
        source_files[relative] = candidate

    # Include files already written below the task directory, including
    # wrappers that were given an explicit task-local output directory.
    for candidate in task_root.rglob("*.png"):
        if not candidate.is_file():
            continue
        try:
            relative = candidate.resolve().relative_to(task_root).as_posix()
        except ValueError:
            continue
        source_files.setdefault(relative, candidate.resolve())

    manifest: list[dict[str, str]] = []
    artifact_files: dict[str, dict[str, str]] = {}
    used_destinations: set[str] = set()
    for relative, source in sorted(source_files.items()):
        reference = by_path.get(relative, {})
        phase = _phase_for_artifact(relative, reference)
        safe_phase = re.sub(r"[^A-Za-z0-9_-]+", "_", phase).strip("_") or "matlab"
        file_name = Path(relative).name
        destination = (task_root / "plots" / safe_phase / file_name).resolve()
        try:
            destination.relative_to(task_root.resolve())
        except ValueError:
            continue
        destination_key = destination.relative_to(task_root.resolve()).as_posix()
        if destination_key in used_destinations:
            stem = destination.stem
            suffix = destination.suffix
            destination = destination.with_name(
                f"{stem}-{hashlib.sha256(relative.encode('utf-8')).hexdigest()[:8]}{suffix}"
            )
            destination_key = destination.relative_to(task_root.resolve()).as_posix()
        used_destinations.add(destination_key)
        destination.parent.mkdir(parents=True, exist_ok=True)
        if source.resolve() != destination:
            shutil.copy2(source, destination)
        artifact_id = "artifact-" + hashlib.sha256(
            f"{task_id}:{destination_key}".encode("utf-8")
        ).hexdigest()[:24]
        manifest.append({
            "id": artifact_id,
            "phase": phase,
            "fileName": file_name,
            "source": str(reference.get("function") or reference.get("nodeId") or "matlab"),
        })
        artifact_files[artifact_id] = {"relativePath": destination_key}
    return manifest, artifact_files


def project_result_data(result_data: Any, manifest: list[dict[str, str]]) -> Any:
    """Remove MATLAB filesystem paths from plot outputs after indexing."""
    def project(value: Any) -> Any:
        if isinstance(value, dict):
            function_name = str(value.get("function") or "")
            if function_name in {"component_engine_plot_flow", "component_engine_plot_map_mission",
                                 "PLOTFLOW", "DRAW_MAP_MISSION"} \
                    and ("files" in value or "output_directory" in value):
                phase = str(value.get("phase") or "").strip()
                selected = [item for item in manifest if not phase or item["phase"] == phase]
                return {"artifacts": copy.deepcopy(selected)}
            projected = {}
            for key, child in value.items():
                if key == "plot_result" and isinstance(child, dict):
                    phase = str(child.get("phase") or value.get("phase") or "").strip()
                    selected = [item for item in manifest if not phase or item["phase"] == phase]
                    projected[key] = {"artifacts": copy.deepcopy(selected)}
                else:
                    projected[key] = project(child)
            return projected
        if isinstance(value, list):
            return [project(child) for child in value]
        return value
    return project(result_data)
