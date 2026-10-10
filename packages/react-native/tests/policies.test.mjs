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
