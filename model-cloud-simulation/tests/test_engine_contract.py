import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
ENGINE_ROOT = ROOT / "model-cloud-backend" / "src" / "main" / "resources" / "static" / "matlab_component_source" / "engine" / "src"
CATALOG_DIR = ROOT / "model-cloud-backend" / "src" / "main" / "resources" / "matlab-components" / "engine"
CATALOG_DIRECTORIES = ["physical", "stages", "workflows", "configurations"]


def _load_catalog():
    """按生产读取顺序聚合单文件发动机组件定义。"""
    entries = []
    for directory in CATALOG_DIRECTORIES:
        for definition_path in sorted((CATALOG_DIR / directory).glob("*.json")):
            definition = json.loads(definition_path.read_text(encoding="utf-8"))
            entries.append(definition)
    return entries


CATALOG = _load_catalog()


class EngineContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.catalog = CATALOG
        cls.by_id = {item["id"]: item for item in cls.catalog}

    def test_three_configuration_entries_are_recursive_templates(self):
        expected_components = {
            "engine.configuration.ducted-fan": ["inlet", "lpc", "nozzle"],
            "engine.configuration.turboshaft": ["inlet", "duct", "hpc", "burn", "hpt", "nozzle"],
            "engine.configuration.mixed-turbofan": [
                "inlet", "duct", "fan", "outer duct", "hpc", "burn", "hpt",
                "mixer", "afterburn", "nozzle",
            ],
        }
        for component_id, legacy_order in expected_components.items():
            entry = self.by_id[component_id]
            self.assertEqual(entry["componentKind"], "subsystem")
            self.assertNotIn("engine.model", [item["type"] for item in entry["outputs"]])
            template = entry["templateDefinition"]
            workflow = template["scenes"][template["rootSceneId"]]
            design_node = next(node for node in workflow["nodes"]
                               if node["id"] == "design_point")
            design = template["scenes"][design_node["childSceneId"]]
            physical_node = next(node for node in design["nodes"]
                                 if node["componentId"] == "project.subsystem.engine-assembly")
            self.assertEqual(physical_node["nodeKind"], "subsystem")
            physical = template["scenes"][physical_node["childSceneId"]]
            self.assertNotIn("kind", physical)
            self.assertTrue(template["physicalAssemblies"])
            member_ids = next(iter(template["physicalAssemblies"].values()))["memberNodeIds"]
            ordered = sorted(
                (node for scene in template["scenes"].values() for node in scene["nodes"]
                 if node["id"] in member_ids),
                key=lambda node: node["legacyOrder"],
            )
            self.assertEqual([node["legacyName"] for node in ordered], legacy_order)
            self.assertEqual(
                [item["name"] for item in entry["outputs"]],
                ["DP", "XD", "MISSION_power", "MISSION_final",
                 "design_plot", "power_plot", "final_plot", "MISSION",
                 "THRUST_ARRAY", "TIT_ARRAY", "COMP_WP", "TURB_WP",
                 "MOTOR_WP", "OP", "X0", "DX"],
            )

    def test_engine_catalog_uses_consistent_display_hierarchy(self):
        expected_configurations = {
            "engine.configuration.ducted-fan": "涵道风扇",
            "engine.configuration.turboshaft": "涡轴发动机",
            "engine.configuration.mixed-turbofan": "混排涡扇",
        }
        expected_workflow_nodes = ["设计点模型", "工况扫描", "特性图绘制"]
        expected_scan_nodes = [
            "非设计点初始化", "功率扫描", "速度扫描重置",
            "速度扫描", "高度扫描", "扫描结果汇总",
        ]
        expected_plot_nodes = ["设计点气路图", "功率扫描特性图", "全工况特性图"]
        for component_id, display_name in expected_configurations.items():
            entry = self.by_id[component_id]
            self.assertEqual(entry["name"], display_name)
            self.assertEqual(entry["category"], "发动机构型")
            scenes = entry["templateDefinition"]["scenes"]
            self.assertEqual(
                [node["instanceName"] for node in scenes["workflow"]["nodes"]],
                expected_workflow_nodes,
            )
            self.assertEqual(
                [node["instanceName"] for node in scenes["scan"]["nodes"]],
                expected_scan_nodes,
            )
            self.assertEqual(
                [node["instanceName"] for node in scenes["plot"]["nodes"]],
                expected_plot_nodes,
            )
            for node in scenes["physical"]["nodes"]:
                self.assertTrue(node["instanceName"].strip())

        self.assertTrue(all(
            entry["category"] == "气路组件"
            for entry in self.catalog
            if entry["id"].startswith("engine.gas-path.")
        ))
        self.assertEqual(self.by_id["engine.configuration.design-point"]["name"], "设计点模型")
        self.assertEqual(self.by_id["engine.configuration.envelope-scan"]["name"], "工况扫描")
        self.assertEqual(self.by_id["engine.configuration.plot"]["name"], "特性图绘制")
        self.assertEqual(self.by_id["engine.workflow.envelope-scan"]["name"], "整段工况扫描")

    def test_stage_envelope_and_plot_entries_use_raw_structures(self):
        for component_id in (
            "engine.stage.initialize-configuration",
            "engine.stage.apply-design-conditions",
            "engine.stage.solve-design-point",
            "engine.plot.flow",
            "engine.plot.map-mission",
        ):
            entry = self.by_id[component_id]
            self.assertTrue((ENGINE_ROOT / entry["sourceRelativePath"]).is_file())
        entry = self.by_id["engine.workflow.envelope-scan"]
        self.assertEqual(entry["functionName"], "component_run_engine_envelope")
        self.assertEqual(entry["inputs"][0]["name"], "DP")
        self.assertEqual(
            [item["name"] for item in entry["outputs"]],
            ["MISSION", "THRUST_ARRAY", "TIT_ARRAY", "COMP_WP", "TURB_WP",
             "MOTOR_WP", "OP", "X0", "DX"],
        )
        self.assertTrue((ENGINE_ROOT / entry["sourceRelativePath"]).is_file())
        self.assertEqual(self.by_id["engine.plot.flow"]["inputs"][-1]["name"], "phase")
        self.assertEqual(self.by_id["engine.plot.flow"]["inputs"][-1]["defaultValue"], "design")
        self.assertEqual(self.by_id["engine.plot.map-mission"]["inputs"][-1]["name"], "phase")
        self.assertEqual(self.by_id["engine.plot.map-mission"]["inputs"][-1]["defaultValue"], "final")

    def test_legacy_resources_are_packaged(self):
        required = [
            "Input/INPUT_DESIGN_PARAMETERS.m",
            "Input/INPUT_ELECTRIC.m",
            "Input/pmsm input.xlsx",
            "Input/Component Map Input.xlsx",
            "Mainprogram-v1/BALANCE_FUNCTION_DESIGN.m",
            "Mainprogram-v1/BALANCE_FUNCTION_OFFDESIGN.m",
            "Mainprogram-v1/DESIGN.m",
            "Mainprogram-v1/OFFDESIGN.m",
            "Map Collection/COMPRESSOR/COMPRESSOR.xlsx",
            "Map Collection/TURBINE/TURBINE.xlsx",
        ]
        for relative in required:
            self.assertTrue((ENGINE_ROOT / relative).is_file(), relative)

    def test_obsolete_engine_model_entry_points_are_removed(self):
        obsolete = [
            "workflows/component_create_ducted_fan_model.m",
            "workflows/component_create_turboshaft_model.m",
            "workflows/component_create_mixed_turbofan_model.m",
            "workflows/engine_build_model.m",
            "workflows/engine_prepare_dp.m",
            "workflows/engine_public_model.m",
        ]
        for relative in obsolete:
            self.assertFalse((ENGINE_ROOT / relative).exists(), relative)
        runner = (ROOT / "model-cloud-simulation" / "julia" / "run_matlab_graph.jl").read_text(encoding="utf-8")
        self.assertNotIn('output_type == "engine.model"', runner)


if __name__ == "__main__":
    unittest.main()
