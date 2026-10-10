import Foundation

/// Validation result for a native numeric form field. No application state is
/// mutated while parsing. Invalid input is kept visible for correction.
public enum MotionNumberFieldResult: Equatable, Sendable {
    case accepted(Double)
    case invalid
}

public enum MotionNumberFieldPolicy {
    /// Strict decimal input for the supplied locale. No grouping, exponents,
    /// partial parses, NaN or infinity. A short final step is selectable.
    public static func parse(
        _ input: String,
        scale: MotionSliderScale,
        locale: Locale
    ) -> MotionNumberFieldResult {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid }

        let separator = locale.decimalSeparator ?? "."
        guard !separator.isEmpty else { return .invalid }

        let unsigned: String
        if trimmed.first == "-" || trimmed.first == "+" {
            unsigned = String(trimmed.dropFirst())
        } else {
            unsigned = trimmed
        }
        let parts = unsigned.components(separatedBy: separator)
        guard parts.count <= 2,
              !parts.isEmpty,
              parts.contains(where: { !$0.isEmpty }),
              parts.allSatisfy({ part in
                  part.allSatisfy { $0 >= "0" && $0 <= "9" }
              })
        else { return .invalid }

        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.isLenient = false
        guard let number = formatter.number(from: trimmed)?.doubleValue,
              number.isFinite else { return .invalid }
        return .accepted(scale.snapped(number))
    }

    public static func display(
        _ value: Double,
        scale: MotionSliderScale,
        locale: Locale
    ) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 9
        return formatter.string(from: NSNumber(value: scale.snapped(value)))
            ?? String(scale.snapped(value))
    }

    public static func adjacent(
        to value: Double,
        direction: Int,
        scale: MotionSliderScale
    ) -> Double {
        scale.adjacentValue(from: value, direction: direction)
    }
}
