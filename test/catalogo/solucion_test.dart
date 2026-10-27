import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genli_conecta/data/mock_data.dart';
import 'package:genli_conecta/models/solucion.dart';
import 'package:genli_conecta/services/solucion_service.dart';

void main() {
  group('Solucion.fromMap', () {
    test('convierte un documento de Firestore', () {
      final Solucion solucion = Solucion.fromMap('SOL-02', {
        'nombre': 'Agua potable',
        'descripcion': 'Gestión sostenible del agua.',
        'categoria': 'Agua',
        'iconoNombre': 'water_drop',
        'colorHex': '3E9FC5',
        'publicada': true,
      });

      expect(solucion.id, 'SOL-02');
      expect(solucion.nombre, 'Agua potable');
      expect(solucion.publicada, isTrue);
      expect(solucion.icono, Icons.water_drop_rounded);
      expect(solucion.color, const Color(0xFF3E9FC5));
    });

    test('usa valores por defecto si faltan campos', () {
      final Solucion solucion = Solucion.fromMap('X', {});

      expect(solucion.nombre, '');
      expect(solucion.publicada, isFalse);
      expect(solucion.icono, Icons.solar_power_rounded);
      expect(solucion.color, const Color(0xFF005C3F));
    });

    test('acepta colorHex con # y tolera valores inválidos', () {
      expect(
        Solucion.fromMap('A', {'colorHex': '#F9B233'}).color,
        const Color(0xFFF9B233),
      );
      expect(
        Solucion.fromMap('B', {'colorHex': 'no-es-color'}).color,
        const Color(0xFF005C3F),
      );
    });
  });

  group('filtrarSoluciones', () {
    const List<Solucion> soluciones = MockData.soluciones;

    test('sin texto devuelve todas', () {
      expect(filtrarSoluciones(soluciones, '   ').length, soluciones.length);
    });

    test('busca por nombre sin distinguir mayúsculas', () {
      final resultado = filtrarSoluciones(soluciones, 'AGUA');
      expect(resultado.map((s) => s.nombre), contains('Agua potable'));
    });

    test('busca por categoría', () {
      final resultado = filtrarSoluciones(soluciones, 'medioambiente');
      expect(resultado.map((s) => s.nombre), contains('Reducción de emisiones'));
    });

    test('busca por descripción', () {
      final resultado = filtrarSoluciones(soluciones, 'comunitario');
      expect(resultado.map((s) => s.id), containsAll(['SOL-03', 'SOL-04']));
    });

    test('sin coincidencias devuelve lista vacía', () {
      expect(filtrarSoluciones(soluciones, 'zzzz'), isEmpty);
    });
  });
}
