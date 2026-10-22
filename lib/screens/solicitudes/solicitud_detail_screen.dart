import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/solucion.dart';
import '../solicitudes/solicitud_form_screen.dart';

class SolucionDetailScreen extends StatelessWidget {
  const SolucionDetailScreen({
    super.key,
    required this.solucion,
  });

  final Solucion solucion;

  void _registrarSolicitud(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SolicitudFormScreen(
            solucion: solucion,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Regresar',
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
        ),
        title: const Text('Detalle de la solución'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            120,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 650,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SolutionHeader(
                    solucion: solucion,
                  ),
                  const SizedBox(height: 22),
                  _InformationCard(
                    solucion: solucion,
                  ),
                  const SizedBox(height: 18),
                  const _ProcessCard(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            18,
          ),
          decoration: BoxDecoration(
            color: AppColors.blanco,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.08,
                ),
                blurRadius: 16,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: () {
                _registrarSolicitud(context);
              },
              icon: const Icon(
                Icons.description_outlined,
              ),
              label: const Text(
                'Registrar solicitud',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SolutionHeader extends StatelessWidget {
  const _SolutionHeader({
    required this.solucion,
  });

  final Solucion solucion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.verdePrincipal,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.verdePrincipal.withValues(
              alpha: 0.18,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.blanco.withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              solucion.icono,
              color: solucion.color,
              size: 38,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: solucion.color,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              solucion.categoria.toUpperCase(),
              style: const TextStyle(
                color: AppColors.verdeOscuro,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            solucion.nombre,
            style: const TextStyle(
              color: AppColors.blanco,
              fontSize: 29,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            solucion.descripcion,
            style: const TextStyle(
              color: Color(0xFFDCEBE4),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.solucion,
  });

  final Solucion solucion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.bordeCampo,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿En qué consiste?',
            style: TextStyle(
              color: AppColors.verdeTexto,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _descripcionAmpliada(),
            style: const TextStyle(
              color: AppColors.textoSecundario,
              fontSize: 15,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 22),
          const Divider(),
          const SizedBox(height: 14),
          const Text(
            'Información que puedes registrar',
            style: TextStyle(
              color: AppColors.verdeTexto,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          const _InformationItem(
            icon: Icons.business_outlined,
            text: 'Organización o comunidad solicitante',
          ),
          const _InformationItem(
            icon: Icons.location_on_outlined,
            text: 'Ubicación relacionada con la necesidad',
          ),
          const _InformationItem(
            icon: Icons.notes_rounded,
            text: 'Descripción detallada de la necesidad',
          ),
          const _InformationItem(
            icon: Icons.category_outlined,
            text: 'Línea de solución seleccionada',
          ),
        ],
      ),
    );
  }

  String _descripcionAmpliada() {
    switch (solucion.id) {
      case 'SOL-01':
        return 'Esta línea reúne alternativas orientadas al '
            'aprovechamiento de fuentes renovables, como la '
            'energía solar. El solicitante podrá describir el '
            'contexto, la ubicación y la necesidad energética '
            'de su organización o comunidad.';

      case 'SOL-02':
        return 'Esta línea contempla necesidades relacionadas '
            'con el acceso, tratamiento y gestión sostenible '
            'del agua potable. La solicitud permitirá describir '
            'la situación y los posibles beneficiarios.';

      case 'SOL-03':
        return 'Esta línea agrupa iniciativas que integran el '
            'bienestar comunitario y la protección del '
            'medioambiente mediante soluciones '
            'socioambientales.';

      case 'SOL-04':
        return 'Esta línea permite registrar necesidades '
            'relacionadas con la formulación y gestión de '
            'proyectos sostenibles con enfoque ambiental y '
            'comunitario.';

      case 'SOL-05':
        return 'Esta línea permite describir necesidades '
            'orientadas a disminuir el impacto ambiental y las '
            'emisiones de CO₂ mediante alternativas '
            'sostenibles.';

      default:
        return solucion.descripcion;
    }
  }
}

class _InformationItem extends StatelessWidget {
  const _InformationItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 13,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.verdeClaro,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.verdePrincipal,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 7,
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.textoSecundario,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessCard extends StatelessWidget {
  const _ProcessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.verdeClaro,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué sucede después?',
            style: TextStyle(
              color: AppColors.verdeTexto,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 16),
          _ProcessStep(
            number: '1',
            title: 'Registra la necesidad',
            description:
            'Completa el formulario con la información solicitada.',
          ),
          _ProcessStep(
            number: '2',
            title: 'Recibe un código',
            description:
            'El sistema asigna un identificador y el estado inicial.',
          ),
          _ProcessStep(
            number: '3',
            title: 'Consulta el seguimiento',
            description:
            'Revisa posteriormente el estado y las observaciones.',
            showLine: false,
          ),
        ],
      ),
    );
  }
}

class _ProcessStep extends StatelessWidget {
  const _ProcessStep({
    required this.number,
    required this.title,
    required this.description,
    this.showLine = true,
  });

  final String number;
  final String title;
  final String description;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.verdePrincipal,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: AppColors.blanco,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    color: AppColors.verdeSecundario,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.verdeTexto,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}