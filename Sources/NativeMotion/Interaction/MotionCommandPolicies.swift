import Foundation

/// Source-only command-search and action validation; host owns outcomes.
public enum MotionCommandPolicies {
    public static func identifiersAreUnique(_ ids: [String]) -> Bool {
        Set(ids).count == ids.count
    }

    public static func matches(
        query: String,
        title: String,
        keywords: [String]
    ) -> Bool {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return true }
        return ([title] + keywords).contains {
            $0.range(
                of: needle,
                options: [.caseInsensitive, .diacriticInsensitive]
            ) != nil
        }
    }

    public static func canExecute(
        id: String, validEnabledIDs: Set<String>, isPresented: Bool
    ) -> Bool {
        isPresented && validEnabledIDs.contains(id)
    }
}
