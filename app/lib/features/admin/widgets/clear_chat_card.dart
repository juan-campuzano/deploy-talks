import 'package:flutter/material.dart';

import '../../../services/admin_service.dart';

class ClearChatCard extends StatefulWidget {
  const ClearChatCard({super.key, required this.adminService});

  final AdminService adminService;

  @override
  State<ClearChatCard> createState() => _ClearChatCardState();
}

class _ClearChatCardState extends State<ClearChatCard> {
  bool _clearing = false;
  String? _message;

  Future<void> _confirmAndClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Limpiar el chat?'),
        content: const Text(
          'Se eliminarán todos los mensajes del chat para todos los usuarios. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _clearing = true;
      _message = null;
    });

    try {
      await widget.adminService.clearChat();
      if (mounted) setState(() => _message = 'Chat limpiado correctamente.');
    } catch (e) {
      if (mounted) {
        setState(() => _message = 'Error al limpiar el chat: $e');
      }
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

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
                const Icon(Icons.delete_sweep),
                const SizedBox(width: 8),
                Text(
                  'Limpiar Chat',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Elimina todos los mensajes del chat para todos los usuarios.',
            ),
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(
                _message!,
                style: TextStyle(
                  color: _message!.startsWith('Error')
                      ? Theme.of(context).colorScheme.error
                      : Colors.green,
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _clearing ? null : _confirmAndClear,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: _clearing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.delete_forever),
              label: Text(_clearing ? 'Limpiando...' : 'Limpiar Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
