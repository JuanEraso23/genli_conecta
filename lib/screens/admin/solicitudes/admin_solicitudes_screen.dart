import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../models/solicitud.dart';
import '../../../services/solicitud_service.dart';
import '../../../widgets/admin_solicitud_card.dart';
import 'admin_solicitud_detail_screen.dart';

class AdminSolicitudesScreen extends StatefulWidget {
  const AdminSolicitudesScreen({super.key});

  @override
  State<AdminSolicitudesScreen> createState() => _AdminSolicitudesScreenState();
}

class _AdminSolicitudesScreenState extends State<AdminSolicitudesScreen> {
  final SolicitudService _solicitudService = SolicitudService();
  final TextEditingController _searchController = TextEditingController();
  
  String _filtroEstado = 'todos';

  List<Solicitud> _filtrarSolicitudes(List<Solicitud> solicitudes) {
    final texto = _searchController.text.trim().toLowerCase();
    
    return solicitudes.where((solicitud) {
      final coincideTexto = texto.isEmpty ||
          solicitud.codigo.toLowerCase().contains(texto) ||
          solicitud.solucionNombre.toLowerCase().contains(texto) ||
          solicitud.organizacion.toLowerCase().contains(texto) ||
          solicitud.ubicacion.toLowerCase().contains(texto);

      final coincideEstado = _filtroEstado == 'todos' || solicitud.estado == _filtroEstado;

      return coincideTexto && coincideEstado;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      appBar: AppBar(
        title: const Text('Administración de solicitudes'),
      ),
      body: StreamBuilder<List<Solicitud>>(
        stream: _solicitudService.observarTodasLasSolicitudes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Ocurrió un error al cargar las solicitudes.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final todasLasSolicitudes = snapshot.data ?? [];
          final solicitudesFiltradas = _filtrarSolicitudes(todasLasSolicitudes);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por código, organización, ubicación...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppColors.blanco,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: _filtroEstado,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.blanco,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'todos', child: Text('Todos los estados')),
                          DropdownMenuItem(value: 'recibida', child: Text('Recibida')),
                          DropdownMenuItem(value: 'en_revision', child: Text('En revisión')),
                          DropdownMenuItem(value: 'aprobada', child: Text('Aprobada')),
                          DropdownMenuItem(value: 'rechazada', child: Text('Rechazada')),
                          DropdownMenuItem(value: 'cerrada', child: Text('Cerrada')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filtroEstado = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mostrando ${solicitudesFiltradas.length} de ${todasLasSolicitudes.length} solicitudes',
                    style: const TextStyle(color: AppColors.textoSecundario, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: solicitudesFiltradas.isEmpty
                    ? const Center(child: Text('No se encontraron solicitudes con esos filtros.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: solicitudesFiltradas.length,
                        itemBuilder: (context, index) {
                          final solicitud = solicitudesFiltradas[index];
                          return AdminSolicitudCard(
                            solicitud: solicitud,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminSolicitudDetailScreen(solicitud: solicitud),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
