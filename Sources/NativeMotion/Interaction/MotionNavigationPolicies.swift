/// Platform-independent selection/pagination invariants. The caller owns
/// the current location, page number and navigation effects.
public enum MotionNavigationPolicies {
    public static func unique(_ ids: [String]) -> Bool {
        Set(ids).count == ids.count
    }

    public static func canNavigate(
        to id: String,
        currentID: String,
        enabledIDs: Set<String>
    ) -> Bool {
        id != currentID && enabledIDs.contains(id)
    }

    /// Returns a stable bounded page window, including the current page,
    /// without allocating huge arrays for large result sets.
    public static func pages(
        current: Int,
        total: Int,
        maxVisible: Int = 5
    ) -> [Int] {
        guard total > 0 else { return [] }
        let count = min(max(1, maxVisible), total)
        let safe = min(total, max(1, current))
        let first = min(
            max(1, safe - count / 2),
            total - count + 1
        )
        return Array(first..<(first + count))
    }

    public static func adjacent(
        current: Int, total: Int, delta: Int
    ) -> Int? {
        guard total > 0, delta == -1 || delta == 1 else { return nil }
        let safe = min(total, max(1, current))
        let next = safe + delta
        return (1...total).contains(next) ? next : nil
    }
}
