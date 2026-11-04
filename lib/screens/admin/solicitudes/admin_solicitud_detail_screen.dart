import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../models/solicitud.dart';
import '../../../services/solicitud_service.dart';

class AdminSolicitudDetailScreen extends StatefulWidget {
  const AdminSolicitudDetailScreen({super.key, required this.solicitud});

  final Solicitud solicitud;

  @override
  State<AdminSolicitudDetailScreen> createState() => _AdminSolicitudDetailScreenState();
}

class _AdminSolicitudDetailScreenState extends State<AdminSolicitudDetailScreen> {
  final SolicitudService _solicitudService = SolicitudService();
  final TextEditingController _observacionController = TextEditingController();
  
  late String _estadoSeleccionado;
  bool _guardandoEstado = false;
  bool _guardandoObservacion = false;

  @override
  void initState() {
    super.initState();
    _estadoSeleccionado = widget.solicitud.estado;
    _observacionController.text = widget.solicitud.observacion;
  }

  @override
  void dispose() {
    _observacionController.dispose();
    super.dispose();
  }

  Future<void> _actualizarEstado() async {
    if (_estadoSeleccionado == widget.solicitud.estado) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cambio de estado'),
        content: Text('¿Cambiar de "${widget.solicitud.estado}" a "$_estadoSeleccionado"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _guardandoEstado = true);
    try {
      await _solicitudService.actualizarEstado(
        id: widget.solicitud.id,
        estado: _estadoSeleccionado,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estado actualizado')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _guardandoEstado = false);
    }
  }

  Future<void> _guardarObservacion() async {
    final texto = _observacionController.text.trim();
    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La observación no puede estar vacía')));
      return;
    }
    if (texto == widget.solicitud.observacion) return;

    setState(() => _guardandoObservacion = true);
    try {
      await _solicitudService.registrarObservacion(
        id: widget.solicitud.id,
        observacion: texto,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Observación guardada')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _guardandoObservacion = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      appBar: AppBar(title: Text('Detalle: ${widget.solicitud.codigo}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Solución: ${widget.solicitud.solucionNombre}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Organización: ${widget.solicitud.organizacion}'),
                    Text('Ubicación: ${widget.solicitud.ubicacion}'),
                    const SizedBox(height: 8),
                    const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.solicitud.descripcion),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gestión de Estado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _estadoSeleccionado,
                      decoration: const InputDecoration(labelText: 'Estado actual', border: OutlineInputBorder()),
                      items: SolicitudService.estadosPermitidos.map((estado) {
                        return DropdownMenuItem(value: estado, child: Text(estado));
                      }).toList(),
                      onChanged: (val) => setState(() => _estadoSeleccionado = val!),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _guardandoEstado ? null : _actualizarEstado,
                        child: _guardandoEstado ? const CircularProgressIndicator() : const Text('Guardar estado'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Observaciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _observacionController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText: 'Escribe una observación visible para el solicitante...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _guardandoObservacion ? null : _guardarObservacion,
                        child: _guardandoObservacion ? const CircularProgressIndicator() : const Text('Guardar observación'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}