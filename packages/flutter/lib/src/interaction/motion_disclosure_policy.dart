/// Deterministic selection transitions shared with the SwiftUI and RN
/// conceptual contract. Widgets never mutate host state themselves.
abstract final class MotionDisclosurePolicy {
  static bool uniqueIds(Iterable<String> ids) {
    final List<String> values = ids.toList();
    return values.toSet().length == values.length;
  }

  static Set<String> toggle({
    required String id,
    required Set<String> expandedIds,
    required Set<String> enabledIds,
    required bool allowsMultiple,
    bool controlEnabled = true,
  }) {
    if (!controlEnabled || !enabledIds.contains(id)) return {...expandedIds};
    if (expandedIds.contains(id)) return {...expandedIds}..remove(id);
    return allowsMultiple ? ({...expandedIds}..add(id)) : <String>{id};
  }
}
