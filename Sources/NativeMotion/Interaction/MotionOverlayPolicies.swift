/// Platform-neutral guardrails for native selection, menu and modal actions.
/// UI renderers own layout; the host owns selection, side effects and results.
public enum MotionOverlayPolicies {
    public static func identifiersAreUnique(_ identifiers: [String]) -> Bool {
        Set(identifiers).count == identifiers.count
    }

    /// Preserves a missing/disabled host selection; only user intent to choose
    /// a valid enabled option can request a new value.
    public static func canSelect(
        id: String,
        currentID: String,
        enabledIDs: Set<String>,
        controlEnabled: Bool
    ) -> Bool {
        controlEnabled && id != currentID && enabledIDs.contains(id)
    }

    public static func canOpenMenu(
        isEnabled: Bool,
        enabledActionCount: Int
    ) -> Bool {
        isEnabled && enabledActionCount > 0
    }

    public static func canPresentDialog(isEnabled: Bool) -> Bool {
        isEnabled
    }

    /// Dialog completion never gets fabricated by UI controls. Busy phases
    /// suppress repeated host actions and interactive dismissal.
    public static func canConfirmDialog(
        isEnabled: Bool,
        isLoading: Bool
    ) -> Bool {
        isEnabled && !isLoading
    }

    public static func canDismissDialog(isLoading: Bool) -> Bool {
        !isLoading
    }
}
