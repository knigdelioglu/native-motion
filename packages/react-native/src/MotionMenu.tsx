import React,{useState} from 'react';
import {Modal,Pressable,View,ScrollView} from 'react-native';
import {MotionAction,MotionPanel} from './primitives';
import type {MotionMenuItem} from './MotionSplitButton';
export type {MotionMenuItem};
export function MotionMenu({label,actions,disabled=false}:{
 label:string;actions:readonly MotionMenuItem[];disabled?:boolean;
}) {
 const [open,setOpen]=useState(false);
 const blocked=disabled||!actions.some(a=>!a.disabled);
 return <View><MotionAction label={label} disabled={blocked} onPress={()=>setOpen(true)}/>
  <Modal visible={open} animationType="fade" transparent onRequestClose={()=>setOpen(false)}>
   <Pressable onPress={()=>setOpen(false)} style={{flex:1,justifyContent:'center',backgroundColor:'#0008',padding:20}}>
    <MotionPanel style={{maxHeight:'75%',gap:6}}>
     <ScrollView>{actions.map(a=><MotionAction key={a.id} label={a.label} disabled={a.disabled}
       destructive={a.destructive} onPress={()=>{setOpen(false);a.onPress();}} />)}</ScrollView>
     <MotionAction label="Close menu" onPress={()=>setOpen(false)}/>
    </MotionPanel>
   </Pressable>
  </Modal>
 </View>;
}
