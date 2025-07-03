import 'package:flutter/material.dart';
import 'package:reciidar/db_helper.dart';

class VerUsuarios extends StatefulWidget {
  const VerUsuarios({super.key});

  @override
  State<VerUsuarios> createState() => _VerUsuariosState();
}

class _VerUsuariosState extends State<VerUsuarios> {
  List<Map<String, dynamic>> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    final usuarios = await DBHelper.obtenerTodosLosUsuarios();
    setState(() {
      _usuarios = usuarios;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios Registrados'),
        backgroundColor: Colors.green,
      ),
      body: _usuarios.isEmpty
          ? const Center(child: Text('No hay usuarios registrados.'))
          : ListView.builder(
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final usuario = _usuarios[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text("${usuario['nombre']} ${usuario['apellido']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Usuario: ${usuario['usuario']}"),
                  Text("Correo: ${usuario['correo']}"),
                  Text("Teléfono: ${usuario['telefono']}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}