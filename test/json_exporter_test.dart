import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:navlens/navlens.dart';

void main() {
  setUp(() => NavLensController.instance.debugReset());

  group('NavLensJsonExporter', () {
    test('emits the expected schema', () {
      final c = NavLensController.instance;
      c.recordPush('Home');
      c.recordPush('Profile', previousRouteName: 'Home');

      final map = const NavLensJsonExporter().toMap();
      expect(map['schemaVersion'], NavLensJsonExporter.schemaVersion);
      expect(map['currentStack'], ['Home', 'Profile']);
      expect(map['currentRoute'], 'Profile');
      expect(map['flowGraph'], {'Home': ['Profile']});
      expect(map['timeline'], hasLength(2));
      expect((map['timeline'] as List).first['type'], 'push');
      expect(map['exportedAt'], isA<String>());
    });

    test('export() returns parseable JSON', () {
      NavLensController.instance.recordPush('Home');
      final jsonStr = const NavLensJsonExporter().export();
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(parsed['currentRoute'], 'Home');
    });
  });
}
