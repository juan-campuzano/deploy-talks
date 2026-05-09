import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/chat/catalog/chat_catalog.dart';
import 'features/enter_name/user_notifier.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'services/chat_service.dart';
import 'services/genui_service.dart';
import 'services/presence_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

  @override
  void initState() {
    super.initState();
    _userNotifier = UserNotifier(FirebaseAuth.instance);
    _chatService = ChatService(FirebaseFirestore.instance);
    _presenceService = PresenceService(FirebaseFirestore.instance);

    _genuiService = GenuiService(catalog: buildChatCatalog());
  }

  @override
  void dispose() {
    _genuiService.dispose();
    _userNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserNotifier>.value(value: _userNotifier),
        Provider<ChatService>.value(value: _chatService),
        Provider<GenuiService>.value(value: _genuiService),
        Provider<PresenceService>.value(value: _presenceService),
      ],
      child: Builder(
        builder: (context) {
          final router = buildRouter(_userNotifier);
          return MaterialApp.router(
            title: 'Deploy Talks Chat',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
