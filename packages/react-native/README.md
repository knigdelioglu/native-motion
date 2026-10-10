# Native Motion — React Native + Expo (experimental)

This is an **independent React Native implementation**, built using React
Native primitives, not a WebView or a wrapper around Flutter or SwiftUI.
It can be imported into an Expo-managed application; no Expo native module,
Reanimated or gesture-handler dependency is required for the current core.

### Installation in an existing Expo app

Use a local package checkout or a Git monorepo reference supported by your
package manager (a Git URL alone does not select the `packages/react-native`
subdirectory on all npm clients):

```sh
# from the Expo app folder, with the repository checked out next to it
npm install ../native-motion/packages/react-native
# alternatively in an npm workspace: "@native-motion/react-native": "file:../native-motion/packages/react-native"
```

Keep React and React Native versions supplied by the Expo SDK rather than
installing a second copy. SDK 55 pairs React Native 0.83 with React 19.2;
verify current pairings with Expo's SDK version reference.

```tsx
import React, {useState} from 'react';
import {View} from 'react-native';
import {MotionButton, MotionCheckbox, MotionToast} from '@native-motion/react-native';

export default function Example() {
  const [state,setState] = useState<'unchecked'|'checked'|'mixed'>('mixed');
  const [visible,setVisible] = useState(false);
  return <View style={{gap:16,padding:24}}>
    <MotionButton label="Save" onPress={() => setVisible(true)}/>
    <MotionCheckbox label="Include attachment" state={state} onChange={setState}/>
    <MotionToast label="Saved by host" kind="success" visible={visible}
      onDismiss={() => setVisible(false)}/>
  </View>;
}
```

### v0.2 inventory and guarantees

All 25 conceptual names are **source-implemented** in
`src/Motion*.tsx` and exported through `src/index.ts`. These are
**experimental APIs**, *not* 25 fully device-verified SwiftUI behavior equivalents.
The state is host-controlled unless explicitly documented (temporary confirmation
arm, menu visibility, input draft). No control fabricates a successful operation.

The renderer has built-in theme tokens matching the SwiftUI light/dark
reference palettes and four motion intent names. Platform-specific
animations are deliberately distinct. It honors OS Reduce Motion for
`MotionSkeleton`. Additional component motion, keyboard and focus QA is
still required.

**Known platform differences / release blockers:**

- `MotionPopover` and `MotionTooltip` use React Native transparent
  `Modal`; these are **centered, not truly anchored or collision-aware**.
- Menus/selects use modal option sheets instead of the iOS native picker
  or Android native context menu. Real TalkBack, VoiceOver and hardware
  keyboard focus-loop audits remain open.
- `MotionElasticSlider` uses native responder events, not yet calibrated
  elastic physics or track-direction parity under RTL.
- There is no Expo router/navigation dependency, no notification timer,
  no clipboard/permissions/network service and no automatic success state.
- Android/iOS screen reader, large text, RTL, Reduce Motion, rotation,
  tap target and real-frame performance acceptance is incomplete.
- No React Native for macOS compatibility promise. Primary targets are
  Expo Android and iOS. Web integration needs separate checks.

### Quality commands

```sh
cd packages/react-native
npm install
npm run typecheck
npm run test:policies
```

The CI additionally confirms exactly **25 public exports and 25 concrete
files**, checks tokens against the Swift reference fixtures, and checks
the single-source component contract. A passing typecheck is **not** a
substitute for Expo on-device behavior or screenshot golden reviews.

### Contract for every new component (v0.5, v1.0+)

1. Register one **conceptual ID** in the platform-neutral inventory.
2. Implement native SwiftUI, Flutter and React Native renderers
   (Compose remains separately beta-scoped); if any are incomplete,
   mark them `planned` explicitly and do not advertise release parity.
3. Keep host-owned result/selection, semantic color/motion intent and
   accessible alternatives to gesture-only interactions.
4. Add React Native TypeScript compile/type checks, pure behavioral
   tests, accessible Expo demo states and visual/device QA evidence.
5. Any platform omitted from a release needs an explicit waiver and
   support-matrix note; **no silently missing components**.

See `docs/RENDERER_POLICY.md` for the ongoing cross-platform rule.
