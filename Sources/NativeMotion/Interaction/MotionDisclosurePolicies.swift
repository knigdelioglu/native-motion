/// v0.5 disclosure-group and accordion selection logic, independent of UI.
/// The host remains authoritative; requests never fabricate completion.
public enum MotionDisclosurePolicies {
    public static func identifiersAreUnique(_ ids: [String]) -> Bool {
        Set(ids).count == ids.count
    }

    public static func toggle(
        id: String,
        expandedIDs: Set<String>,
        enabledIDs: Set<String>,
        allowsMultiple: Bool,
        controlEnabled: Bool = true
    ) -> Set<String> {
        guard controlEnabled, enabledIDs.contains(id) else { return expandedIDs }
        if expandedIDs.contains(id) {
            return expandedIDs.subtracting([id])
        }
        return allowsMultiple ? expandedIDs.union([id]) : [id]
    }
}
