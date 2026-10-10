import React,{type ReactNode} from 'react';
import {Modal,View,Pressable,Text} from 'react-native';
import {MotionAction,MotionPanel} from './primitives';
import {useMotionPalette} from './theme';
/// React Native core has no cross-platform anchored popover API. This uses a
/// platform Modal with an explicit dismiss path, not a claimed anchored popover.
export function MotionPopover({label,visible,onOpen,onDismiss,children,disabled=false}:{
 label:string;visible:boolean;onOpen:()=>void;onDismiss:()=>void;children:ReactNode;disabled?:boolean;
}) {
 const p=useMotionPalette();
 return <View>
  <MotionAction label={label} disabled={disabled} onPress={onOpen}/>
  <Modal visible={visible} transparent animationType="fade" onRequestClose={onDismiss}>
   <View style={{flex:1,justifyContent:'center',padding:20,backgroundColor:'#0008'}}>
    <MotionPanel style={{gap:10}}>
     <View style={{flexDirection:'row',alignItems:'center'}}>
      <Text accessibilityRole="header" style={{color:p.primaryText,fontSize:18,flex:1}}>{label}</Text>
      <MotionAction label="Close popover" onPress={onDismiss}/>
     </View>
     {children}
    </MotionPanel>
   </View>
  </Modal>
 </View>;
}
