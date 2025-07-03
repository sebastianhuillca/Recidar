import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:reciidar/db_helper.dart';

class ListaVentasPage extends StatefulWidget {
  const ListaVentasPage({super.key});

  @override
  State<ListaVentasPage> createState() => _ListaVentasPageState();
}

class _ListaVentasPageState extends State<ListaVentasPage> {
  List<Map<String, dynamic>> _ventas = [];

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    final ventas = await DBHelper.obtenerVentasConNombreProducto();
    setState(() {
      _ventas = ventas;
    });
  }

  Future<void> _completarVenta(int id) async {
    await DBHelper.actualizarEstadoVenta(id, 'Completado');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Venta marcada como completada')),
    );
    _cargarVentas();
  }

  Future<void> _eliminarVenta(int id) async {
    await DBHelper.eliminarVenta(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Venta eliminada')),
    );
    _cargarVentas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas Recibidas'),
        backgroundColor: Colors.green,
      ),
      body: _ventas.isEmpty
          ? const Center(child: Text('No hay ventas registradas'))
          : ListView.builder(
        itemCount: _ventas.length,
        itemBuilder: (context, index) {
          final venta = _ventas[index];
          final lat = double.tryParse(venta['latitud'].toString());
          final lng = double.tryParse(venta['longitud'].toString());

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Producto: ${venta['nombreProducto'] ?? 'Desconocido'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text('Nombre completo: ${venta['nombreCompleto']}'),
                  Text('Correo: ${venta['correo']}'),
                  Text('Teléfono: ${venta['telefono']}'),
                  Text('Distrito: ${venta['distrito']}'),
                  Text('Dirección: ${venta['direccion']}'),
                  Text('Urbanización: ${venta['urbanizacion']}'),
                  Text('Estado: ${venta['estadoVenta']}'),
                  Text('Fecha: ${venta['fecha'] ?? ''}'),
                  const SizedBox(height: 10),
                  if (lat != null && lng != null)
                    SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(lat, lng),
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                            userAgentPackageName: 'com.example.reciidar',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(lat, lng),
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    const Text('Ubicación no disponible'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (venta['estadoVenta'] == 'Pendiente')
                        ElevatedButton(
                          onPressed: () => _completarVenta(venta['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Marcar como Completado'),
                        ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => _eliminarVenta(venta['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        icon: const Icon(Icons.delete),
                        label: const Text('Eliminar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}