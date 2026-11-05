import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/solucion.dart';

/// Tarjeta del catálogo administrativo con estado y acciones.
class AdminSolucionCard extends StatelessWidget {
  const AdminSolucionCard({
    super.key,
    required this.solucion,
    required this.onEditar,
    required this.onCambiarPublicacion,
    this.procesando = false,
  });

  final Solucion solucion;
  final VoidCallback onEditar;
  final VoidCallback onCambiarPublicacion;

  /// Deshabilita las acciones mientras se publica o despublica.
  final bool procesando;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.blanco,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.bordeCampo.withValues(alpha: 0.8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: solucion.color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(solucion.icono, color: solucion.color, size: 27),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    solucion.categoria.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: solucion.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                EstadoPublicacionChip(publicada: solucion.publicada),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              solucion.nombre,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.verdeTexto,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              solucion.descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textoSecundario,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: procesando ? null : onEditar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.verdePrincipal,
                    side: const BorderSide(color: AppColors.verdePrincipal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Editar'),
                ),
                FilledButton.icon(
                  onPressed: procesando ? null : onCambiarPublicacion,
                  style: FilledButton.styleFrom(
                    backgroundColor: solucion.publicada
                        ? AppColors.textoSecundario
                        : AppColors.verdePrincipal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(
                    solucion.publicada
                        ? Icons.visibility_off_outlined
                        : Icons.publish_rounded,
                    size: 18,
                  ),
                  label: Text(solucion.publicada ? 'Despublicar' : 'Publicar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Cápsula "Publicada" / "No publicada".
class EstadoPublicacionChip extends StatelessWidget {
  const EstadoPublicacionChip({super.key, required this.publicada});

  final bool publicada;

  @override
  Widget build(BuildContext context) {
    final Color color = publicada
        ? AppColors.verdePrincipal
        : AppColors.textoSecundario;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: publicada ? AppColors.verdeClaro : AppColors.fondoCampo,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        publicada ? 'Publicada' : 'No publicada',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
