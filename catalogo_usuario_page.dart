import 'dart:io';
import 'package:flutter/material.dart';
import 'package:reciidar/db_helper.dart';
import 'package:reciidar/formulario_compra_page.dart';

class CatalogoUsuarioPage extends StatefulWidget {
  final String nombreUsuario;
  const CatalogoUsuarioPage({super.key, required this.nombreUsuario});

  @override
  State<CatalogoUsuarioPage> createState() => _CatalogoUsuarioPageState();
}

class _CatalogoUsuarioPageState extends State<CatalogoUsuarioPage> {
  List<Map<String, dynamic>> _productos = [];
  int _descuentoActual = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final productos = await DBHelper.obtenerProductosDisponibles();

    final donaciones =
    await DBHelper.obtenerDonacionesPorUsuario(widget.nombreUsuario);
    final recibidas = donaciones.where((d) => d['estado'] == 'Recibida').length;

    int bloques = (recibidas ~/ 5);
    int descuento = bloques * 5;
    if (descuento > 15) descuento = 0;

    setState(() {
      _productos = productos;
      _descuentoActual = descuento;
    });
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Disponible':
        return Colors.green;
      case 'Pendiente':
        return Colors.orange;
      case 'Vendido':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        backgroundColor: Colors.green,
      ),
      body: _productos.isEmpty
          ? const Center(child: Text('No hay productos disponibles.'))
          : ListView.builder(
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final producto = _productos[index];
          final String? imagenPath = producto['foto'];
          final estado = producto['estado'] ?? 'Pendiente';

          double precioOriginal = 0;
          try {
            precioOriginal = producto['precio'] is double
                ? producto['precio']
                : double.parse(producto['precio'].toString());
          } catch (e) {
            precioOriginal = 0;
          }

          final precioConDescuento =
              precioOriginal * (1 - _descuentoActual / 100);

          return Card(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imagenPath != null && File(imagenPath).existsSync())
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: Image.file(
                      File(imagenPath),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 180,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Text("Sin imagen"),
                  ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto['nombreProducto'] ?? '',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text("Descripción: ${producto['descripcion'] ?? ''}"),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            "Precio: S/ ${precioConDescuento.toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (_descuentoActual > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(-$_descuentoActual% descuento)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text("Estado: "),
                          Text(
                            estado,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _colorEstado(estado),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_cart),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        onPressed: estado == 'Disponible'
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormularioCompraPage(
                                producto: producto,
                                nombreUsuario: widget.nombreUsuario,
                              ),
                            ),
                          );
                        }
                            : null,
                        label: const Text('Contactar para comprar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
