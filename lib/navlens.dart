/// NavLens — runtime navigation visualizer for Flutter apps.
///
/// Add [NavLensObserver] to your `MaterialApp.navigatorObservers` and plug
/// [NavLens.wrap] into `MaterialApp.builder` to get a draggable debug
/// overlay showing the current navigation stack, a tree of visited screens,
/// a timeline of push/pop/replace events and one-tap JSON + PNG export.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:navlens/navlens.dart';
///
/// void main() => runApp(const MyApp());
///
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
///   @override
///   Widget build(BuildContext context) => MaterialApp(
///         navigatorObservers: [NavLensObserver()],
///         builder: (context, child) =>
///             NavLens.wrap(child: child ?? const SizedBox.shrink()),
///         home: const Scaffold(body: Center(child: Text('Hello'))),
///       );
/// }
/// ```
library;

export 'src/models/nav_event.dart';
export 'src/models/nav_node.dart';
export 'src/navlens_observer.dart';
export 'src/overlay/navlens_inspector.dart' show NavLensInspector;
export 'src/overlay/navlens_overlay.dart' show NavLens, NavLensOverlay;
export 'src/state/navlens_controller.dart';
export 'src/export/json_exporter.dart';
export 'src/export/png_exporter.dart';
export 'src/ui/current_view.dart';
export 'src/ui/timeline_view.dart';
export 'src/ui/tree_view.dart';
