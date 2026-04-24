import 'package:flutter/widgets.dart';

import 'state/navlens_controller.dart';

/// A [NavigatorObserver] that forwards every navigation event into
/// [NavLensController].
///
/// Add it to `MaterialApp.navigatorObservers` (or to the observers list of
/// any router that wraps `Navigator` 1.0, like `go_router` or `auto_route`)
/// and NavLens will track the app's navigation in real time.
class NavLensObserver extends NavigatorObserver {
  NavLensObserver({NavLensController? controller})
      : _controller = controller ?? NavLensController.instance;

  final NavLensController _controller;

  /// Route names starting with this prefix are considered NavLens-internal
  /// (the inspector, any future sub-screens) and are never recorded.
  static const String internalRoutePrefix = '__NavLens';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _controller.registerNavigator(navigator);
    if (_isInternal(route)) return;
    _controller.recordPush(
      _nameOf(route),
      previousRouteName: previousRoute == null || _isInternal(previousRoute)
          ? null
          : _nameOf(previousRoute),
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _controller.registerNavigator(navigator);
    if (_isInternal(route)) return;
    _controller.recordPop(
      _nameOf(route),
      previousRouteName: previousRoute == null || _isInternal(previousRoute)
          ? null
          : _nameOf(previousRoute),
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _controller.registerNavigator(navigator);
    if (newRoute == null || _isInternal(newRoute)) return;
    _controller.recordReplace(
      oldRouteName: oldRoute == null || _isInternal(oldRoute)
          ? null
          : _nameOf(oldRoute),
      newRouteName: _nameOf(newRoute),
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _controller.registerNavigator(navigator);
    if (_isInternal(route)) return;
    _controller.recordRemove(
      _nameOf(route),
      previousRouteName: previousRoute == null || _isInternal(previousRoute)
          ? null
          : _nameOf(previousRoute),
    );
  }

  static bool _isInternal(Route<dynamic> route) {
    final name = route.settings.name;
    return name != null && name.startsWith(internalRoutePrefix);
  }

  /// Best-effort human-readable name for [route].
  ///
  /// Prefers the developer-supplied `RouteSettings.name`, falling back to the
  /// route's runtime type. Anonymous dialog/modal routes therefore surface
  /// as e.g. `MaterialPageRoute<dynamic>` which, while verbose, is still
  /// more useful than `null`.
  static String _nameOf(Route<dynamic> route) {
    final settingsName = route.settings.name;
    if (settingsName != null && settingsName.isNotEmpty) {
      return settingsName;
    }
    return route.runtimeType.toString();
  }
}
