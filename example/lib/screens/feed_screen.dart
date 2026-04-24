import 'package:flutter/material.dart';

/// Renders a scrollable list of demo items. Used both as a standalone route
/// (when pushed) and as the Feed tab's body inside [HomeScreen] (embedded).
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = ListView.builder(
      itemCount: 20,
      itemBuilder: (context, i) => ListTile(
        leading: CircleAvatar(child: Text('${i + 1}')),
        title: Text('Feed item #${i + 1}'),
        subtitle: const Text('Tap to push a detail screen'),
        onTap: () => Navigator.of(context).pushNamed('/detail'),
      ),
    );
    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: body,
    );
  }
}
