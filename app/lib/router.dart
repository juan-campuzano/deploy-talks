import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/chat/chat_page.dart';
import 'features/enter_name/enter_name_page.dart';
import 'features/enter_name/user_notifier.dart';

GoRouter buildRouter(UserNotifier userNotifier) {
  return GoRouter(
    initialLocation: '/enter-name',
    refreshListenable: userNotifier,
    redirect: _nameGuard(userNotifier),
    routes: [
      GoRoute(
        path: '/enter-name',
        builder: (context, state) => EnterNamePage(userNotifier: userNotifier),
      ),
      GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
      // Redirect root to appropriate page
      GoRoute(
        path: '/',
        redirect: (context, state) =>
            userNotifier.value == null ? '/enter-name' : '/chat',
      ),
    ],
  );
}

GoRouterRedirect _nameGuard(UserNotifier userNotifier) {
  return (BuildContext context, GoRouterState state) {
    final hasUser = userNotifier.value != null;
    final isOnEnterName = state.matchedLocation == '/enter-name';

    if (!hasUser && !isOnEnterName) return '/enter-name';
    if (hasUser && isOnEnterName) return '/chat';
    return null;
  };
}
