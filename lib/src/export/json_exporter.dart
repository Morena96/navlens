import 'dart:convert';

import '../state/navlens_controller.dart';

/// Serialises the current [NavLensController] state into a JSON string.
///
/// The format is deliberately stable and versioned so downstream consumers
/// (CLI, docs pipelines, teammates) can parse it safely.
class NavLensJsonExporter {
  const NavLensJsonExporter({this.controller});

  final NavLensController? controller;

  /// Version of the on-wire schema.
  static const int schemaVersion = 1;

  /// Returns the NavLens state as a pretty-printed JSON string.
  String export({bool pretty = true}) {
    final data = toMap();
    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(data);
    }
    return jsonEncode(data);
  }

  /// Returns the raw map that [export] encodes. Exposed for testing and for
  /// callers that want to embed the snapshot in a larger document.
  Map<String, dynamic> toMap() {
    final ctrl = controller ?? NavLensController.instance;
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'currentStack': ctrl.currentStack,
      'currentRoute': ctrl.currentRoute,
      'flowGraph': ctrl.flowGraph
          .map((parent, children) => MapEntry(parent, children.toList()..sort())),
      'timeline': ctrl.timeline.map((e) => e.toJson()).toList(),
    };
  }
}
