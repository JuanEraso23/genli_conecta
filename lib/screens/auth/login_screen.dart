import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _correoController = TextEditingController();

  final TextEditingController _contrasenaController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _ocultarContrasena = true;
  bool _cargando = false;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    final bool accesoPermitido = await _authService.iniciarSesion(
      correo: _correoController.text,
      contrasena: _contrasenaController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _cargando = false;
    });

    if (!accesoPermitido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo o contraseña incorrectos.')),
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  void _abrirRegistro() {
    Navigator.pushNamed(context, AppRoutes.register);
  }

  void _completarCredencialesDemo() {
    _correoController.text = AuthService.correoDemo;
    _contrasenaController.text = AuthService.contrasenaDemo;

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verdePrincipal,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 56,
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _LoginHeader(),
                        const SizedBox(height: 34),
                        _LoginForm(
                          formKey: _formKey,
                          correoController: _correoController,
                          contrasenaController: _contrasenaController,
                          ocultarContrasena: _ocultarContrasena,
                          cargando: _cargando,
                          onCambiarVisibilidad: () {
                            setState(() {
                              _ocultarContrasena = !_ocultarContrasena;
                            });
                          },
                          onIniciarSesion: _iniciarSesion,
                          onCrearCuenta: _abrirRegistro,
                          onUsarCredencialesDemo: _completarCredencialesDemo,
                        ),
                        const SizedBox(height: 28),
                        const Center(
                          child: Text(
                            'Prototipo académico',
                            style: TextStyle(
                              color: Color(0xFFB9D5C9),
                              fontSize: 12,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
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

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Logo(),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'GenLi Conecta',
                style: TextStyle(
                  color: AppColors.blanco,
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Text(
          'Soluciones sostenibles, un solo lugar para '
          'consultarlas y hacer seguimiento.',
          style: TextStyle(
            color: AppColors.blanco,
            fontSize: 17,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: AppColors.amarillo,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.bolt_rounded,
        color: AppColors.verdeOscuro,
        size: 31,
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.correoController,
    required this.contrasenaController,
    required this.ocultarContrasena,
    required this.cargando,
    required this.onCambiarVisibilidad,
    required this.onIniciarSesion,
    required this.onCrearCuenta,
    required this.onUsarCredencialesDemo,
  });

  final GlobalKey<FormState> formKey;

  final TextEditingController correoController;
  final TextEditingController contrasenaController;

  final bool ocultarContrasena;
  final bool cargando;

  final VoidCallback onCambiarVisibilidad;
  final VoidCallback onIniciarSesion;
  final VoidCallback onCrearCuenta;
  final VoidCallback onUsarCredencialesDemo;

  static String? _validarCorreo(String? value) {
    final String correo = value?.trim() ?? '';

    if (correo.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    final RegExp expresionCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!expresionCorreo.hasMatch(correo)) {
      return 'Ingresa un correo válido';
    }

    return null;
  }

  static String? _validarContrasena(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña';
    }

    if (value.length < 6) {
      return 'Debe tener mínimo 6 caracteres';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 22),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inicia sesión',
              style: TextStyle(
                color: AppColors.verdeTexto,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),

            const _FieldLabel(text: 'Correo electrónico'),
            const SizedBox(height: 8),

            TextFormField(
              controller: correoController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                hintText: 'nombre@correo.com',
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF829087),
                  size: 21,
                ),
              ),
              validator: _validarCorreo,
            ),

            const SizedBox(height: 18),

            const _FieldLabel(text: 'Contraseña'),
            const SizedBox(height: 8),

            TextFormField(
              controller: contrasenaController,
              obscureText: ocultarContrasena,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) {
                if (!cargando) {
                  onIniciarSesion();
                }
              },
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFF829087),
                  size: 21,
                ),
                suffixIcon: IconButton(
                  tooltip: ocultarContrasena
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
                  onPressed: onCambiarVisibilidad,
                  icon: Icon(
                    ocultarContrasena
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: const Color(0xFF829087),
                    size: 21,
                  ),
                ),
              ),
              validator: _validarContrasena,
            ),

            const SizedBox(height: 18),

            // Botón para completar las credenciales de demostración.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: cargando ? null : onUsarCredencialesDemo,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.verdePrincipal,
                  side: const BorderSide(color: AppColors.verdePrincipal),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline_rounded, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Usar credenciales de demostración',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Botón principal para iniciar sesión.
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: cargando ? null : onIniciarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.verdePrincipal,
                  foregroundColor: AppColors.blanco,
                  disabledBackgroundColor: AppColors.verdePrincipal.withValues(
                    alpha: 0.65,
                  ),
                  disabledForegroundColor: AppColors.blanco,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: cargando
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.blanco,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 19),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 18),

            // Enlace a crear cuenta
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 2,
              runSpacing: 0,
              children: [
                const Text(
                  '¿Nuevo solicitante?',
                  style: TextStyle(color: AppColors.textoCampo, fontSize: 14),
                ),
                TextButton(
                  onPressed: onCrearCuenta,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Crear cuenta',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textoCampo,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
