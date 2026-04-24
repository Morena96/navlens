import 'package:flutter/widgets.dart';

import '../models/nav_event.dart';
import '../models/nav_node.dart';

/// Central state for NavLens.
///
/// Holds the navigation [timeline], the currently mounted [currentStack], and
/// a [flowGraph] of parent → children edges derived from observed pushes.
/// The singleton is observed by [NavLensObserver] and read by the inspector
/// UI. Listens via [ChangeNotifier], so any widget can rebuild on changes
/// with a simple `AnimatedBuilder`.
class NavLensController extends ChangeNotifier {
  NavLensController._();

  /// Process-wide singleton used by observers and UI.
  static final NavLensController instance = NavLensController._();

  /// Maximum number of events retained in [timeline]. Older events are
  /// dropped to keep the debug overlay responsive on long sessions.
  static const int maxTimelineLength = 500;

  final List<NavEvent> _timeline = <NavEvent>[];
  final List<String> _currentStack = <String>[];
  final Map<String, Set<String>> _flowGraph = <String, Set<String>>{};
  NavigatorState? _activeNavigator;

  /// Immutable view of recorded events in insertion order (oldest first).
  List<NavEvent> get timeline => List<NavEvent>.unmodifiable(_timeline);

  /// Immutable view of the currently mounted route names, bottom to top.
  List<String> get currentStack => List<String>.unmodifiable(_currentStack);

  /// The route currently visible to the user, if any.
  String? get currentRoute =>
      _currentStack.isEmpty ? null : _currentStack.last;

  /// Immutable view of the parent → children push relationships.
  Map<String, Set<String>> get flowGraph => Map<String, Set<String>>.unmodifiable(
        _flowGraph.map(
          (key, value) => MapEntry(key, Set<String>.unmodifiable(value)),
        ),
      );

  /// Records a push of [routeName] from [previousRouteName] (if any).
  void recordPush(String routeName, {String? previousRouteName}) {
    _timeline.add(NavEvent(
      type: NavEventType.push,
      routeName: routeName,
      previousRouteName: previousRouteName,
    ));
    _trimTimeline();
    _currentStack.add(routeName);
    if (previousRouteName != null) {
      _addEdge(previousRouteName, routeName);
    }
    notifyListeners();
  }

  /// Records a pop of [routeName]; [previousRouteName] is the route revealed
  /// beneath.
  void recordPop(String routeName, {String? previousRouteName}) {
    _timeline.add(NavEvent(
      type: NavEventType.pop,
      routeName: routeName,
      previousRouteName: previousRouteName,
    ));
    _trimTimeline();
    _removeFromStack(routeName);
    notifyListeners();
  }

  /// Records a replace of [oldRouteName] with [newRouteName].
  void recordReplace({
    required String? oldRouteName,
    required String newRouteName,
  }) {
    _timeline.add(NavEvent(
      type: NavEventType.replace,
      routeName: newRouteName,
      previousRouteName: oldRouteName,
    ));
    _trimTimeline();
    if (oldRouteName != null) {
      final index = _currentStack.lastIndexOf(oldRouteName);
      if (index != -1) {
        _currentStack[index] = newRouteName;
      } else {
        _currentStack.add(newRouteName);
      }
    } else {
      _currentStack.add(newRouteName);
    }
    // A replace is a "transition" from old to new, so record it in the graph
    // too. This keeps pushReplacement visible as a connection in the tree.
    if (oldRouteName != null) {
      _addEdge(oldRouteName, newRouteName);
    }
    notifyListeners();
  }

  /// Records a removal of [routeName] from anywhere in the stack.
  void recordRemove(String routeName, {String? previousRouteName}) {
    _timeline.add(NavEvent(
      type: NavEventType.remove,
      routeName: routeName,
      previousRouteName: previousRouteName,
    ));
    _trimTimeline();
    _removeFromStack(routeName);
    notifyListeners();
  }

  /// Clears all recorded state. Useful between runs in the inspector.
  void reset() {
    _timeline.clear();
    _currentStack.clear();
    _flowGraph.clear();
    notifyListeners();
  }

  /// The most recently observed [NavigatorState]. Populated by
  /// [NavLensObserver]; used by the debug overlay to push the inspector
  /// without requiring the user to plumb a `GlobalKey` through their app.
  NavigatorState? get activeNavigator => _activeNavigator;

  /// Registers [navigator] as the current active navigator. Called by
  /// [NavLensObserver] whenever a navigation event fires.
  void registerNavigator(NavigatorState? navigator) {
    if (navigator == null || identical(_activeNavigator, navigator)) return;
    _activeNavigator = navigator;
  }

  /// Builds a rooted tree from the flow graph.
  ///
  /// Roots are screens that were never pushed onto from another screen — in
  /// other words, the natural entry points of the app. Cycles are broken so
  /// the returned tree is always finite.
  List<NavNode> buildTree() {
    final hasParent = <String>{};
    for (final children in _flowGraph.values) {
      hasParent.addAll(children);
    }

    final allNodes = <String>{
      ..._flowGraph.keys,
      for (final children in _flowGraph.values) ...children,
      ..._currentStack,
    };

    final roots = allNodes.where((name) => !hasParent.contains(name)).toList()
      ..sort();

    // Fallback: if every node has a parent (e.g. a cycle), use the first-seen
    // route in the timeline as the root so the user still sees something.
    if (roots.isEmpty && allNodes.isNotEmpty) {
      roots.add(_timeline.isNotEmpty ? _timeline.first.routeName : allNodes.first);
    }

    return roots.map((name) => _buildNode(name, <String>{})).toList();
  }

  NavNode _buildNode(String name, Set<String> visited) {
    if (visited.contains(name)) {
      return NavNode(name: name);
    }
    final next = <String>{...visited, name};
    final childNames = (_flowGraph[name] ?? const <String>{}).toList()..sort();
    return NavNode(
      name: name,
      children: childNames.map((c) => _buildNode(c, next)).toList(),
    );
  }

  void _addEdge(String parent, String child) {
    if (parent == child) return;
    _flowGraph.putIfAbsent(parent, () => <String>{}).add(child);
  }

  void _removeFromStack(String routeName) {
    final index = _currentStack.lastIndexOf(routeName);
    if (index != -1) {
      _currentStack.removeAt(index);
    }
  }

  void _trimTimeline() {
    if (_timeline.length > maxTimelineLength) {
      _timeline.removeRange(0, _timeline.length - maxTimelineLength);
    }
  }

  /// Test-only hook for resetting the singleton's state. Exposed via
  /// `@visibleForTesting` to keep tests fast without re-creating instances.
  @visibleForTesting
  void debugReset() => reset();
}
