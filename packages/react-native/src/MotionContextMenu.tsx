import React,{type ReactNode,useState} from 'react';
import {Modal,Pressable,ScrollView,Text,View} from 'react-native';
import {MotionAction,MotionPanel} from './primitives';
import {useMotionPalette} from './theme';
import {uniqueIds} from './policies';
import type {MotionMenuItem} from './MotionMenu';

/** Native long press with a visible accessible actions trigger. The fallback
 * uses a platform Modal (not an OS-owned context-menu extension). */
export function MotionContextMenu({label,actions,children,disabled=false}:{
 label:string;actions:readonly MotionMenuItem[];children:ReactNode;disabled?:boolean;
}) {
 const [open,setOpen]=useState(false),p=useMotionPalette();
 if(__DEV__&&!uniqueIds(actions.map(a=>a.id)))
   throw new Error('MotionContextMenu action IDs must be unique');
 const allowed=!disabled&&actions.some(a=>!a.disabled);
 const close=()=>setOpen(false);
 return <View style={{gap:8}}>
  <View style={{flexDirection:'row',alignItems:'center',gap:8}}>
   <Pressable onLongPress={()=>{if(allowed)setOpen(true);}}
    accessible accessibilityRole="button" accessibilityLabel={label+' context actions'}
    disabled={!allowed} style={{flex:1,minHeight:44,justifyContent:'center'}}>
    {children}
   </Pressable>
   <MotionAction label="More actions" disabled={!allowed} onPress={()=>setOpen(true)}/>
  </View>
  <Modal visible={open} transparent animationType="fade" onRequestClose={close}
   accessibilityViewIsModal>
   <View style={{flex:1,justifyContent:'center',padding:20}}>
    <Pressable onPress={close} accessibilityLabel="Dismiss context actions"
      style={{position:'absolute',top:0,bottom:0,left:0,right:0,backgroundColor:'#0008'}}/>
    <MotionPanel style={{maxHeight:'80%',gap:12}}>
     <Text accessibilityRole="header" style={{fontWeight:'700',fontSize:18,
      color:p.primaryText}}>{label}</Text>
     <ScrollView>{actions.map(item=><MotionAction key={item.id}
      label={item.label} disabled={item.disabled} destructive={item.destructive}
      onPress={()=>{if(item.disabled)return;close();item.onPress();}}/>)}</ScrollView>
     <MotionAction label="Close context actions" onPress={close}/>
    </MotionPanel>
   </View>
  </Modal>
 </View>;
}
