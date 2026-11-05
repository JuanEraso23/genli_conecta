import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../models/solucion.dart';
import '../../../services/solucion_service.dart';

/// Categorías base del catálogo (las mismas de los datos de ejemplo).
const List<String> categoriasBase = [
  'Energía',
  'Agua',
  'Socioambiental',
  'Sostenibilidad',
  'Medioambiente',
];

/// Colores sugeridos para las soluciones (sin '#').
const List<String> coloresPredefinidos = [
  '005C3F',
  '75A989',
  'F9B233',
  '3E9FC5',
  'E58A3B',
];

const Map<String, String> _etiquetasIcono = {
  'solar_power': 'Energía solar',
  'water_drop': 'Agua',
  'groups': 'Comunidad',
  'eco': 'Ecología',
  'co2': 'Emisiones CO₂',
};

/// Formulario para crear (HU-14) o editar (HU-15) una solución.
///
/// Si recibe [solucion] funciona en modo edición.
class SolucionFormAdminScreen extends StatefulWidget {
  const SolucionFormAdminScreen({
    super.key,
    this.solucion,
    this.solucionService,
    this.categoriasDisponibles = const [],
  });

  final Solucion? solucion;

  /// Permite inyectar un servicio alterno en pruebas.
  final SolucionService? solucionService;

  /// Categorías adicionales encontradas en el catálogo.
  final List<String> categoriasDisponibles;

  @override
  State<SolucionFormAdminScreen> createState() =>
      _SolucionFormAdminScreenState();
}

