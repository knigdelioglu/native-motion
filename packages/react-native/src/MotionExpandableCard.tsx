import React, {type ReactNode} from 'react';
import {View} from 'react-native';
import {MotionAction,MotionPanel} from './primitives';
export function MotionExpandableCard({title,expanded,onChange,children,disabled=false}:{
 title:string;expanded:boolean;onChange:(next:boolean)=>void;children:ReactNode;disabled?:boolean;
}) {
 return <MotionPanel style={{gap:8}}><MotionAction label={title+(expanded?', expanded':', collapsed')}
   selected={expanded} disabled={disabled} onPress={()=>onChange(!expanded)}/>
   {expanded?<View accessibilityLabel={title+' details'}>{children}</View>:null}
 </MotionPanel>;
}
