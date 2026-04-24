import 'package:flutter/material.dart';

import '../state/navlens_controller.dart';

/// Renders the currently mounted navigation stack bottom-to-top, with the
/// topmost (visible) route highlighted.
class NavLensCurrentView extends StatelessWidget {
  const NavLensCurrentView({
    super.key,
    this.controller,
    this.emptyText = 'No routes on the stack',
  });

  final NavLensController? controller;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final ctrl = controller ?? NavLensController.instance;
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final stack = ctrl.currentStack;
        if (stack.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(emptyText),
            ),
          );
        }
        final theme = Theme.of(context);
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stack.length,
          itemBuilder: (context, i) {
            // Render top-of-stack first so the visible screen is at the top.
            final reverseIndex = stack.length - 1 - i;
            final name = stack[reverseIndex];
            final isTop = reverseIndex == stack.length - 1;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Material(
                color: isTop
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          '${reverseIndex + 1}',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isTop ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isTop)
                        Text(
                          'active',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
