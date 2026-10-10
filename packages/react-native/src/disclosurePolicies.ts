/** Shared host-owned disclosure transitions. No internal business state. */
export function uniqueDisclosureIds(ids:readonly string[]):boolean {
  return new Set(ids).size===ids.length;
}
export function toggleDisclosure(
  id:string,
  expandedIds:readonly string[],
  enabledIds:ReadonlySet<string>,
  allowsMultiple:boolean,
  controlEnabled=true,
):string[] {
  if(!controlEnabled||!enabledIds.has(id))return [...expandedIds];
  if(expandedIds.includes(id))return expandedIds.filter(value=>value!==id);
  return allowsMultiple?[...expandedIds,id]:[id];
}
