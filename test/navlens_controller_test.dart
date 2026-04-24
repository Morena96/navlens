import 'package:flutter_test/flutter_test.dart';
import 'package:navlens/navlens.dart';

void main() {
  setUp(() => NavLensController.instance.debugReset());

  group('NavLensController', () {
    test('records pushes and exposes current stack', () {
      final c = NavLensController.instance;
      c.recordPush('Home');
      c.recordPush('Profile', previousRouteName: 'Home');
      c.recordPush('Settings', previousRouteName: 'Profile');

      expect(c.currentStack, ['Home', 'Profile', 'Settings']);
      expect(c.currentRoute, 'Settings');
      expect(c.timeline.map((e) => e.type),
          [NavEventType.push, NavEventType.push, NavEventType.push]);
    });

    test('pop drops the top of the stack', () {
      final c = NavLensController.instance;
      c.recordPush('Home');
      c.recordPush('Profile', previousRouteName: 'Home');
      c.recordPop('Profile', previousRouteName: 'Home');

      expect(c.currentStack, ['Home']);
      expect(c.currentRoute, 'Home');
    });

    test('replace swaps old for new in the current stack', () {
      final c = NavLensController.instance;
      c.recordPush('Home');
      c.recordPush('Profile', previousRouteName: 'Home');
      c.recordReplace(oldRouteName: 'Profile', newRouteName: 'Settings');

      expect(c.currentStack, ['Home', 'Settings']);
      expect(c.flowGraph['Profile'], contains('Settings'));
    });

    test('flow graph accumulates parent -> children edges from pushes', () {
      final c = NavLensController.instance;
      c.recordPush('Home');
      c.recordPush('Profile', previousRouteName: 'Home');
      c.recordPush('Settings', previousRouteName: 'Profile');
      c.recordPop('Settings', previousRouteName: 'Profile');
      c.recordPop('Profile', previousRouteName: 'Home');
      c.recordPush('Chat', previousRouteName: 'Home');

      expect(c.flowGraph['Home'], {'Profile', 'Chat'});
      expect(c.flowGraph['Profile'], {'Settings'});
    });

    test('buildTree matches the spec example', () {
      final c = NavLensController.instance;
      c.recordPush('Home');
      c.recordPush('Profile', previousRouteName: 'Home');
      c.recordPush('Settings', previousRouteName: 'Profile');
      c.recordPop('Settings', previousRouteName: 'Profile');
      c.recordPop('Profile', previousRouteName: 'Home');
      c.recordPush('Chat', previousRouteName: 'Home');

      final roots = c.buildTree();
      expect(roots, hasLength(1));
      final home = roots.single;
      expect(home.name, 'Home');
      expect(home.children.map((n) => n.name), ['Chat', 'Profile']);
      final profile = home.children.firstWhere((n) => n.name == 'Profile');
      expect(profile.children.map((n) => n.name), ['Settings']);
    });

    test('timeline is trimmed to the configured maximum', () {
      final c = NavLensController.instance;
      for (var i = 0; i < NavLensController.maxTimelineLength + 50; i++) {
        c.recordPush('route_$i');
      }
      expect(c.timeline.length, NavLensController.maxTimelineLength);
      expect(c.timeline.first.routeName, isNot('route_0'));
    });

    test('notifies listeners on each event', () {
      final c = NavLensController.instance;
      var notifications = 0;
      void listener() => notifications++;
      c.addListener(listener);
      addTearDown(() => c.removeListener(listener));

      c.recordPush('A');
      c.recordPush('B', previousRouteName: 'A');
      c.recordPop('B', previousRouteName: 'A');

      expect(notifications, 3);
    });
  });
}
