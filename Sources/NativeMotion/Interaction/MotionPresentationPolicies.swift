/// Deterministic guardrails shared by native overlay and tab renderers.
/// The host owns presentation/selection; no policy mutates application state.
public enum MotionPresentationPolicies {
    public static func canOpen(isEnabled: Bool, isPresented: Bool) -> Bool {
        isEnabled && !isPresented
    }

    public static func canDismiss(isPresented: Bool) -> Bool {
        isPresented
    }

    public static func identifiersAreUnique(_ ids: [String]) -> Bool {
        Set(ids).count == ids.count
    }

    public static func canSelectTab(
        id: String,
        currentID: String,
        enabledIDs: Set<String>,
        controlEnabled: Bool
    ) -> Bool {
        controlEnabled && id != currentID && enabledIDs.contains(id)
    }

    public static func adjacentTab(
        from currentID: String,
        step: Int,
        ids: [String],
        disabledIDs: Set<String>
    ) -> String? {
        MotionSelectionNavigation.adjacentID(
            from: currentID,
            step: step,
            ids: ids,
            disabledIDs: disabledIDs
        )
    }
}
