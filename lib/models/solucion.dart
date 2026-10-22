import 'package:flutter/material.dart';

class Solucion {
  const Solucion({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.icono,
    required this.color,
  });

  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final IconData icono;
  final Color color;
}