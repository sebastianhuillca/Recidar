import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:reciidar/db_helper.dart';

class DonarProductoPage extends StatefulWidget {
  final String nombreUsuario;

  const DonarProductoPage({super.key, required this.nombreUsuario});

  @override
  State<DonarProductoPage> createState() => _DonarProductoPageState();
}

class _DonarProductoPageState extends State<DonarProductoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCompletoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _productoController = TextEditingController();
  final _descripcionController = TextEditingController();

  File? _imagenSeleccionada;
  LatLng? _ubicacionSeleccionada;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }

  Future<void> _enviarFormulario() async {
    if (_formKey.currentState!.validate() &&
        _imagenSeleccionada != null &&
        _ubicacionSeleccionada != null) {
      await DBHelper.insertarDonacion(
        nombreUsuario: widget.nombreUsuario,
        nombreProducto: _productoController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        telefono: _telefonoController.text.trim(),
        foto: _imagenSeleccionada!.path,
        ubicacion:
        '${_ubicacionSeleccionada!.latitude},${_ubicacionSeleccionada!.longitude}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donación enviada exitosamente')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos e imagen')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donar Producto'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _campoTexto(_nombreCompletoController, 'Nombres completos'),
              _campoTexto(_telefonoController, 'Teléfono', tipo: TextInputType.phone),
              _campoTexto(_productoController, 'Nombre del producto'),
              _campoTexto(_descripcionController, 'Descripción del producto', maxLineas: 3),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _seleccionarImagen,
                icon: const Icon(Icons.image),
                label: const Text('Seleccionar imagen'),
              ),
              if (_imagenSeleccionada != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.file(_imagenSeleccionada!, height: 150),
                ),
              const SizedBox(height: 10),
              const Text('Selecciona ubicación de recojo:'),
              const SizedBox(height: 5),
              SizedBox(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(-12.0464, -77.0428),
                    initialZoom: 12,
                    onTap: (tapPosition, latlng) {
                      setState(() {
                        _ubicacionSeleccionada = latlng;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.reciidar',
                    ),
                    if (_ubicacionSeleccionada != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _ubicacionSeleccionada!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _enviarFormulario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Enviar Donación'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(TextEditingController controller, String label,
      {TextInputType tipo = TextInputType.text, int maxLineas = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        maxLines: maxLineas,
        validator: (value) =>
        value == null || value.isEmpty ? 'Requerido' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}