import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "release_metadata", Path(__file__).with_name("verify_release_metadata.py"))
metadata = importlib.util.module_from_spec(spec)
spec.loader.exec_module(metadata)


class ReleaseMetadataTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "docs").mkdir()
        entries = []
        for name, version, stage in [
            ("widgets", "1.0.0-rc.1", "candidate"),
            ("updates", "0.8.0-dev.0", "development"),
            ("fuzz", "0.1.0-dev.0", "experimental"),
        ]:
            entries.append(dict(name=name, path=name, group="app-library", stage=stage))
            (self.root / name).mkdir()
            (self.root / name / "pubspec.yaml").write_text(f"name: {name}\nversion: {version}\n")
            (self.root / name / "CHANGELOG.md").write_text(
                f"## {version} - 2026-10-16\n" if name == "widgets" else "## Unreleased\n")
        (self.root / "docs/package-catalog.json").write_text(json.dumps({"packages": entries}))

    def test_mixed_versions_are_valid_on_main_and_develop(self):
        for ref in ["main", "develop", "feat/versioning"]:
            self.assertEqual(metadata.validate(self.root, ref), [])

    def test_release_selects_only_one_package_and_requires_notes(self):
        self.assertEqual(metadata.validate(self.root, "release/widgets/1.0.0-rc.1"), [])
        self.assertEqual(metadata.validate(self.root, "widgets/v1.0.0-rc.1"), [])
        self.assertTrue(metadata.validate(self.root, "widgets/v1.0.0"))
        self.assertTrue(metadata.validate(self.root, "updates/v0.8.0-dev.0"))

    def test_legacy_integration_branch_accepts_independent_versions(self):
        self.assertEqual(metadata.validate(self.root, "release/0.7.0"), [])
        # Only this existing integration branch is allowed, not arbitrary
        # workspace release branches or new global release tags.
        for ref in ["release/0.8.0", "release/1.0.0", "v0.7.0"]:
            self.assertTrue(metadata.validate(self.root, ref), ref)

    def test_integration_branch_still_checks_every_package(self):
        (self.root / "fuzz/pubspec.yaml").write_text("name: fuzz\nversion: 1.0.0\n")
        (self.root / "updates/CHANGELOG.md").write_text("No version notes\n")
        errors = metadata.validate(self.root, "release/0.7.0")
        self.assertTrue(any("experimental" in error for error in errors))
        self.assertTrue(any("updates: add a dated" in error for error in errors))

    def test_integration_exception_does_not_relax_package_release_notes(self):
        self.assertEqual(metadata.validate(self.root, "release/0.7.0"), [])
        self.assertTrue(metadata.validate(self.root, "release/updates/0.8.0-dev.0"))
        self.assertTrue(metadata.validate(self.root, "release/widgets/1.0.0"))

    def test_wrong_name_or_stage_does_not_pass(self):
        (self.root / "fuzz/pubspec.yaml").write_text("name: something_else\nversion: 1.0.0\n")
        errors = metadata.validate(self.root, "main")
        self.assertTrue(any("name does not match" in error for error in errors))
        self.assertTrue(any("experimental" in error for error in errors))

    def test_catalog_cannot_escape_root_or_repeat_a_package(self):
        catalog = self.root / "docs/package-catalog.json"
        entries = json.loads(catalog.read_text())["packages"]
        entries.append(entries[0])
        entries[1]["path"] = "../outside"
        catalog.write_text(json.dumps({"packages": entries}))
        errors = metadata.validate(self.root, "main")
        self.assertTrue(any("duplicate" in error for error in errors))
        self.assertTrue(any("root-level" in error for error in errors))

    def test_stable_promotion_requires_an_explicit_maturity_decision(self):
        (self.root / "updates/pubspec.yaml").write_text("name: updates\nversion: 1.0.0\n")
        (self.root / "updates/CHANGELOG.md").write_text("## 1.0.0 - 2026-10-16\n")
        self.assertTrue(metadata.validate(self.root, "updates/v1.0.0"))
        catalog = self.root / "docs/package-catalog.json"
        entries = json.loads(catalog.read_text())["packages"]
        entries[1]["stage"] = "stable"
        catalog.write_text(json.dumps({"packages": entries}))
        self.assertEqual(metadata.validate(self.root, "updates/v1.0.0"), [])

    def test_malformed_version_and_workspace_release_are_rejected(self):
        (self.root / "updates/pubspec.yaml").write_text("name: updates\nversion: 01.0.0\n")
        self.assertTrue(metadata.validate(self.root, "main"))
        self.assertTrue(metadata.validate(self.root, "release/1.0.0"))
        self.assertTrue(metadata.validate(self.root, "v1.0.0"))


if __name__ == "__main__":
    unittest.main()
