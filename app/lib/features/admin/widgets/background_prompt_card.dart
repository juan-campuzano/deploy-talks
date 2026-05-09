import 'package:flutter/material.dart';

import '../../../services/admin_service.dart';
import '../../../theme.dart';

class BackgroundPromptCard extends StatefulWidget {
  const BackgroundPromptCard({super.key, required this.adminService});

  final AdminService adminService;

  @override
  State<BackgroundPromptCard> createState() => _BackgroundPromptCardState();
}

class _BackgroundPromptCardState extends State<BackgroundPromptCard> {
  final _controller = TextEditingController();
  bool _generating = false;
  String? _successLabel;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _generating = true;
      _successLabel = null;
      _error = null;
    });

    try {
      final bg = await widget.adminService.generateBackground(prompt);
      if (mounted) {
        setState(() => _successLabel = 'Fondo aplicado: ${bg.label}');
        _controller.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Error al generar el fondo: $e');
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDim, Color(0xFF2D1B69)],
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: AppColors.primaryBright,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Background con IA',
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
            'Describe el fondo que quieres para el chat. Gemini generará los colores y se aplicarán a todos los usuarios.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              hintText: 'Ej. fondo espacial con nebulosas moradas',
              prefixIcon: Icon(
                Icons.palette_outlined,
                color: AppColors.textMuted,
                size: 18,
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _generating ? null : _generate(),
            enabled: !_generating,
            onChanged: (_) => setState(() {
              _error = null;
              _successLabel = null;
            }),
          ),
          if (_successLabel != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 15,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _successLabel!,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.dangerDim,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Text(
                _error!,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: AppColors.danger,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: _generating || _controller.text.trim().isEmpty
                  ? null
                  : _generate,
              style: FilledButton.styleFrom(
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: _generating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.brush_rounded, size: 16),
              label: Text(
                _generating ? 'Generando...' : 'Aplicar fondo',
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
