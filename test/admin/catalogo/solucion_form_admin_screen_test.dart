import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genli_conecta/models/solucion.dart';
import 'package:genli_conecta/screens/admin/catalogo/solucion_form_admin_screen.dart';

import 'fake_solucion_service.dart';

const String _descripcionValida =
    'Una descripción suficientemente larga para validar.';

/// Monta el formulario sobre una pantalla base para poder verificar el pop.
Future<FakeSolucionService> _montar(
  WidgetTester tester, {
  Solucion? solucion,
}) async {
  await tester.binding.setSurfaceSize(const Size(430, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final FakeSolucionService servicio = FakeSolucionService();
  addTearDown(servicio.controller.close);

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => SolucionFormAdminScreen(
                        solucion: solucion,
                        solucionService: servicio,
                      ),
                    ),
                  );
                },
                child: const Text('abrir'),
              ),
            ),
          );
        },
      ),
    ),
  );

  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();

  return servicio;
}

Future<void> _seleccionar(
  WidgetTester tester,
  String campo,
  String opcion,
) async {
  await tester.tap(find.byKey(Key(campo)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(opcion).last);
  await tester.pumpAndSettle();
}

Future<void> _llenarValido(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('campoNombre')), '  Huertas  ');
  await tester.enterText(
    find.byKey(const Key('campoDescripcion')),
    _descripcionValida,
  );
  await _seleccionar(tester, 'campoCategoria', 'Sostenibilidad');
  await _seleccionar(tester, 'campoIcono', 'Ecología');
  await tester.enterText(find.byKey(const Key('campoColor')), '#75a989');
  await tester.pump();
}

void main() {
  testWidgets('modo creación muestra título y Switch apagado', (tester) async {
    await _montar(tester);

    expect(find.text('Crear solución'), findsOneWidget);
    final SwitchListTile interruptor = tester.widget(
      find.byKey(const Key('campoPublicada')),
    );
    expect(interruptor.value, isFalse);
  });

  testWidgets('rechaza nombre corto, descripción corta y color inválido', (
    tester,
  ) async {
    final servicio = await _montar(tester);

    await tester.enterText(find.byKey(const Key('campoNombre')), ' ab ');
    await tester.enterText(
      find.byKey(const Key('campoDescripcion')),
      'Muy corta',
    );
    await tester.enterText(find.byKey(const Key('campoColor')), '#12345G');
    await tester.tap(find.byKey(const Key('botonGuardar')));
    await tester.pump();

    expect(
      find.text('El nombre debe tener al menos 3 caracteres'),
      findsOneWidget,
    );
    expect(
      find.text('La descripción debe tener al menos 20 caracteres'),
      findsOneWidget,
    );
    expect(find.text('Ingresa un color hexadecimal válido'), findsOneWidget);
    expect(find.text('Selecciona una categoría'), findsOneWidget);
    expect(find.text('Selecciona un icono'), findsOneWidget);
    expect(servicio.creaciones, isEmpty);
  });

  testWidgets('el campo de color acepta # y rechaza longitudes erróneas', (
    tester,
  ) async {
    await _montar(tester);
    await _llenarValido(tester);

    await tester.enterText(find.byKey(const Key('campoColor')), 'ABC');
    await tester.tap(find.byKey(const Key('botonGuardar')));
    await tester.pump();
    expect(find.text('Ingresa un color hexadecimal válido'), findsOneWidget);
  });

  testWidgets('crear llama una sola vez al servicio con doble toque', (
    tester,
  ) async {
    final servicio = await _montar(tester);
    servicio.escrituraPendiente = Completer<void>();
    await _llenarValido(tester);

    final Finder guardar = find.byKey(const Key('botonGuardar'));
    await tester.tap(guardar);
    await tester.tap(guardar, warnIfMissed: false);
    await tester.pump();

    expect(find.text('Guardando...'), findsOneWidget);
    await tester.tap(guardar, warnIfMissed: false);
    await tester.pump();

    expect(servicio.creaciones, hasLength(1));
    expect(servicio.creaciones.single, {
      'nombre': '  Huertas  ',
      'descripcion': _descripcionValida,
      'categoria': 'Sostenibilidad',
      'iconoNombre': 'eco',
      'colorHex': '#75a989',
      'publicada': false,
    });

    servicio.escrituraPendiente!.complete();
    await tester.pumpAndSettle();

    expect(find.byType(SolucionFormAdminScreen), findsNothing);
    expect(find.text('La solución se creó correctamente.'), findsOneWidget);
  });

  testWidgets('si crear falla, muestra error y no cierra el formulario', (
    tester,
  ) async {
    final servicio = await _montar(tester);
    servicio.fallarEscritura = true;
    await _llenarValido(tester);

    await tester.tap(find.byKey(const Key('botonGuardar')));
    await tester.pumpAndSettle();

    expect(find.byType(SolucionFormAdminScreen), findsOneWidget);
    expect(
      find.text('No fue posible guardar la solución. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(find.text('Guardar'), findsOneWidget);
  });

  testWidgets('editar precarga valores y actualiza con el mismo ID', (
    tester,
  ) async {
    final servicio = await _montar(tester, solucion: solucionPublicada);

    expect(find.text('Editar solución'), findsOneWidget);
    expect(find.text('Agua potable'), findsOneWidget);
    expect(find.text(solucionPublicada.descripcion), findsOneWidget);
    expect(find.text('3E9FC5'), findsOneWidget);
    expect(find.byKey(const Key('campoPublicada')), findsNothing);

    final DropdownButtonFormField<String> categoria = tester.widget(
      find.byKey(const Key('campoCategoria')),
    );
    final DropdownButtonFormField<String> icono = tester.widget(
      find.byKey(const Key('campoIcono')),
    );
    expect(categoria.initialValue, 'Agua');
    expect(icono.initialValue, 'water_drop');

    await tester.enterText(
      find.byKey(const Key('campoNombre')),
      'Agua potable rural',
    );
    await tester.tap(find.byKey(const Key('botonGuardar')));
    await tester.pumpAndSettle();

    expect(servicio.creaciones, isEmpty);
    expect(servicio.actualizaciones, hasLength(1));
    expect(servicio.actualizaciones.single['id'], 'SOL-A');
    expect(servicio.actualizaciones.single['nombre'], 'Agua potable rural');
    expect(servicio.actualizaciones.single.containsKey('fechaCreacion'), false);
    expect(
      find.text('La solución se actualizó correctamente.'),
      findsOneWidget,
    );
  });
}
