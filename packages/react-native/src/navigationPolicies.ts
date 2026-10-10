/** Cross-renderer navigation contracts, without business side effects. */
export function canNavigate(id:string,current:string,enabled:ReadonlySet<string>):boolean {
 return id!==current&&enabled.has(id);
}
export function pageWindow(current:number,total:number,maxVisible=5):number[] {
 if(!Number.isFinite(total)||total<=0)return [];
 const count=Math.min(Math.max(1,Math.floor(maxVisible)||1),Math.floor(total));
 const safe=Math.min(Math.floor(total),Math.max(1,Math.floor(current)||1));
 const start=Math.min(Math.max(1,safe-Math.floor(count/2)),Math.floor(total)-count+1);
 return Array.from({length:count},(_,i)=>start+i);
}
export function nextPage(current:number,total:number,delta:-1|1):number|null {
 if(total<=0)return null;
 const safe=Math.min(total,Math.max(1,current)),next=safe+delta;
 return next>=1&&next<=total?next:null;
}
