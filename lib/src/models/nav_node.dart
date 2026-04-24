/// A node in a rendered navigation tree.
///
/// Nodes are produced by [NavLensController.buildTree] from the observed
/// flow graph. The tree is intentionally simple: a [name] and an ordered
/// list of [children]. Cycles in the flow graph are broken during tree
/// construction so the tree is always finite.
class NavNode {
  NavNode({required this.name, List<NavNode>? children})
      : children = children ?? <NavNode>[];

  /// Display name of the route represented by this node.
  final String name;

  /// Child screens that were pushed from this one at any point.
  final List<NavNode> children;

  /// Whether this node has any descendants.
  bool get isLeaf => children.isEmpty;

  @override
  String toString() {
    final buffer = StringBuffer();
    _write(buffer, '', true);
    return buffer.toString();
  }

  void _write(StringBuffer buffer, String prefix, bool isLast) {
    buffer.writeln(name);
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final last = i == children.length - 1;
      buffer.write(prefix);
      buffer.write(last ? '└── ' : '├── ');
      child._write(buffer, '$prefix${last ? '    ' : '│   '}', last);
    }
  }
}
