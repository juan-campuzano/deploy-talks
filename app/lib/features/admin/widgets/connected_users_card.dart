import 'package:flutter/material.dart';

import '../../../models/presence_record.dart';
import '../../../services/presence_service.dart';

class ConnectedUsersCard extends StatelessWidget {
  const ConnectedUsersCard({super.key, required this.presenceService});

  final PresenceService presenceService;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people),
                const SizedBox(width: 8),
                Text(
                  'Usuarios conectados',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<PresenceRecord>>(
              stream: presenceService.connectedUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data ?? [];

                if (users.isEmpty) {
                  return const Text(
                    'Ningún usuario conectado.',
                    style: TextStyle(color: Colors.grey),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${users.length} ${users.length == 1 ? 'usuario' : 'usuarios'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...users.map(
                      (u) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 8,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(u.displayName),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
