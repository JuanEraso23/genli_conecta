import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genli_conecta/models/solicitud.dart';
import 'package:genli_conecta/screens/solicitudes/solicitud_detail_screen.dart';
import 'package:genli_conecta/screens/solicitudes/solicitudes_screen.dart';
import 'package:genli_conecta/widgets/estado_chip.dart';

final _a = Solicitud(
  id: 'a',
  codigo: 'SOL-AAAA1111',
  usuarioId: 'uid-1',
  solucionId: 'SOL-01',
  solucionNombre: 'Energías renovables',
  organizacion: 'Alcaldía de Pasto',
  ubicacion: 'Pasto, Nariño',
  descripcion: 'Necesitamos energía para la escuela rural.',
  estado: 'recibida',
  observacion: '',
  fechaCreacion: DateTime(2026, 11, 3),
  fechaActualizacion: DateTime(2026, 11, 3),
);

final _b = Solicitud(
  id: 'b',
  codigo: 'SOL-BBBB2222',
  usuarioId: 'uid-1',
  solucionId: 'SOL-02',
  solucionNombre: 'Agua potable',
  organizacion: 'Junta Vereda Sur',
  ubicacion: 'Tangua, Nariño',
  descripcion: 'Falta acceso a agua potable en la vereda.',
  estado: 'en_revision',
  observacion: 'Visitaremos la vereda la próxima semana.',
  fechaCreacion: DateTime(2026, 11, 1),
  fechaActualizacion: DateTime(2026, 11, 2),
);

Widget _app(Widget home) => MaterialApp(home: home);

Widget _lista(Stream<List<Solicitud>> Function() fabrica) =>
    _app(SolicitudesScreen(observarSolicitudes: fabrica));

void main() {
  group('Mis solicitudes (HU-11)', () {
    testWidgets('con dos solicitudes muestra códigos y estados', (
      tester,
    ) async {
      await tester.pumpWidget(_lista(() => Stream.value([_a, _b])));
      await tester.pumpAndSettle();

      expect(find.text('Mis solicitudes'), findsOneWidget);
      expect(find.text('SOL-AAAA1111'), findsOneWidget);
      expect(find.text('SOL-BBBB2222'), findsOneWidget);
      expect(find.text('Recibida'), findsOneWidget);
      expect(find.text('En revisión'), findsOneWidget);
    });

    testWidgets('muestra indicador de carga mientras no hay datos', (
      tester,
    ) async {
      final controlador = StreamController<List<Solicitud>>();
      addTearDown(controlador.close);

      await tester.pumpWidget(_lista(() => controlador.stream));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('lista vacía muestra el mensaje', (tester) async {
      await tester.pumpWidget(_lista(() => Stream.value(<Solicitud>[])));
      await tester.pumpAndSettle();

      expect(
        find.text('Aún no tienes solicitudes registradas'),
        findsOneWidget,
      );
    });

    testWidgets('error muestra Reintentar y vuelve a cargar', (tester) async {
      var intentos = 0;
      await tester.pumpWidget(
        _lista(() {
          intentos++;
          return intentos == 1
              ? Stream<List<Solicitud>>.error(Exception('sin conexión'))
              : Stream.value([_a]);
        }),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reintentar'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('SOL-AAAA1111'), findsOneWidget);
      expect(find.text('Reintentar'), findsNothing);
    });

    testWidgets('tocar una tarjeta abre el detalle', (tester) async {
      await tester.pumpWidget(_lista(() => Stream.value([_a, _b])));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SOL-BBBB2222'));
      await tester.pumpAndSettle();

      expect(find.byType(SolicitudDetailScreen), findsOneWidget);
      expect(find.text('Junta Vereda Sur'), findsOneWidget);
    });
  });

  group('Detalle de solicitud (HU-12 y HU-13)', () {
    testWidgets('muestra código, solución, organización, ubicación y '
        'descripción', (tester) async {
      await tester.pumpWidget(_app(SolicitudDetailScreen(solicitud: _a)));

      expect(find.text('SOL-AAAA1111'), findsOneWidget);
      expect(find.text('Energías renovables'), findsOneWidget);
      expect(find.text('Alcaldía de Pasto'), findsOneWidget);
      expect(find.text('Pasto, Nariño'), findsOneWidget);
      expect(
        find.text('Necesitamos energía para la escuela rural.'),
        findsOneWidget,
      );
      expect(find.text('03/11/2026'), findsWidgets);
    });

    testWidgets('observación vacía muestra mensaje neutro', (tester) async {
      await tester.pumpWidget(_app(SolicitudDetailScreen(solicitud: _a)));

      expect(find.text('Aún no hay observaciones'), findsOneWidget);
    });

    testWidgets('observación existente aparece completa', (tester) async {
      await tester.pumpWidget(_app(SolicitudDetailScreen(solicitud: _b)));

      expect(
        find.text('Visitaremos la vereda la próxima semana.'),
        findsOneWidget,
      );
      expect(find.text('Aún no hay observaciones'), findsNothing);
    });
  });

  group('EstadoChip', () {
    testWidgets('muestra la etiqueta de cada estado', (tester) async {
      const casos = {
        'recibida': 'Recibida',
        'en_revision': 'En revisión',
        'aprobada': 'Aprobada',
        'rechazada': 'Rechazada',
        'cerrada': 'Cerrada',
        'otro_valor': 'Estado desconocido',
      };

      for (final caso in casos.entries) {
        await tester.pumpWidget(_app(EstadoChip(estado: caso.key)));
        expect(find.text(caso.value), findsOneWidget);
      }
    });
  });
}
