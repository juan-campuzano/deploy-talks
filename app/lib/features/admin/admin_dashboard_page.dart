import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/admin_service.dart';
import '../../services/presence_service.dart';
import 'admin_session_notifier.dart';
import 'widgets/background_prompt_card.dart';
import 'widgets/clear_chat_card.dart';
import 'widgets/connected_users_card.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminNotifier = context.read<AdminSessionNotifier>();
    final adminService = context.read<AdminService>();
    final presenceService = context.read<PresenceService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        actions: [
          TextButton.icon(
            onPressed: () => adminNotifier.logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Salir'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ConnectedUsersCard(presenceService: presenceService),
              const SizedBox(height: 16),
              ClearChatCard(adminService: adminService),
              const SizedBox(height: 16),
              BackgroundPromptCard(adminService: adminService),
            ],
          ),
        ),
      ),
    );
  }
}
