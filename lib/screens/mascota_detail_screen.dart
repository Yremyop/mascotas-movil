import 'package:flutter/material.dart';

import '../models/mascota.dart';
import '../services/mascota_service.dart';
import 'mascota_form_screen.dart';

/// Consulta de un registro: muestra los datos de Firestore y la imagen de Cloudinary.
class MascotaDetailScreen extends StatelessWidget {
  final String mascotaId;

  const MascotaDetailScreen({super.key, required this.mascotaId});

  Future<void> _confirmarEliminar(BuildContext context, Mascota mascota) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar mascota'),
        content: Text('¿Seguro que quieres eliminar a "${mascota.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await MascotaService().eliminar(mascota.id);
      messenger.showSnackBar(
          SnackBar(content: Text('"${mascota.nombre}" fue eliminada.')));
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('No se pudo eliminar: $e'),
        backgroundColor: Colors.red.shade700,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Mascota?>(
      stream: MascotaService().mascota(mascotaId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final mascota = snapshot.data;
        if (mascota == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('El registro ya no existe.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(mascota.nombre),
            actions: [
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MascotaFormScreen(mascota: mascota)),
                ),
              ),
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmarEliminar(context, mascota),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(
                        mascota.imagenUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progreso) =>
                            progreso == null
                                ? child
                                : const Center(child: CircularProgressIndicator()),
                        errorBuilder: (_, _, _) => const Center(
                            child: Icon(Icons.broken_image, size: 64)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Dato(etiqueta: 'Nombre', valor: mascota.nombre),
                  _Dato(etiqueta: 'Especie', valor: mascota.especie),
                  _Dato(etiqueta: 'Edad', valor: '${mascota.edad} año(s)'),
                  _Dato(etiqueta: 'Descripción', valor: mascota.descripcion),
                  const Divider(),
                  _Dato(etiqueta: 'UID del dueño', valor: mascota.uid),
                  _Dato(etiqueta: 'URL de la imagen', valor: mascota.imagenUrl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Dato extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _Dato({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: Theme.of(context).textTheme.labelMedium),
          SelectableText(valor, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
