import 'dart:async';

import 'package:genli_conecta/models/solucion.dart';
import 'package:genli_conecta/services/solucion_service.dart';

/// Servicio falso que no usa Firebase y registra las llamadas recibidas.
class FakeSolucionService implements SolucionService {
  final StreamController<List<Solucion>> controller =
      StreamController<List<Solucion>>.broadcast();

  int llamadasObservarTodas = 0;
  final List<Map<String, Object>> creaciones = [];
  final List<Map<String, Object>> actualizaciones = [];
  final List<Map<String, Object>> cambiosPublicacion = [];

  /// Si se asigna, las operaciones de escritura esperan este Completer.
  Completer<void>? escrituraPendiente;

  /// Si es true, las operaciones de escritura lanzan un error.
  bool fallarEscritura = false;

  Future<void> _resolverEscritura() async {
    if (escrituraPendiente != null) {
      await escrituraPendiente!.future;
    }

    if (fallarEscritura) {
      throw Exception('fallo simulado');
    }
  }

  @override
  Stream<List<Solucion>> observarSolucionesPublicadas() => controller.stream;

  @override
  Stream<List<Solucion>> observarTodasLasSoluciones() {
    llamadasObservarTodas++;
    return controller.stream;
  }

  @override
  Future<void> crearSolucion({
    required String nombre,
    required String descripcion,
    required String categoria,
    required String iconoNombre,
    required String colorHex,
    required bool publicada,
  }) async {
    creaciones.add({
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'iconoNombre': iconoNombre,
      'colorHex': colorHex,
      'publicada': publicada,
    });
    await _resolverEscritura();
  }

  @override
  Future<void> actualizarSolucion({
    required String id,
    required String nombre,
    required String descripcion,
    required String categoria,
    required String iconoNombre,
    required String colorHex,
  }) async {
    actualizaciones.add({
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'iconoNombre': iconoNombre,
      'colorHex': colorHex,
    });
    await _resolverEscritura();
  }

  @override
  Future<void> cambiarPublicacion({
    required String id,
    required bool publicada,
  }) async {
    cambiosPublicacion.add({'id': id, 'publicada': publicada});
    await _resolverEscritura();
  }
}

const Solucion solucionPublicada = Solucion(
  id: 'SOL-A',
  nombre: 'Agua potable',
  descripcion: 'Gestión sostenible del agua para comunidades rurales.',
  categoria: 'Agua',
  iconoNombre: 'water_drop',
  colorHex: '3E9FC5',
  publicada: true,
);

const Solucion solucionNoPublicada = Solucion(
  id: 'SOL-B',
  nombre: 'Energía solar',
  descripcion: 'Paneles solares comunitarios para zonas apartadas.',
  categoria: 'Energía',
  iconoNombre: 'solar_power',
  colorHex: 'F9B233',
  publicada: false,
);
