import 'package:flutter/material.dart';

/// Chat tab content — a simple list of conversations. Tapping one pushes a
/// detail route to demonstrate `push` from a secondary tab.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      children: [
        for (final name in const ['Alice', 'Bob', 'Carol', 'Dan'])
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(name),
            subtitle: const Text('Last message preview...'),
            onTap: () => Navigator.of(context).pushNamed('/detail'),
          ),
      ],
    );
    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: body,
    );
  }
}
