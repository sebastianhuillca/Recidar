import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reciidar/db_helper.dart';

class GestionProductosAdminPage extends StatefulWidget {
  const GestionProductosAdminPage({super.key});

  @override
  State<GestionProductosAdminPage> createState() => _GestionProductosAdminPageState();
}

class _GestionProductosAdminPageState extends State<GestionProductosAdminPage> {
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

  Future<void> _eliminarProducto(int id) async {
    await DBHelper.eliminarProducto(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado')),
    );
    _cargarProductos();
  }

  Future<void> _editarProducto(Map<String, dynamic> producto) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _DialogEditarProducto(producto: producto),
    );

    if (result != null) {
      await DBHelper.actualizarProducto(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado')),
      );
      _cargarProductos();
    }
  }

  Future<void> _agregarProducto() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _DialogAgregarProducto(),
    );

    if (result != null) {
      await DBHelper.insertarProductoCatalogo(
        nombreProducto: result['nombreProducto'],
        descripcion: result['descripcion'],
        precio: result['precio'],
        foto: result['foto'],
        estado: result['estado'],
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado')),
      );
      _cargarProductos();
    }
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
        title: const Text('Gestionar Productos'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar Producto',
            onPressed: _agregarProducto,
          ),
        ],
      ),
      body: _productos.isEmpty
          ? const Center(child: Text('No hay productos registrados.'))
          : ListView.builder(
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final producto = _productos[index];
          final String? imagenPath = producto['foto'];
          final estado = producto['estado'] ?? 'Pendiente';

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
                      Text("Precio: S/ ${producto['precio']?.toStringAsFixed(2) ?? '0.00'}"),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () => _editarProducto(producto),
                            label: const Text('Editar'),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar eliminación'),
                                content: const Text('¿Estás seguro de eliminar este producto?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            ).then((confirmed) {
                              if (confirmed ?? false) {
                                _eliminarProducto(producto['id']);
                              }
                            }),
                            label: const Text('Eliminar'),
                          ),
                        ],
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

class _DialogAgregarProducto extends StatefulWidget {
  const _DialogAgregarProducto();

  @override
  State<_DialogAgregarProducto> createState() => _DialogAgregarProductoState();
}

class _DialogAgregarProductoState extends State<_DialogAgregarProducto> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  String _estado = 'Disponible';
  XFile? _imagen;
  final ImagePicker _picker = ImagePicker();

  Future<void> _seleccionarImagen() async {
    final imagen = await _picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() {
        _imagen = imagen;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Producto'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: _seleccionarImagen,
              child: _imagen == null
                  ? Container(
                height: 150,
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Text('Toca para seleccionar imagen'),
              )
                  : Image.file(
                File(_imagen!.path),
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 2,
            ),
            TextField(
              controller: _precioController,
              decoration: const InputDecoration(labelText: 'Precio (S/)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            DropdownButtonFormField<String>(
              value: _estado,
              items: ['Disponible', 'Pendiente', 'Vendido']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Estado'),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _estado = val;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final nombre = _nombreController.text.trim();
            final descripcion = _descripcionController.text.trim();
            final precio = double.tryParse(_precioController.text) ?? 0.0;

            if (nombre.isEmpty || descripcion.isEmpty || precio <= 0 || _imagen == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor, complete todos los campos y seleccione imagen')),
              );
              return;
            }

            final nuevoProducto = {
              'nombreProducto': nombre,
              'descripcion': descripcion,
              'precio': precio,
              'estado': _estado,
              'foto': _imagen!.path,
            };

            Navigator.of(context).pop(nuevoProducto);
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}

class _DialogEditarProducto extends StatefulWidget {
  final Map<String, dynamic> producto;
  const _DialogEditarProducto({required this.producto});

  @override
  State<_DialogEditarProducto> createState() => _DialogEditarProductoState();
}

class _DialogEditarProductoState extends State<_DialogEditarProducto> {
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;
  String _estado = 'Disponible';

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto['nombreProducto']);
    _descripcionController = TextEditingController(text: widget.producto['descripcion']);
    _precioController = TextEditingController(
        text: widget.producto['precio']?.toStringAsFixed(2) ?? '0.00');
    _estado = widget.producto['estado'] ?? 'Disponible';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Producto'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 2,
            ),
            TextField(
              controller: _precioController,
              decoration: const InputDecoration(labelText: 'Precio (S/)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            DropdownButtonFormField<String>(
              value: _estado,
              items: ['Disponible', 'Pendiente', 'Vendido']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Estado'),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _estado = val;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final nombre = _nombreController.text.trim();
            final descripcion = _descripcionController.text.trim();
            final precio = double.tryParse(_precioController.text) ?? 0.0;

            if (nombre.isEmpty || descripcion.isEmpty || precio <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Por favor, complete todos los campos correctamente')),
              );
              return;
            }

            final productoActualizado = {
              'id': widget.producto['id'],
              'nombreProducto': nombre,
              'descripcion': descripcion,
              'precio': precio,
              'estado': _estado,
              'foto': widget.producto['foto'],
            };

            Navigator.of(context).pop(productoActualizado);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}