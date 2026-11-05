import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../models/solucion.dart';
import '../../../services/solucion_service.dart';
import '../../../widgets/admin_solucion_card.dart';
import 'solucion_form_admin_screen.dart';

/// Listado administrativo del catálogo (HU-16).
///
/// Pendiente de protección por rol en HU-22.
class AdminCatalogoScreen extends StatefulWidget {
  const AdminCatalogoScreen({super.key, this.solucionService});

  /// Permite inyectar un servicio alterno en pruebas.
  final SolucionService? solucionService;

  @override
  State<AdminCatalogoScreen> createState() => _AdminCatalogoScreenState();
}

class _AdminCatalogoScreenState extends State<AdminCatalogoScreen> {
  late final SolucionService _solucionService =
      widget.solucionService ?? SolucionService();

  StreamSubscription<List<Solucion>>? _suscripcion;
  List<Solucion> _soluciones = const [];
  bool _cargando = true;
  bool _hayError = false;
  Object? _error;
  final Set<String> _procesando = <String>{};

  @override
  void initState() {
    super.initState();
    _escucharSoluciones();
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }

  void _reintentar() {
    setState(() {
      _cargando = true;
      _hayError = false;
    });

    _escucharSoluciones();
  }

  void _escucharSoluciones() {
    _suscripcion?.cancel();

    _suscripcion = _solucionService.observarTodasLasSoluciones().listen(
      (soluciones) {
        if (!mounted) {
          return;
        }

        setState(() {
          _soluciones = soluciones;
          _cargando = false;
          _hayError = false;
        });
      },
      onError: (Object error) {
        debugPrint('Error al cargar el catálogo administrativo: $error');

        if (!mounted) {
          return;
        }

        setState(() {
          _cargando = false;
          _hayError = true;
          _error = error;
        });
      },
    );
  }

  List<String> get _categoriasExistentes {
    return _soluciones
        .map((solucion) => solucion.categoria.trim())
        .where((categoria) => categoria.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<void> _abrirFormulario([Solucion? solucion]) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SolucionFormAdminScreen(
          solucion: solucion,
          solucionService: _solucionService,
          categoriasDisponibles: _categoriasExistentes,
        ),
      ),
    );
  }

  Future<void> _confirmarCambioPublicacion(Solucion solucion) async {
    final bool publicar = !solucion.publicada;

    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(publicar ? 'Publicar solución' : 'Despublicar solución'),
          content: Text(
            publicar
                ? '"${solucion.nombre}" será visible para los solicitantes en el catálogo.'
                : '"${solucion.nombre}" dejará de mostrarse a los solicitantes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(publicar ? 'Publicar' : 'Despublicar'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true) {
      return;
    }

    setState(() => _procesando.add(solucion.id));

    try {
      await _solucionService.cambiarPublicacion(
        id: solucion.id,
        publicada: publicar,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            publicar
                ? 'La solución se publicó correctamente.'
                : 'La solución se despublicó correctamente.',
          ),
        ),
      );
    } catch (error) {
      debugPrint('Error al cambiar la publicación: $error');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mensajeErrorCatalogo(
              error,
              'No fue posible cambiar la publicación. Inténtalo de nuevo.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _procesando.remove(solucion.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administración del catálogo')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: AppColors.verdePrincipal,
        foregroundColor: AppColors.blanco,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Crear solución'),
      ),
      body: _construirContenido(),
    );
  }

  Widget _construirContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.verdePrincipal),
      );
    }

    if (_hayError) {
      return _MensajeCatalogo(
        icono: Icons.cloud_off_rounded,
        colorIcono: AppColors.error,
        titulo: 'No fue posible cargar el catálogo',
        descripcion: mensajeErrorCatalogo(
          _error ?? Exception(),
          'Revisa tu conexión a internet e inténtalo de nuevo.',
        ),
        accion: FilledButton.icon(
          onPressed: _reintentar,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reintentar'),
        ),
      );
    }

    if (_soluciones.isEmpty) {
      return const _MensajeCatalogo(
        icono: Icons.inventory_2_outlined,
        colorIcono: AppColors.verdeSecundario,
        titulo: 'Aún no hay soluciones registradas',
        descripcion:
            'Usa "Crear solución" para agregar la primera al catálogo.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const double espacio = 16;
        const double margen = 20;
        final double anchoMaximo = constraints.maxWidth > 1140
            ? 1140
            : constraints.maxWidth;
        final double ancho = anchoMaximo - margen * 2;
        final int columnas = ancho >= 900
            ? 3
            : ancho >= 600
            ? 2
            : 1;
        final double anchoTarjeta =
            (ancho - espacio * (columnas - 1)) / columnas;

        return SingleChildScrollView(
          // Espacio inferior para que el FAB no tape la última tarjeta.
          padding: const EdgeInsets.fromLTRB(margen, margen, margen, 96),
          child: Center(
            child: SizedBox(
              width: ancho < 0 ? 0 : ancho,
              child: Wrap(
                spacing: espacio,
                runSpacing: espacio,
                children: [
                  for (final Solucion solucion in _soluciones)
                    SizedBox(
                      width: anchoTarjeta < 0 ? 0 : anchoTarjeta,
                      child: AdminSolucionCard(
                        key: ValueKey(solucion.id),
                        solucion: solucion,
                        procesando: _procesando.contains(solucion.id),
                        onEditar: () => _abrirFormulario(solucion),
                        onCambiarPublicacion: () =>
                            _confirmarCambioPublicacion(solucion),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MensajeCatalogo extends StatelessWidget {
  const _MensajeCatalogo({
    required this.icono,
    required this.colorIcono,
    required this.titulo,
    required this.descripcion,
    this.accion,
  });

  final IconData icono;
  final Color colorIcono;
  final String titulo;
  final String descripcion;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, color: colorIcono, size: 48),
              const SizedBox(height: 16),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.verdeTexto,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                descripcion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textoSecundario,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (accion != null) ...[const SizedBox(height: 20), accion!],
            ],
          ),
        ),
      ),
    );
  }
}
