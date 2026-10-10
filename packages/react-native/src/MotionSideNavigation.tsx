import React from 'react';
import {ScrollView,Text,View} from 'react-native';
import {MotionAction} from './primitives';
import {canNavigate} from './navigationPolicies';
import {uniqueIds} from './policies';
import {useMotionPalette} from './theme';

export type MotionSideNavigationItem={id:string;label:string;disabled?:boolean};
export function MotionSideNavigation({label,items,selection,onChange,disabled=false}:{
 label:string;items:readonly MotionSideNavigationItem[];selection:string;
 onChange:(id:string)=>void;disabled?:boolean;
}) {
 const p=useMotionPalette();
 if(__DEV__&&!uniqueIds(items.map(x=>x.id)))throw new Error('SideNavigation IDs must be unique');
 const enabledIds=new Set(items.filter(x=>!x.disabled).map(x=>x.id));
 return <View accessibilityLabel={label} style={{width:240,maxWidth:'100%'}}>
  <Text accessibilityRole="header" style={{color:p.primaryText,fontWeight:'700',
   fontSize:17,marginBottom:10}}>{label}</Text>
  <ScrollView style={{maxHeight:480}} contentContainerStyle={{gap:6}}>
   {items.map(item=><MotionAction key={item.id} label={item.label}
    disabled={disabled||item.disabled} selected={selection===item.id}
    style={{alignItems:'stretch'}} onPress={()=>{
      if(!disabled&&canNavigate(item.id,selection,enabledIds))onChange(item.id);
    }} />)}
  </ScrollView>
 </View>;
}
