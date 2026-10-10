/// Host-owned overlay and mobile detent transitions.
public enum MotionSurfacePolicies {
    public static func canOpen(isEnabled: Bool, isPresented: Bool) -> Bool {
        isEnabled && !isPresented
    }

    public static func canDismiss(isPresented: Bool, isBusy: Bool) -> Bool {
        isPresented && !isBusy
    }

    /// A pull-to-close must be deliberate, and loading work cannot be
    /// interrupted by an accidental downward gesture.
    public static func shouldDismissDrag(
        translation: Double, isBusy: Bool, threshold: Double = 96
    ) -> Bool {
        !isBusy && translation > max(40, threshold)
    }
}

public enum MotionBottomDetent: String, CaseIterable, Sendable {
    case compact, medium, expanded
}

public enum MotionBottomDetentPolicy {
    public static func next(
        from current: MotionBottomDetent,
        dragDown: Bool
    ) -> MotionBottomDetent? {
        switch (current, dragDown) {
        case (.expanded, true): return .medium
        case (.medium, true): return .compact
        case (.compact, true): return nil
        case (.compact, false): return .medium
        case (.medium, false): return .expanded
        case (.expanded, false): return .expanded
        }
    }
}
