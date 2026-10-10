import React,{useState} from 'react';
import {SafeAreaView,ScrollView,Text,View} from 'react-native';
import {
 MotionButton,MotionSegmentedControl,MotionExpandableCard,MotionElasticSlider,
 MotionStatusIndicator,MotionIconButton,MotionSplitButton,MotionConfirmButton,
 MotionToggle,MotionCheckbox,MotionRadioGroup,MotionSwitch,MotionTextField,
 MotionSearchField,MotionNumberField,MotionSelect,MotionMenu,MotionDialog,
 MotionPopover,MotionTooltip,MotionTabs,MotionProgress,MotionToast,MotionSkeleton,MotionStepper,
 MotionAccordion,MotionDisclosureGroup,
 type CheckboxState, type MotionToastKind,
} from '@native-motion/react-native';

const primaryOptions=[{id:'all',label:'All'},{id:'recent',label:'Recent'},{id:'disabled',label:'Unavailable',disabled:true}];
const steps=[{id:'choose',label:'Choose'},{id:'review',label:'Review'},{id:'send',label:'Publish'}];

export default function App() {
 const [segment,setSegment]=useState('all');
 const [expanded,setExpanded]=useState(true);
 const [slider,setSlider]=useState(45);
 const [toggled,setToggled]=useState(false);
 const [checked,setChecked]=useState<CheckboxState>('mixed');
 const [selected,setSelected]=useState('all');
 const [name,setName]=useState('');
 const [query,setQuery]=useState('');
 const [quantity,setQuantity]=useState(15);
 const [menuResult,setMenuResult]=useState('Not chosen');
 const [dialogOpen,setDialogOpen]=useState(false);
 const [popoverOpen,setPopoverOpen]=useState(false);
 const [tab,setTab]=useState('all');
 const [progress,setProgress]=useState(0.4);
 const [toastOpen,setToastOpen]=useState(false);
 const [kind,setKind]=useState<MotionToastKind>('success');
 const [current,setCurrent]=useState('review');
 const [completed,setCompleted]=useState<Set<string>>(new Set(['choose']));
 const [future,setFuture]=useState(false);
 const [accordionOpen,setAccordionOpen]=useState<string[]>(['general']);
 const [multipleOpen,setMultipleOpen]=useState(false);
 const [nestedOpen,setNestedOpen]=useState(false);
 const section=(heading:string,children:React.ReactNode)=>
  <View style={{gap:12,paddingVertical:16,borderBottomWidth:1,borderColor:'#BBC5D4'}}>
    <Text accessibilityRole="header" style={{fontSize:19,fontWeight:'700'}}>{heading}</Text>{children}
  </View>;
 return <SafeAreaView style={{flex:1,backgroundColor:'#F7F8FA'}}>
  <ScrollView contentContainerStyle={{padding:18,paddingBottom:80,gap:8}}>
   <Text style={{fontSize:28,fontWeight:'700'}}>Native Motion · Expo</Text>
   <Text>Experimental 25-component interaction catalog. Host-owned states.</Text>
   {section('Actions (1, 6, 7, 8)',<>
     <MotionButton label="Show notification" onPress={()=>setToastOpen(true)}/>
     <MotionIconButton label="Help icon" icon={<Text>?</Text>} onPress={()=>setPopoverOpen(true)}/>
     <MotionSplitButton label="Export" onPress={()=>setMenuResult('Default export')}
       actions={[{id:'pdf',label:'PDF',onPress:()=>setMenuResult('PDF')},{id:'disabled',label:'Disabled',disabled:true,onPress:()=>{}}]}/>
     <MotionConfirmButton label="Remove local draft" onConfirm={()=>setMenuResult('Draft removal confirmed')}/>
     <Text>{menuResult}</Text>
   </>)}
   {section('Selections (2, 9–12, 16, 21)',<>
     <MotionSegmentedControl label="Filter" segments={primaryOptions} selection={segment} onChange={setSegment}/>
     <MotionToggle label="Compact toggle" value={toggled} onChange={setToggled}/>
     <MotionCheckbox label="Select all" state={checked} onChange={setChecked}/>
     <MotionRadioGroup label="Category" options={primaryOptions} selection={selected} onChange={setSelected}/>
     <MotionSwitch label="System switch" value={toggled} onChange={setToggled}/>
     <MotionSelect label="Dropdown choice" options={primaryOptions} selection={selected} onChange={setSelected}/>
     <MotionTabs label="Tabs" tabs={primaryOptions} selection={tab} onChange={setTab}>
       {id=><Text>Visible: {id}</Text>}
     </MotionTabs>
   </>)}
   {section('Disclosure and input (3, 4, 13–15)',<>
     <MotionExpandableCard title="More" expanded={expanded} onChange={setExpanded}>
       <Text>Independent nested content</Text>
     </MotionExpandableCard>
     <MotionElasticSlider label="Volume" value={slider} onChange={setSlider} minimum={0} maximum={95} step={5}/>
     <MotionTextField label="Name" value={name} onChangeText={setName} error={!name?'Name needed':undefined}/>
     <MotionSearchField label="Search" query={query} onChange={setQuery}/>
     <MotionNumberField label="Amount" value={quantity} onChange={setQuantity} minimum={0} maximum={95} step={5} locale="tr-TR"/>
   </>)}
   {section('v0.5 · Accordions and nested disclosure (26–27)',<>
     <MotionToggle label="Allow multiple accordion sections" value={multipleOpen} onChange={setMultipleOpen}/>
     <MotionAccordion label="Preferences" items={[
       {id:'general',label:'General'},{id:'advanced',label:'Advanced'},
       {id:'disabled',label:'Unavailable',disabled:true}
     ]} expandedIds={accordionOpen} onChange={setAccordionOpen} allowsMultiple={multipleOpen}>
       {id=><View style={{gap:12}}>
         <Text>{id+' preferences'}</Text>
         {id==='general'?<MotionDisclosureGroup label="Nested help" expanded={nestedOpen}
           onChange={setNestedOpen}>
           <MotionButton label="Nested action" onPress={()=>setMenuResult('Nested')}/>
         </MotionDisclosureGroup>:null}
       </View>}
     </MotionAccordion>
   </>)}
   {section('Native overlays (17–20)',<>
     <MotionMenu label="More actions" actions={[{id:'share',label:'Share',onPress:()=>setMenuResult('Share')}]}/>
     <MotionButton label="Open dialog" onPress={()=>setDialogOpen(true)}/>
     <MotionPopover label="Popover" visible={popoverOpen} onOpen={()=>setPopoverOpen(true)}
       onDismiss={()=>setPopoverOpen(false)}><Text>Centered modal on mobile; anchoring not yet available.</Text></MotionPopover>
     <MotionTooltip label="Why?" message="Accessible contextual explanation"/>
   </>)}
   {section('Feedback (5, 22–24)',<>
     <MotionStatusIndicator label="Upload" status="processing"/>
     <MotionProgress label="Progress" value={progress}/>
     <MotionButton label="Advance host progress" onPress={()=>setProgress(Math.min(1,progress+0.1))}/>
     <MotionToast label="Saved" kind={kind} visible={toastOpen} onDismiss={()=>setToastOpen(false)}/>
     <MotionSkeleton label="Loading cards" rows={3} avatar/>
   </>)}
   {section('Workflow (25)',<>
     <MotionStepper label="Publish flow" steps={steps} selection={current}
       completedIds={completed} allowFuture={future} onChange={setCurrent}/>
     <MotionToggle label="Allow future step" value={future} onChange={setFuture}/>
     <MotionButton label="Mark step completed" onPress={()=>setCompleted(prev=>new Set([...prev,current]))}/>
   </>)}
   <MotionDialog title="Confirm operation" visible={dialogOpen} onDismiss={()=>setDialogOpen(false)}
     onConfirm={()=>{setDialogOpen(false);setToastOpen(true);}}><Text>Host owns completion.</Text></MotionDialog>
  </ScrollView>
 </SafeAreaView>;
}
