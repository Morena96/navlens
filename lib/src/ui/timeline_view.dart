import 'package:flutter/material.dart';

import '../models/nav_event.dart';
import '../state/navlens_controller.dart';

/// Shows the navigation history in reverse-chronological order (newest first).
///
/// Each event is rendered as a single row with a type-specific icon, the
/// route name, the previous route and the wall-clock time it occurred at.
class NavLensTimelineView extends StatelessWidget {
  const NavLensTimelineView({
    super.key,
    this.controller,
    this.emptyText = 'No navigation events yet',
  });

  final NavLensController? controller;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final ctrl = controller ?? NavLensController.instance;
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final events = ctrl.timeline.reversed.toList(growable: false);
        if (events.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(emptyText),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: events.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) => _EventTile(event: events[i]),
        );
      },
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});
  final NavEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color, label) = switch (event.type) {
      NavEventType.push => (
          Icons.arrow_upward,
          Colors.green,
          'push',
        ),
      NavEventType.pop => (
          Icons.arrow_downward,
          Colors.orange,
          'pop',
        ),
      NavEventType.replace => (
          Icons.swap_horiz,
          Colors.blue,
          'replace',
        ),
      NavEventType.remove => (
          Icons.close,
          Colors.redAccent,
          'remove',
        ),
    };
    final subtitle = event.previousRouteName == null
        ? label
        : '$label · from ${event.previousRouteName}';
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, size: 16, color: color),
      ),
      title: Text(
        event.routeName,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: Text(
        _formatTime(event.timestamp),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  static String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}
