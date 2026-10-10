import React from 'react';
import {View,Text} from 'react-native';
import {MotionAction} from './primitives';
import {useMotionPalette} from './theme';
import {uniqueIds} from './policies';
export type MotionRadioOption={id:string;label:string;disabled?:boolean};
export function MotionRadioGroup({label,options,selection,onChange,disabled=false}:{
 label:string;options:readonly MotionRadioOption[];selection:string;onChange:(id:string)=>void;disabled?:boolean;
}) {
 const p=useMotionPalette();
 if(__DEV__&&!uniqueIds(options.map(o=>o.id)))throw new Error('Radio IDs must be unique');
 return <View accessibilityLabel={label} style={{gap:5}}>
  <Text style={{fontWeight:'600',color:p.primaryText}}>{label}</Text>
  {options.map(o=><MotionAction key={o.id} label={o.label+(selection===o.id?', selected':'')}
    disabled={disabled||o.disabled} selected={selection===o.id} onPress={()=>{if(selection!==o.id)onChange(o.id);}}>
   <View style={{flexDirection:'row',alignItems:'center',gap:8}}>
    <Text style={{color:p.accent}}>{selection===o.id?'◉':'○'}</Text><Text style={{color:p.primaryText}}>{o.label}</Text>
   </View>
  </MotionAction>)}
 </View>;
}
