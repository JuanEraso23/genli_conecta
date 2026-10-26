import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/usuario.dart';

class AuthService {
  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuthPersonalizado = firebaseAuth,
       _firestorePersonalizado = firestore;

  final firebase_auth.FirebaseAuth? _firebaseAuthPersonalizado;
  final FirebaseFirestore? _firestorePersonalizado;

  firebase_auth.FirebaseAuth get _firebaseAuth {
    return _firebaseAuthPersonalizado ?? firebase_auth.FirebaseAuth.instance;
  }

  FirebaseFirestore get _firestore {
    return _firestorePersonalizado ?? FirebaseFirestore.instance;
  }

  static const String _coleccionUsuarios = 'usuarios';

  firebase_auth.User? get usuarioAutenticado {
    return _firebaseAuth.currentUser;
  }

  Stream<firebase_auth.User?> get cambiosDeAutenticacion {
    return _firebaseAuth.authStateChanges();
  }

  Future<Usuario> registrarUsuario({
    required String nombre,
    required String organizacion,
    required String correo,
    required String contrasena,
  }) async {
    firebase_auth.UserCredential? credencial;

    try {
      final String correoNormalizado = correo.trim().toLowerCase();

      credencial = await _firebaseAuth.createUserWithEmailAndPassword(
        email: correoNormalizado,
        password: contrasena,
      );

      final firebase_auth.User? usuarioFirebase = credencial.user;

      if (usuarioFirebase == null) {
        throw const AuthServiceException(
          'No fue posible obtener el usuario creado.',
        );
      }

      await usuarioFirebase.updateDisplayName(nombre.trim());

      final Usuario usuario = Usuario(
        id: usuarioFirebase.uid,
        nombre: nombre.trim(),
        correo: correoNormalizado,
        organizacion: organizacion.trim(),
        rol: RolUsuario.solicitante,
        activo: true,
        fechaRegistro: DateTime.now(),
      );

      await _firestore
          .collection(_coleccionUsuarios)
          .doc(usuarioFirebase.uid)
          .set(usuario.toMap());

      return usuario;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthServiceException(_mensajeErrorFirebase(error.code));
    } on FirebaseException {
      await credencial?.user?.delete();

      throw const AuthServiceException(
        'La cuenta no pudo guardarse correctamente. '
        'Inténtalo nuevamente.',
      );
    } on AuthServiceException {
      rethrow;
    } catch (_) {
      await credencial?.user?.delete();

      throw const AuthServiceException(
        'Ocurrió un error inesperado al crear la cuenta.',
      );
    }
  }

  Future<Usuario> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final firebase_auth.UserCredential credencial = await _firebaseAuth
          .signInWithEmailAndPassword(
            email: correo.trim().toLowerCase(),
            password: contrasena,
          );

      final firebase_auth.User? usuarioFirebase = credencial.user;

      if (usuarioFirebase == null) {
        throw const AuthServiceException(
          'No fue posible obtener la sesión iniciada.',
        );
      }

      final DocumentSnapshot<Map<String, dynamic>> documento = await _firestore
          .collection(_coleccionUsuarios)
          .doc(usuarioFirebase.uid)
          .get();

      final Map<String, dynamic>? datos = documento.data();

      if (!documento.exists || datos == null) {
        await _firebaseAuth.signOut();

        throw const AuthServiceException(
          'La cuenta no tiene un perfil registrado.',
        );
      }

      final Usuario usuario = Usuario.fromMap(id: documento.id, data: datos);

      if (!usuario.activo) {
        await _firebaseAuth.signOut();

        throw const AuthServiceException(
          'Esta cuenta se encuentra desactivada.',
        );
      }

      return usuario;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthServiceException(_mensajeErrorFirebase(error.code));
    } on AuthServiceException {
      rethrow;
    } on FirebaseException {
      await _firebaseAuth.signOut();

      throw const AuthServiceException(
        'No fue posible consultar el perfil del usuario.',
      );
    } catch (_) {
      await _firebaseAuth.signOut();

      throw const AuthServiceException(
        'Ocurrió un error inesperado al iniciar sesión.',
      );
    }
  }

  Future<Usuario?> obtenerPerfilActual() async {
    final firebase_auth.User? usuarioFirebase = _firebaseAuth.currentUser;

    if (usuarioFirebase == null) {
      return null;
    }

    final DocumentSnapshot<Map<String, dynamic>> documento = await _firestore
        .collection(_coleccionUsuarios)
        .doc(usuarioFirebase.uid)
        .get();

    final Map<String, dynamic>? datos = documento.data();

    if (!documento.exists || datos == null) {
      return null;
    }

    return Usuario.fromMap(id: documento.id, data: datos);
  }

  Future<void> cerrarSesion() async {
    await _firebaseAuth.signOut();
  }

  static String _mensajeErrorFirebase(String codigo) {
    switch (codigo) {
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'user-disabled':
        return 'Esta cuenta se encuentra deshabilitada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'too-many-requests':
        return 'Se realizaron demasiados intentos. '
            'Inténtalo más tarde.';
      case 'network-request-failed':
        return 'No fue posible conectarse. '
            'Revisa tu conexión a internet.';
      case 'operation-not-allowed':
        return 'El acceso con correo y contraseña '
            'no está habilitado.';
      default:
        return 'No fue posible completar la operación.';
    }
  }
}

class AuthServiceException implements Exception {
  const AuthServiceException(this.mensaje);

  final String mensaje;

  @override
  String toString() {
    return mensaje;
  }
}
