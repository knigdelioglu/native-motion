import React, {type ReactNode} from 'react';
import {MotionAction} from './primitives';
export function MotionIconButton({label,icon,onPress,disabled=false}:{
 label:string;icon:ReactNode;onPress:()=>void;disabled?:boolean;
}) {
 return <MotionAction label={label} disabled={disabled} onPress={onPress}
   style={{width:48,paddingHorizontal:0}}>{icon}</MotionAction>;
}
