import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/solicitud.dart';

class AdminSolicitudCard extends StatelessWidget {
  const AdminSolicitudCard({
    super.key,
    required this.solicitud,
    required this.onTap,
  });

  final Solicitud solicitud;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.bordeCampo),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    solicitud.codigo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.verdePrincipal,
                    ),
                  ),
                  _buildEstadoChip(solicitud.estado),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                solicitud.solucionNombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.verdeTexto,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.business, size: 16, color: AppColors.textoSecundario),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      solicitud.organizacion,
                      style: const TextStyle(color: AppColors.textoSecundario),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.textoSecundario),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      solicitud.ubicacion,
                      style: const TextStyle(color: AppColors.textoSecundario),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Creada: ${solicitud.fechaCreacion.day}/${solicitud.fechaCreacion.month}/${solicitud.fechaCreacion.year}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.verdePrincipal),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoChip(String estado) {
    Color colorFondo;
    Color colorTexto;
    String textoVisible;

    switch (estado) {
      case 'en_revision':
        colorFondo = Colors.orange.withValues(alpha: 0.1);
        colorTexto = Colors.orange[800]!;
        textoVisible = 'En revisión';
        break;
      case 'aprobada':
        colorFondo = Colors.green.withValues(alpha: 0.1);
        colorTexto = Colors.green[800]!;
        textoVisible = 'Aprobada';
        break;
      case 'rechazada':
        colorFondo = Colors.red.withValues(alpha: 0.1);
        colorTexto = Colors.red[800]!;
        textoVisible = 'Rechazada';
        break;
      case 'cerrada':
        colorFondo = Colors.grey.withValues(alpha: 0.1);
        colorTexto = Colors.grey[800]!;
        textoVisible = 'Cerrada';
        break;
      case 'recibida':
      default:
        colorFondo = AppColors.verdeClaro;
        colorTexto = AppColors.verdePrincipal;
        textoVisible = 'Recibida';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        textoVisible,
        style: TextStyle(
          color: colorTexto,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}