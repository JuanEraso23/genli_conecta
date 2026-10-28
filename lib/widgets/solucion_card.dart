import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/solucion.dart';

class SolucionCard extends StatelessWidget {
  const SolucionCard({
    super.key,
    required this.solucion,
    required this.onTap,
    this.onSolicitar,
  });

  final Solucion solucion;
  final VoidCallback onTap;
  final VoidCallback? onSolicitar;

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(solucion: solucion),
              const SizedBox(height: 16),

              Text(
                solucion.nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.verdeTexto,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                solucion.descripcion,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textoSecundario,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.verdePrincipal,
                        side: const BorderSide(color: AppColors.verdePrincipal),
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.visibility_outlined, size: 19),
                      label: const Text(
                        'Ver detalle',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),

                  if (onSolicitar != null) ...[
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 48,
                      height: 46,
                      child: IconButton.filled(
                        tooltip: 'Registrar solicitud',
                        onPressed: onSolicitar,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.verdePrincipal,
                          foregroundColor: AppColors.blanco,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.solucion});

  final Solucion solucion;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: solucion.color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(solucion.icono, color: solucion.color, size: 29),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: solucion.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
              ),
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
          ),
        ),

        const SizedBox(width: 8),

        const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Color(0xFF9AA7A0),
          size: 16,
        ),
      ],
    );
  }
}
