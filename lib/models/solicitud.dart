import 'package:cloud_firestore/cloud_firestore.dart';

class Solicitud {
  const Solicitud({
    required this.id,
    required this.codigo,
    required this.usuarioId,
    required this.solucionId,
    required this.solucionNombre,
    required this.organizacion,
    required this.ubicacion,
    required this.descripcion,
    required this.estado,
    required this.observacion,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  final String id;
  final String codigo;
  final String usuarioId;
  final String solucionId;
  final String solucionNombre;
  final String organizacion;
  final String ubicacion;
  final String descripcion;
  final String estado;
  final String observacion;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  Map<String, dynamic> toMap() => {
    'codigo': codigo,
    'usuarioId': usuarioId,
    'solucionId': solucionId,
    'solucionNombre': solucionNombre,
    'organizacion': organizacion,
    'ubicacion': ubicacion,
    'descripcion': descripcion,
    'estado': estado,
    'observacion': observacion,
    'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    'fechaActualizacion': Timestamp.fromDate(fechaActualizacion),
  };

  factory Solicitud.fromMap(String id, Map<String, dynamic> data) {
    final creacion = data['fechaCreacion'];
    final actualizacion = data['fechaActualizacion'];
    
    return Solicitud(
      id: id,
      codigo: data['codigo'] as String? ?? '',
      usuarioId: data['usuarioId'] as String? ?? '',
      solucionId: data['solucionId'] as String? ?? '',
      solucionNombre: data['solucionNombre'] as String? ?? '',
      organizacion: data['organizacion'] as String? ?? '',
      ubicacion: data['ubicacion'] as String? ?? '',
      descripcion: data['descripcion'] as String? ?? '',
      estado: data['estado'] as String? ?? 'recibida',
      observacion: data['observacion'] as String? ?? '',
      fechaCreacion: creacion is Timestamp ? creacion.toDate() : DateTime.now(),
      fechaActualizacion: actualizacion is Timestamp ? actualizacion.toDate() : DateTime.now(),
    );
  }
}