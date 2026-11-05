import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/solucion.dart';

class SolucionService {
  SolucionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Escucha en tiempo real las soluciones con `publicada == true`.
  ///
  /// El orden se aplica en Dart para no requerir un índice compuesto.
  Stream<List<Solucion>> observarSolucionesPublicadas() {
    return _firestore
        .collection('soluciones')
        .where('publicada', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final List<Solucion> soluciones = snapshot.docs
              .map((doc) => Solucion.fromMap(doc.id, doc.data()))
              .toList();

          soluciones.sort((a, b) => a.nombre.compareTo(b.nombre));

          return soluciones;
        });
  }

  /// Escucha en tiempo real todo el catálogo (publicadas y no publicadas).
  ///
  /// Uso exclusivo de la administración. Ordena por nombre en Dart.
  Stream<List<Solucion>> observarTodasLasSoluciones() {
    return _firestore.collection('soluciones').snapshots().map((snapshot) {
      final List<Solucion> soluciones = snapshot.docs
          .map((doc) => Solucion.fromMap(doc.id, doc.data()))
          .toList();

      soluciones.sort((a, b) => a.nombre.compareTo(b.nombre));

      return soluciones;
    });
  }

  /// Crea un documento nuevo en `soluciones`.
  Future<void> crearSolucion({
    required String nombre,
    required String descripcion,
    required String categoria,
    required String iconoNombre,
    required String colorHex,
    required bool publicada,
  }) async {
    final Timestamp ahora = Timestamp.now();

    await _firestore.collection('soluciones').add({
      'nombre': nombre.trim(),
      'descripcion': descripcion.trim(),
      'categoria': categoria.trim(),
      'iconoNombre': iconoNombre,
      'colorHex': normalizarColorHex(colorHex),
      'publicada': publicada,
      'fechaCreacion': ahora,
      'fechaActualizacion': ahora,
    });
  }

  /// Actualiza los datos de una solución existente.
  ///
  /// No modifica `fechaCreacion` ni `publicada`, y nunca crea documentos.
  Future<void> actualizarSolucion({
    required String id,
    required String nombre,
    required String descripcion,
    required String categoria,
    required String iconoNombre,
    required String colorHex,
  }) async {
    await _firestore.collection('soluciones').doc(id).update({
      'nombre': nombre.trim(),
      'descripcion': descripcion.trim(),
      'categoria': categoria.trim(),
      'iconoNombre': iconoNombre,
      'colorHex': normalizarColorHex(colorHex),
      'fechaActualizacion': Timestamp.now(),
    });
  }

  /// Publica o despublica una solución existente.
  Future<void> cambiarPublicacion({
    required String id,
    required bool publicada,
  }) async {
    await _firestore.collection('soluciones').doc(id).update({
      'publicada': publicada,
      'fechaActualizacion': Timestamp.now(),
    });
  }
}

/// Traduce un error de escritura del catálogo a un mensaje para la UI.
String mensajeErrorCatalogo(Object error, String mensajePorDefecto) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return 'No tienes permisos para gestionar el catálogo. '
            'Verifica que tu cuenta sea administradora y esté activa.';
      case 'unavailable':
        return 'Sin conexión con el servidor. Inténtalo de nuevo.';
      case 'not-found':
        return 'La solución ya no existe en el catálogo.';
    }
  }

  return mensajePorDefecto;
}

/// Iconos permitidos para las soluciones del catálogo.
const List<String> iconosPermitidos = [
  'solar_power',
  'water_drop',
  'groups',
  'eco',
  'co2',
];

/// Quita el `#`, los espacios y convierte el color a mayúsculas.
String normalizarColorHex(String colorHex) {
  return colorHex.replaceAll('#', '').trim().toUpperCase();
}

/// Indica si el color (ya sin `#`) tiene 6 caracteres hexadecimales.
bool esColorHexValido(String colorHex) {
  return RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(normalizarColorHex(colorHex));
}

/// Filtra por nombre, categoría o descripción sin distinguir mayúsculas.
List<Solucion> filtrarSoluciones(List<Solucion> soluciones, String consulta) {
  final String texto = consulta.trim().toLowerCase();

  if (texto.isEmpty) {
    return soluciones;
  }

  return soluciones.where((solucion) {
    return solucion.nombre.toLowerCase().contains(texto) ||
        solucion.categoria.toLowerCase().contains(texto) ||
        solucion.descripcion.toLowerCase().contains(texto);
  }).toList();
}
