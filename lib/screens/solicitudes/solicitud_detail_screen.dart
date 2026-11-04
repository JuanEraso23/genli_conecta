import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/solicitud.dart';
import '../../widgets/estado_chip.dart';
import '../../widgets/solicitud_card.dart';

/// HU-12 y HU-13: detalle de una solicitud, con su estado y observación.
/// Es solo de consulta: el solicitante no puede editar nada aquí.
class SolicitudDetailScreen extends StatelessWidget {
  const SolicitudDetailScreen({super.key, required this.solicitud});

  final Solicitud solicitud;

  @override
  Widget build(BuildContext context) {
    final observacion = solicitud.observacion.trim();

    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Regresar',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: const Text('Detalle de solicitud'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Seccion(
                titulo: 'Solicitud',
                hijos: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          solicitud.codigo,
                          style: const TextStyle(
                            color: AppColors.verdeTexto,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      EstadoChip(estado: solicitud.estado),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Dato(etiqueta: 'Solución', valor: solicitud.solucionNombre),
                  _Dato(
                    etiqueta: 'Fecha de creación',
                    valor: formatearFecha(solicitud.fechaCreacion),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Seccion(
                titulo: 'Datos enviados',
                hijos: [
                  _Dato(
                    etiqueta: 'Organización',
                    valor: solicitud.organizacion,
                  ),
                  _Dato(etiqueta: 'Ubicación', valor: solicitud.ubicacion),
                  _Dato(etiqueta: 'Descripción', valor: solicitud.descripcion),
                ],
              ),
              const SizedBox(height: 12),
              _Seccion(
                titulo: 'Seguimiento',
                hijos: [
                  _Dato(
                    etiqueta: 'Estado actual',
                    valor: EstadoChip.etiquetaDe(solicitud.estado),
                  ),
                  _Dato(
                    etiqueta: 'Última actualización',
                    valor: formatearFecha(solicitud.fechaActualizacion),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Seccion(
                titulo: 'Observación',
                hijos: [
                  Text(
                    observacion.isEmpty
                        ? 'Aún no hay observaciones'
                        : observacion,
                    style: TextStyle(
                      color: observacion.isEmpty
                          ? AppColors.textoSecundario
                          : AppColors.verdeTexto,
                      fontSize: 15,
                      height: 1.4,
                      fontStyle: observacion.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.maybePop(context),
                child: const Text('Regresar a Mis solicitudes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.hijos});

  final String titulo;
  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bordeCampo),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.verdePrincipal,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          ...hijos,
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              color: AppColors.textoSecundario,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: const TextStyle(
              color: AppColors.verdeTexto,
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
