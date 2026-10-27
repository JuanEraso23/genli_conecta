import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genli_conecta/data/mock_data.dart';
import 'package:genli_conecta/models/solucion.dart';
import 'package:genli_conecta/screens/home/home_screen.dart';
import 'package:genli_conecta/services/solucion_service.dart';

class _FakeSolucionService implements SolucionService {
  final StreamController<List<Solucion>> controller =
      StreamController<List<Solucion>>.broadcast();

  @override
  Stream<List<Solucion>> observarSolucionesPublicadas() => controller.stream;
}

Future<_FakeSolucionService> _montarHome(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final _FakeSolucionService servicio = _FakeSolucionService();
  addTearDown(servicio.controller.close);

  await tester.pumpWidget(
    MaterialApp(home: HomeScreen(solucionService: servicio)),
  );

  return servicio;
}

void main() {
  testWidgets('muestra carga y luego las soluciones', (tester) async {
    final servicio = await _montarHome(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    servicio.controller.add(MockData.soluciones);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('5 resultados'), findsOneWidget);
  });

  testWidgets('filtra y permite limpiar la búsqueda', (tester) async {
    final servicio = await _montarHome(tester);
    servicio.controller.add(MockData.soluciones);
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'agua');
    await tester.pump();
    expect(find.text('1 resultados'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump();
    expect(find.text('No encontramos resultados'), findsOneWidget);

    await tester.tap(find.byTooltip('Limpiar búsqueda'));
    await tester.pump();
    expect(find.text('5 resultados'), findsOneWidget);
  });

  testWidgets('muestra error con botón Reintentar', (tester) async {
    final servicio = await _montarHome(tester);

    servicio.controller.addError(Exception('sin conexión'));
    await tester.pump();

    expect(find.text('No fue posible cargar las soluciones'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
