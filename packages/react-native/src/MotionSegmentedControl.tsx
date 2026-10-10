import React from 'react';
import { ScrollView, View } from 'react-native';
import { MotionAction } from './primitives';
import { uniqueIds } from './policies';
export type MotionSegment={id:string;label:string;disabled?:boolean};
export function MotionSegmentedControl({label,segments,selection,onChange,disabled=false}:{
 label:string;segments:readonly MotionSegment[];selection:string;onChange:(id:string)=>void;disabled?:boolean;
}) {
 if(__DEV__&&!uniqueIds(segments.map(s=>s.id))) throw new Error('MotionSegment IDs must be unique');
 return <View accessibilityLabel={label}><ScrollView horizontal showsHorizontalScrollIndicator={false}
  contentContainerStyle={{gap:5}}>
  {segments.map(s=><MotionAction key={s.id} label={s.label} disabled={disabled||s.disabled}
    selected={selection===s.id} onPress={()=>{if(selection!==s.id)onChange(s.id);}} />)}
 </ScrollView></View>;
}
