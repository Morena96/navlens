import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../export/json_exporter.dart';
import '../export/png_exporter.dart';
import '../state/navlens_controller.dart';
import '../ui/current_view.dart';
import '../ui/timeline_view.dart';
import '../ui/tree_view.dart';

/// Full-screen navigation inspector.
///
/// Surfaces three tabs — Current / Tree / Timeline — along with export
/// actions (JSON to clipboard, PNG to clipboard-as-text-notice) and a reset
/// button. Intended to be pushed as a full-screen dialog from the overlay's
/// floating button so it can use its own `Navigator` without disturbing the
/// app's own nav stack state.
class NavLensInspector extends StatefulWidget {
  const NavLensInspector({super.key, this.controller});

  final NavLensController? controller;

  /// Pushes the inspector as a full-screen dialog onto the navigator the
  /// [NavLensObserver] most recently observed — falling back to the nearest
  /// Navigator above [context] if (and only if) no observer has registered
  /// one yet. This lets [NavLens.wrap] sit inside `MaterialApp.builder`
  /// (where its own context is an *ancestor* of the app's Navigator) and
  /// still be able to push the inspector.
  static Future<void>? show(BuildContext context,
      {NavLensController? controller}) {
    final ctrl = controller ?? NavLensController.instance;
    final navigator = ctrl.activeNavigator ??
        Navigator.maybeOf(context, rootNavigator: true);
    if (navigator == null) {
      debugPrint(
        'NavLens: cannot open inspector because no Navigator has been '
        'observed yet. Make sure `NavLensObserver()` is in '
        '`MaterialApp.navigatorObservers` and the app has rendered at '
        'least one route.',
      );
      return null;
    }
    return navigator.push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        settings: const RouteSettings(name: '__NavLensInspector'),
        builder: (_) => NavLensInspector(controller: ctrl),
      ),
    );
  }

  @override
  State<NavLensInspector> createState() => _NavLensInspectorState();
}

class _NavLensInspectorState extends State<NavLensInspector>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 3, vsync: this);
  final GlobalKey _treeBoundaryKey = GlobalKey();

  NavLensController get _controller =>
      widget.controller ?? NavLensController.instance;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _copyJson() async {
    final json = NavLensJsonExporter(controller: _controller).export();
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    _snack('Navigation graph copied as JSON');
  }

  Future<void> _exportPng() async {
    try {
      final bytes = await const NavLensPngExporter().export(
        boundaryKey: _treeBoundaryKey,
      );
      if (!mounted) return;
      _snack('Captured PNG: ${bytes.lengthInBytes} bytes');
    } catch (e) {
      if (!mounted) return;
      _snack('PNG export failed: $e');
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmReset() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset NavLens?'),
        content: const Text(
          'Clears the recorded navigation history, current stack and flow '
          'graph. The running app is not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _controller.reset();
              Navigator.pop(ctx);
              _snack('NavLens state cleared');
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NavLens'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.layers), text: 'Current'),
            Tab(icon: Icon(Icons.account_tree), text: 'Tree'),
            Tab(icon: Icon(Icons.history), text: 'Timeline'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Copy JSON',
            icon: const Icon(Icons.data_object),
            onPressed: _copyJson,
          ),
          IconButton(
            tooltip: 'Export tree as PNG',
            icon: const Icon(Icons.image),
            onPressed: _exportPng,
          ),
          IconButton(
            tooltip: 'Reset',
            icon: const Icon(Icons.delete_sweep),
            onPressed: _confirmReset,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NavLensCurrentView(controller: _controller),
          // Wrap the tree in a RepaintBoundary so PNG export can capture it
          // regardless of which tab is currently in focus — Flutter keeps
          // tab contents built by default in TabBarView.
          RepaintBoundary(
            key: _treeBoundaryKey,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: NavLensTreeView(controller: _controller),
            ),
          ),
          NavLensTimelineView(controller: _controller),
        ],
      ),
    );
  }
}
