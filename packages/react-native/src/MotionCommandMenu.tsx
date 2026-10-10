import React,{useMemo,type ReactNode} from 'react';
import {Modal,ScrollView,Text,TextInput,View} from 'react-native';
import {MotionAction,MotionPanel} from './primitives';
import {visibleCommands,canExecuteCommand} from './commandPolicies';
import {uniqueIds} from './policies';
import {useMotionPalette} from './theme';

export type MotionCommandItem={
 id:string;title:string;keywords?:readonly string[];disabled?:boolean;
 onPress:()=>void;
};
/** Explicitly controlled command palette. Search/selection never fabricates
 * completion; host owns visible/query and each command side-effect. */
export function MotionCommandMenu({
 label,commands,visible,query,onQueryChange,onDismiss,children,
}:{
 label:string;commands:readonly MotionCommandItem[];visible:boolean;
 query:string;onQueryChange:(value:string)=>void;onDismiss:()=>void;
 children?:ReactNode;
}) {
 const p=useMotionPalette();
 if(__DEV__&&!uniqueIds(commands.map(c=>c.id)))
   throw new Error('MotionCommandItem IDs must be unique');
 const filtered=useMemo(()=>visibleCommands(commands,query),[commands,query]);
 const execute=(item:MotionCommandItem)=>{
  if(!canExecuteCommand(item.id,commands,visible))return;
  onDismiss();item.onPress();
 };
 return <Modal visible={visible} transparent animationType="fade"
  onRequestClose={onDismiss} accessibilityViewIsModal>
  <View style={{flex:1,justifyContent:'center',padding:18,backgroundColor:'#0008'}}>
   <MotionPanel style={{maxHeight:'86%',gap:12}}>
    <View style={{flexDirection:'row',alignItems:'center',gap:8}}>
     <Text accessibilityRole="header" style={{flex:1,fontSize:19,
       fontWeight:'700',color:p.primaryText}}>{label}</Text>
     <MotionAction label="Close commands" onPress={onDismiss}/>
    </View>
    <TextInput accessibilityLabel="Search commands" autoFocus
      value={query} onChangeText={onQueryChange} placeholder="Search commands"
      placeholderTextColor={p.secondaryText} returnKeyType="search"
      style={{color:p.primaryText,borderColor:p.border,borderWidth:1,
        borderRadius:12,minHeight:48,paddingHorizontal:12}}/>
    <ScrollView keyboardShouldPersistTaps="handled">
     {filtered.length===0?<Text style={{color:p.secondaryText}}>No matching commands</Text>:null}
     {filtered.map(item=><MotionAction key={item.id} label={item.title}
       disabled={item.disabled} onPress={()=>execute(item)}/>)}
    </ScrollView>
    {children}
   </MotionPanel>
  </View>
 </Modal>;
}
