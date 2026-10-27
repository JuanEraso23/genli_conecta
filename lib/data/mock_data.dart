import '../models/solucion.dart';

/// Datos de respaldo de las soluciones.
///
/// Ya NO se usan como fuente en HomeScreen: el catálogo se consulta desde
/// Cloud Firestore (colección `soluciones`) mediante SolucionService.
/// Se conservan como referencia de los documentos iniciales SOL-01 a SOL-05.
abstract final class MockData {
  static const List<Solucion> soluciones = [
    Solucion(
      id: 'SOL-01',
      nombre: 'Energías renovables',
      descripcion:
          'Soluciones sostenibles orientadas al aprovechamiento de fuentes de energía limpia.',
      categoria: 'Energía',
      iconoNombre: 'solar_power',
      colorHex: 'F9B233',
      publicada: true,
    ),
    Solucion(
      id: 'SOL-02',
      nombre: 'Agua potable',
      descripcion:
          'Proyectos relacionados con el acceso, tratamiento y gestión sostenible del agua.',
      categoria: 'Agua',
      iconoNombre: 'water_drop',
      colorHex: '3E9FC5',
      publicada: true,
    ),
    Solucion(
      id: 'SOL-03',
      nombre: 'Soluciones socioambientales',
      descripcion:
          'Iniciativas orientadas al bienestar comunitario y al cuidado del medioambiente.',
      categoria: 'Socioambiental',
      iconoNombre: 'groups',
      colorHex: '75A989',
      publicada: true,
    ),
    Solucion(
      id: 'SOL-04',
      nombre: 'Proyectos sostenibles',
      descripcion:
          'Gestión y desarrollo de proyectos con enfoque ambiental y comunitario.',
      categoria: 'Sostenibilidad',
      iconoNombre: 'eco',
      colorHex: '005C3F',
      publicada: true,
    ),
    Solucion(
      id: 'SOL-05',
      nombre: 'Reducción de emisiones',
      descripcion:
          'Alternativas orientadas a disminuir el impacto ambiental y las emisiones de CO₂.',
      categoria: 'Medioambiente',
      iconoNombre: 'co2',
      colorHex: 'E58A3B',
      publicada: true,
    ),
  ];
}
