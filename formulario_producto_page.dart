import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reciidar/db_helper.dart';

class FormularioProductoPage extends StatefulWidget {
  const FormularioProductoPage({super.key});

  @override
  State<FormularioProductoPage> createState() => _FormularioProductoPageState();
}

class _FormularioProductoPageState extends State<FormularioProductoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  File? _imagen;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final imagenSeleccionada = await picker.pickImage(source: ImageSource.gallery);

    if (imagenSeleccionada != null) {
      setState(() {
        _imagen = File(imagenSeleccionada.path);
      });
    }
  }

  Future<void> _guardarProducto() async {
    if (_formKey.currentState!.validate() && _imagen != null) {
      await DBHelper.insertarProductoCatalogo(
        nombreProducto: _nombreController.text,
        descripcion: _descripcionController.text,
        precio: double.parse(_precioController.text),
        foto: _imagen!.path,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado exitosamente')),
      );

      Navigator.pop(context); // Vuelve al catálogo
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos e imagen')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del producto'),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio (S/)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Seleccionar Imagen'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _seleccionarImagen,
              ),
              const SizedBox(height: 10),
              if (_imagen != null)
                Image.file(_imagen!, height: 200),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar Producto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _guardarProducto,
              ),
            ],
          ),
        ),
      ),
    );
  }
}