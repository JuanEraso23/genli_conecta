import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/solicitud.dart';
import '../models/solucion.dart';

class SolicitudService {
  SolicitudService([FirebaseFirestore? firestore, FirebaseAuth? auth])
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<Solicitud> crearSolicitud({
    required Solucion solucion,
    required String organizacion,
    required String ubicacion,
    required String descripcion,
  }) async {
    final usuario = _auth.currentUser;
    if (usuario == null) {
      throw const SolicitudServiceException('Debes iniciar sesión.');
    }

    final referencia = _firestore.collection('solicitudes').doc();
    final sufijo = referencia.id.substring(0, 8).toUpperCase();
    final codigo = 'SOL-$sufijo';
    final ahora = DateTime.now();

    final solicitud = Solicitud(
      id: referencia.id,
      codigo: codigo,
      usuarioId: usuario.uid,
      solucionId: solucion.id,
      solucionNombre: solucion.nombre,
      organizacion: organizacion.trim(),
      ubicacion: ubicacion.trim(),
      descripcion: descripcion.trim(),
      estado: 'recibida',
      observacion: '',
      fechaCreacion: ahora,
      fechaActualizacion: ahora,
    );

    try {
      await referencia.set(solicitud.toMap());
      return solicitud;
    } on FirebaseException {
      throw const SolicitudServiceException(
        'No fue posible registrar la solicitud.',
      );
    }
  }
}

class SolicitudServiceException implements Exception {
  const SolicitudServiceException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}
