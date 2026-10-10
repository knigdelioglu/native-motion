import React,{useState} from 'react';
import {Modal,Pressable,View,Text,ScrollView} from 'react-native';
import {MotionAction,MotionPanel} from './primitives';
import {useMotionPalette} from './theme';
import {uniqueIds} from './policies';
export type MotionSelectOption={id:string;label:string;disabled?:boolean};
export function MotionSelect({label,options,selection,onChange,disabled=false}:{
 label:string;options:readonly MotionSelectOption[];selection:string;onChange:(id:string)=>void;disabled?:boolean;
}) {
 const [open,setOpen]=useState(false),p=useMotionPalette();
 if(__DEV__&&!uniqueIds(options.map(o=>o.id)))throw new Error('Select IDs must be unique');
 const chosen=options.find(o=>o.id===selection);
 return <View>
  <MotionAction label={label+', '+(chosen?.label??'No selection')}
    disabled={disabled||!options.some(o=>!o.disabled)} onPress={()=>setOpen(true)}>
   <Text style={{color:p.primaryText}}>{label+': '+(chosen?.label??'Choose')+' ▾'}</Text>
  </MotionAction>
  <Modal transparent visible={open} animationType="fade" onRequestClose={()=>setOpen(false)}>
   <Pressable onPress={()=>setOpen(false)} style={{flex:1,justifyContent:'center',backgroundColor:'#0008',padding:18}}>
    <MotionPanel style={{maxHeight:'70%',gap:10}}>
     <Text style={{color:p.primaryText,fontWeight:'600',fontSize:18}}>{label}</Text>
     <ScrollView>{options.map(o=><MotionAction key={o.id} label={o.label}
       selected={selection===o.id} disabled={o.disabled}
       onPress={()=>{setOpen(false);if(selection!==o.id)onChange(o.id);}}/>)}</ScrollView>
     <MotionAction label="Cancel" onPress={()=>setOpen(false)}/>
    </MotionPanel>
   </Pressable>
  </Modal>
 </View>;
}
