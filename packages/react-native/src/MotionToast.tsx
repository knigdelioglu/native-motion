import React from 'react';
import {View,Text} from 'react-native';
import {MotionAction,MotionPanel} from './primitives';
import {useMotionPalette} from './theme';
export type MotionToastKind='neutral'|'success'|'warning'|'failure';
export function MotionToast({label,detail,kind='neutral',visible,onDismiss}:{
 label:string;detail?:string;kind?:MotionToastKind;visible:boolean;onDismiss:()=>void;
}) {
 const p=useMotionPalette();
 const color=kind==='success'?p.success:kind==='failure'?p.danger:kind==='warning'?p.warning:p.accent;
 if(!visible)return null;
 return <MotionPanel style={{flexDirection:'row',alignItems:'center',gap:8}}>
  <Text accessibilityElementsHidden style={{color}}>{kind==='success'?'✓':kind==='failure'?'!':'●'}</Text>
  <View accessibilityRole="text" accessibilityLabel={kind+', '+label+(detail?', '+detail:'')} style={{flex:1}}>
   <Text style={{fontWeight:'600',color:p.primaryText}}>{label}</Text>
   {detail?<Text style={{color:p.secondaryText}}>{detail}</Text>:null}
  </View>
  <MotionAction label="Dismiss notification" onPress={onDismiss}>
    <Text style={{color:p.primaryText}}>×</Text>
  </MotionAction>
 </MotionPanel>;
}
