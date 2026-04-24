import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../state/navlens_controller.dart';
import 'navlens_inspector.dart';

/// Wraps the user's application with a draggable NavLens debug button.
///
/// Use via [NavLens.wrap] rather than constructing directly:
/// ```dart
/// runApp(NavLens.wrap(child: const MyApp()));
/// ```
///
/// The overlay is hidden automatically in release builds (unless [enabled]
/// is forced to `true`) so it is safe to leave in place year-round.
class NavLensOverlay extends StatefulWidget {
  const NavLensOverlay({
    super.key,
    required this.child,
    this.enabled,
    this.controller,
    this.initialAlignment = const Alignment(0.95, 0.85),
  });

  final Widget child;

  /// Whether the overlay should render. Defaults to "debug and profile
  /// builds only" via [kReleaseMode].
  final bool? enabled;

  final NavLensController? controller;

  /// Where the floating button starts on first launch. Users can drag it.
  final Alignment initialAlignment;

  @override
  State<NavLensOverlay> createState() => _NavLensOverlayState();
}

class _NavLensOverlayState extends State<NavLensOverlay> {
  Offset? _position;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled ?? !kReleaseMode;
    if (!enabled) return widget.child;
    // LayoutBuilder must wrap the Stack — not sit inside it — because
    // `Positioned` must be a direct child of `Stack` to apply its
    // StackParentData. Previously nesting LayoutBuilder → Positioned inside
    // Stack caused a ParentDataWidget assertion on every frame.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const buttonSize = 48.0;
          final initial = _resolveInitial(constraints, buttonSize);
          final pos = _position ?? initial;
          final clamped = _clamp(pos, constraints, buttonSize);
          return Stack(
            children: [
              Positioned.fill(child: widget.child),
              Positioned(
                left: clamped.dx,
                top: clamped.dy,
                child: _DraggableButton(
                  onTap: () => NavLensInspector.show(
                    context,
                    controller: widget.controller,
                  ),
                  onDrag: (delta) {
                    setState(() {
                      _position = _clamp(
                        (_position ?? initial) + delta,
                        constraints,
                        buttonSize,
                      );
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Offset _resolveInitial(BoxConstraints c, double size) {
    final a = widget.initialAlignment;
    final dx = (c.maxWidth - size) * ((a.x + 1) / 2);
    final dy = (c.maxHeight - size) * ((a.y + 1) / 2);
    return Offset(dx, dy);
  }

  Offset _clamp(Offset pos, BoxConstraints c, double size) {
    return Offset(
      pos.dx.clamp(0.0, (c.maxWidth - size).clamp(0.0, double.infinity)),
      pos.dy.clamp(0.0, (c.maxHeight - size).clamp(0.0, double.infinity)),
    );
  }
}

class _DraggableButton extends StatelessWidget {
  const _DraggableButton({required this.onTap, required this.onDrag});

  final VoidCallback onTap;
  final ValueChanged<Offset> onDrag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onPanUpdate: (details) => onDrag(details.delta),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF6750A4),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_tree,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Public entry-point for NavLens overlay setup.
///
/// The static [wrap] helper is a thin constructor for [NavLensOverlay],
/// kept at the top level so users get a discoverable, memorable API:
/// `NavLens.wrap(child: ...)`.
abstract class NavLens {
  /// Wraps [child] with the NavLens debug overlay.
  static Widget wrap({
    required Widget child,
    bool? enabled,
    NavLensController? controller,
    Alignment initialAlignment = const Alignment(0.95, 0.85),
  }) {
    return NavLensOverlay(
      enabled: enabled,
      controller: controller,
      initialAlignment: initialAlignment,
      child: child,
    );
  }

  /// Convenience accessor for the shared controller.
  static NavLensController get controller => NavLensController.instance;
}