class _SolucionFormAdminScreenState extends State<SolucionFormAdminScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final SolucionService _solucionService =
      widget.solucionService ?? SolucionService();

  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _colorController;

  late final List<String> _categorias;
  String? _categoria;
  String? _iconoNombre;
  bool _publicada = false;
  bool _guardando = false;

  bool get _esEdicion => widget.solucion != null;

  @override
  void initState() {
    super.initState();

    final Solucion? solucion = widget.solucion;

    _nombreController = TextEditingController(text: solucion?.nombre ?? '');
    _descripcionController = TextEditingController(
      text: solucion?.descripcion ?? '',
    );
    _colorController = TextEditingController(
      text: normalizarColorHex(solucion?.colorHex ?? coloresPredefinidos.first),
    );
    _colorController.addListener(_alCambiarColor);

    final String categoriaActual = solucion?.categoria.trim() ?? '';
    _categorias = <String>{
      ...categoriasBase,
      ...widget.categoriasDisponibles.map((c) => c.trim()),
      if (categoriaActual.isNotEmpty) categoriaActual,
    }.where((c) => c.isNotEmpty).toList();
    _categoria = categoriaActual.isEmpty ? null : categoriaActual;

    final String? icono = solucion?.iconoNombre;
    _iconoNombre = iconosPermitidos.contains(icono) ? icono : null;
  }

  @override
  void dispose() {
    _colorController.removeListener(_alCambiarColor);
    _nombreController.dispose();
    _descripcionController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _alCambiarColor() {
    setState(() {});
  }

  Color? get _colorVistaPrevia {
    final String hex = normalizarColorHex(_colorController.text);

    if (!esColorHexValido(hex)) {
      return null;
    }

    return Color(int.parse('FF$hex', radix: 16));
  }

  String? _validarNombre(String? valor) {
    final String texto = valor?.trim() ?? '';

    if (texto.isEmpty) {
      return 'Ingresa el nombre de la solución';
    }

    if (texto.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }

    return null;
  }

  String? _validarDescripcion(String? valor) {
    final String texto = valor?.trim() ?? '';

    if (texto.isEmpty) {
      return 'Ingresa la descripción de la solución';
    }

    if (texto.length < 20) {
      return 'La descripción debe tener al menos 20 caracteres';
    }

    return null;
  }

  String? _validarColor(String? valor) {
    if (!esColorHexValido(valor ?? '')) {
      return 'Ingresa un color hexadecimal válido';
    }

    return null;
  }

  Future<void> _guardar() async {
    if (_guardando) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _guardando = true);

    try {
      final Solucion? solucion = widget.solucion;

      if (solucion != null) {
        await _solucionService.actualizarSolucion(
          id: solucion.id,
          nombre: _nombreController.text,
          descripcion: _descripcionController.text,
          categoria: _categoria!,
          iconoNombre: _iconoNombre!,
          colorHex: _colorController.text,
        );
      } else {
        await _solucionService.crearSolucion(
          nombre: _nombreController.text,
          descripcion: _descripcionController.text,
          categoria: _categoria!,
          iconoNombre: _iconoNombre!,
          colorHex: _colorController.text,
          publicada: _publicada,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'La solución se actualizó correctamente.'
                : 'La solución se creó correctamente.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      debugPrint('Error al guardar la solución: $error');

      if (!mounted) {
        return;
      }

      setState(() => _guardando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mensajeErrorCatalogo(
              error,
              'No fue posible guardar la solución. Inténtalo de nuevo.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar solución' : 'Crear solución'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Form(
                key: _formKey,
                child: AbsorbPointer(
                  absorbing: _guardando,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        key: const Key('campoNombre'),
                        controller: _nombreController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                        validator: _validarNombre,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('campoDescripcion'),
                        controller: _descripcionController,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          alignLabelWithHint: true,
                        ),
                        validator: _validarDescripcion,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        key: const Key('campoCategoria'),
                        initialValue: _categoria,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: [
                          for (final String categoria in _categorias)
                            DropdownMenuItem<String>(
                              value: categoria,
                              child: Text(
                                categoria,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (valor) =>
                            setState(() => _categoria = valor),
                        validator: (valor) =>
                            valor == null ? 'Selecciona una categoría' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        key: const Key('campoIcono'),
                        initialValue: _iconoNombre,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Icono'),
                        items: [
                          for (final String nombre in iconosPermitidos)
                            DropdownMenuItem<String>(
                              value: nombre,
                              child: Row(
                                children: [
                                  Icon(
                                    _iconoDe(nombre),
                                    color: AppColors.verdePrincipal,
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      _etiquetasIcono[nombre] ?? nombre,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (valor) =>
                            setState(() => _iconoNombre = valor),
                        validator: (valor) =>
                            valor == null ? 'Selecciona un icono' : null,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Color',
                        style: TextStyle(
                          color: AppColors.verdeTexto,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final String hex in coloresPredefinidos)
                            _MuestraColor(
                              hex: hex,
                              seleccionado:
                                  normalizarColorHex(_colorController.text) ==
                                  hex,
                              onTap: () => _colorController.text = hex,
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              key: const Key('campoColor'),
                              controller: _colorController,
                              decoration: const InputDecoration(
                                labelText: 'Color hexadecimal',
                                hintText: 'Ej. 005C3F',
                                prefixText: '#',
                              ),
                              validator: _validarColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _VistaPreviaColor(
                            color: _colorVistaPrevia,
                            icono: _iconoDe(_iconoNombre ?? 'solar_power'),
                          ),
                        ],
                      ),
                      if (!_esEdicion) ...[
                        const SizedBox(height: 12),
                        SwitchListTile(
                          key: const Key('campoPublicada'),
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Publicar al crear'),
                          subtitle: const Text(
                            'Si está activo, los solicitantes la verán en el catálogo.',
                          ),
                          value: _publicada,
                          onChanged: (valor) =>
                              setState(() => _publicada = valor),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        key: const Key('botonGuardar'),
                        onPressed: _guardando ? null : _guardar,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.verdePrincipal,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: _guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.blanco,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(_guardando ? 'Guardando...' : 'Guardar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconoDe(String nombre) {
    return Solucion(
      id: '',
      nombre: '',
      descripcion: '',
      categoria: '',
      iconoNombre: nombre,
      colorHex: '',
      publicada: false,
    ).icono;
  }
}

class _MuestraColor extends StatelessWidget {
  const _MuestraColor({
    required this.hex,
    required this.seleccionado,
    required this.onTap,
  });

  final String hex;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(int.parse('FF$hex', radix: 16));

    return Tooltip(
      message: '#$hex',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: seleccionado ? AppColors.verdeTexto : AppColors.blanco,
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 4),
            ],
          ),
          child: seleccionado
              ? const Icon(
                  Icons.check_rounded,
                  color: AppColors.blanco,
                  size: 20,
                )
              : null,
        ),
      ),
    );
  }
}

class _VistaPreviaColor extends StatelessWidget {
  const _VistaPreviaColor({required this.color, required this.icono});

  final Color? color;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final Color? colorActual = color;

    return Tooltip(
      message: 'Vista previa del color',
      child: Container(
        key: const Key('vistaPreviaColor'),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: colorActual?.withValues(alpha: 0.16) ?? AppColors.fondoCampo,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: colorActual ?? AppColors.bordeCampo),
        ),
        child: Icon(
          colorActual == null ? Icons.help_outline_rounded : icono,
          color: colorActual ?? AppColors.textoSugerencia,
          size: 28,
        ),
      ),
    );
  }
}
