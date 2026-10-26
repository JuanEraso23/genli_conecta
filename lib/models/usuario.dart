import 'package:cloud_firestore/cloud_firestore.dart';

enum RolUsuario { solicitante, administrador }

class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.organizacion,
    required this.rol,
    required this.activo,
    required this.fechaRegistro,
  });

  final String id;
  final String nombre;
  final String correo;
  final String organizacion;
  final RolUsuario rol;
  final bool activo;
  final DateTime fechaRegistro;

  bool get esAdministrador {
    return rol == RolUsuario.administrador;
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'correo': correo,
      'organizacion': organizacion,
      'rol': rol.name,
      'activo': activo,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
    };
  }

  factory Usuario.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final dynamic fecha = data['fechaRegistro'];

    return Usuario(
      id: id,
      nombre: data['nombre'] as String? ?? '',
      correo: data['correo'] as String? ?? '',
      organizacion: data['organizacion'] as String? ?? '',
      rol: _rolDesdeTexto(data['rol'] as String?),
      activo: data['activo'] as bool? ?? true,
      fechaRegistro: fecha is Timestamp ? fecha.toDate() : DateTime.now(),
    );
  }

  static RolUsuario _rolDesdeTexto(String? valor) {
    if (valor == RolUsuario.administrador.name) {
      return RolUsuario.administrador;
    }

    return RolUsuario.solicitante;
  }
}
