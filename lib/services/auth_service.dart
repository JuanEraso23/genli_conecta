class AuthService {
  static const String correoDemo = 'solicitante@genli.com';
  static const String contrasenaDemo = '123456';

  Future<bool> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    // Simula el tiempo de respuesta de Firebase Authentication.
    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    final String correoNormalizado =
    correo.trim().toLowerCase();

    return correoNormalizado == correoDemo &&
        contrasena == contrasenaDemo;
  }
}