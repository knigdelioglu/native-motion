import React,{type ReactNode} from 'react';
import {View,ScrollView} from 'react-native';
import {MotionAction,MotionText} from './primitives';
import {uniqueIds} from './policies';
export type MotionTabItem={id:string;label:string;disabled?:boolean};
export function MotionTabs({label,tabs,selection,onChange,children,disabled=false}:{
 label:string;tabs:readonly MotionTabItem[];selection:string;onChange:(id:string)=>void;
 children:(id:string)=>ReactNode;disabled?:boolean;
}) {
 if(__DEV__&&!uniqueIds(tabs.map(t=>t.id)))throw new Error('Tab IDs must be unique');
 const selected=tabs.find(t=>t.id===selection&&!t.disabled);
 return <View accessibilityLabel={label} style={{gap:12}}>
  <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{gap:5}}>
   {tabs.map(t=><MotionAction key={t.id} label={t.label} disabled={disabled||t.disabled}
      selected={t.id===selection} onPress={()=>{if(selection!==t.id)onChange(t.id);}} />)}
  </ScrollView>
  {selected?children(selection):<MotionText muted>No available tab selected</MotionText>}
 </View>;
}
