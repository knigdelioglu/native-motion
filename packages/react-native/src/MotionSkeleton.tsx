import React,{useEffect,useRef} from 'react';
import {View,Text,Animated} from 'react-native';
import {MotionPanel} from './primitives';
import {useMotionPalette,useReducedMotion} from './theme';
export function MotionSkeleton({label='Loading content',rows=3,avatar=false}:{
 label?:string;rows?:number;avatar?:boolean;
}) {
 const p=useMotionPalette(),reduced=useReducedMotion();
 const fade=useRef(new Animated.Value(1)).current;
 useEffect(()=>{
   if(reduced){fade.setValue(1);return;}
   const animation=Animated.loop(Animated.sequence([
      Animated.timing(fade,{toValue:0.6,duration:750,useNativeDriver:true}),
      Animated.timing(fade,{toValue:1,duration:750,useNativeDriver:true}),
   ]));
   animation.start();return ()=>animation.stop();
 },[reduced,fade]);
 return <MotionPanel>
  <View accessibilityLabel={label} accessibilityRole="text" style={{flexDirection:'row',gap:12}}>
   {avatar?<Animated.View style={{width:44,height:44,borderRadius:22,backgroundColor:p.border,opacity:fade}}/>:null}
   <Animated.View style={{flex:1,gap:8,opacity:fade}}>
    {Array.from({length:Math.max(1,Math.min(8,Math.floor(rows)||1))},(_,i)=>
      <View key={i} style={{height:13,backgroundColor:p.border,borderRadius:5,
        width:i===rows-1?'75%':'100%'}}/>)}
   </Animated.View>
  </View>
 </MotionPanel>;
}
