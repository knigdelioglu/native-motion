/// Host-controlled notification severity. It describes a supplied event,
/// never the success of a task inferred by the UI library.
public enum MotionToastKind: String, CaseIterable, Sendable {
    case neutral, success, warning, failure
}

public enum MotionToastPolicy {
    public static func canDismiss(isPresented: Bool) -> Bool { isPresented }
}

/// Progress through workflow steps belongs to the consuming application.
/// Prior items are NOT marked completed automatically.
public enum MotionWorkflowStepState: String, Equatable, Sendable {
    case current, completed, pending
}

public enum MotionStepperPolicy {
    public static func identifiersAreUnique(_ ids: [String]) -> Bool {
        Set(ids).count == ids.count
    }

    public static func state(
        for id: String,
        currentID: String,
        completedIDs: Set<String>
    ) -> MotionWorkflowStepState {
        if id == currentID { return .current }
        return completedIDs.contains(id) ? .completed : .pending
    }

    public static func canNavigate(
        to id: String,
        currentID: String,
        ids: [String],
        completedIDs: Set<String>,
        disabledIDs: Set<String>,
        isEnabled: Bool,
        allowsFutureNavigation: Bool
    ) -> Bool {
        guard isEnabled,
              ids.contains(currentID),
              ids.contains(id),
              id != currentID,
              !disabledIDs.contains(id)
        else { return false }

        return completedIDs.contains(id) || allowsFutureNavigation
    }

    /// Keyboard navigation never wraps and never bypasses a host gate.
    public static func adjacentAllowed(
        from focusedID: String,
        currentID: String,
        direction: Int,
        ids: [String],
        completedIDs: Set<String>,
        disabledIDs: Set<String>,
        allowsFutureNavigation: Bool,
        isEnabled: Bool
    ) -> String? {
        guard direction == -1 || direction == 1,
              let currentIndex = ids.firstIndex(of: focusedID)
        else { return nil }
        var index = currentIndex + direction
        while ids.indices.contains(index) {
            let candidate = ids[index]
            if canNavigate(
                to: candidate,
                currentID: currentID,
                ids: ids,
                completedIDs: completedIDs,
                disabledIDs: disabledIDs,
                isEnabled: isEnabled,
                allowsFutureNavigation: allowsFutureNavigation
            ) {
                return candidate
            }
            index += direction
        }
        return nil
    }
}
