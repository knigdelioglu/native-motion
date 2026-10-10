import React from 'react';
import {View,Text,TextInput} from 'react-native';
import {useMotionPalette} from './theme';
export function MotionTextField({label,value,onChangeText,placeholder='',error,help,disabled=false,onSubmit}:{
 label:string;value:string;onChangeText:(text:string)=>void;placeholder?:string;
 error?:string;help?:string;disabled?:boolean;onSubmit?:()=>void;
}) {
 const p=useMotionPalette();
 return <View style={{gap:5,opacity:disabled?0.5:1}}>
  <Text style={{color:p.primaryText,fontWeight:'600'}}>{label}</Text>
  <TextInput accessibilityLabel={label} value={value} onChangeText={onChangeText}
   placeholder={placeholder} placeholderTextColor={p.secondaryText} editable={!disabled}
   onSubmitEditing={onSubmit} returnKeyType="done"
   style={{minHeight:48,borderWidth:1,borderColor:error?p.danger:p.border,
   borderRadius:12,backgroundColor:p.surface,color:p.primaryText,paddingHorizontal:12}}/>
  {error||help?<Text accessibilityRole="text" style={{color:error?p.danger:p.secondaryText}}>{error||help}</Text>:null}
 </View>;
}
