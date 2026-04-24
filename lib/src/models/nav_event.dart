/// The kind of navigation action that was observed.
enum NavEventType {
  push,
  pop,
  replace,
  remove,
}

/// A single navigation event recorded by [NavLensController].
///
/// Events are immutable and timestamped at construction time.
class NavEvent {
  NavEvent({
    required this.type,
    required this.routeName,
    this.previousRouteName,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// What happened (push/pop/replace/remove).
  final NavEventType type;

  /// The route that became relevant (pushed, popped, newly active, removed).
  final String routeName;

  /// The other route involved, when applicable.
  ///
  /// For a push this is the route it was pushed on top of, for a pop it's the
  /// route revealed beneath, for a replace it's the route that was replaced.
  final String? previousRouteName;

  /// Wall-clock time at which the event was recorded.
  final DateTime timestamp;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        'routeName': routeName,
        if (previousRouteName != null) 'previousRouteName': previousRouteName,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() =>
      'NavEvent(${type.name}, $routeName, prev=$previousRouteName)';
}
