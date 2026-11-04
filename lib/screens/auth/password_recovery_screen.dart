import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../services/auth_service.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _correoController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _cargando = false;

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _enviarEnlace() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      await _authService.enviarCorreoRecuperacion(
        correo: _correoController.text,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
      });

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.mark_email_read_rounded,
              color: AppColors.verdePrincipal,
              size: 52,
            ),
            title: const Text('Revisa tu correo', textAlign: TextAlign.center),
            content: Text(
              'Si existe una cuenta asociada a '
              '${_correoController.text.trim()}, recibirás un enlace '
              'para restablecer la contraseña.\n\n'
              'Revisa también la carpeta de correo no deseado.',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Entendido'),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.mensaje)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrió un error inesperado al enviar el correo.'),
        ),
      );
    }
  }

  String? _validarCorreo(String? valor) {
    final String correo = valor?.trim() ?? '';

    if (correo.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    final RegExp formatoCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!formatoCorreo.hasMatch(correo)) {
      return 'Ingresa un correo electrónico válido';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verdePrincipal,
      appBar: AppBar(
        backgroundColor: AppColors.verdePrincipal,
        foregroundColor: AppColors.blanco,
        elevation: 0,
        title: const Text('Recuperar acceso'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.blanco,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: const BoxDecoration(
                              color: AppColors.verdeClaro,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              color: AppColors.verdePrincipal,
                              size: 42,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            '¿Olvidaste tu contraseña?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.verdeTexto,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ingresa el correo asociado a tu cuenta. '
                            'Te enviaremos un enlace para crear una '
                            'contraseña nueva.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textoSecundario,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28),
                          TextFormField(
                            controller: _correoController,
                            validator: _validarCorreo,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            autocorrect: false,
                            enableSuggestions: false,
                            autofillHints: const [AutofillHints.email],
                            onFieldSubmitted: (_) {
                              if (!_cargando) {
                                _enviarEnlace();
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              hintText: 'correo@ejemplo.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: AppColors.fondoClaro,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              onPressed: _cargando ? null : _enviarEnlace,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.verdePrincipal,
                                foregroundColor: AppColors.blanco,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _cargando
                                  ? const SizedBox(
                                      width: 23,
                                      height: 23,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.blanco,
                                      ),
                                    )
                                  : const Text(
                                      'Enviar enlace',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _cargando
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Volver al inicio de sesión'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
