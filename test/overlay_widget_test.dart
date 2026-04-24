import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navlens/navlens.dart';

/// Builds a realistic app with NavLens plugged into MaterialApp.builder —
/// the pattern the README documents and that gives the overlay access to
/// the root Navigator, theme, MediaQuery and ScaffoldMessenger.
Widget _wrappedApp({bool enabled = true, Widget? home}) {
  return MaterialApp(
    navigatorObservers: [NavLensObserver()],
    builder: (context, child) => NavLens.wrap(
      enabled: enabled,
      child: child ?? const SizedBox.shrink(),
    ),
    home: home ?? const Scaffold(body: Center(child: Text('hello'))),
  );
}

void main() {
  setUp(() => NavLensController.instance.debugReset());

  testWidgets('NavLens.wrap mounts without ParentDataWidget errors',
      (tester) async {
    await tester.pumpWidget(_wrappedApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('hello'), findsOneWidget);
    expect(find.byIcon(Icons.account_tree), findsOneWidget);
  });

  testWidgets('overlay is hidden when disabled', (tester) async {
    await tester.pumpWidget(_wrappedApp(enabled: false));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.account_tree), findsNothing);
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('tapping the button opens the inspector', (tester) async {
    NavLensController.instance.recordPush('Home');
    await tester.pumpWidget(_wrappedApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.account_tree));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'NavLens'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Tree'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
  });

  testWidgets('inspector route is not recorded in the timeline',
      (tester) async {
    await tester.pumpWidget(_wrappedApp());
    await tester.pumpAndSettle();

    final timelineBefore = NavLensController.instance.timeline.length;
    await tester.tap(find.byIcon(Icons.account_tree));
    await tester.pumpAndSettle();

    expect(
      NavLensController.instance.timeline.length,
      timelineBefore,
      reason: 'Opening the NavLens inspector must not pollute the observed '
          'timeline with its own route',
    );
  });
}
