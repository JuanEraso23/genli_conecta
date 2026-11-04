import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/solicitud.dart';
import '../../services/solicitud_service.dart';
import '../../widgets/solicitud_card.dart';
import 'solicitud_detail_screen.dart';

/// HU-11: lista en tiempo real de las solicitudes del usuario autenticado.
class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key, this.observarSolicitudes});

  /// Permite inyectar el stream en pruebas. Si es null se usa Firestore
  /// mediante [SolicitudService.observarMisSolicitudes].
  final Stream<List<Solicitud>> Function()? observarSolicitudes;

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  late Stream<List<Solicitud>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _crearStream();
  }

  Stream<List<Solicitud>> _crearStream() {
    final fabrica =
        widget.observarSolicitudes ?? SolicitudService().observarMisSolicitudes;
    return fabrica();
  }

  void _reintentar() {
    setState(() {
      _stream = _crearStream();
    });
  }

  void _abrirDetalle(Solicitud solicitud) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SolicitudDetailScreen(solicitud: solicitud),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Regresar',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: const Text('Mis solicitudes'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Solicitud>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _MensajeCentral(
                icono: Icons.cloud_off_rounded,
                texto: snapshot.error is SolicitudServiceException
                    ? snapshot.error.toString()
                    : 'No fue posible cargar tus solicitudes.',
                accion: FilledButton(
                  onPressed: _reintentar,
                  child: const Text('Reintentar'),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final solicitudes = snapshot.data!;
            if (solicitudes.isEmpty) {
              return const _MensajeCentral(
                icono: Icons.inbox_outlined,
                texto: 'Aún no tienes solicitudes registradas',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: solicitudes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final solicitud = solicitudes[index];
                return SolicitudCard(
                  solicitud: solicitud,
                  onTap: () => _abrirDetalle(solicitud),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MensajeCentral extends StatelessWidget {
  const _MensajeCentral({
    required this.icono,
    required this.texto,
    this.accion,
  });

  final IconData icono;
  final String texto;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: AppColors.verdeSecundario),
            const SizedBox(height: 16),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.verdeTexto,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (accion != null) ...[const SizedBox(height: 16), accion!],
          ],
        ),
      ),
    );
  }
}
