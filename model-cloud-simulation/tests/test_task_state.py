import json

import pytest

from app.task_state import load_task, save_task, task_directory


def test_roundtrip_completed_result_and_internal_artifact_registry(tmp_path):
    task = {"taskId": "task-1", "status": "completed", "resultData": {"DP": [None, 2]},
            "artifactFiles": {"image-1": {"relativePath": "plots/design/a.png"}}}
    save_task(tmp_path, "task-1", task)
    assert load_task(tmp_path, "task-1") == task
    assert not (tmp_path / "task-1" / "task_status.tmp").exists()


def test_no_snapshot_and_path_escape(tmp_path):
    assert load_task(tmp_path, "missing") is None
    with pytest.raises(ValueError):
        task_directory(tmp_path, "../other")


def test_reload_recovers_finished_matlab_data_without_reexecution(tmp_path, monkeypatch):
    from app import main
    monkeypatch.setattr(main.settings, "MATLAB_TASK_WORK_DIR", str(tmp_path))
    monkeypatch.setattr(main, "TASKS", {})
    root = task_directory(tmp_path, "done")
    root.mkdir()
    (root / "generated_workflow.jl").write_text("# original code", encoding="utf-8")
    (root / "result.json").write_text(json.dumps({"success": True, "nodeResults": {},
                                                  "publicOutputs": {"DP": {"value": [None, 3]}}}), encoding="utf-8")
    task = main._get_task("done")
    assert task["status"] == "completed"
    assert task["resultData"]["publicOutputs"]["DP"]["value"] == [None, 3]
    main.TASKS.clear()
    assert main._get_task("done")["status"] == "completed"


def test_reload_marks_unfinished_task_interrupted(tmp_path, monkeypatch):
    from app import main
    monkeypatch.setattr(main.settings, "MATLAB_TASK_WORK_DIR", str(tmp_path))
    monkeypatch.setattr(main, "TASKS", {})
    save_task(tmp_path, "running", {"taskId": "running", "status": "running", "errorMessage": None})
    task = main._get_task("running")
    assert task["status"] == "failed"
    assert "重启" in task["errorMessage"]
