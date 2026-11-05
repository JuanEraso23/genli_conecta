import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/solicitud.dart';
import '../models/solucion.dart';

class SolicitudService {
  // Lista de estados permitidos (HU-19)
  static const estadosPermitidos = <String>{
    'recibida',
    'en_revision',
    'aprobada',
    'rechazada',
    'cerrada',
  };

  SolicitudService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestorePersonalizado = firestore,
      _authPersonalizado = auth;

  final FirebaseFirestore? _firestorePersonalizado;
  final FirebaseAuth? _authPersonalizado;

  FirebaseFirestore get _firestore {
    return _firestorePersonalizado ?? FirebaseFirestore.instance;
  }

  FirebaseAuth get _auth {
    return _authPersonalizado ?? FirebaseAuth.instance;
  }

  // HU-09 / HU-10: Registrar solicitud (TU CÓDIGO ORIGINAL)
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

  // HU-11: Consultar mis solicitudes.
  // El filtro por usuarioId forma parte de la consulta a Firestore.
  // Se ordena en Dart para no requerir un índice compuesto.
  Stream<List<Solicitud>> observarMisSolicitudes() {
    final usuario = _auth.currentUser;
    if (usuario == null) {
      return Stream.error(
        const SolicitudServiceException('Debes iniciar sesión.'),
      );
    }

    return _firestore
        .collection('solicitudes')
        .where('usuarioId', isEqualTo: usuario.uid)
        .snapshots()
        .map((snapshot) {
          final solicitudes = snapshot.docs
              .map((doc) => Solicitud.fromMap(doc.id, doc.data()))
              .toList();
          solicitudes.sort(
            (a, b) => b.fechaCreacion.compareTo(a.fechaCreacion),
          );
          return solicitudes;
        });
  }

  // ==========================================
  // MÓDULO ADMINISTRATIVO (HU-17 a HU-20)
  // ==========================================

  // HU-17: Consultar todas las solicitudes
  Stream<List<Solicitud>> observarTodasLasSolicitudes() {
    return _firestore.collection('solicitudes').snapshots().map((snapshot) {
      final solicitudes = snapshot.docs
          .map((doc) => Solicitud.fromMap(doc.id, doc.data()))
          .toList();

      // Ordenar desde la más reciente
      solicitudes.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));

      return solicitudes;
    });
  }

  // HU-19: Actualizar estado
  Future<void> actualizarEstado({
    required String id,
    required String estado,
  }) async {
    if (!estadosPermitidos.contains(estado)) {
      throw const SolicitudServiceException('Estado no válido.');
    }

    await _firestore.collection('solicitudes').doc(id).update({
      'estado': estado,
      'fechaActualizacion': Timestamp.now(),
    });
  }

  // HU-20: Registrar observación
  Future<void> registrarObservacion({
    required String id,
    required String observacion,
  }) async {
    await _firestore.collection('solicitudes').doc(id).update({
      'observacion': observacion.trim(),
      'fechaActualizacion': Timestamp.now(),
    });
  }
}

class SolicitudServiceException implements Exception {
  const SolicitudServiceException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}
