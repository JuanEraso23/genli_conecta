import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/usuario.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();

  final TextEditingController _organizacionController = TextEditingController();

  final AuthService _authService = AuthService();

  Usuario? _usuario;
  bool _cargandoPerfil = true;
  bool _guardando = false;
  String? _mensajeError;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _organizacionController.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    setState(() {
      _cargandoPerfil = true;
      _mensajeError = null;
    });

    try {
      final Usuario? usuario = await _authService.obtenerPerfilActual();

      if (!mounted) {
        return;
      }

      if (usuario == null) {
        setState(() {
          _cargandoPerfil = false;
          _mensajeError = 'No fue posible encontrar el perfil del usuario.';
        });

        return;
      }

      _nombreController.text = usuario.nombre;
      _organizacionController.text = usuario.organizacion;

      setState(() {
        _usuario = usuario;
        _cargandoPerfil = false;
      });
    } on FirebaseException catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargandoPerfil = false;
        _mensajeError = 'No fue posible consultar el perfil.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargandoPerfil = false;
        _mensajeError = 'Ocurrió un error inesperado al cargar el perfil.';
      });
    }
  }

  Future<void> _guardarCambios() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final Usuario usuarioActualizado = await _authService
          .actualizarPerfilActual(
            nombre: _nombreController.text,
            organizacion: _organizacionController.text,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _usuario = usuarioActualizado;
        _guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El perfil fue actualizado correctamente.'),
        ),
      );
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _guardando = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.mensaje)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrió un error inesperado al actualizar el perfil.'),
        ),
      );
    }
  }

  String? _validarNombre(String? valor) {
    final String nombre = valor?.trim() ?? '';

    if (nombre.isEmpty) {
      return 'Ingresa tu nombre';
    }

    if (nombre.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }

    return null;
  }

  String? _validarOrganizacion(String? valor) {
    final String organizacion = valor?.trim() ?? '';

    if (organizacion.isEmpty) {
      return 'Ingresa tu organización';
    }

    if (organizacion.length < 3) {
      return 'La organización debe tener al menos 3 caracteres';
    }

    return null;
  }

  String _textoRol(RolUsuario rol) {
    switch (rol) {
      case RolUsuario.administrador:
        return 'Administrador';
      case RolUsuario.solicitante:
        return 'Solicitante';
    }
  }

  String _formatearFecha(DateTime fecha) {
    final String dia = fecha.day.toString().padLeft(2, '0');
    final String mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      appBar: AppBar(
        backgroundColor: AppColors.verdePrincipal,
        foregroundColor: AppColors.blanco,
        title: const Text('Mi perfil'),
      ),
      body: SafeArea(child: _construirContenido()),
    );
  }

  Widget _construirContenido() {
    if (_cargandoPerfil) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mensajeError != null || _usuario == null) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_off_outlined,
                color: AppColors.textoSecundario,
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                _mensajeError ?? 'No fue posible consultar el perfil.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textoSecundario,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _cargarPerfil,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final Usuario usuario = _usuario!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 680),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _ProfileHeader(usuario: usuario),
                    const SizedBox(height: 20),
                    _ProfileFormCard(
                      nombreController: _nombreController,
                      organizacionController: _organizacionController,
                      correo: usuario.correo,
                      rol: _textoRol(usuario.rol),
                      activo: usuario.activo,
                      fechaRegistro: _formatearFecha(usuario.fechaRegistro),
                      guardando: _guardando,
                      validarNombre: _validarNombre,
                      validarOrganizacion: _validarOrganizacion,
                      onGuardar: _guardarCambios,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final String inicial = usuario.nombre.trim().isEmpty
        ? '?'
        : usuario.nombre.trim()[0].toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.verdePrincipal,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.blanco,
            child: Text(
              inicial,
              style: const TextStyle(
                color: AppColors.verdePrincipal,
                fontSize: 34,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            usuario.nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.blanco,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            usuario.correo,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFD7EBE1), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ProfileFormCard extends StatelessWidget {
  const _ProfileFormCard({
    required this.nombreController,
    required this.organizacionController,
    required this.correo,
    required this.rol,
    required this.activo,
    required this.fechaRegistro,
    required this.guardando,
    required this.validarNombre,
    required this.validarOrganizacion,
    required this.onGuardar,
  });

  final TextEditingController nombreController;
  final TextEditingController organizacionController;
  final String correo;
  final String rol;
  final bool activo;
  final String fechaRegistro;
  final bool guardando;
  final String? Function(String?) validarNombre;
  final String? Function(String?) validarOrganizacion;
  final VoidCallback onGuardar;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.blanco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.bordeCampo.withValues(alpha: 0.8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de la cuenta',
              style: TextStyle(
                color: AppColors.verdeTexto,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: nombreController,
              validator: validarNombre,
              textInputAction: TextInputAction.next,
              enabled: !guardando,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: organizacionController,
              validator: validarOrganizacion,
              textInputAction: TextInputAction.done,
              enabled: !guardando,
              onFieldSubmitted: (_) {
                if (!guardando) {
                  onGuardar();
                }
              },
              decoration: const InputDecoration(
                labelText: 'Organización',
                prefixIcon: Icon(Icons.business_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _ProfileInfoRow(
              icon: Icons.email_outlined,
              label: 'Correo electrónico',
              value: correo,
            ),
            _ProfileInfoRow(
              icon: Icons.badge_outlined,
              label: 'Rol',
              value: rol,
            ),
            _ProfileInfoRow(
              icon: Icons.verified_user_outlined,
              label: 'Estado',
              value: activo ? 'Activo' : 'Inactivo',
            ),
            _ProfileInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha de registro',
              value: fechaRegistro,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: guardando ? null : onGuardar,
                icon: guardando
                    ? const SizedBox.shrink()
                    : const Icon(Icons.save_outlined),
                label: guardando
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.blanco,
                        ),
                      )
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.verdePrincipal, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.verdeTexto,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
