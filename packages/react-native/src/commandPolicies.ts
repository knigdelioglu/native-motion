/** Pure command matching/gating independent from React Native rendering. */
export type MotionSearchableCommand={
 id:string;title:string;keywords?:readonly string[];disabled?:boolean;
};
export function visibleCommands<T extends MotionSearchableCommand>(
 commands:readonly T[],query:string,
):T[] {
 const normalized=query.trim().toLocaleLowerCase();
 if(!normalized)return [...commands];
 return commands.filter(c=>[c.title,...(c.keywords??[])].some(x=>
  x.toLocaleLowerCase().includes(normalized)));
}
export function canExecuteCommand(
 id:string,commands:readonly MotionSearchableCommand[],visible:boolean,
):boolean {
 return visible&&commands.some(c=>c.id===id&&!c.disabled);
}
