import 'package:flutter/material.dart';

/// Tail screen of the Home → Profile → Settings push chain. Matches the
/// tree example from the NavLens spec README.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          SwitchListTile(
            value: true,
            onChanged: _noop,
            title: Text('Notifications'),
            subtitle: Text('Receive push notifications'),
          ),
          SwitchListTile(
            value: false,
            onChanged: _noop,
            title: Text('Dark mode'),
            subtitle: Text('Use the system dark theme'),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
          ),
        ],
      ),
    );
  }

  static void _noop(bool _) {}
}
