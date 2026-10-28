import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();

  final TextEditingController _organizacionController = TextEditingController();

  final TextEditingController _correoController = TextEditingController();

  final TextEditingController _contrasenaController = TextEditingController();

  final TextEditingController _confirmacionController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _ocultarContrasena = true;
  bool _ocultarConfirmacion = true;
  bool _cargando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _organizacionController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmacionController.dispose();
    super.dispose();
  }

  Future<void> _crearCuenta() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      await _authService.registrarUsuario(
        nombre: _nombreController.text,
        organizacion: _organizacionController.text,
        correo: _correoController.text,
        contrasena: _contrasenaController.text,
      );

      // Firebase inicia sesión automáticamente después del registro.
      // Cerramos esa sesión para conservar el flujo actual:
      // crear cuenta → regresar al login → iniciar sesión.
      await _authService.cerrarSesion();

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
              Icons.check_circle_rounded,
              color: AppColors.verdePrincipal,
              size: 52,
            ),
            title: const Text('Cuenta creada', textAlign: TextAlign.center),
            content: Text(
              'La cuenta de ${_nombreController.text.trim()} '
              'fue creada correctamente.\n\n'
              'Ahora puedes iniciar sesión con tu correo y contraseña.',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Continuar'),
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
          content: Text('Ocurrió un error inesperado al crear la cuenta.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Regresar',
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Datos del solicitante',
                      style: TextStyle(
                        color: AppColors.verdeTexto,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Completa la información para '
                      'crear tu cuenta en GenLi Conecta.',
                      style: TextStyle(
                        color: AppColors.textoSecundario,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _RegisterField(
                      label: 'NOMBRE COMPLETO',
                      controller: _nombreController,
                      hintText: 'Nombre y apellido',
                      icon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final nombre = value?.trim() ?? '';

                        if (nombre.isEmpty) {
                          return 'Ingresa tu nombre completo';
                        }

                        if (nombre.length < 3) {
                          return 'El nombre es demasiado corto';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _RegisterField(
                      label: 'ORGANIZACIÓN O COMUNIDAD',
                      controller: _organizacionController,
                      hintText: 'Ej. Corporación Ríos Vivos',
                      icon: Icons.business_outlined,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final organizacion = value?.trim() ?? '';

                        if (organizacion.isEmpty) {
                          return 'Ingresa la organización o comunidad';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _RegisterField(
                      label: 'CORREO ELECTRÓNICO',
                      controller: _correoController,
                      hintText: 'nombre@correo.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validarCorreo,
                    ),

                    const SizedBox(height: 20),

                    _RegisterField(
                      label: 'CONTRASEÑA',
                      controller: _contrasenaController,
                      hintText: 'Mínimo 6 caracteres',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _ocultarContrasena,
                      textInputAction: TextInputAction.next,
                      suffixIcon: IconButton(
                        tooltip: _ocultarContrasena
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        onPressed: () {
                          setState(() {
                            _ocultarContrasena = !_ocultarContrasena;
                          });
                        },
                        icon: Icon(
                          _ocultarContrasena
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textoSecundario,
                        ),
                      ),
                      validator: _validarContrasena,
                    ),

                    const SizedBox(height: 20),

                    _RegisterField(
                      label: 'CONFIRMAR CONTRASEÑA',
                      controller: _confirmacionController,
                      hintText: 'Escribe nuevamente la contraseña',
                      icon: Icons.lock_reset_rounded,
                      obscureText: _ocultarConfirmacion,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_cargando) {
                          _crearCuenta();
                        }
                      },
                      suffixIcon: IconButton(
                        tooltip: _ocultarConfirmacion
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        onPressed: () {
                          setState(() {
                            _ocultarConfirmacion = !_ocultarConfirmacion;
                          });
                        },
                        icon: Icon(
                          _ocultarConfirmacion
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textoSecundario,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirma tu contraseña';
                        }

                        if (value != _contrasenaController.text) {
                          return 'Las contraseñas no coinciden';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: _cargando ? null : _crearCuenta,
                        child: _cargando
                            ? const SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.blanco,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Crear cuenta'),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Ya tengo una cuenta'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String? _validarCorreo(String? value) {
    final correo = value?.trim() ?? '';

    if (correo.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    final expresionCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!expresionCorreo.hasMatch(correo)) {
      return 'Ingresa un correo válido';
    }

    return null;
  }

  static String? _validarContrasena(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa una contraseña';
    }

    if (value.length < 6) {
      return 'Debe tener mínimo 6 caracteres';
    }

    return null;
  }
}

class _RegisterField extends StatelessWidget {
  const _RegisterField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final String? Function(String?) validator;

  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.verdePrincipal,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.25,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          obscureText: obscureText,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFF77857E), size: 21),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
