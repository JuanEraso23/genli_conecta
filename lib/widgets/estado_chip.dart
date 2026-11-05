import 'package:flutter/material.dart';

/// Muestra el estado técnico de una solicitud como una etiqueta legible.
/// No modifica el valor guardado en Firestore: solo cambia la presentación.
class EstadoChip extends StatelessWidget {
  const EstadoChip({super.key, required this.estado});

  final String estado;

  /// Texto visible para un valor técnico de estado.
  static String etiquetaDe(String estado) {
    switch (estado) {
      case 'recibida':
        return 'Recibida';
      case 'en_revision':
        return 'En revisión';
      case 'aprobada':
        return 'Aprobada';
      case 'rechazada':
        return 'Rechazada';
      case 'cerrada':
        return 'Cerrada';
      default:
        return 'Estado desconocido';
    }
  }

  static Color _fondoDe(String estado) {
    switch (estado) {
      case 'recibida':
        return const Color(0xFFDCEBFA);
      case 'en_revision':
        return const Color(0xFFFFF1CC);
      case 'aprobada':
        return const Color(0xFFDDF0E4);
      case 'rechazada':
        return const Color(0xFFFBE0DE);
      default:
        return const Color(0xFFE6E8E7);
    }
  }

  static Color _textoDe(String estado) {
    switch (estado) {
      case 'recibida':
        return const Color(0xFF1B5E8A);
      case 'en_revision':
        return const Color(0xFF8A5A00);
      case 'aprobada':
        return const Color(0xFF1E6B3A);
      case 'rechazada':
        return const Color(0xFF9E2A22);
      default:
        return const Color(0xFF55605B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _fondoDe(estado),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        etiquetaDe(estado),
        style: TextStyle(
          color: _textoDe(estado),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
