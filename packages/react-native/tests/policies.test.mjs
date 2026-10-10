import test from 'node:test';
import assert from 'node:assert/strict';
import {toggle,nextCheckbox,uniqueIds,canChoose,clampFraction,range,decimalInput,stepAllowed} from '../src/policies.ts';
test('binary and mixed selection transitions are intentional',()=>{
 assert.equal(toggle(true),false);assert.equal(nextCheckbox('mixed'),'checked');
 assert.equal(nextCheckbox('checked'),'unchecked');
 assert.equal(uniqueIds(['a','b']),true);assert.equal(uniqueIds(['a','a']),false);
});
test('host selection is never silently overwritten',()=>{
 const enabled=new Set(['all','active']);
 assert.equal(canChoose('active','all',enabled),true);
 assert.equal(canChoose('all','all',enabled),false);
 assert.equal(canChoose('blocked','all',enabled),false);
 assert.equal(canChoose('active','all',enabled,false),false);
});
test('progress rejects nonfinite and clamps bounded input',()=>{
 assert.equal(clampFraction(Number.NaN),null);assert.equal(clampFraction(null),null);
 assert.equal(clampFraction(-2),0);assert.equal(clampFraction(5),1);
});
test('slider preserves short terminal step and avoids invalid values',()=>{
 const s=range(0,95,10);
 assert.equal(s.snap(93),95);assert.equal(s.adjacent(90,1),95);
 assert.equal(s.adjacent(95,-1),90);assert.equal(s.snap(Number.NaN),0);
});
test('strict locale numbers do not silently parse invalid text',()=>{
 assert.equal(decimalInput('2,25','tr-TR',0,10,0.25),2.25);
 assert.equal(decimalInput('2.25','tr-TR',0,10,0.25),null);
 assert.equal(decimalInput('abc','en-US',0,10,1),null);
 assert.equal(decimalInput('1e5','en-US',0,10,1),null);
});
test('workflow steps remain pending without explicit completion',()=>{
 const ids=['choose','review','send'], done=new Set(['choose']),disabled=new Set();
 assert.equal(stepAllowed('send','review',ids,done,disabled,false),false);
 assert.equal(stepAllowed('choose','review',ids,done,disabled,false),true);
 assert.equal(stepAllowed('send','review',ids,done,disabled,true),true);
});

import {toggleDisclosure,uniqueDisclosureIds} from '../src/disclosurePolicies.ts';
test('v0.5 single accordion closes the previously expanded item',()=>{
 assert.deepEqual(toggleDisclosure('b',['a'],new Set(['a','b']),false),['b']);
 assert.deepEqual(toggleDisclosure('b',['b'],new Set(['a','b']),false),[]);
});
test('v0.5 multiple accordion retains independent expansion',()=>{
 assert.deepEqual(toggleDisclosure('b',['a'],new Set(['a','b']),true),['a','b']);
 assert.deepEqual(toggleDisclosure('a',['a','b'],new Set(['a','b']),true),['b']);
});
test('v0.5 disabled and missing entries cannot mutate host state',()=>{
 const ids=new Set(['a']);
 assert.deepEqual(toggleDisclosure('missing',['a'],ids,false),['a']);
 assert.deepEqual(toggleDisclosure('a',['a'],ids,false,false),['a']);
 assert.equal(uniqueDisclosureIds(['a','b']),true);
 assert.equal(uniqueDisclosureIds(['a','a']),false);
});

import {
  canOpenSurface, canDismissSurface, shouldDismissDrag,
  nextSheetDetent, heightFraction,
} from '../src/surfacePolicies.ts';

test('v0.5 overlay visibility is host controlled and busy-safe', () => {
 assert.equal(canOpenSurface(true,false),true);
 assert.equal(canOpenSurface(true,true),false);
 assert.equal(canOpenSurface(false,false),false);
 assert.equal(canDismissSurface(true,true),false);
 assert.equal(canDismissSurface(true,false),true);
 assert.equal(canDismissSurface(false,false),false);
});
test('v0.5 bottom detent and drag steps never auto-complete work', () => {
 assert.equal(shouldDismissDrag(120,false),true);
 assert.equal(shouldDismissDrag(90,false),false);
 assert.equal(shouldDismissDrag(200,true),false);
 assert.equal(nextSheetDetent('expanded',true),'medium');
 assert.equal(nextSheetDetent('medium',true),'compact');
 assert.equal(nextSheetDetent('compact',true),null);
 assert.equal(nextSheetDetent('compact',false),'medium');
 assert.equal(nextSheetDetent('expanded',false),'expanded');
 assert.ok(heightFraction('compact')<heightFraction('medium'));
 assert.ok(heightFraction('medium')<heightFraction('expanded'));
});
