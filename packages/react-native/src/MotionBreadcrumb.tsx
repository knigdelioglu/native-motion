import React from 'react';
import {ScrollView,Text,View,I18nManager} from 'react-native';
import {MotionAction} from './primitives';
import {canNavigate} from './navigationPolicies';
import {uniqueIds} from './policies';
import {useMotionPalette} from './theme';

export type MotionBreadcrumbItem={id:string;label:string;disabled?:boolean};
/** Visible, accessible ancestor links. Native horizontal overflow and RTL. */
export function MotionBreadcrumb({label,items,currentId,onNavigate}:{
 label:string;items:readonly MotionBreadcrumbItem[];currentId:string;
 onNavigate:(id:string)=>void;
}) {
 const p=useMotionPalette();
 if(__DEV__&&!uniqueIds(items.map(i=>i.id)))throw new Error('Breadcrumb IDs must be unique');
 const enabled=new Set(items.filter(i=>!i.disabled).map(i=>i.id));
 return <ScrollView horizontal showsHorizontalScrollIndicator={false}
  accessibilityLabel={label} contentContainerStyle={{alignItems:'center',gap:6}}>
  {items.map((item,i)=><View key={item.id} style={{flexDirection:'row',alignItems:'center',gap:6}}>
   {i>0?<Text accessibilityElementsHidden style={{color:p.secondaryText}}>
     {I18nManager.isRTL?'‹':'›'}
   </Text>:null}
   {item.id===currentId?
    <Text accessibilityRole="text" style={{fontWeight:'700',color:p.primaryText}}>
      {item.label}
    </Text>:
    <MotionAction label={item.label} disabled={item.disabled}
     onPress={()=>{if(canNavigate(item.id,currentId,enabled))onNavigate(item.id);}} />}
  </View>)}
 </ScrollView>;
}
