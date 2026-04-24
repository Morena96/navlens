import 'package:flutter/material.dart';

import '../models/nav_node.dart';
import '../state/navlens_controller.dart';

/// Renders [NavLensController.buildTree] as an indented tree using the
/// familiar `├──`, `│`, `└──` line-drawing characters from the spec.
///
/// The currently active route is highlighted with the theme's primary colour
/// so developers can see at a glance where they are in the flow.
class NavLensTreeView extends StatelessWidget {
  const NavLensTreeView({
    super.key,
    this.controller,
    this.emptyText = 'No navigation yet',
  });

  final NavLensController? controller;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final ctrl = controller ?? NavLensController.instance;
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final roots = ctrl.buildTree();
        if (roots.isEmpty) {
          return _EmptyState(message: emptyText);
        }
        final rows = <_TreeRow>[];
        for (var i = 0; i < roots.length; i++) {
          _flatten(
            rows: rows,
            node: roots[i],
            prefix: '',
            isLast: i == roots.length - 1,
            isRoot: true,
          );
        }
        final current = ctrl.currentRoute;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          itemCount: rows.length,
          itemBuilder: (context, i) => _TreeRowTile(
            row: rows[i],
            isCurrent: rows[i].node.name == current,
          ),
        );
      },
    );
  }

  void _flatten({
    required List<_TreeRow> rows,
    required NavNode node,
    required String prefix,
    required bool isLast,
    required bool isRoot,
  }) {
    final connector = isRoot ? '' : (isLast ? '└── ' : '├── ');
    rows.add(_TreeRow(node: node, prefix: '$prefix$connector'));
    final childPrefix = isRoot ? '' : '$prefix${isLast ? '    ' : '│   '}';
    for (var i = 0; i < node.children.length; i++) {
      _flatten(
        rows: rows,
        node: node.children[i],
        prefix: childPrefix,
        isLast: i == node.children.length - 1,
        isRoot: false,
      );
    }
  }
}

class _TreeRow {
  const _TreeRow({required this.node, required this.prefix});
  final NavNode node;
  final String prefix;
}

class _TreeRowTile extends StatelessWidget {
  const _TreeRowTile({required this.row, required this.isCurrent});

  final _TreeRow row;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          fontFamilyFallback: const ['RobotoMono', 'Menlo', 'Courier'],
        ) ??
        const TextStyle(fontFamily: 'monospace');
    final nameStyle = isCurrent
        ? baseStyle.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          )
        : baseStyle;
    final prefixStyle = baseStyle.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: row.prefix, style: prefixStyle),
            TextSpan(text: row.node.name, style: nameStyle),
            if (isCurrent)
              TextSpan(
                text: '  ← active',
                style: baseStyle.copyWith(
                  color: theme.colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
