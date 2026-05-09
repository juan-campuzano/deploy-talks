import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'admin_session_notifier.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key, required this.adminNotifier});

  final AdminSessionNotifier adminNotifier;

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  String? _error;

  static const _adminPassword = String.fromEnvironment('ADMIN_PASSWORD');
  bool get _isDisabled => _adminPassword.isEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = widget.adminNotifier.authenticate(_controller.text);
    if (success) {
      if (mounted) context.go('/admin');
    } else {
      setState(() => _error = 'Contraseña incorrecta. Intenta de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Panel de Administración',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (_isDisabled) ...[
                    const Text(
                      'El panel de administración no está configurado. '
                      'Ejecuta la app con --dart-define=ADMIN_PASSWORD=...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.orange),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _controller,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Ingresa la contraseña'
                          : null,
                      onChanged: (_) => setState(() => _error = null),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _submit,
                      child: const Text('Ingresar'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
