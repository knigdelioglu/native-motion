#if canImport(SwiftUI)
import SwiftUI

public enum NativeMotionTheme {
    public static func color(_ role: NativeMotionColorRole, colorScheme: ColorScheme) -> Color {
        let appearance: NativeMotionAppearance = colorScheme == .dark ? .dark : .light
        let rgb = NativeMotionPalette.color(role, appearance: appearance)
        return Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
    }
}

public enum NativeMotionAnimations {
    public static func spring(_ preset: NativeMotionPreset, reduceMotion: Bool) -> Animation? {
        guard !reduceMotion else { return nil }
        let parameters = NativeMotionTiming.spring(for: preset)
        return .spring(response: parameters.response, dampingFraction: parameters.dampingFraction)
    }
}
#endif
