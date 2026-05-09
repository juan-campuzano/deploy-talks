import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'features/admin/admin_session_notifier.dart';
import 'features/chat/catalog/chat_catalog.dart';
import 'features/enter_name/user_notifier.dart';
import 'router.dart';
import 'services/admin_service.dart';
import 'services/chat_service.dart';
import 'services/genui_service.dart';
import 'services/presence_service.dart';
import 'theme.dart';

const _webFirebaseOptions = FirebaseOptions(
  apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
  authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
  projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
  storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
  messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
  appId: String.fromEnvironment('FIREBASE_APP_ID'),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: _webFirebaseOptions);
  runApp(const DeployTalksApp());
}

class DeployTalksApp extends StatefulWidget {
  const DeployTalksApp({super.key});

  @override
  State<DeployTalksApp> createState() => _DeployTalksAppState();
}

class _DeployTalksAppState extends State<DeployTalksApp> {
  late final UserNotifier _userNotifier;
  late final ChatService _chatService;
  late final GenuiService _genuiService;
  late final PresenceService _presenceService;
  late final AdminSessionNotifier _adminSessionNotifier;
  late final AdminService _adminService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _userNotifier = UserNotifier(FirebaseAuth.instance);
    _chatService = ChatService(FirebaseFirestore.instance);
    _presenceService = PresenceService(FirebaseFirestore.instance);
    _adminSessionNotifier = AdminSessionNotifier();
    _adminService = AdminService(FirebaseFirestore.instance);
    _genuiService = GenuiService(catalog: buildChatCatalog());
    _router = buildRouter(_userNotifier, _adminSessionNotifier);
  }

  @override
  void dispose() {
    _genuiService.dispose();
    _userNotifier.dispose();
    _adminSessionNotifier.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserNotifier>.value(value: _userNotifier),
        ChangeNotifierProvider<AdminSessionNotifier>.value(
          value: _adminSessionNotifier,
        ),
        Provider<ChatService>.value(value: _chatService),
        Provider<GenuiService>.value(value: _genuiService),
        Provider<PresenceService>.value(value: _presenceService),
        Provider<AdminService>.value(value: _adminService),
      ],
      child: MaterialApp.router(
        title: 'Deploy Talks',
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: _router,
      ),
    );
  }
}
