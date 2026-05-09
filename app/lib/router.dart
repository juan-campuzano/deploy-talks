import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/admin/admin_dashboard_page.dart';
import 'features/admin/admin_login_page.dart';
import 'features/admin/admin_session_notifier.dart';
import 'features/home/home_page.dart';
import 'features/enter_name/enter_name_page.dart';
import 'features/enter_name/user_notifier.dart';

GoRouter buildRouter(
  UserNotifier userNotifier,
  AdminSessionNotifier adminSessionNotifier,
) {
  return GoRouter(
    initialLocation: '/enter-name',
    refreshListenable: Listenable.merge([userNotifier, adminSessionNotifier]),
    redirect: _buildRedirect(userNotifier),
    routes: [
      GoRoute(
        path: '/enter-name',
        builder: (context, state) => EnterNamePage(userNotifier: userNotifier),
      ),
      GoRoute(path: '/chat', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/admin',
        builder: (context, state) => ValueListenableBuilder<bool>(
          valueListenable: adminSessionNotifier,
          builder: (context, isAuthenticated, _) => isAuthenticated
              ? const AdminDashboardPage()
              : AdminLoginPage(adminNotifier: adminSessionNotifier),
        ),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) =>
            userNotifier.value == null ? '/enter-name' : '/chat',
      ),
    ],
  );
}

GoRouterRedirect _buildRedirect(UserNotifier userNotifier) {
  return (BuildContext context, GoRouterState state) {
    final hasUser = userNotifier.value != null;
    final isOnEnterName = state.matchedLocation == '/enter-name';
    final isOnAdmin = state.matchedLocation == '/admin';

    // Admin route is always accessible regardless of chat user state
    if (isOnAdmin) return null;

    if (!hasUser && !isOnEnterName) return '/enter-name';
    if (hasUser && isOnEnterName) return '/chat';
    return null;
  };
}
