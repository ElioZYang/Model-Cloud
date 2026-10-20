import tempfile
import unittest
from pathlib import Path

from app.artifacts import collect_artifacts, project_result_data


class ArtifactManifestTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_manifest_is_task_scoped_and_served_by_id(self):
        task_id = "task-1"
        task_root = Path(self.temp_dir.name) / task_id
        plot_dir = task_root / "plots"
        plot_dir.mkdir(parents=True)
        image = plot_dir / "design.png"
        image.write_bytes(b"PNG")
        result = {
            "resultData": {
                "nodeResults": {
                    "design_plot": {
                        "functionName": "component_engine_plot_flow",
                        "outputs": {"plot_result": {"files": [{
                            "id": "design:design.png", "phase": "design",
                            "fileName": "design.png", "source": "PLOTFLOW",
                            "path": str(image),
                        }]}},
                    }
                }
            }
        }
        manifest, artifact_files = collect_artifacts(task_id, result, task_root)
        self.assertEqual(len(manifest), 1)
        item = manifest[0]
        self.assertEqual(set(item), {"id", "phase", "fileName", "source"})
        self.assertEqual(item["phase"], "design")
        self.assertEqual(item["fileName"], "design.png")
        self.assertEqual(item["source"], "PLOTFLOW")
        self.assertNotIn(str(task_root), str(item))

        self.assertEqual(artifact_files[item["id"]], {"relativePath": "plots/design/design.png"})
        self.assertEqual((task_root / "plots" / "design" / "design.png").read_bytes(), b"PNG")
        projected = project_result_data(result["resultData"], manifest)
        self.assertNotIn(str(task_root), str(projected))
        self.assertEqual(projected["nodeResults"]["design_plot"]["outputs"]["plot_result"]["artifacts"], manifest)
        public = project_result_data({
            "publicOutputs": {
                "design_plot": {"value": {
                    "function": "PLOTFLOW", "phase": "design",
                    "output_directory": str(task_root),
                    "files": [{"path": str(image), "fileName": "design.png"}],
                }}
            }
        }, manifest)
        self.assertNotIn(str(task_root), str(public))

    def test_unknown_id_and_traversal_are_rejected(self):
        task_id = "task-2"
        task_root = Path(self.temp_dir.name) / task_id
        task_root.mkdir(parents=True)
        outside = Path(self.temp_dir.name) / "outside.png"
        outside.write_bytes(b"PNG")
        manifest, artifact_files = collect_artifacts(
            task_id, {"resultData": {}}, task_root
        )
        self.assertEqual(manifest, [])
        self.assertEqual(artifact_files, {})


if __name__ == "__main__":
    unittest.main()
