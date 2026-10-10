// Pure, dependency-free contracts: no renderer, no timers, no implicit success.
export type CheckboxState = 'unchecked' | 'checked' | 'mixed';
export const toggle = (value:boolean):boolean => !value;
export function nextCheckbox(value:CheckboxState):CheckboxState {
  return value === 'checked' ? 'unchecked' : 'checked';
}
export function uniqueIds(ids:readonly string[]):boolean { return new Set(ids).size===ids.length; }
export function canChoose(id:string, selection:string, enabled:ReadonlySet<string>, controlEnabled=true):boolean {
  return controlEnabled && id!==selection && enabled.has(id);
}
export function clampFraction(value:number|null|undefined):number|null {
  return value==null || !Number.isFinite(value) ? null : Math.max(0,Math.min(1,value));
}
export function range(minimum:number, maximum:number, step:number) {
  const min = Number.isFinite(minimum)? minimum:0;
  const max = Number.isFinite(maximum)&&maximum>min?maximum:min+1;
  const interval = Number.isFinite(step)&&step>0?step:1;
  const clamp=(v:number)=>Number.isFinite(v)?Math.max(min,Math.min(max,v)):min;
  const snap=(v:number)=>{
    const x=clamp(v), low=clamp(min+Math.floor((x-min)/interval)*interval);
    const high=clamp(low+interval);
    return x-low<=high-x?low:high;
  };
  const adjacent=(v:number,direction:number)=>{
    const current=snap(v);
    if (direction!==1&&direction!==-1) return current;
    if(direction===-1&&current===max) {
      const last=clamp(min+Math.floor((max-min)/interval)*interval);
      if(last<max)return last;
    }
    return snap(current+direction*interval);
  };
  return {min,max,step:interval,clamp,snap,adjacent,progress:(v:number)=>(clamp(v)-min)/(max-min)};
}
export function stepAllowed(target:string,current:string,ids:readonly string[],completed:ReadonlySet<string>,disabled:ReadonlySet<string>,allowFuture:boolean,enabled=true):boolean {
  return enabled&&ids.includes(current)&&ids.includes(target)&&target!==current&&!disabled.has(target)&&(completed.has(target)||allowFuture);
}
export function decimalInput(raw:string, locale:string, minimum:number, maximum:number, step:number):number|null {
  const input=raw.trim(), sep=Intl.NumberFormat(locale).format(1.5).replace(/\d/g,'').trim();
  const decimal=sep.length===1?sep:'.';
  const escaped=decimal==='.'?'\\.':decimal===','?',':decimal;
  const re=new RegExp('^[+-]?(?:[0-9]+(?:'+escaped+'[0-9]*)?|'+escaped+'[0-9]+)$');
  if(!re.test(input))return null;
  const value=Number(input.replace(decimal,'.'));
  return Number.isFinite(value)?range(minimum,maximum,step).snap(value):null;
}
