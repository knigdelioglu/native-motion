import React from 'react';
import { ActivityIndicator, Text } from 'react-native';
import { MotionAction } from './primitives';
import { useMotionPalette } from './theme';
export type MotionButtonPhase='idle'|'loading'|'success'|'failure';
export type MotionButtonVariant='primary'|'secondary'|'ghost'|'destructive';
export function MotionButton({label,onPress,phase='idle',variant='primary',disabled=false}:{
 label:string;onPress:()=>void;phase?:MotionButtonPhase;variant?:MotionButtonVariant;disabled?:boolean;
}) {
 const p=useMotionPalette(); const busy=phase==='loading';
 return <MotionAction label={label} disabled={disabled||busy} onPress={onPress}
   selected={variant==='primary'} destructive={variant==='destructive'}>
   {busy?<ActivityIndicator accessibilityLabel="In progress" color={p.accent}/>
   :<Text style={{fontWeight:'600',color:variant==='destructive'?p.danger:p.primaryText}}>
     {phase==='success'?'✓ ':phase==='failure'?'! ':''}{label}
   </Text>}
 </MotionAction>;
}
