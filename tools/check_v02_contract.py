#!/usr/bin/env python3
"""Dependency-free structural/implementation audit for Native Motion v0.2.

This checker deliberately DOES NOT claim device accessibility or visual QA.
It verifies the inventory, target count, file paths, semantic motion intents,
and baseline token references against the working repository.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "design" / "v0.2-component-contract.json"
PLAN = ROOT / "plan" / "0.2.md"
REQUIRED_INTENTS = ["responsive", "gentle", "morph", "settle"]
VALID_STATUSES = {"available", "planned"}
RENDERERS = {"swiftui", "flutter", "compose"}


def ensure(condition: bool, detail: str) -> None:
    if not condition:
        raise ValueError(detail)


def main() -> None:
    doc = json.loads(CATALOG.read_text(encoding="utf-8"))
    plan = PLAN.read_text(encoding="utf-8")
    ensure(doc.get("releaseTarget") == "v0.2.0", "Unexpected version target")
    ensure(doc.get("status") == "work-in-progress", "Target is not a released version")
    ensure(doc.get("countRule") == "conceptual-components-not-renderer-implementations", "Wrong counting rule")
    ensure(doc.get("motionIntents") == REQUIRED_INTENTS, "Motion intent contract changed")
    ensure(len(doc.get("completionRequires", [])) >= 5, "Missing release gates")
    references = doc["colorReference"]
    ensure(references.get("policy") == "exact-semantic-role-parity", "Wrong token contract")
    for key in ("light", "dark"):
        ensure((ROOT / references[key]).is_file(), f"Missing {key} token reference")

    components = doc.get("components", [])
    ensure(len(components) == 25, f"Expected 25 conceptual components, got {len(components)}")
    names = [component["name"] for component in components]
    ensure(len(set(names)) == len(names), "Duplicate component names")

    plan_entries = [
        (int(identifier), name)
        for identifier, name in re.findall(
            r"^\\|\\s*(\\d+)\\s*\\|[^\\n]*?\\|\\s*`(Motion[A-Za-z0-9]+)`\\s*\\|",
            plan,
            flags=re.MULTILINE,
        )
    ]
    ensure(len(plan_entries) == 25, f"Plan has {len(plan_entries)} indexed components")
    ensure(plan_entries == [(c["id"], c["name"]) for c in components],
           "Inventory order or identifiers differ from plan/0.2.md")

    counts = {renderer: 0 for renderer in RENDERERS}
    for idx, component in enumerate(components, 1):
        ensure(component["id"] == idx, f"Gap at component {idx}")
        ensure(re.fullmatch(r"Motion[A-Za-z0-9]+", component["name"]) is not None,
               f"Invalid name for {idx}")
        ensure(component["states"] and len(set(component["states"])) == len(component["states"]),
               f"State contract is missing or duplicated for {component['name']}")
        renderers = component["renderers"]
        ensure(set(renderers) == RENDERERS, f"Renderer list inconsistent for {component['name']}")
        for renderer, info in renderers.items():
            state = info.get("implementation")
            ensure(state in VALID_STATUSES, f"Unknown status: {renderer} {component['name']}")
            source = info.get("source")
            if state == "available":
                ensure(isinstance(source, str) and source and (ROOT / source).is_file(),
                       f"Claimed available without source: {renderer} {component['name']}")
                ensure(info.get("validation") in {"automated-only", "device-verified"},
                       f"No verification status: {renderer} {component['name']}")
                counts[renderer] += 1
            else:
                ensure(source is None and info.get("validation") == "not-run",
                       f"Planned item falsely claims source/verification: {renderer} {component['name']}")
    print(f"v0.2 draft contract OK: {len(components)} names; "
          + ", ".join(f"{platform}={counts[platform]}" for platform in sorted(counts))
          + " (available != device-verified)")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError, TypeError, OSError, json.JSONDecodeError) as exc:
        print(f"v0.2 contract FAILED: {exc}", file=sys.stderr)
        sys.exit(1)
