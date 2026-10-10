/// Deterministic design-token snapshots run on macOS and Linux.
/// These are textual regression fixtures, not screenshots or UI-render tests.
public enum MotionVisualManifest {
    private static let namedRoles: [(String, NativeMotionColorRole)] = [
        ("background", .background),
        ("surface", .surface),
        ("elevatedSurface", .elevatedSurface),
        ("primaryText", .primaryText),
        ("secondaryText", .secondaryText),
        ("accent", .accent),
        ("accentText", .accentText),
        ("border", .border),
        ("success", .success),
        ("warning", .warning),
        ("danger", .danger)
    ]

    private static func hex(_ rgb: NativeMotionRGB) -> String {
        let red = Int((rgb.red * 255).rounded())
        let green = Int((rgb.green * 255).rounded())
        let blue = Int((rgb.blue * 255).rounded())
        let digits = "0123456789ABCDEF"
        let bytes = [red, green, blue]
        var value = "#"
        for byte in bytes {
            value.append(digits[digits.index(digits.startIndex, offsetBy: byte >> 4)])
            value.append(digits[digits.index(digits.startIndex, offsetBy: byte & 15)])
        }
        return value
    }

    public static func snapshot(appearance: NativeMotionAppearance) -> String {
        let name = appearance == .dark ? "dark" : "light"
        let header = ["native-motion-manifest:v1", "appearance:\(name)"]
        let colors = namedRoles.map { roleName, role in
            "\(roleName)=\(hex(NativeMotionPalette.color(role, appearance: appearance)))"
        }
        let geometry = [
            "spacing=4,8,12,16,24,32",
            "radius=12,18,24",
            "controlHeight=36,44,52",
            "motion=responsive,gentle,morph,settle"
        ]
        return (header + colors + geometry).joined(separator: "\n") + "\n"
    }
}
