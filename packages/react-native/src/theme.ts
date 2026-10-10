import { useEffect, useState } from 'react';
import { AccessibilityInfo, useColorScheme } from 'react-native';

export type MotionPalette = {
  background: string; surface: string; elevatedSurface: string;
  primaryText: string; secondaryText: string; accent: string;
  accentText: string; border: string; success: string;
  warning: string; danger: string;
};
export const lightPalette: MotionPalette = {
  background:'#F7F8FA',surface:'#FFFFFF',elevatedSurface:'#FFFFFF',
  primaryText:'#171A21',secondaryText:'#526074',accent:'#245DCC',
  accentText:'#FFFFFF',border:'#D5DDE8',success:'#187448',
  warning:'#875000',danger:'#B62D39',
};
export const darkPalette: MotionPalette = {
  background:'#141922',surface:'#1D2531',elevatedSurface:'#293241',
  primaryText:'#F5F7FB',secondaryText:'#B5C0D0',accent:'#91B4FF',
  accentText:'#101925',border:'#445064',success:'#74DFA7',
  warning:'#FFCB70',danger:'#FF9198',
};
export const spacing = { xSmall:4, small:8, medium:12, large:16, xLarge:24, xxLarge:32 } as const;
export const radii = { control:12, card:18, panel:24 } as const;
export const motionIntent = { responsive:180, gentle:290, morph:250, settle:350 } as const;
export function useMotionPalette(): MotionPalette {
  return useColorScheme() === 'dark' ? darkPalette : lightPalette;
}
export function useReducedMotion(): boolean {
  const [reduced, setReduced] = useState(true);
  useEffect(() => {
    let active = true;
    AccessibilityInfo.isReduceMotionEnabled()
      .then((v) => { if (active) setReduced(v); })
      .catch(() => { if (active) setReduced(true); });
    const sub = AccessibilityInfo.addEventListener('reduceMotionChanged', setReduced);
    return () => { active = false; sub.remove(); };
  }, []);
  return reduced;
}
