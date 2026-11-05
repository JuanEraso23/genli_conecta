import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genli_conecta/screens/admin/catalogo/admin_catalogo_screen.dart';
import 'package:genli_conecta/screens/admin/catalogo/solucion_form_admin_screen.dart';

import 'fake_solucion_service.dart';

Future<FakeSolucionService> _montar(
  WidgetTester tester, {
  Size tamano = const Size(430, 900),
}) async {
  await tester.binding.setSurfaceSize(tamano);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final FakeSolucionService servicio = FakeSolucionService();
  addTearDown(servicio.controller.close);

  await tester.pumpWidget(
    MaterialApp(home: AdminCatalogoScreen(solucionService: servicio)),
  );

  return servicio;
}

void main() {
  testWidgets('muestra carga y luego publicadas y no publicadas', (
    tester,
  ) async {
    final servicio = await _montar(tester);

    expect(find.text('Administración del catálogo'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    servicio.controller.add([solucionPublicada, solucionNoPublicada]);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Agua potable'), findsOneWidget);
    expect(find.text('Energía solar'), findsOneWidget);
    expect(find.text('Publicada'), findsOneWidget);
    expect(find.text('No publicada'), findsOneWidget);
    expect(find.text('Despublicar'), findsOneWidget);
    expect(find.text('Publicar'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(find.text('Crear solución'), findsOneWidget);
  });

  testWidgets('muestra el estado vacío', (tester) async {
    final servicio = await _montar(tester);

    servicio.controller.add([]);
    await tester.pump();

    expect(find.text('Aún no hay soluciones registradas'), findsOneWidget);
  });

  testWidgets('muestra el error y Reintentar vuelve a suscribirse', (
    tester,
  ) async {
    final servicio = await _montar(tester);

    servicio.controller.addError(Exception('sin conexión'));
    await tester.pump();

    expect(find.text('No fue posible cargar el catálogo'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pump();

    expect(servicio.llamadasObservarTodas, 2);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    servicio.controller.add([solucionPublicada]);
    await tester.pump();
    expect(find.text('Agua potable'), findsOneWidget);
  });

  testWidgets('se adapta a pantallas anchas sin overflow', (tester) async {
    final servicio = await _montar(tester, tamano: const Size(1300, 900));

    servicio.controller.add([solucionPublicada, solucionNoPublicada]);
    await tester.pump();

    expect(tester.takeException(), isNull);
    final double xA = tester.getTopLeft(find.text('Agua potable')).dx;
    final double xB = tester.getTopLeft(find.text('Energía solar')).dx;
    expect(xA, isNot(equals(xB)), reason: 'deben quedar en columnas');
  });

  group('publicar y despublicar', () {
    testWidgets('al cancelar no llama al servicio', (tester) async {
      final servicio = await _montar(tester);
      servicio.controller.add([solucionNoPublicada]);
      await tester.pump();

      await tester.tap(find.text('Publicar'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Publicar solución'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(servicio.cambiosPublicacion, isEmpty);
    });

    testWidgets('al confirmar publicar llama al servicio y avisa', (
      tester,
    ) async {
      final servicio = await _montar(tester);
      servicio.controller.add([solucionNoPublicada]);
      await tester.pump();

      await tester.tap(find.text('Publicar'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Publicar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(servicio.cambiosPublicacion, [
        {'id': 'SOL-B', 'publicada': true},
      ]);
      expect(
        find.text('La solución se publicó correctamente.'),
        findsOneWidget,
      );
    });

    testWidgets('despublicar muestra diálogo y al confirmar llama', (
      tester,
    ) async {
      final servicio = await _montar(tester);
      servicio.controller.add([solucionPublicada]);
      await tester.pump();

      await tester.tap(find.text('Despublicar'));
      await tester.pumpAndSettle();

      expect(find.text('Despublicar solución'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(servicio.cambiosPublicacion, isEmpty);

      await tester.tap(find.text('Despublicar'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Despublicar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(servicio.cambiosPublicacion, [
        {'id': 'SOL-A', 'publicada': false},
      ]);
      expect(
        find.text('La solución se despublicó correctamente.'),
        findsOneWidget,
      );
    });

    testWidgets('si el servicio falla muestra un mensaje de error', (
      tester,
    ) async {
      final servicio = await _montar(tester);
      servicio.fallarEscritura = true;
      servicio.controller.add([solucionNoPublicada]);
      await tester.pump();

      await tester.tap(find.text('Publicar'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Publicar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('No fue posible cambiar la publicación. Inténtalo de nuevo.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('Editar y Crear solución abren el formulario', (tester) async {
    final servicio = await _montar(tester);
    servicio.controller.add([solucionPublicada]);
    await tester.pump();

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    expect(find.byType(SolucionFormAdminScreen), findsOneWidget);
    expect(find.text('Editar solución'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crear solución'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Crear solución'),
      ),
      findsOneWidget,
    );
  });
}
