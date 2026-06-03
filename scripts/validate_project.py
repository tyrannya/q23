#!/usr/bin/env python3
"""Lightweight repository validation for the INVERTED Rojo demo.

The script intentionally avoids Roblox-specific execution. It checks the parts
that can be validated in CI or a bare container: JSON syntax, required project
paths, unresolved merge conflict markers, and basic Luau delimiter balance.
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONFLICT_MARKERS = ("<" * 7, "=" * 7, ">" * 7)
REQUIRED_FILES = (
    "default.project.json",
    "README.md",
    "src/shared/Config.luau",
    "src/shared/Signals.luau",
    "src/client/MovementController.client.luau",
    "src/client/ObjectiveUI.client.luau",
    "src/server/LevelBuilder.server.luau",
    "src/server/ObjectiveService.server.luau",
)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def validate_default_project() -> None:
    project_path = ROOT / "default.project.json"
    project = json.loads(read_text(project_path))

    tree = project.get("tree", {})
    assert project.get("name") == "inverted-demo", "Unexpected Rojo project name"
    assert tree.get("$className") == "DataModel", "Rojo tree must map to DataModel"
    assert tree["ReplicatedStorage"]["Shared"]["$path"] == "src/shared"
    assert tree["ServerScriptService"]["Server"]["$path"] == "src/server"
    assert tree["StarterPlayer"]["StarterPlayerScripts"]["$path"] == "src/client"

    watch_ui = tree["StarterGui"]["WatchUI"]
    assert watch_ui["$className"] == "ScreenGui"
    assert watch_ui["$properties"]["ResetOnSpawn"] is False
    assert watch_ui["$properties"]["IgnoreGuiInset"] is True


def validate_required_files() -> None:
    missing = [relative for relative in REQUIRED_FILES if not (ROOT / relative).is_file()]
    assert not missing, f"Missing required files: {missing}"


def validate_no_conflict_markers() -> None:
    checked_suffixes = {".json", ".md", ".luau", ".py"}
    for path in ROOT.rglob("*"):
        if ".git" in path.parts or not path.is_file() or path.suffix not in checked_suffixes:
            continue

        text = read_text(path)
        for marker in CONFLICT_MARKERS:
            assert marker not in text, f"Unresolved merge conflict marker {marker!r} in {path.relative_to(ROOT)}"


def validate_luau_delimiters() -> None:
    for path in (ROOT / "src").rglob("*.luau"):
        text = read_text(path)
        assert text.count("(") >= text.count(")"), f"Suspicious parenthesis balance in {path.relative_to(ROOT)}"
        assert text.count("{") >= text.count("}"), f"Suspicious brace balance in {path.relative_to(ROOT)}"


def main() -> None:
    validate_required_files()
    validate_default_project()
    validate_no_conflict_markers()
    validate_luau_delimiters()
    print("INVERTED project validation passed")


if __name__ == "__main__":
    main()
