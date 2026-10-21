import 'package:flutter/material.dart';

import '../models/mascota.dart';
import '../services/auth_service.dart';
import '../services/mascota_service.dart';
import 'mascota_detail_screen.dart';
import 'mascota_form_screen.dart';

/// Pantalla principal: lista las mascotas del usuario autenticado.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final email = authService.usuarioActual?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mascotas'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => authService.cerrarSesion(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text('Sesión iniciada: $email'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MascotaFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nueva mascota'),
      ),
      body: StreamBuilder<List<Mascota>>(
        stream: MascotaService().misMascotas(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error al cargar los datos:\n${snapshot.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final mascotas = snapshot.data!;
          if (mascotas.isEmpty) {
            return const Center(
              child: Text(
                'Aún no tienes mascotas registradas.\nToca "Nueva mascota" para agregar una.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: mascotas.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = mascotas[i];
              return ListTile(
                leading: CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(m.imagenUrl),
                ),
                title: Text(m.nombre),
                subtitle: Text('${m.especie} · ${m.edad} año(s)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MascotaDetailScreen(mascotaId: m.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
