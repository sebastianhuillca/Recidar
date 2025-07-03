import 'package:flutter/material.dart';
import 'package:reciidar/db_helper.dart';

class VerUsuariosPage extends StatefulWidget {
  const VerUsuariosPage({super.key});

  @override
  State<VerUsuariosPage> createState() => _VerUsuariosPageState();
}

class _VerUsuariosPageState extends State<VerUsuariosPage> {
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

  Future<void> _eliminarUsuario(String nombreUsuario) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Text("¿Estás seguro de que deseas eliminar a '$nombreUsuario'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado ?? false) {
      await DBHelper.eliminarUsuarioPorNombreUsuario(nombreUsuario);
      await DBHelper.eliminarProductosPorNombreUsuario(nombreUsuario);
      _cargarUsuarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuarios Registrados"),
        backgroundColor: Colors.green,
      ),
      body: _usuarios.isEmpty
          ? const Center(child: Text("No hay usuarios registrados."))
          : ListView.builder(
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final usuario = _usuarios[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text('${usuario['nombre']} ${usuario['apellido']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usuario: ${usuario['usuario']}'),
                  Text('Correo: ${usuario['correo']}'),
                  Text('Teléfono: ${usuario['telefono']}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _eliminarUsuario(usuario['usuario']),
              ),
            ),
          );
        },
      ),
    );
  }
}