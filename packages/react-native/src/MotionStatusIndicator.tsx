import React from 'react';
import {View,Text,ActivityIndicator} from 'react-native';
import {MotionPanel,MotionText} from './primitives';
import {useMotionPalette} from './theme';
export type MotionStatus='neutral'|'processing'|'success'|'warning'|'failure';
export function MotionStatusIndicator({label,status,detail}:{
 label:string;status:MotionStatus;detail?:string;
}) {
 const p=useMotionPalette();
 const color=status==='failure'?p.danger:status==='warning'?p.warning:status==='success'?p.success:p.secondaryText;
 return <MotionPanel><View accessibilityRole="text" accessibilityLabel={label+', '+status+(detail?', '+detail:'')}
  style={{flexDirection:'row',alignItems:'center',gap:8}}>
  {status==='processing'?<ActivityIndicator color={color}/>:<Text style={{color}}>{status==='success'?'✓':status==='failure'?'!':'●'}</Text>}
  <View style={{flex:1}}><MotionText>{label}</MotionText>{detail?<MotionText muted>{detail}</MotionText>:null}</View>
  <Text style={{color}}>{status}</Text>
 </View></MotionPanel>;
}
