import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genli_conecta/services/solucion_service.dart';

void main() {
  group('normalizarColorHex', () {
    test('quita # y espacios y pasa a mayúsculas', () {
      expect(normalizarColorHex(' #3e9fc5 '), '3E9FC5');
      expect(normalizarColorHex('f9b233'), 'F9B233');
    });
  });

  group('esColorHexValido', () {
    test('acepta 6 hexadecimales con o sin #', () {
      expect(esColorHexValido('005C3F'), isTrue);
      expect(esColorHexValido('#e58a3b'), isTrue);
    });

    test('rechaza longitudes y caracteres inválidos', () {
      expect(esColorHexValido(''), isFalse);
      expect(esColorHexValido('ABC'), isFalse);
      expect(esColorHexValido('1234567'), isFalse);
      expect(esColorHexValido('12345G'), isFalse);
    });
  });

  test('iconosPermitidos contiene solo los cinco del contrato', () {
    expect(iconosPermitidos, [
      'solar_power',
      'water_drop',
      'groups',
      'eco',
      'co2',
    ]);
  });

  group('mensajeErrorCatalogo', () {
    test('explica la falta de permisos', () {
      final String mensaje = mensajeErrorCatalogo(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
        'por defecto',
      );
      expect(mensaje, contains('No tienes permisos'));
    });

    test('usa el mensaje por defecto en errores desconocidos', () {
      expect(
        mensajeErrorCatalogo(Exception('x'), 'por defecto'),
        'por defecto',
      );
    });
  });
}
