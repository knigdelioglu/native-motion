import React from 'react';
import {ScrollView,Text,View} from 'react-native';
import {MotionAction} from './primitives';
import {pageWindow,nextPage} from './navigationPolicies';
import {useMotionPalette} from './theme';

/** Pages remain application-owned; the window never allocates O(total). */
export function MotionPagination({label,page,totalPages,onChange,maxVisible=5,disabled=false}:{
 label:string;page:number;totalPages:number;onChange:(next:number)=>void;
 maxVisible?:number;disabled?:boolean;
}) {
 const p=useMotionPalette(),pages=pageWindow(page,totalPages,maxVisible);
 const previous=nextPage(page,totalPages,-1);
 const next=nextPage(page,totalPages,1);
 return <View accessibilityLabel={label}>
  <ScrollView horizontal showsHorizontalScrollIndicator={false}
   contentContainerStyle={{alignItems:'center',gap:5}}>
   <MotionAction label="Previous page" disabled={disabled||previous===null}
      onPress={()=>{if(previous!==null)onChange(previous);}}>
      <Text style={{color:p.primaryText}}>‹</Text>
   </MotionAction>
   {pages.map(n=><MotionAction key={n} label={'Page '+n+(n===page?', current':'')}
     selected={n===page} disabled={disabled||n===page} onPress={()=>onChange(n)}>
     <Text style={{fontWeight:n===page?'700':'400',color:p.primaryText}}>{n}</Text>
   </MotionAction>)}
   <MotionAction label="Next page" disabled={disabled||next===null}
      onPress={()=>{if(next!==null)onChange(next);}}>
      <Text style={{color:p.primaryText}}>›</Text>
   </MotionAction>
  </ScrollView>
 </View>;
}
