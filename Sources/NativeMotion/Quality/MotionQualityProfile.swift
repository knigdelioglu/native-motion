/// Shared expectations used by native renderers and regression tooling.
/// The exact visual physics are platform-local. The states and scenarios are not.
public enum MotionQualityScenario: String, CaseIterable, Sendable {
    case light
    case dark
    case reducedMotion
    case largeText
}

public enum MotionQualityContract {
    /// These baselines describe which cases every renderer's catalog should expose.
    /// They are not an assertion that screenshots look identical across platforms.
    public static let expectedScenarios: [MotionQualityScenario] = [
        .light, .dark, .reducedMotion, .largeText
    ]

    public static let componentNames: [String] = [
        "MotionButton",
        "MotionSegmentedControl",
        "MotionExpandableCard",
        "MotionElasticSlider",
        "MotionStatusIndicator"
    ]
}
