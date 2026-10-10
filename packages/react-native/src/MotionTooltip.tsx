import React,{useState,type ReactNode} from 'react';
import {View,Text,Modal} from 'react-native';
import {MotionAction,MotionPanel} from './primitives';
import {useMotionPalette} from './theme';
export function MotionTooltip({label,message,children,disabled=false}:{
 label:string;message:string;children?:ReactNode;disabled?:boolean;
}) {
 const [open,setOpen]=useState(false),p=useMotionPalette();
 return <View>
  <MotionAction label={label} disabled={disabled} onPress={()=>setOpen(true)}>
   {children??<Text style={{color:p.accent}}>ⓘ {label}</Text>}
  </MotionAction>
  <Modal visible={open} transparent animationType="fade" onRequestClose={()=>setOpen(false)}>
   <View style={{flex:1,justifyContent:'center',padding:24,backgroundColor:'#0008'}}>
    <MotionPanel style={{gap:12}}>
     <Text accessibilityRole="text" style={{color:p.primaryText}}>{message}</Text>
     <MotionAction label="Close help" onPress={()=>setOpen(false)}/>
    </MotionPanel>
   </View>
  </Modal>
 </View>;
}
