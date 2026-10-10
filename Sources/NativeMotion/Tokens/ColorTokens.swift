import Foundation

/// Framework-independent sRGB for reusable design tokens.
public struct NativeMotionRGB: Equatable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double

    public init(hex: UInt32) {
        red = Double((hex >> 16) & 255) / 255
        green = Double((hex >> 8) & 255) / 255
        blue = Double(hex & 255) / 255
    }

    private static func linearize(_ value: Double) -> Double {
        value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
    }

    public var relativeLuminance: Double {
        0.2126 * Self.linearize(red) + 0.7152 * Self.linearize(green) + 0.0722 * Self.linearize(blue)
    }

    public func contrastRatio(against other: Self) -> Double {
        let brighter = max(relativeLuminance, other.relativeLuminance)
        let darker = min(relativeLuminance, other.relativeLuminance)
        return (brighter + 0.05) / (darker + 0.05)
    }
}

public enum NativeMotionAppearance: CaseIterable, Sendable { case light, dark }
public enum NativeMotionColorRole: CaseIterable, Sendable {
    case background, surface, elevatedSurface, primaryText, secondaryText
    case accent, accentText, border, success, warning, danger
}

public enum NativeMotionPalette {
    public static func color(_ role: NativeMotionColorRole, appearance: NativeMotionAppearance) -> NativeMotionRGB {
        let value: UInt32
        switch (appearance, role) {
        case (.light, .background): value = 0xF7F8FA
        case (.light, .surface): value = 0xFFFFFF
        case (.light, .elevatedSurface): value = 0xFFFFFF
        case (.light, .primaryText): value = 0x171A21
        case (.light, .secondaryText): value = 0x526074
        case (.light, .accent): value = 0x245DCC
        case (.light, .accentText): value = 0xFFFFFF
        case (.light, .border): value = 0xD5DDE8
        case (.light, .success): value = 0x187448
        case (.light, .warning): value = 0x875000
        case (.light, .danger): value = 0xB62D39
        case (.dark, .background): value = 0x141922
        case (.dark, .surface): value = 0x1D2531
        case (.dark, .elevatedSurface): value = 0x293241
        case (.dark, .primaryText): value = 0xF5F7FB
        case (.dark, .secondaryText): value = 0xB5C0D0
        case (.dark, .accent): value = 0x91B4FF
        case (.dark, .accentText): value = 0x101925
        case (.dark, .border): value = 0x445064
        case (.dark, .success): value = 0x74DFA7
        case (.dark, .warning): value = 0xFFCB70
        case (.dark, .danger): value = 0xFF9198
        }
        return .init(hex: value)
    }
}
