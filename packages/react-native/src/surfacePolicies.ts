/** Native Motion v0.5 modal surface policies. No automatic dismissal. */
export type MotionSheetDetent = 'compact'|'medium'|'expanded';
export function canOpenSurface(enabled:boolean,visible:boolean):boolean {
 return enabled&&!visible;
}
export function canDismissSurface(visible:boolean,busy:boolean):boolean {
 return visible&&!busy;
}
export function shouldDismissDrag(distance:number,busy:boolean,threshold=96):boolean {
 return !busy&&distance>Math.max(40,threshold);
}
export function nextSheetDetent(detent:MotionSheetDetent,down:boolean):MotionSheetDetent|null {
 if(down) return detent==='expanded'?'medium':detent==='medium'?'compact':null;
 return detent==='compact'?'medium':'expanded';
}
export function heightFraction(detent:MotionSheetDetent):number {
 return detent==='compact'?0.34:detent==='medium'?0.58:0.91;
}
