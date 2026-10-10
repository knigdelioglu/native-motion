#!/usr/bin/env python3
"""Verify 25 native source files/exports and Swift semantic token parity."""
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
repo=ROOT/'packages/react-native'
contract=json.loads((ROOT/'design/v0.2-component-contract.json').read_text())
components=contract['components']
assert len(components)==25 and len({x['name'] for x in components})==25
exports=(repo/'src/index.ts').read_text()
for item in components:
    name=item['name']
    source=repo/'src'/f'{name}.tsx'
    assert source.is_file(), name+' missing implementation'
    assert re.search(r'export function '+name+r'\b',source.read_text()), name+' missing React Native implementation'
    assert re.search(r'export \{ '+name+r' \}',exports), name+' missing public export'
    renderer=item['renderers']['react_native']
    assert renderer['source']==f'packages/react-native/src/{name}.tsx'
    assert renderer['implementation']=='available'
    assert renderer['validation']=='automated-only'
assert len(list((repo/'src').glob('Motion*.tsx')))==25
theme=(repo/'src/theme.ts').read_text()
roles=('background','surface','elevatedSurface','primaryText','secondaryText','accent','accentText','border','success','warning','danger')
for appearance in ('light','dark'):
    fixture=(ROOT/f'Tests/NativeMotionTests/Snapshots/tokens-{appearance}.txt').read_text()
    for role in roles:
        match=re.search(r'^'+role+r'=(#[0-9A-F]{6})$',fixture,re.M)
        assert match and f"{role}:'{match.group(1)}'" in theme, appearance+' '+role+' token drift'
print('React Native renderer inventory PASS: 25 source components, 25 exports, light/dark tokens')
