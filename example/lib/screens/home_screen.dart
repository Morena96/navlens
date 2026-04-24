import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'feed_screen.dart';

/// Host screen with a bottom nav bar for Feed + Chat tabs.
///
/// The Feed tab's AppBar exposes navigation controls that push Profile,
/// Detail, or replace the current route so users can exercise every kind
/// of navigation event in NavLens.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [FeedScreen(embedded: true), ChatScreen(embedded: true)];
    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? 'Feed' : 'Chat'),
        actions: [
          IconButton(
            tooltip: 'Open Profile',
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
          IconButton(
            tooltip: 'Push Detail',
            icon: const Icon(Icons.article),
            onPressed: () => Navigator.of(context).pushNamed('/detail'),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dynamic_feed), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.chat_bubble), label: 'Chat'),
        ],
      ),
    );
  }
}
