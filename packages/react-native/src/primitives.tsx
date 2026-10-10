import React, { type ReactNode } from 'react';
import { Pressable, Text, View, type StyleProp, type ViewStyle } from 'react-native';
import { radii, spacing, useMotionPalette } from './theme';

export function MotionPanel({children,style}:{children:ReactNode,style?:StyleProp<ViewStyle>}) {
  const p=useMotionPalette();
  return <View style={[{padding:spacing.large,borderRadius:radii.card,borderWidth:1,borderColor:p.border,backgroundColor:p.surface},style]}>{children}</View>;
}
export function MotionText({children,muted=false,large=false}:{children:ReactNode,muted?:boolean,large?:boolean}) {
  const p=useMotionPalette();
  return <Text style={{color:muted?p.secondaryText:p.primaryText,fontSize:large?17:14,fontWeight:large?'600':'400'}}>{children}</Text>;
}
export function MotionAction({label,onPress,disabled=false,children,selected=false,destructive=false,style}:{
 label:string;onPress:()=>void;disabled?:boolean;children?:ReactNode;selected?:boolean;destructive?:boolean;style?:StyleProp<ViewStyle>;
}) {
 const p=useMotionPalette();
 return <Pressable accessibilityRole="button" accessibilityLabel={label}
   accessibilityState={{disabled,selected}} disabled={disabled} onPress={onPress}
   style={({pressed})=>[{paddingHorizontal:14,minHeight:44,justifyContent:'center',alignItems:'center',
   borderRadius:radii.control,borderWidth:1,borderColor:p.border,
   backgroundColor:selected?p.elevatedSurface:p.surface,opacity:disabled?0.5:pressed?0.75:1},style]}>
   {children??<Text style={{color:destructive?p.danger:p.primaryText,fontWeight:'600'}}>{label}</Text>}
 </Pressable>;
}
