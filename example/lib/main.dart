import 'package:flutter/material.dart';
import 'package:navlens/navlens.dart';

import 'screens/chat_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const NavLensDemoApp());
}

class NavLensDemoApp extends StatelessWidget {
  const NavLensDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavLens Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      navigatorObservers: [NavLensObserver()],
      builder: (context, child) =>
          NavLens.wrap(child: child ?? const SizedBox.shrink()),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/feed': (_) => const FeedScreen(),
        '/chat': (_) => const ChatScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/profile/settings': (_) => const SettingsScreen(),
        '/detail': (_) => const DetailScreen(),
      },
    );
  }
}
