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
