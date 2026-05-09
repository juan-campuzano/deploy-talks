import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/admin_service.dart';
import '../../services/presence_service.dart';
import '../../theme.dart';
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bg,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.surfaceEl,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Panel de Administración',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => adminNotifier.logout(),
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    label: const Text(
                      'Salir',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(20),
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
