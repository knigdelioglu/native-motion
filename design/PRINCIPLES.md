# Native Motion principles

Native Motion is an independent, native-first design system. Its original
source is informed by the general idea of calm, precise interactions; it is
not a port of another UI library.

1. **Meaningful motion:** Communicate action, state, and continuity.
2. **Platform-native input:** Respect keyboard, touch, hover, accessibility and focus.
3. **Perceptual consistency:** Match behaviors, not identical spring constants.
4. **Honest feedback:** Never use animation to masquerade as completed work.
5. **Calm by default:** Prompt reaction, short transition, controlled settling.
6. **Accessible by construction:** Dynamic Type, VoiceOver, contrast, Reduce Motion.
7. **No application coupling:** Host code owns persistence, routing and async work.

## Motion presets

| Preset | Intended behavior |
| --- | --- |
| responsive | Short feedback for press and selection |
| gentle | Low-distraction surface transitions |
| morph | Shape, layout and status changes |
| settle | Gesture release and spring recovery |

When Reduce Motion is enabled, avoid zoom and physical movement. Treat
accessibility, not decorative animation, as the higher priority.

## Component contract

Every public component must document its state model, platform adaptations,
keyboard behavior, accessible descriptions and Reduce Motion fallback.
The component must not depend on an existing application or backend.
