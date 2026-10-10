import React,{useState} from 'react';
import {View} from 'react-native';
import {MotionAction} from './primitives';
export function MotionConfirmButton({label,confirmLabel='Confirm',onConfirm,disabled=false,loading=false}:{
 label:string;confirmLabel?:string;onConfirm:()=>void;disabled?:boolean;loading?:boolean;
}) {
 const [armed,setArmed]=useState(false);
 const blocked=disabled||loading;
 return <View style={{flexDirection:'row',gap:8}}>
  <MotionAction label={armed?confirmLabel:label} destructive selected={armed} disabled={blocked}
   onPress={()=>{if(!armed){setArmed(true);return;}setArmed(false);onConfirm();}}/>
  {armed?<MotionAction label="Cancel" disabled={blocked} onPress={()=>setArmed(false)}/>:null}
 </View>;
}
