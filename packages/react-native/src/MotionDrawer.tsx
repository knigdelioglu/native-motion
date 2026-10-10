import React,{type ReactNode} from 'react';
import {I18nManager,Modal,Pressable,Text,View,useWindowDimensions} from 'react-native';
import {MotionAction} from './primitives';
import {useMotionPalette} from './theme';
import {canDismissSurface} from './surfacePolicies';

/** Native side drawer overlay. Swipe-to-close/focus-trap require real-device
 * validation; host controls visibility and business navigation. */
export function MotionDrawer({label,visible,onDismiss,children,side='start',busy=false}:{
 label:string;visible:boolean;onDismiss:()=>void;children:ReactNode;
 side?:'start'|'end';busy?:boolean;
}) {
 const p=useMotionPalette(),{width}=useWindowDimensions();
 const left=(side==='start')!==I18nManager.isRTL;
 const close=()=>{if(canDismissSurface(visible,busy))onDismiss();};
 return <Modal visible={visible} transparent animationType="slide" onRequestClose={close}
  accessibilityViewIsModal statusBarTranslucent>
  <View style={{flex:1,justifyContent:left?'flex-start':'flex-end',
    flexDirection:'row',backgroundColor:'transparent'}}>
   <Pressable accessibilityLabel="Dismiss drawer" onPress={close}
     style={{position:'absolute',top:0,bottom:0,left:0,right:0,backgroundColor:'#0008'}}/>
   <View style={{width:Math.min(width*0.9,360),backgroundColor:p.surface,
     paddingTop:48,paddingHorizontal:16,paddingBottom:24,gap:16}}>
    <View style={{flexDirection:'row',alignItems:'center',gap:8}}>
     <Text accessibilityRole="header" style={{flex:1,fontSize:19,
       color:p.primaryText,fontWeight:'700'}}>{label}</Text>
     <MotionAction label="Close drawer" disabled={busy} onPress={close}/>
    </View>
    {children}
   </View>
  </View>
 </Modal>;
}
