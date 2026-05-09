import 'package:flutter/material.dart';

import '../../../services/admin_service.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome),
                const SizedBox(width: 8),
                Text(
                  'Background con IA',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Describe el fondo que quieres para el chat. '
              'Gemini generará los colores y se aplicarán a todos los usuarios.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ej. fondo espacial con estrellas moradas',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
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
              const SizedBox(height: 8),
              Text(_successLabel!, style: const TextStyle(color: Colors.green)),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _generating || _controller.text.trim().isEmpty
                  ? null
                  : _generate,
              icon: _generating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.brush),
              label: Text(_generating ? 'Generando...' : 'Aplicar fondo'),
            ),
          ],
        ),
      ),
    );
  }
}
