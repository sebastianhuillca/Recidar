import 'dart:io';
import 'package:flutter/material.dart';
import 'package:reciidar/db_helper.dart';

class VerHistorialPorUsuarioAdmin extends StatefulWidget {
  const VerHistorialPorUsuarioAdmin({super.key});

  @override
  State<VerHistorialPorUsuarioAdmin> createState() =>
      _VerHistorialPorUsuarioAdminState();
}

class _VerHistorialPorUsuarioAdminState extends State<VerHistorialPorUsuarioAdmin> {
  List<Map<String, dynamic>> _usuarios = [];
  String? _usuarioSeleccionado;
  List<Map<String, dynamic>> _donacionesDelUsuario = [];

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    final usuarios = await DBHelper.obtenerTodosLosUsuarios();

    // Ordenamos alfabéticamente por nombre
    usuarios.sort((a, b) => a['nombre'].toString().compareTo(b['nombre'].toString()));

    setState(() {
      _usuarios = usuarios;
    });
  }

  Future<void> _mostrarDonaciones(String nombreUsuario) async {
    final donaciones = await DBHelper.obtenerDonacionesPorUsuario(nombreUsuario);
    setState(() {
      _usuarioSeleccionado = nombreUsuario;
      _donacionesDelUsuario = donaciones;
    });
  }

  void _volverAListaUsuarios() {
    setState(() {
      _usuarioSeleccionado = null;
      _donacionesDelUsuario = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_usuarioSeleccionado == null
            ? 'Historial por Usuario'
            : 'Donaciones de $_usuarioSeleccionado'),
        backgroundColor: Colors.green,
        leading: _usuarioSeleccionado != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _volverAListaUsuarios,
        )
            : null,
      ),
      body: _usuarioSeleccionado == null
          ? ListView.builder(
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final usuario = _usuarios[index];
          final nombreCompleto = "${usuario['nombre']} ${usuario['apellido']}";
          final username = usuario['usuario'];

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: DBHelper.obtenerDonacionesPorUsuario(username),
            builder: (context, snapshot) {
              final donaciones = snapshot.data ?? [];
              return ListTile(
                title: Text(nombreCompleto),
                subtitle: Text('Usuario: $username - Donaciones: ${donaciones.length}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _mostrarDonaciones(username),
              );
            },
          );
        },
      )
          : _donacionesDelUsuario.isEmpty
          ? const Center(child: Text("Este usuario no tiene donaciones registradas."))
          : ListView.builder(
        itemCount: _donacionesDelUsuario.length,
        itemBuilder: (context, index) {
          final donacion = _donacionesDelUsuario[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donacion['nombreProducto'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text("Estado: ${donacion['estado']}"),
                  Text("Descripción: ${donacion['descripcion'] ?? ''}"),
                  Text("Ubicación: ${donacion['ubicacion'] ?? ''}"),
                  if (donacion['fechaRecojo'] != null)
                    Text("Fecha de recojo: ${donacion['fechaRecojo']}"),
                  const SizedBox(height: 10),
                  if (donacion['foto'] != null &&
                      File(donacion['foto']).existsSync())
                    Image.file(
                      File(donacion['foto']),
                      height: 150,
                      fit: BoxFit.cover,
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