import 'package:flutter/material.dart';

import '../../../services/admin_service.dart';
import '../../../theme.dart';

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
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
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
      if (mounted) setState(() => _message = '✓ Chat limpiado correctamente.');
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
    final isError = _message?.startsWith('Error') ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.dangerDim,
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  size: 16,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Limpiar Chat',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Elimina todos los mensajes del chat para todos los usuarios.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isError ? AppColors.dangerDim : AppColors.accentDim,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isError
                      ? AppColors.danger.withOpacity(0.3)
                      : AppColors.accent.withOpacity(0.3),
                ),
              ),
              child: Text(
                _message!,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: isError ? AppColors.danger : AppColors.accent,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _clearing ? null : _confirmAndClear,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: _clearing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.danger,
                      ),
                    )
                  : const Icon(Icons.delete_forever_rounded, size: 16),
              label: Text(
                _clearing ? 'Limpiando...' : 'Limpiar Chat',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
