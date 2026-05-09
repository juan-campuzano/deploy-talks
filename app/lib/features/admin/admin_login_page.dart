import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme.dart';
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
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.surfaceEl,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: AppColors.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Admin',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Acceso restringido',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 36),
                      if (_isDisabled) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Color(0xFF451A00),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.warning.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Panel no configurado. Agrega ADMIN_PASSWORD al build.',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: AppColors.warning,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        TextFormField(
                          controller: _controller,
                          obscureText: _obscure,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
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
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.dangerDim,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.danger.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 16,
                                  color: AppColors.danger,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _error!,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: AppColors.danger,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}
