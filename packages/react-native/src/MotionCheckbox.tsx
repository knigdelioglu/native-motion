import React from 'react';
import {Text,View} from 'react-native';
import {MotionAction} from './primitives';
import {nextCheckbox,type CheckboxState} from './policies';
import {useMotionPalette} from './theme';
export type {CheckboxState};
export function MotionCheckbox({label,state,onChange,disabled=false}:{
 label:string;state:CheckboxState;onChange:(next:CheckboxState)=>void;disabled?:boolean;
}) {
 const p=useMotionPalette();
 return <MotionAction label={label+', '+state} selected={state==='checked'}
   disabled={disabled} onPress={()=>onChange(nextCheckbox(state))}>
   <View style={{flexDirection:'row',alignItems:'center',gap:8}}>
    <Text style={{fontSize:20,color:p.accent}}>{state==='checked'?'☑':state==='mixed'?'▣':'☐'}</Text>
    <Text style={{color:p.primaryText}}>{label}</Text>
   </View>
 </MotionAction>;
}
