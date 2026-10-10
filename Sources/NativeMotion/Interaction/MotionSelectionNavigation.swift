/// Testable navigation policy independent of SwiftUI focus infrastructure.
public enum MotionSelectionNavigation {
    /// Finds the next enabled ID without wrapping around the edges.
    /// When the current ID no longer exists, falls back to the first
    /// enabled option in the requested direction.
    public static func adjacentID(
        from currentID: String,
        step: Int,
        ids: [String],
        disabledIDs: Set<String> = []
    ) -> String? {
        guard step == -1 || step == 1, !ids.isEmpty else { return nil }
        let indices: [Int]
        if let currentIndex = ids.firstIndex(of: currentID) {
            if step == 1 {
                indices = Array((currentIndex + 1)..<ids.count)
            } else {
                indices = Array((0..<currentIndex).reversed())
            }
        } else {
            indices = step == 1 ? Array(ids.indices) : Array(ids.indices.reversed())
        }
        for index in indices where !disabledIDs.contains(ids[index]) {
            return ids[index]
        }
        return nil
    }
}
