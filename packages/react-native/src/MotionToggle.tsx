import React from 'react';
import {MotionAction} from './primitives';
export function MotionToggle({label,value,onChange,disabled=false}:{
 label:string;value:boolean;onChange:(next:boolean)=>void;disabled?:boolean;
}) {
 return <MotionAction label={label+', '+(value?'on':'off')} selected={value}
   disabled={disabled} onPress={()=>onChange(!value)} />;
}
