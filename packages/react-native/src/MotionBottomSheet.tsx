import React,{type ReactNode,useMemo,useRef} from 'react';
import {Animated,Modal,PanResponder,Pressable,Text,View,useWindowDimensions} from 'react-native';
import {MotionAction} from './primitives';
import {useMotionPalette,useReducedMotion} from './theme';
import {
 canDismissSurface,nextSheetDetent,shouldDismissDrag,heightFraction,type MotionSheetDetent,
} from './surfacePolicies';
export type {MotionSheetDetent};

/** Android/iOS native Modal with bottom alignment and a dedicated accessible
 * drag handle; detents and visibility remain host-controlled.
 * Gesture applies to the handle only, so nested ScrollViews remain independent.
 * This is a core-RN adapter rather than an OS-native bottom-sheet primitive. */
export function MotionBottomSheet({label,visible,onDismiss,children,detent,onDetentChange,busy=false}:{
 label:string;visible:boolean;onDismiss:()=>void;children:ReactNode;
 detent:MotionSheetDetent;onDetentChange:(next:MotionSheetDetent)=>void;busy?:boolean;
}) {
 const p=useMotionPalette(),reduced=useReducedMotion(),{height}=useWindowDimensions();
 const pull=useRef(new Animated.Value(0)).current;
 const latest=useRef({visible,busy,detent,onDismiss,onDetentChange,reduced});
 latest.current={visible,busy,detent,onDismiss,onDetentChange,reduced};
 const close=()=>{
   const s=latest.current;
   if(canDismissSurface(s.visible,s.busy))s.onDismiss();
 };
 const settle=()=>{
   if(latest.current.reduced)pull.setValue(0);
   else Animated.spring(pull,{toValue:0,useNativeDriver:true,bounciness:0}).start();
 };
 const drag=useMemo(()=>PanResponder.create({
   onStartShouldSetPanResponder:()=>!latest.current.busy,
   onMoveShouldSetPanResponder:(_,gesture)=>!latest.current.busy&&Math.abs(gesture.dy)>10,
   onPanResponderMove:(_,gesture)=>pull.setValue(Math.max(-60,gesture.dy)),
   onPanResponderRelease:(_,gesture)=>{
     const s=latest.current;
     const down=gesture.dy>0;
     if(Math.abs(gesture.dy)>=64&&!s.busy) {
       const next=nextSheetDetent(s.detent,down);
       if(next===null){
         if(shouldDismissDrag(gesture.dy,false,96))s.onDismiss();
       } else s.onDetentChange(next);
     }
     settle();
   },
   onPanResponderTerminate:settle,
 }),[pull]);
 return <Modal visible={visible} transparent animationType={reduced?'none':'slide'}
   onRequestClose={close} accessibilityViewIsModal>
   <View style={{flex:1,justifyContent:'flex-end'}}>
    <Pressable accessibilityLabel="Dismiss bottom sheet" onPress={close}
      style={{position:'absolute',top:0,left:0,right:0,bottom:0,backgroundColor:'#0008'}}/>
    <Animated.View style={{height:height*heightFraction(detent),maxHeight:'95%',
      backgroundColor:p.surface,borderTopLeftRadius:24,borderTopRightRadius:24,
      transform:[{translateY:pull}],paddingHorizontal:16,paddingTop:8,paddingBottom:24}}>
     <View {...drag.panHandlers} accessible accessibilityRole="adjustable"
       accessibilityLabel={label+' sheet height'} accessibilityState={{disabled:busy}}
       accessibilityActions={[{name:'increment'},{name:'decrement'}]}
       onAccessibilityAction={e=>{
         if(busy)return;
         const next=nextSheetDetent(detent,e.nativeEvent.actionName==='decrement');
         if(next===null)close();else onDetentChange(next);
       }} style={{height:44,justifyContent:'center',alignItems:'center'}}>
       <View style={{width:42,height:5,borderRadius:3,backgroundColor:p.border}}/>
     </View>
     <View style={{flexDirection:'row',alignItems:'center',gap:12,marginBottom:10}}>
      <Text accessibilityRole="header" style={{flex:1,fontSize:19,
        fontWeight:'700',color:p.primaryText}}>{label}</Text>
      <MotionAction label="Close bottom sheet" disabled={busy} onPress={close}/>
     </View>
     {children}
    </Animated.View>
   </View>
  </Modal>;
}
