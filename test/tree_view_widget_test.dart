import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navlens/navlens.dart';

/// Concatenates every `Text` and `RichText` span rendered into [tester] so
/// we can assert the tree view's content regardless of how it composes
/// route names alongside the indent prefixes.
String _renderedText(WidgetTester tester) {
  final buffer = StringBuffer();
  for (final element in find.byType(Text).evaluate()) {
    final widget = element.widget as Text;
    if (widget.data != null) buffer.writeln(widget.data);
  }
  for (final element in find.byType(RichText).evaluate()) {
    final widget = element.widget as RichText;
    buffer.writeln(_flattenSpan(widget.text));
  }
  return buffer.toString();
}

String _flattenSpan(InlineSpan span) {
  final buf = StringBuffer();
  span.visitChildren((s) {
    if (s is TextSpan && s.text != null) buf.write(s.text);
    return true;
  });
  return buf.toString();
}

void main() {
  setUp(() => NavLensController.instance.debugReset());

  testWidgets('renders tree with indent guides matching the spec',
      (tester) async {
    final c = NavLensController.instance;
    c.recordPush('Home');
    c.recordPush('Profile', previousRouteName: 'Home');
    c.recordPush('Settings', previousRouteName: 'Profile');
    c.recordPop('Settings', previousRouteName: 'Profile');
    c.recordPop('Profile', previousRouteName: 'Home');
    c.recordPush('Chat', previousRouteName: 'Home');

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: NavLensTreeView()),
    ));
    await tester.pumpAndSettle();

    final rendered = _renderedText(tester);
    expect(rendered, contains('Home'));
    expect(rendered, contains('Chat'));
    expect(rendered, contains('Profile'));
    expect(rendered, contains('Settings'));
    expect(rendered, contains('├── '));
    expect(rendered, contains('└── '));
    expect(rendered, contains('active'));
  });

  testWidgets('empty state message shown with no events', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: NavLensTreeView(emptyText: 'nothing here')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('nothing here'), findsOneWidget);
  });
}
