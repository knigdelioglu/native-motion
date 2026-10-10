/// State-only action policies are independent of SwiftUI and run in Linux CI.
/// They never assume work has succeeded; applications own operation phases.

public enum MotionConfirmationState: String, Equatable, Sendable {
    case idle, armed
}

public enum MotionConfirmationEvent: Equatable, Sendable {
    case primaryTap, cancel, reset
}

public struct MotionConfirmationTransition: Equatable, Sendable {
    public let next: MotionConfirmationState
    public let firesAction: Bool

    public init(next: MotionConfirmationState, firesAction: Bool) {
        self.next = next
        self.firesAction = firesAction
    }
}

public enum MotionConfirmButtonPolicy {
    /// A deliberate second activation is required. Cancel/Reset never fire.
    public static func transition(
        from state: MotionConfirmationState,
        event: MotionConfirmationEvent
    ) -> MotionConfirmationTransition {
        switch event {
        case .cancel, .reset:
            return .init(next: .idle, firesAction: false)
        case .primaryTap:
            return state == .idle
                ? .init(next: .armed, firesAction: false)
                : .init(next: .idle, firesAction: true)
        }
    }
}

public enum MotionSplitButtonPolicy {
    /// A split button always has an independent primary action. The secondary
    /// menu is unavailable when there are no enabled alternatives.
    public static func canOpenMenu(
        isLoading: Bool,
        enabledAlternativeCount: Int
    ) -> Bool {
        !isLoading && enabledAlternativeCount > 0
    }

    public static func identifiersAreUnique(_ ids: [String]) -> Bool {
        Set(ids).count == ids.count
    }
}
