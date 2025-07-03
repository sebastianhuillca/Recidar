import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaSeleccionPage extends StatefulWidget {
  const MapaSeleccionPage({super.key});

  @override
  State<MapaSeleccionPage> createState() => _MapaSeleccionPageState();
}

class _MapaSeleccionPageState extends State<MapaSeleccionPage> {
  final MapController _mapController = MapController();
  LatLng? _ubicacionSeleccionada;

  final LatLng _posicionInicial = LatLng(-12.0464, -77.0428); // Lima

  void _seleccionarUbicacion(LatLng punto) {
    setState(() {
      _ubicacionSeleccionada = punto;
    });
  }

  void _confirmarUbicacion() {
    if (_ubicacionSeleccionada != null) {
      Navigator.pop(context, _ubicacionSeleccionada);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una ubicación en el mapa')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Confirmar',
            onPressed: _confirmarUbicacion,
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _posicionInicial,
          initialZoom: 13.0,
          onTap: (tapPosition, point) {
            _seleccionarUbicacion(point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          if (_ubicacionSeleccionada != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _ubicacionSeleccionada!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
        ],
      ),
    );
  }
}