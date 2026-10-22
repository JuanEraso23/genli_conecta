
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/solucion.dart';

class SolicitudFormScreen extends StatefulWidget {
  const SolicitudFormScreen({
    super.key,
    required this.solucion,
  });

  final Solucion solucion;

  @override
  State<SolicitudFormScreen> createState() =>
      _SolicitudFormScreenState();
}

class _SolicitudFormScreenState
    extends State<SolicitudFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _organizacionController =
  TextEditingController();

  final TextEditingController _ubicacionController =
  TextEditingController();

  final TextEditingController _descripcionController =
  TextEditingController();

  bool _cargando = false;

  @override
  void dispose() {
    _organizacionController.dispose();
    _ubicacionController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _registrarSolicitud() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    // Simulación del registro.
    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _cargando = false;
    });

    await _mostrarConfirmacion();
  }

  Future<void> _mostrarConfirmacion() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: AppColors.verdeClaro,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.verdePrincipal,
              size: 44,
            ),
          ),
          title: const Text(
            'Solicitud registrada',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'La solicitud fue registrada correctamente.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.verdeClaro,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Código de seguimiento',
                      style: TextStyle(
                        color: AppColors.textoSecundario,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'SOL-001',
                      style: TextStyle(
                        color: AppColors.verdePrincipal,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Estado: Recibida',
                      style: TextStyle(
                        color: AppColors.verdeTexto,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

    Navigator.popUntil(
      context,
          (route) => route.isFirst,
    );
  }

  Future<bool> _confirmarSalida() async {
    if (_organizacionController.text.trim().isEmpty &&
        _ubicacionController.text.trim().isEmpty &&
        _descripcionController.text.trim().isEmpty) {
      return true;
    }

    final bool? salir = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.amarillo,
            size: 44,
          ),
          title: const Text(
            'Descartar solicitud',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'La información ingresada no se guardará. '
                '¿Deseas regresar?',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Continuar editando'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Descartar'),
            ),
          ],
        );
      },
    );

    return salir ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final bool salir = await _confirmarSalida();

        if (salir && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.fondoClaro,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Regresar',
            onPressed: () async {
              final bool salir = await _confirmarSalida();

              if (salir && context.mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
            ),
          ),
          title: const Text('Registrar solicitud'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                20,
                22,
                20,
                36,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 620,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SelectedSolutionCard(
                        solucion: widget.solucion,
                      ),
                      const SizedBox(height: 22),
                      _FormCard(
                        organizacionController:
                        _organizacionController,
                        ubicacionController:
                        _ubicacionController,
                        descripcionController:
                        _descripcionController,
                      ),
                      const SizedBox(height: 22),
                      const _InformationNotice(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: _cargando
                              ? null
                              : _registrarSolicitud,
                          icon: _cargando
                              ? const SizedBox.shrink()
                              : const Icon(
                            Icons.send_rounded,
                          ),
                          label: _cargando
                              ? const SizedBox(
                            width: 23,
                            height: 23,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.blanco,
                            ),
                          )
                              : const Text(
                            'Registrar solicitud',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedSolutionCard extends StatelessWidget {
  const _SelectedSolutionCard({
    required this.solucion,
  });

  final Solucion solucion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.verdePrincipal,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.blanco.withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              solucion.icono,
              color: solucion.color,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Línea seleccionada',
                  style: TextStyle(
                    color: Color(0xFFD7E8E0),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  solucion.nombre,
                  style: const TextStyle(
                    color: AppColors.blanco,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  solucion.categoria,
                  style: TextStyle(
                    color: solucion.color,
                    fontSize: 12,
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

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.organizacionController,
    required this.ubicacionController,
    required this.descripcionController,
  });

  final TextEditingController organizacionController;
  final TextEditingController ubicacionController;
  final TextEditingController descripcionController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.bordeCampo,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Describe tu necesidad',
            style: TextStyle(
              color: AppColors.verdeTexto,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Completa todos los campos para registrar la solicitud.',
            style: TextStyle(
              color: AppColors.textoSecundario,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          _FormField(
            label: 'ORGANIZACIÓN O COMUNIDAD',
            child: TextFormField(
              controller: organizacionController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Ej. Corporación Ríos Vivos',
                prefixIcon: Icon(
                  Icons.business_outlined,
                  color: Color(0xFF77857E),
                ),
              ),
              validator: (value) {
                final String organizacion =
                    value?.trim() ?? '';

                if (organizacion.isEmpty) {
                  return 'Ingresa la organización o comunidad';
                }

                if (organizacion.length < 3) {
                  return 'El nombre es demasiado corto';
                }

                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          _FormField(
            label: 'UBICACIÓN',
            child: TextFormField(
              controller: ubicacionController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText:
                'Municipio, corregimiento o dirección general',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF77857E),
                ),
              ),
              validator: (value) {
                final String ubicacion =
                    value?.trim() ?? '';

                if (ubicacion.isEmpty) {
                  return 'Ingresa la ubicación';
                }

                if (ubicacion.length < 3) {
                  return 'La ubicación es demasiado corta';
                }

                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          _FormField(
            label: 'DESCRIPCIÓN DE LA NECESIDAD',
            child: TextFormField(
              controller: descripcionController,
              textCapitalization:
              TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 8,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText:
                'Describe la situación, los beneficiarios '
                    'y la solución que necesitas...',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                final String descripcion =
                    value?.trim() ?? '';

                if (descripcion.isEmpty) {
                  return 'Describe la necesidad';
                }

                if (descripcion.length < 20) {
                  return 'Escribe al menos 20 caracteres';
                }

                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

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
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _InformationNotice extends StatelessWidget {
  const _InformationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.verdeClaro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.verdePrincipal,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Al registrar la solicitud, el sistema generará '
                  'un código de seguimiento y asignará el estado '
                  'inicial “Recibida”.',
              style: TextStyle(
                color: AppColors.verdeTexto,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}