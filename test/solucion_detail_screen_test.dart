import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genli_conecta/models/solucion.dart';
import 'package:genli_conecta/screens/soluciones/solucion_detail_screen.dart';
import 'package:genli_conecta/screens/solicitudes/solicitud_form_screen.dart';

const _agua = Solucion(
  id: 'SOL-02',
  nombre: 'Agua potable',
  descripcion: 'Acceso y gestión sostenible del agua.',
  categoria: 'Agua',
  iconoNombre: 'water_drop',
  colorHex: '3E9FC5',
  publicada: true,
);

const _energia = Solucion(
  id: 'SOL-01',
  nombre: 'Energías renovables',
  descripcion: 'Aprovechamiento de fuentes renovables.',
  categoria: 'Energía',
  iconoNombre: 'solar_power',
  colorHex: 'F9B233',
  publicada: true,
);

// ID que no existe en el catálogo fijo anterior.
const _otra = Solucion(
  id: 'SOL-99',
  nombre: 'Solución de prueba',
  descripcion: 'Descripción de prueba de una línea nueva.',
  categoria: 'Otra',
  iconoNombre: 'eco',
  colorHex: '005C3F',
  publicada: true,
);

Widget _app(Solucion solucion) {
  return MaterialApp(home: SolucionDetailScreen(solucion: solucion));
}

void main() {
  group('SolucionDetailScreen', () {
    testWidgets('muestra nombre, categoría, descripción e icono reales', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_agua));

      expect(find.text('Agua potable'), findsOneWidget);
      expect(find.text('AGUA'), findsOneWidget);
      expect(
        find.text('Acceso y gestión sostenible del agua.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.water_drop_rounded), findsOneWidget);
    });

    testWidgets('cambia el contenido según la solución recibida', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_energia));
      expect(find.text('Energías renovables'), findsOneWidget);
      expect(find.byIcon(Icons.solar_power_rounded), findsOneWidget);

      await tester.pumpWidget(_app(_otra));
      expect(find.text('Solución de prueba'), findsOneWidget);
      expect(find.byIcon(Icons.eco_rounded), findsOneWidget);
      expect(find.text('Energías renovables'), findsNothing);
    });

    testWidgets('no conserva textos fijos de energía solar', (tester) async {
      await tester.pumpWidget(_app(_agua));
      expect(find.textContaining('energía solar'), findsNothing);

      await tester.pumpWidget(_app(_otra));
      expect(find.textContaining('energía solar'), findsNothing);
    });

    testWidgets('usa el nombre de la solución en el texto de apoyo', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_agua));
      expect(
        find.textContaining('relacionada con Agua potable'),
        findsOneWidget,
      );
    });

    testWidgets('una solución con ID nuevo no repite su descripción', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_otra));
      expect(
        find.text('Descripción de prueba de una línea nueva.'),
        findsOneWidget,
      );
    });

    testWidgets('muestra botón de solicitud y de regresar', (tester) async {
      await tester.pumpWidget(_app(_agua));
      expect(find.text('Registrar solicitud'), findsOneWidget);
      expect(find.byTooltip('Regresar'), findsOneWidget);
    });

    testWidgets('soporta descripciones largas en pantalla pequeña', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final larga = Solucion(
        id: 'SOL-LARGA',
        nombre: 'Solución con un nombre bastante largo para probar el ajuste',
        descripcion: 'Texto largo de prueba. ' * 80,
        categoria: 'Categoría larga',
        iconoNombre: 'eco',
        colorHex: '005C3F',
        publicada: true,
      );

      await tester.pumpWidget(_app(larga));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('el botón abre el formulario de solicitud', (tester) async {
      await tester.pumpWidget(_app(_agua));

      await tester.tap(find.text('Registrar solicitud'));
      await tester.pumpAndSettle();

      expect(find.byType(SolicitudFormScreen), findsOneWidget);
    });
  });
}
