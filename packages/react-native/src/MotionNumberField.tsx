import React,{useEffect,useState} from 'react';
import {View,Text,TextInput} from 'react-native';
import {MotionAction} from './primitives';
import {decimalInput,range} from './policies';
import {useMotionPalette} from './theme';
export function MotionNumberField({label,value,onChange,minimum=0,maximum=100,step=1,locale='en-US',disabled=false}:{
 label:string;value:number;onChange:(next:number)=>void;minimum?:number;maximum?:number;
 step?:number;locale?:string;disabled?:boolean;
}) {
 const p=useMotionPalette(),scale=range(minimum,maximum,step);
 const display=(v:number)=>new Intl.NumberFormat(locale,{maximumFractionDigits:9,useGrouping:false}).format(scale.snap(v));
 const [draft,setDraft]=useState(display(value));
 const [focused,setFocused]=useState(false),[invalid,setInvalid]=useState(false);
 useEffect(()=>{if(!focused){setDraft(display(value));setInvalid(false);}},[value,locale,focused,minimum,maximum,step]);
 const commit=()=>{
   setFocused(false);
   const parsed=decimalInput(draft,locale,minimum,maximum,step);
   if(parsed===null){setInvalid(true);return;}
   setInvalid(false);setDraft(display(parsed));onChange(parsed);
 };
 const adjust=(direction:number)=>{
   const next=scale.adjacent(value,direction);setDraft(display(next));setInvalid(false);onChange(next);
 };
 return <View style={{gap:6,opacity:disabled?0.5:1}}>
  <Text style={{color:p.primaryText,fontWeight:'600'}}>{label}</Text>
  <View style={{flexDirection:'row',gap:8,alignItems:'center'}}>
   <TextInput accessibilityLabel={label} editable={!disabled} value={draft}
    keyboardType="decimal-pad" onChangeText={text=>{setDraft(text);setInvalid(false);}}
    onFocus={()=>setFocused(true)} onBlur={commit} onSubmitEditing={commit}
    style={{color:p.primaryText,flex:1,minHeight:48,borderWidth:1,paddingHorizontal:12,
     borderRadius:12,borderColor:invalid?p.danger:p.border,backgroundColor:p.surface}} />
   <MotionAction label="Decrease" disabled={disabled||scale.snap(value)===scale.min} onPress={()=>adjust(-1)} />
   <MotionAction label="Increase" disabled={disabled||scale.snap(value)===scale.max} onPress={()=>adjust(1)} />
  </View>
  {invalid?<Text style={{color:p.danger}} accessibilityRole="text">Enter a valid number</Text>:null}
 </View>;
}
