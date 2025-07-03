import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:reciidar/db_helper.dart';
import 'package:intl/intl.dart';

class FormularioCompraPage extends StatefulWidget {
  final Map<String, dynamic> producto;
  final String nombreUsuario; // ← Agregado para saber quién compra

  const FormularioCompraPage({
    Key? key,
    required this.producto,
    required this.nombreUsuario,
  }) : super(key: key);

  @override
  State<FormularioCompraPage> createState() => _FormularioCompraPageState();
}

class _FormularioCompraPageState extends State<FormularioCompraPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _distritoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _urbanizacionController = TextEditingController();

  LatLng? _puntoEntrega;

  Future<void> _guardarFormulario() async {
    if (!_formKey.currentState!.validate() || _puntoEntrega == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos y selecciona un punto de entrega')),
      );
      return;
    }

    final fechaActual = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    await DBHelper.insertarVenta({
      'nombreUsuario': widget.nombreUsuario,
      'nombreCompleto': _nombreController.text,
      'correo': _correoController.text,
      'telefono': _telefonoController.text,
      'distrito': _distritoController.text,
      'direccion': _direccionController.text,
      'urbanizacion': _urbanizacionController.text,
      'latitud': _puntoEntrega!.latitude,
      'longitud': _puntoEntrega!.longitude,
      'productoId': widget.producto['id'],
      'estadoVenta': 'Pendiente',
      'fecha': fechaActual,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nos contactaremos contigo lo más pronto posible')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Compra'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre completo'),
                    validator: (value) => value!.isEmpty ? 'Ingresa tu nombre completo' : null,
                  ),
                  TextFormField(
                    controller: _correoController,
                    decoration: const InputDecoration(labelText: 'Correo'),
                    validator: (value) => value!.isEmpty ? 'Ingresa tu correo' : null,
                  ),
                  TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    validator: (value) => value!.isEmpty ? 'Ingresa tu teléfono' : null,
                  ),
                  TextFormField(
                    controller: _distritoController,
                    decoration: const InputDecoration(labelText: 'Distrito'),
                    validator: (value) => value!.isEmpty ? 'Ingresa tu distrito' : null,
                  ),
                  TextFormField(
                    controller: _direccionController,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                    validator: (value) => value!.isEmpty ? 'Ingresa tu dirección' : null,
                  ),
                  TextFormField(
                    controller: _urbanizacionController,
                    decoration: const InputDecoration(labelText: 'Urbanización'),
                    validator: (value) => value!.isEmpty ? 'Ingresa tu urbanización' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Selecciona el punto de entrega en el mapa:'),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(-12.0464, -77.0428),
                  initialZoom: 13,
                  onTap: (_, point) {
                    setState(() {
                      _puntoEntrega = point;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.reciidar',
                  ),
                  if (_puntoEntrega != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _puntoEntrega!,
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
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarFormulario,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Enviar solicitud'),
            ),
          ],
        ),
      ),
    );
  }
}