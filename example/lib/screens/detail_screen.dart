import 'package:flutter/material.dart';

/// Demonstrates every navigation primitive NavLens observes: push, pop,
/// pushReplacement, and pushAndRemoveUntil.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Try the NavLens overlay (top-right button) after running '
              'any of the actions below.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.arrow_upward),
              onPressed: () => Navigator.of(context).pushNamed('/detail'),
              label: const Text('Push another Detail'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.swap_horiz),
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/profile'),
              label: const Text('Replace with Profile'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.first_page),
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil('/feed', (r) => false),
              label: const Text('Reset stack to Feed'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.arrow_downward),
              onPressed: () => Navigator.of(context).maybePop(),
              label: const Text('Pop'),
            ),
          ],
        ),
      ),
    );
  }
}
