import 'dart:io';
import 'package:flutter/material.dart';
import 'package:reciidar/db_helper.dart';
import 'package:reciidar/formulario_producto_page.dart';

class CatalogoAdminPage extends StatefulWidget {
  const CatalogoAdminPage({Key? key}) : super(key: key);

  @override
  _CatalogoAdminPageState createState() => _CatalogoAdminPageState();
}

class _CatalogoAdminPageState extends State<CatalogoAdminPage> {
  List<Map<String, dynamic>> _productos = [];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final productos = await DBHelper.obtenerTodosLosProductos();
    setState(() {
      _productos = productos;
    });
  }

  Future<void> _cambiarEstadoProducto(int id, String nuevoEstado) async {
    await DBHelper.actualizarEstadoProducto(id, nuevoEstado);
    await _cargarProductos();
  }

  Future<void> _eliminarProducto(int id) async {
    await DBHelper.eliminarProducto(id);
    await _cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar producto',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FormularioProductoPage()),
              ).then((_) => _cargarProductos());
            },
          ),
        ],
      ),
      body: _productos.isEmpty
          ? const Center(child: Text('No hay productos en el catálogo'))
          : ListView.builder(
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final producto = _productos[index];
          final estado = producto['estado'] as String? ?? 'Disponible';
          final foto = producto['foto'];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: (foto != null && foto.toString().isNotEmpty && File(foto).existsSync())
                  ? Image.file(File(foto), width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported),
              title: Text(producto['nombreProducto'] ?? 'Sin nombre'),
              subtitle: Text(
                'Estado: $estado\nPrecio: S/ ${producto['precio']?.toStringAsFixed(2) ?? '0.00'}',
              ),
              isThreeLine: true,
              trailing: SizedBox(
                width: 160,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (estado != 'Vendido')
                      ElevatedButton(
                        onPressed: () {
                          _cambiarEstadoProducto(producto['id'], 'Vendido');
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Marcar Vendido', style: TextStyle(fontSize: 12)),
                      ),
                    if (estado == 'Vendido')
                      ElevatedButton(
                        onPressed: () {
                          _cambiarEstadoProducto(producto['id'], 'Disponible');
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Disponible', style: TextStyle(fontSize: 12)),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _eliminarProducto(producto['id']);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
                      child: const Icon(Icons.delete, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormularioProductoPage()),
          ).then((_) => _cargarProductos());
        },
        label: const Text('Agregar Producto'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}