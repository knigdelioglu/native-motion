import React,{useState} from 'react';
import {View,Text,Modal,Pressable} from 'react-native';
import {MotionAction,MotionPanel} from './primitives';
import {useMotionPalette} from './theme';
export type MotionMenuItem={id:string;label:string;onPress:()=>void;disabled?:boolean;destructive?:boolean};
export function MotionSplitButton({label,onPress,actions,disabled=false,loading=false}:{
 label:string;onPress:()=>void;actions:readonly MotionMenuItem[];disabled?:boolean;loading?:boolean;
}) {
 const [open,setOpen]=useState(false),p=useMotionPalette();
 const blocked=disabled||loading;
 return <View style={{flexDirection:'row',gap:3}}>
  <MotionAction label={label} disabled={blocked} onPress={onPress}/>
  <MotionAction label={label+' alternatives'} disabled={blocked||!actions.some(a=>!a.disabled)} onPress={()=>setOpen(true)}> 
   <Text style={{color:p.primaryText}}>⌄</Text>
  </MotionAction>
  <Modal visible={open} transparent animationType="fade" onRequestClose={()=>setOpen(false)}>
   <Pressable style={{flex:1,justifyContent:'center',padding:24,backgroundColor:'#0007'}} onPress={()=>setOpen(false)}>
    <MotionPanel style={{gap:8}}>
     {actions.map(a=><MotionAction key={a.id} label={a.label} disabled={blocked||a.disabled}
       destructive={a.destructive} onPress={()=>{setOpen(false);a.onPress();}} />)}
     <MotionAction label="Cancel" onPress={()=>setOpen(false)} />
    </MotionPanel>
   </Pressable>
  </Modal>
 </View>;
}
