import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/solicitud.dart';
import 'estado_chip.dart';

/// Formatea una fecha como dd/mm/aaaa sin usar paquetes externos.
String formatearFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year}';
}

/// Tarjeta compacta de una solicitud para la lista "Mis solicitudes".
class SolicitudCard extends StatelessWidget {
  const SolicitudCard({super.key, required this.solicitud, this.onTap});

  final Solicitud solicitud;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.blanco,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.bordeCampo),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      solicitud.codigo,
                      style: const TextStyle(
                        color: AppColors.verdeTexto,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  EstadoChip(estado: solicitud.estado),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                solicitud.solucionNombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.verdeTexto,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatearFecha(solicitud.fechaCreacion),
                style: const TextStyle(
                  color: AppColors.textoSecundario,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                solicitud.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textoCampo,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Ver detalle',
                  style: TextStyle(
                    color: AppColors.verdePrincipal,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
