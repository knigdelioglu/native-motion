import React, {type ReactNode} from 'react';
import {View,Text} from 'react-native';
import {MotionDisclosureGroup} from './MotionDisclosureGroup';
import {toggleDisclosure,uniqueDisclosureIds} from './disclosurePolicies';
import {useMotionPalette} from './theme';
export type MotionAccordionItem={id:string;label:string;detail?:string;disabled?:boolean};

/** Single/multiple controlled accordion; children never live inside the
 * header Pressable. Missing IDs stay untouched until the host updates them. */
export function MotionAccordion({label,items,expandedIds,onChange,allowsMultiple=false,disabled=false,children}:{
  label:string;items:readonly MotionAccordionItem[];expandedIds:readonly string[];
  onChange:(ids:string[])=>void;allowsMultiple?:boolean;disabled?:boolean;
  children:(id:string)=>ReactNode;
}) {
  const p=useMotionPalette();
  if(__DEV__&&!uniqueDisclosureIds(items.map(item=>item.id)))
    throw new Error('MotionAccordionItem IDs must be unique');
  const enabled=new Set(items.filter(item=>!item.disabled).map(item=>item.id));
  return <View style={{gap:12}} accessibilityLabel={label}>
    <Text accessibilityRole="header" style={{fontWeight:'700',color:p.primaryText}}>{label}</Text>
    {items.map(item=><MotionDisclosureGroup key={item.id}
      label={item.label} detail={item.detail}
      expanded={expandedIds.includes(item.id)}
      disabled={disabled||item.disabled}
      onChange={()=>onChange(toggleDisclosure(
        item.id,expandedIds,enabled,allowsMultiple,!disabled
      ))}>
      {children(item.id)}
    </MotionDisclosureGroup>)}
  </View>;
}
