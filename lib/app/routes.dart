import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/password_recovery_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';

abstract final class AppRoutes {
  static const String login = '/login';
  static const String passwordRecovery = '/password-recovery';
  static const String register = '/register';
  static const String home = '/home';

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

      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
    }
  }
}
