import 'package:flutter/material.dart';
import 'package:reciidar/ver_donaciones_admin.dart';
import 'package:reciidar/ver_usuarios.dart';
import 'package:reciidar/ranking_usuarios_page.dart';
import 'package:reciidar/catalogo_admin_page.dart';
import 'package:reciidar/catalogo_usuario_page.dart';
import 'package:reciidar/lista_ventas_page.dart';

class PantallaAdmin extends StatelessWidget {
  const PantallaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              'Bienvenido, Administrador',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VerDonacionesAdminPage()),
                );
              },
              label: const Text('Ver Donaciones Pendientes'),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.people),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VerUsuariosPage()),
                );
              },
              label: const Text('Ver Usuarios Registrados'),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.star),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RankingUsuariosPage()),
                );
              },
              label: const Text('Ver Ranking de Usuarios Evaluados'),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CatalogoAdminPage()),
                );
              },
              label: const Text('Gestionar Catálogo de Productos'),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CatalogoUsuarioPage(nombreUsuario: 'admin'),
                  ),
                );
              },
              label: const Text('Ver Catálogo (Vista Usuario)'),
            ),
            const SizedBox(height: 20),

            // NUEVO BOTÓN: Ver Ventas
            ElevatedButton.icon(
              icon: const Icon(Icons.receipt_long),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListaVentasPage()),
                );
              },
              label: const Text('Ver Ventas Recibidas'),
            ),
          ],
        ),
      ),
    );
  }
}