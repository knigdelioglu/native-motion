import React,{type ReactNode} from 'react';
import {Modal,Pressable,Text,View} from 'react-native';
import {MotionPanel,MotionAction} from './primitives';
import {useMotionPalette} from './theme';
export function MotionDialog({title,visible,onDismiss,onConfirm,children,confirmLabel='Confirm',
 cancelLabel='Cancel',loading=false,destructive=false}:{
 title:string;visible:boolean;onDismiss:()=>void;onConfirm:()=>void;children:ReactNode;
 confirmLabel?:string;cancelLabel?:string;loading?:boolean;destructive?:boolean;
}) {
 const p=useMotionPalette();
 return <Modal visible={visible} transparent animationType="fade"
  onRequestClose={()=>{if(!loading)onDismiss();}} accessibilityViewIsModal>
  <View style={{flex:1,justifyContent:'center',padding:20,backgroundColor:'#0008'}}>
   <MotionPanel style={{gap:12}}>
    <Text accessibilityRole="header" style={{color:p.primaryText,fontWeight:'700',fontSize:20}}>{title}</Text>
    {children}
    <View style={{flexDirection:'row',justifyContent:'flex-end',gap:8}}>
     <MotionAction label={cancelLabel} disabled={loading} onPress={onDismiss}/>
     <MotionAction label={confirmLabel} disabled={loading} destructive={destructive} onPress={onConfirm}/>
    </View>
   </MotionPanel>
  </View>
 </Modal>;
}
