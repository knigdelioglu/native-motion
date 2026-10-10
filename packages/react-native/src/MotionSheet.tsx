import React,{type ReactNode} from 'react';
import {Modal,Pressable,Text,View,useWindowDimensions} from 'react-native';
import {MotionAction,MotionPanel} from './primitives';
import {canDismissSurface} from './surfacePolicies';
import {useMotionPalette} from './theme';

/** Native Modal-based adaptive page for Expo iOS/Android. The host owns
 * visible/busy and receives an explicit dismissal request. */
export function MotionSheet({label,visible,onDismiss,children,busy=false}:{
 label:string;visible:boolean;onDismiss:()=>void;children:ReactNode;busy?:boolean;
}) {
 const p=useMotionPalette(),{width}=useWindowDimensions();
 const dismiss=()=>{if(canDismissSurface(visible,busy))onDismiss();};
 return <Modal visible={visible} animationType="slide" transparent
  onRequestClose={dismiss} accessibilityViewIsModal>
  <View style={{flex:1,justifyContent:'center',alignItems:'center',padding:18}}>
   <Pressable onPress={dismiss} accessibilityLabel="Dismiss sheet"
      style={{position:'absolute',top:0,left:0,right:0,bottom:0,backgroundColor:'#0008'}} />
   <MotionPanel style={{width:Math.min(width-36,560),maxHeight:'88%',gap:14}}>
    <View style={{flexDirection:'row',alignItems:'center',gap:12}}>
     <Text accessibilityRole="header" style={{flex:1,fontSize:20,
       color:p.primaryText,fontWeight:'700'}}>{label}</Text>
     <MotionAction label="Close sheet" disabled={busy} onPress={dismiss}/>
    </View>
    {children}
   </MotionPanel>
  </View>
 </Modal>;
}
