#!/usr/bin/env python3
"""v0.5 cross-renderer source evidence; never implies real-device approval."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]
doc = json.loads((ROOT / "design/v0.5-component-contract.json").read_text())
old = json.loads((ROOT / doc["baseInventory"]).read_text())
plan = (ROOT / "plan/0.5.md").read_text()
assert doc["releaseTarget"] == "v0.5.0" and doc["status"] == "in-development"
assert doc["baseCount"] == len(old["components"]) == 25 and doc["targetCount"] == 55
assert doc["countRule"] == old["countRule"]
items = doc["components"]
assert len(items) == 30 and len({x["name"] for x in items}) == 30
assert set(x["name"] for x in items).isdisjoint(x["name"] for x in old["components"])
plan_items = []
for line in plan.splitlines():
    cells = [s.strip() for s in line.split("|")[1:-1]]
    if len(cells) > 2 and cells[0].isdigit() and re.fullmatch(r"`Motion[A-Za-z0-9]+`",cells[2]):
        plan_items.append((int(cells[0]),cells[2].strip("`")))
assert len(plan_items) == 30, f"Expected 30 v0.5 plan rows; found {len(plan_items)}"
assert plan_items == [(x["id"],x["name"]) for x in items]
renderers = set(doc["requiredRenderers"])
assert renderers == {"swiftui","flutter","react_native","compose"}
counts = {k:0 for k in renderers}
rn_exports = (ROOT / "packages/react-native/src/index.ts").read_text()
flutter_exports = (ROOT / "packages/flutter/lib/native_motion.dart").read_text()
for item in items:
    assert set(item["renderers"]) == renderers
    for platform, spec in item["renderers"].items():
        state, path = spec["implementation"], spec["source"]
        if state == "planned":
            assert path is None and spec["validation"] == "not-run"
            continue
        assert state == "available" and spec["validation"] in {"automated-only","device-verified"}
        assert isinstance(path,str) and (ROOT/path).is_file(), (platform,item["name"],path)
        counts[platform] += 1
        if platform == "react_native":
            assert re.search(r"export\s+(?:function|const)\s+"+item["name"]+r"\b",(ROOT/path).read_text())
            assert "export { "+item["name"]+" }" in rn_exports
        if platform == "flutter":
            assert "export '"+str(Path(path).relative_to("packages/flutter/lib"))+"';" in flutter_exports
print("v0.5 incremental contract PASS (26–55): "+", ".join(
    f"{name}={counts[name]}" for name in sorted(counts)
)+". Existing v0.2 base=25. Source != device QA.")
