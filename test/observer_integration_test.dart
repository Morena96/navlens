import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navlens/navlens.dart';

void main() {
  setUp(() => NavLensController.instance.debugReset());

  testWidgets('observer records real Navigator push and pop', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: nav,
      navigatorObservers: [NavLensObserver()],
      initialRoute: '/',
      routes: {
        '/': (_) => const Scaffold(body: Text('home-screen')),
        '/profile': (_) => const Scaffold(body: Text('profile-screen')),
        '/settings': (_) => const Scaffold(body: Text('settings-screen')),
      },
    ));
    await tester.pumpAndSettle();

    nav.currentState!.pushNamed('/profile');
    await tester.pumpAndSettle();
    nav.currentState!.pushNamed('/settings');
    await tester.pumpAndSettle();
    nav.currentState!.pop();
    await tester.pumpAndSettle();

    final c = NavLensController.instance;
    expect(c.currentStack, ['/', '/profile']);
    expect(c.currentRoute, '/profile');
    expect(c.flowGraph['/'], contains('/profile'));
    expect(c.flowGraph['/profile'], contains('/settings'));
    expect(c.timeline.map((e) => e.type).toList(), [
      NavEventType.push, // '/' pushed on mount
      NavEventType.push, // '/profile'
      NavEventType.push, // '/settings'
      NavEventType.pop,  // '/settings' popped
    ]);
  });

  testWidgets('observer records pushReplacement as a replace event',
      (tester) async {
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: nav,
      navigatorObservers: [NavLensObserver()],
      initialRoute: '/',
      routes: {
        '/': (_) => const Scaffold(body: Text('home')),
        '/other': (_) => const Scaffold(body: Text('other')),
      },
    ));
    await tester.pumpAndSettle();
    nav.currentState!.pushReplacementNamed('/other');
    await tester.pumpAndSettle();

    final c = NavLensController.instance;
    expect(
      c.timeline.map((e) => e.type).toList(),
      contains(NavEventType.replace),
    );
    expect(c.currentStack, ['/other']);
  });
}
