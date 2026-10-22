import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

class GenLiConectaApp extends StatelessWidget {
  const GenLiConectaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GenLi Conecta',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
