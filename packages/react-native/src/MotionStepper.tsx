import React from 'react';
import {View,Text} from 'react-native';
import {MotionAction} from './primitives';
import {stepAllowed,uniqueIds} from './policies';
import {useMotionPalette} from './theme';
export type MotionStepItem={id:string;label:string;detail?:string;disabled?:boolean};
export function MotionStepper({label,steps,selection,completedIds,onChange,allowFuture=false,disabled=false}:{
 label:string;steps:readonly MotionStepItem[];selection:string;completedIds:ReadonlySet<string>;
 onChange:(id:string)=>void;allowFuture?:boolean;disabled?:boolean;
}) {
 const p=useMotionPalette(),ids=steps.map(s=>s.id);
 if(__DEV__&&!uniqueIds(ids))throw new Error('Step IDs must be unique');
 const blocked=new Set(steps.filter(s=>s.disabled).map(s=>s.id));
 return <View accessibilityLabel={label} style={{gap:6}}>
  <Text style={{color:p.primaryText,fontWeight:'600',fontSize:17}}>{label}</Text>
  {steps.map((s,i)=>{
   const current=selection===s.id,complete=!current&&completedIds.has(s.id);
   const enabled=stepAllowed(s.id,selection,ids,completedIds,blocked,allowFuture,!disabled);
   return <MotionAction key={s.id} label={(i+1)+'. '+s.label+', '+(current?'current':complete?'completed':'pending')}
      disabled={!enabled} selected={current} onPress={()=>onChange(s.id)}>
     <View style={{flexDirection:'row',gap:9,alignItems:'center',alignSelf:'stretch'}}>
      <Text style={{color:complete?p.success:current?p.accent:p.secondaryText}}>{complete?'✓':String(i+1)}</Text>
      <View><Text style={{color:p.primaryText,fontWeight:current?'700':'400'}}>{s.label}</Text>
        {s.detail?<Text style={{color:p.secondaryText}}>{s.detail}</Text>:null}</View>
     </View>
   </MotionAction>;
  })}
 </View>;
}
