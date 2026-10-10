import React, {useState} from 'react';
import {View,Text} from 'react-native';
import {MotionPanel} from './primitives';
import {range} from './policies';
import {useMotionPalette} from './theme';
export function MotionElasticSlider({label,value,onChange,onCommit,minimum=0,maximum=100,step=1,disabled=false}:{
 label:string;value:number;onChange:(next:number)=>void;onCommit?:(next:number)=>void;
 minimum?:number;maximum?:number;step?:number;disabled?:boolean;
}) {
 const p=useMotionPalette(),scale=range(minimum,maximum,step);
 const [width,setWidth]=useState(240);
 const [draft,setDraft]=useState<number|null>(null);
 // PanResponder retains stable responders across parent-owned value updates:
 // the host remains authoritative on release.
 const shown=draft??scale.snap(value);
 const fromX=(x:number)=>scale.snap(scale.min+(Math.max(0,Math.min(width,x))/width)*(scale.max-scale.min));
 return <MotionPanel>
  <Text style={{color:p.primaryText}}>{label+': '+shown}</Text>
  <View onLayout={e=>setWidth(Math.max(1,e.nativeEvent.layout.width))}
   accessibilityRole="adjustable" accessibilityLabel={label}
   accessibilityValue={{min:scale.min,max:scale.max,now:shown}}
   accessibilityState={{disabled}}
   accessibilityActions={[{name:'increment'},{name:'decrement'}]}
   onAccessibilityAction={e=>{
     if(disabled)return;
     const next=scale.adjacent(value,e.nativeEvent.actionName==='increment'?1:-1);
     onChange(next);onCommit?.(next);
   }}
   onStartShouldSetResponder={()=>!disabled} onMoveShouldSetResponder={()=>!disabled}
   onResponderGrant={e=>{const next=fromX(e.nativeEvent.locationX);setDraft(next);onChange(next);}}
   onResponderMove={e=>{const next=fromX(e.nativeEvent.locationX);setDraft(next);onChange(next);}}
   onResponderRelease={e=>{const next=fromX(e.nativeEvent.locationX);setDraft(null);onChange(next);onCommit?.(next);}}
   onResponderTerminate={()=>setDraft(null)}
   style={{height:48,justifyContent:'center',opacity:disabled?0.5:1}}>
   <View style={{height:5,borderRadius:3,backgroundColor:p.border}} />
   <View style={{height:5,borderRadius:3,backgroundColor:p.accent,position:'absolute',left:0,width:width*scale.progress(shown)}}/>
  </View>
 </MotionPanel>;
}
