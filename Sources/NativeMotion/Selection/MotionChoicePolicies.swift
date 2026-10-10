/// Pure, framework-independent selection transitions used by native renderers.
/// The host keeps authoritative values; these routines never mutate app state.
public enum MotionCheckboxState: String, CaseIterable, Equatable, Sendable {
    case unchecked
    case checked
    case mixed
}

public enum MotionCheckboxPolicy {
    /// Tapping mixed resolves to checked. The host may independently set mixed
    /// when aggregating child selections; user taps always yield binary state.
    public static func next(_ current: MotionCheckboxState) -> MotionCheckboxState {
        current == .checked ? .unchecked : .checked
    }
}

public enum MotionTogglePolicy {
    public static func next(_ current: Bool) -> Bool { !current }
}
