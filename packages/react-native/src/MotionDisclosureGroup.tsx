import React, {type ReactNode} from 'react';
import {Text, View} from 'react-native';
import {MotionAction, MotionPanel} from './primitives';
import {useMotionPalette} from './theme';

/** Controlled disclosure region. Children may contain another disclosure or
 * independently focusable actions. Expansion state is always host-owned. */
export function MotionDisclosureGroup({label,detail,expanded,onChange,disabled=false,children}:{
  label:string;detail?:string;expanded:boolean;
  onChange:(next:boolean)=>void;disabled?:boolean;children:ReactNode;
}) {
  const p=useMotionPalette();
  return <MotionPanel style={{gap:8}}>
    <MotionAction
      label={label+(expanded?', expanded':', collapsed')}
      onPress={()=>onChange(!expanded)}
      disabled={disabled}
      selected={expanded}
      style={{alignItems:'stretch'}}
    >
      <View style={{flexDirection:'row',alignItems:'center',gap:8}}>
        <View style={{flex:1}}>
          <Text style={{fontWeight:'600',color:p.primaryText}}>{label}</Text>
          {detail?<Text style={{color:p.secondaryText}}>{detail}</Text>:null}
        </View>
        <Text accessibilityElementsHidden style={{color:p.secondaryText}}>{expanded?'▴':'▾'}</Text>
      </View>
    </MotionAction>
    {expanded?<View accessibilityLabel={label+' content'} style={{padding:8}}>
      {children}
    </View>:null}
  </MotionPanel>;
}
