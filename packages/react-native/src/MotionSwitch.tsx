import React from 'react';
import {View,Text,Switch} from 'react-native';
import {useMotionPalette} from './theme';
export function MotionSwitch({label,value,onChange,disabled=false,detail}:{
 label:string;value:boolean;onChange:(next:boolean)=>void;disabled?:boolean;detail?:string;
}) {
 const p=useMotionPalette();
 return <View style={{flexDirection:'row',alignItems:'center',minHeight:48,gap:12}}>
  <View style={{flex:1}}>
   <Text style={{color:p.primaryText,fontWeight:'600'}}>{label}</Text>
   {detail?<Text style={{color:p.secondaryText}}>{detail}</Text>:null}
  </View>
  <Switch accessibilityLabel={label} value={value} onValueChange={onChange} disabled={disabled}
    trackColor={{false:p.border,true:p.accent}} thumbColor={p.surface}/>
 </View>;
}
