import 'package:flutter/material.dart';

import '../screens/admin/catalogo/admin_catalogo_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/password_recovery_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/home/home_screen.dart';

abstract final class AppRoutes {
  static const String login = '/login';
  static const String passwordRecovery = '/password-recovery';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';

  /// Acceso de desarrollo al catálogo administrativo.
  /// Sin botón visible; la protección por rol se agrega en HU-22.
  static const String adminCatalogo = '/admin/catalogo';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case passwordRecovery:
        return MaterialPageRoute(
          builder: (_) => const PasswordRecoveryScreen(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      case adminCatalogo:
        return MaterialPageRoute(
          builder: (_) => const AdminCatalogoScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
    }
  }
}
