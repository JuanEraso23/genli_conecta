import 'package:flutter/material.dart';

import '../models/solucion.dart';

abstract final class MockData {
  static const List<Solucion> soluciones = [
    Solucion(
      id: 'SOL-01',
      nombre: 'Energías renovables',
      descripcion:
      'Soluciones sostenibles orientadas al aprovechamiento de fuentes de energía limpia.',
      categoria: 'Energía',
      icono: Icons.solar_power_rounded,
      color: Color(0xFFF9B233),
    ),
    Solucion(
      id: 'SOL-02',
      nombre: 'Agua potable',
      descripcion:
      'Proyectos relacionados con el acceso, tratamiento y gestión sostenible del agua.',
      categoria: 'Agua',
      icono: Icons.water_drop_rounded,
      color: Color(0xFF3E9FC5),
    ),
    Solucion(
      id: 'SOL-03',
      nombre: 'Soluciones socioambientales',
      descripcion:
      'Iniciativas orientadas al bienestar comunitario y al cuidado del medioambiente.',
      categoria: 'Socioambiental',
      icono: Icons.groups_rounded,
      color: Color(0xFF75A989),
    ),
    Solucion(
      id: 'SOL-04',
      nombre: 'Proyectos sostenibles',
      descripcion:
      'Gestión y desarrollo de proyectos con enfoque ambiental y comunitario.',
      categoria: 'Sostenibilidad',
      icono: Icons.eco_rounded,
      color: Color(0xFF005C3F),
    ),
    Solucion(
      id: 'SOL-05',
      nombre: 'Reducción de emisiones',
      descripcion:
      'Alternativas orientadas a disminuir el impacto ambiental y las emisiones de CO₂.',
      categoria: 'Medioambiente',
      icono: Icons.co2_rounded,
      color: Color(0xFFE58A3B),
    ),
  ];
}