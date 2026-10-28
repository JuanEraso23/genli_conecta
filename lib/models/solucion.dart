import 'package:flutter/material.dart';

class Solucion {
  const Solucion({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.iconoNombre,
    required this.colorHex,
    required this.publicada,
  });

  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String iconoNombre;
  final String colorHex;
  final bool publicada;

  static const String _colorPorDefecto = '005C3F';

  IconData get icono {
    switch (iconoNombre) {
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'groups':
        return Icons.groups_rounded;
      case 'eco':
        return Icons.eco_rounded;
      case 'co2':
        return Icons.co2_rounded;
      default:
        return Icons.solar_power_rounded;
    }
  }

  Color get color {
    final String limpio = colorHex.replaceAll('#', '').trim();
    final int? valor = limpio.length == 6
        ? int.tryParse('FF$limpio', radix: 16)
        : null;

    return Color(valor ?? int.parse('FF$_colorPorDefecto', radix: 16));
  }

  factory Solucion.fromMap(String id, Map<String, dynamic> data) {
    return Solucion(
      id: id,
      nombre: data['nombre'] as String? ?? '',
      descripcion: data['descripcion'] as String? ?? '',
      categoria: data['categoria'] as String? ?? '',
      iconoNombre: data['iconoNombre'] as String? ?? 'solar_power',
      colorHex: data['colorHex'] as String? ?? _colorPorDefecto,
      publicada: data['publicada'] as bool? ?? false,
    );
  }
}
