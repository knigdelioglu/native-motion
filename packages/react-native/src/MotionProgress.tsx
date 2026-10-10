import React from 'react';
import {View,Text,ActivityIndicator} from 'react-native';
import {MotionPanel} from './primitives';
import {useMotionPalette} from './theme';
import {clampFraction} from './policies';
export function MotionProgress({label,value,detail}:{
 label:string;value?:number|null;detail?:string;
}) {
 const p=useMotionPalette(),fraction=clampFraction(value);
 return <MotionPanel>
  <View style={{flexDirection:'row',justifyContent:'space-between',marginBottom:8}}>
   <Text style={{color:p.primaryText,fontWeight:'600'}}>{label}</Text>
   <Text style={{color:p.secondaryText}}>{fraction===null?'In progress':Math.round(fraction*100)+'%'}</Text>
  </View>
  {fraction===null?<ActivityIndicator accessibilityLabel="In progress" color={p.accent}/>:
  <View accessibilityRole="progressbar" accessibilityValue={{min:0,max:100,now:Math.round(fraction*100)}}
    style={{height:7,borderRadius:4,backgroundColor:p.border,overflow:'hidden'}}>
    <View style={{height:7,width:(String(fraction*100)+'%') as `${number}%`,backgroundColor:p.accent}}/>
  </View>}
  {detail?<Text style={{color:p.secondaryText,marginTop:8}}>{detail}</Text>:null}
 </MotionPanel>;
}
