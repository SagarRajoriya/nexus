import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/transfer/transfer_screen.dart';
import '../screens/stream/stream_screen.dart';
import '../screens/mouse/mouse_screen.dart';
import '../screens/clipboard/clipboard_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/cloud/cloud_screen.dart';
import '../screens/devices/devices_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/shell_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authAsync.valueOrNull != null;
      final isLoginPage = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginPage) return '/login';
      if (isLoggedIn && isLoginPage)  return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(path: '/',              builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/devices',       builder: (_, __) => const DevicesScreen()),
          GoRoute(path: '/transfer',      builder: (_, __) => const TransferScreen()),
          GoRoute(path: '/stream',        builder: (_, __) => const StreamScreen()),
          GoRoute(path: '/mouse',         builder: (_, __) => const MouseScreen()),
          GoRoute(path: '/clipboard',     builder: (_, __) => const ClipboardScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/cloud',         builder: (_, __) => const CloudScreen()),
          GoRoute(path: '/settings',      builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
