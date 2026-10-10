import React from 'react';
import {View,TextInput,Text} from 'react-native';
import {MotionAction} from './primitives';
import {useMotionPalette} from './theme';
export function MotionSearchField({label,query,onChange,placeholder='Search',disabled=false,onSubmit}:{
 label:string;query:string;onChange:(next:string)=>void;placeholder?:string;disabled?:boolean;onSubmit?:()=>void;
}) {
 const p=useMotionPalette();
 return <View style={{flexDirection:'row',alignItems:'center',gap:6}}>
  <Text accessibilityElementsHidden style={{color:p.secondaryText}}>⌕</Text>
  <TextInput accessibilityLabel={label} placeholder={placeholder} value={query} onChangeText={onChange}
   onSubmitEditing={onSubmit} returnKeyType="search" editable={!disabled}
   placeholderTextColor={p.secondaryText}
   style={{flex:1,minHeight:48,paddingHorizontal:12,borderWidth:1,borderRadius:12,
    borderColor:p.border,color:p.primaryText,backgroundColor:p.surface}}/>
  {query.length>0?<MotionAction label="Clear search" disabled={disabled} onPress={()=>onChange('')}>
   <Text style={{color:p.primaryText}}>×</Text>
  </MotionAction>:null}
 </View>;
}
