import 'package:flutter/material.dart';
import 'package:reciidar/db_helper.dart';
import 'package:reciidar/donar_producto_page.dart';
import 'package:reciidar/ver_historial_usuario.dart';
import 'package:reciidar/catalogo_usuario_page.dart'; // <- Import añadido

class PantallaUsuario extends StatefulWidget {
  final String nombreUsuario;

  const PantallaUsuario({super.key, required this.nombreUsuario});

  @override
  State<PantallaUsuario> createState() => _PantallaUsuarioState();
}

class _PantallaUsuarioState extends State<PantallaUsuario> {
  int _descuentoActual = 0;

  @override
  void initState() {
    super.initState();
    _calcularDescuentoActual();
  }

  Future<void> _calcularDescuentoActual() async {
    final donaciones = await DBHelper.obtenerDonacionesPorUsuario(widget.nombreUsuario);
    final recibidas = donaciones.where((d) => d['estado'] == 'Recibida').length;
    int bloques = (recibidas ~/ 5);
    int descuento = bloques * 5;
    if (descuento > 15) descuento = 0;
    setState(() {
      _descuentoActual = descuento;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Usuario'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Hola, ${widget.nombreUsuario}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.discount, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Descuento actual: $_descuentoActual%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DonarProductoPage(nombreUsuario: widget.nombreUsuario),
                  ),
                ).then((_) => _calcularDescuentoActual());
              },
              label: const Text('Donar Producto'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VerHistorialUsuario(nombreUsuario: widget.nombreUsuario),
                  ),
                ).then((_) => _calcularDescuentoActual());
              },
              label: const Text('Ver Historial de Donaciones'),
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
                    builder: (_) => CatalogoUsuarioPage(nombreUsuario: widget.nombreUsuario),
                  ),
                );
              },
              label: const Text('Ver Catálogo'),
            ),
          ],
        ),
      ),
    );
  }
}