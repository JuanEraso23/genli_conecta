import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genli_conecta/app/app.dart';

void main() {
  testWidgets('La aplicación inicia en la pantalla de acceso', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));

    await tester.pumpWidget(const GenLiConectaApp());

    await tester.pump();

    expect(find.text('GenLi Conecta'), findsOneWidget);

    expect(find.text('Inicia sesión'), findsOneWidget);

    expect(find.byType(TextFormField), findsNWidgets(2));

    expect(find.text('Crear cuenta'), findsOneWidget);

    expect(find.byType(ElevatedButton), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });
}
