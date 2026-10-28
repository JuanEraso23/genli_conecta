import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/solucion.dart';
import '../../widgets/solucion_card.dart';
import '../soluciones/solucion_detail_screen.dart';
import '../solicitudes/solicitud_form_screen.dart';
import '../../services/auth_service.dart';
import '../../services/solucion_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.solucionService});

  /// Permite inyectar un servicio alterno en pruebas.
  final SolucionService? solucionService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _busquedaController = TextEditingController();
  final AuthService _authService = AuthService();
  late final SolucionService _solucionService =
      widget.solucionService ?? SolucionService();

  StreamSubscription<List<Solucion>>? _suscripcion;
  List<Solucion> _soluciones = const [];
  List<Solucion> _solucionesFiltradas = const [];
  bool _cargando = true;
  bool _hayError = false;

  @override
  void initState() {
    super.initState();
    _escucharSoluciones();
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    _busquedaController.dispose();
    super.dispose();
  }

  void _reintentarCarga() {
    setState(() {
      _cargando = true;
      _hayError = false;
    });

    _escucharSoluciones();
  }

  void _escucharSoluciones() {
    _suscripcion?.cancel();

    _suscripcion = _solucionService.observarSolucionesPublicadas().listen(
      (soluciones) {
        if (!mounted) {
          return;
        }

        setState(() {
          _soluciones = soluciones;
          _solucionesFiltradas = filtrarSoluciones(
            soluciones,
            _busquedaController.text,
          );
          _cargando = false;
          _hayError = false;
        });
      },
      onError: (Object error) {
        debugPrint('Error al cargar soluciones: $error');

        if (!mounted) {
          return;
        }

        setState(() {
          _cargando = false;
          _hayError = true;
        });
      },
    );
  }

  void _filtrarSoluciones(String texto) {
    setState(() {
      _solucionesFiltradas = filtrarSoluciones(_soluciones, texto);
    });
  }

  void _limpiarBusqueda() {
    _busquedaController.clear();
    _filtrarSoluciones('');
    FocusScope.of(context).unfocus();
  }

  void _abrirDetalle(Solucion solucion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SolucionDetailScreen(solucion: solucion);
        },
      ),
    );
  }

  void _registrarSolicitud(Solucion solucion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SolicitudFormScreen(solucion: solucion);
        },
      ),
    );
  }

  void _mostrarPerfil() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La pantalla de perfil se agregará posteriormente.'),
      ),
    );
  }

  void _mostrarSolicitudes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'El historial de solicitudes se agregará posteriormente.',
        ),
      ),
    );
  }

  Future<void> _confirmarCierreSesion() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.logout_rounded,
            color: AppColors.verdePrincipal,
            size: 42,
          ),
          title: const Text('Cerrar sesión', textAlign: TextAlign.center),
          content: const Text(
            '¿Seguro que deseas cerrar la sesión?',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    try {
      await _authService.cerrarSesion();
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.mensaje)));

      return;
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible cerrar la sesión.')),
      );

      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const _AppBarTitle(),
        actions: [
          IconButton(
            tooltip: 'Mi perfil',
            onPressed: _mostrarPerfil,
            icon: const Icon(Icons.account_circle_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              switch (value) {
                case 'solicitudes':
                  _mostrarSolicitudes();
                  break;
                case 'perfil':
                  _mostrarPerfil();
                  break;
                case 'cerrar_sesion':
                  _confirmarCierreSesion();
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<String>(
                  value: 'solicitudes',
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: AppColors.verdePrincipal,
                      ),
                      SizedBox(width: 12),
                      Text('Mis solicitudes'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'perfil',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.verdePrincipal,
                      ),
                      SizedBox(width: 12),
                      Text('Mi perfil'),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'cerrar_sesion',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.error),
                      SizedBox(width: 12),
                      Text('Cerrar sesión'),
                    ],
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.verdePrincipal,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 600));

            if (!mounted) {
              return;
            }

            _limpiarBusqueda();

            if (_hayError) {
              _reintentarCarga();
            }
          },
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _HomeHeader(
                  busquedaController: _busquedaController,
                  onBuscar: _filtrarSoluciones,
                  onLimpiar: _limpiarBusqueda,
                ),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(cantidad: _solucionesFiltradas.length),
              ),
              if (_cargando)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _CargandoCatalogo(),
                )
              else if (_hayError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorCatalogo(onReintentar: _reintentarCarga),
                )
              else if (_solucionesFiltradas.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptySearch(
                    busqueda: _busquedaController.text.trim(),
                    onLimpiar: _limpiarBusqueda,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final double anchoDisponible =
                          constraints.crossAxisExtent;

                      final int columnas = anchoDisponible >= 900
                          ? 3
                          : anchoDisponible >= 600
                          ? 2
                          : 1;

                      if (columnas == 1) {
                        return SliverList.separated(
                          itemCount: _solucionesFiltradas.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 16);
                          },
                          itemBuilder: (context, index) {
                            final Solucion solucion =
                                _solucionesFiltradas[index];

                            return SolucionCard(
                              solucion: solucion,
                              onTap: () {
                                _abrirDetalle(solucion);
                              },
                              onSolicitar: () {
                                _registrarSolicitud(solucion);
                              },
                            );
                          },
                        );
                      }

                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columnas,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.94,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final Solucion solucion = _solucionesFiltradas[index];

                          return SolucionCard(
                            solucion: solucion,
                            onTap: () {
                              _abrirDetalle(solucion);
                            },
                            onSolicitar: () {
                              _registrarSolicitud(solucion);
                            },
                          );
                        }, childCount: _solucionesFiltradas.length),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: AppColors.blanco,
        indicatorColor: AppColors.verdeClaro,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              _mostrarSolicitudes();
              break;
            case 2:
              _mostrarPerfil();
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: AppColors.verdePrincipal,
            ),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(
              Icons.description_rounded,
              color: AppColors.verdePrincipal,
            ),
            label: 'Solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: AppColors.verdePrincipal,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.amarillo,
          child: Icon(
            Icons.bolt_rounded,
            color: AppColors.verdeOscuro,
            size: 22,
          ),
        ),
        SizedBox(width: 10),
        Flexible(
          child: Text(
            'GenLi Conecta',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.busquedaController,
    required this.onBuscar,
    required this.onLimpiar,
  });

  final TextEditingController busquedaController;
  final ValueChanged<String> onBuscar;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.verdePrincipal,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hola, solicitante',
                style: TextStyle(
                  color: AppColors.blanco,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Encuentra una solución sostenible para las necesidades de tu organización o comunidad.',
                style: TextStyle(
                  color: Color(0xFFD7E8E0),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: busquedaController,
                builder: (context, value, child) {
                  return TextField(
                    controller: busquedaController,
                    textInputAction: TextInputAction.search,
                    onChanged: onBuscar,
                    decoration: InputDecoration(
                      hintText: 'Buscar solución...',
                      fillColor: AppColors.blanco,
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.verdePrincipal,
                      ),
                      suffixIcon: value.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpiar búsqueda',
                              onPressed: onLimpiar,
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textoSecundario,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.cantidad});

  final int cantidad;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1140),
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 17),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soluciones sostenibles',
                    style: TextStyle(
                      color: AppColors.verdeTexto,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Consulta las líneas disponibles.',
                    style: TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.verdeClaro,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '$cantidad resultados',
                style: const TextStyle(
                  color: AppColors.verdePrincipal,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.busqueda, required this.onLimpiar});

  final String busqueda;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 430),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: AppColors.verdeClaro,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: AppColors.verdePrincipal,
                size: 43,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No encontramos resultados',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.verdeTexto,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              busqueda.isEmpty
                  ? 'No hay soluciones disponibles.'
                  : 'No hay soluciones relacionadas con "$busqueda".',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textoSecundario,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onLimpiar,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.verdePrincipal,
                side: const BorderSide(color: AppColors.verdePrincipal),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Ver todas las soluciones'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CargandoCatalogo extends StatelessWidget {
  const _CargandoCatalogo();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.verdePrincipal),
            SizedBox(height: 16),
            Text(
              'Cargando soluciones...',
              style: TextStyle(color: AppColors.textoSecundario, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCatalogo extends StatelessWidget {
  const _ErrorCatalogo({required this.onReintentar});

  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 430),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'No fue posible cargar las soluciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.verdeTexto,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Revisa tu conexión a internet e inténtalo de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textoSecundario,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
