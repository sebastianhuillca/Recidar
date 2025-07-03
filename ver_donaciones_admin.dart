import 'dart:io';
import 'package:flutter/material.dart';
import 'package:reciidar/db_helper.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class VerDonacionesAdminPage extends StatefulWidget {
  const VerDonacionesAdminPage({super.key});

  @override
  State<VerDonacionesAdminPage> createState() => _VerDonacionesAdminPageState();
}

class _VerDonacionesAdminPageState extends State<VerDonacionesAdminPage> {
  Map<String, List<Map<String, dynamic>>> _donacionesPorUsuario = {};
  String? _usuarioSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarDonaciones();
  }

  Future<void> _cargarDonaciones() async {
    final todasLasDonaciones = await DBHelper.obtenerDonacionesConUsuarios();

    Map<String, List<Map<String, dynamic>>> agrupadas = {};
    for (var donacion in todasLasDonaciones) {
      String nombreCompleto = '${donacion['nombre']} ${donacion['apellido']}';
      if (!agrupadas.containsKey(nombreCompleto)) {
        agrupadas[nombreCompleto] = [];
      }
      agrupadas[nombreCompleto]!.add(donacion);
    }

    setState(() {
      _donacionesPorUsuario = agrupadas;
    });
  }

  void _mostrarDonacionesUsuario(String nombreCompleto) {
    setState(() {
      _usuarioSeleccionado = nombreCompleto;
    });
  }

  void _volverAListaUsuarios() {
    setState(() {
      _usuarioSeleccionado = null;
    });
  }

  Future<void> _actualizarEstado(int id, String nuevoEstado) async {
    DateTime? fechaSeleccionada;

    if (nuevoEstado == 'Aprobado') {
      fechaSeleccionada = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 30)),
      );

      if (fechaSeleccionada == null) return;
    }

    await DBHelper.actualizarEstadoYFechaRecojo(
      id: id,
      estado: nuevoEstado,
      fechaRecojo: nuevoEstado == 'Aprobado' ? fechaSeleccionada!.toIso8601String() : '',
    );

    _cargarDonaciones();

    if (nuevoEstado == 'Aprobado') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donación aprobada con fecha de recojo.')),
      );
    } else if (nuevoEstado == 'Recibida') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donación marcada como recibida.')),
      );
    }
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'Aprobado':
        return Colors.green;
      case 'Denegado':
        return Colors.red;
      case 'Recibida':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final listaUsuarios = _donacionesPorUsuario.keys.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Ver Donaciones'),
        leading: _usuarioSeleccionado != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _volverAListaUsuarios,
        )
            : null,
      ),
      body: _usuarioSeleccionado == null
          ? ListView.builder(
        itemCount: listaUsuarios.length,
        itemBuilder: (context, index) {
          final usuario = listaUsuarios[index];
          return ListTile(
            title: Text(usuario),
            subtitle: Text('Donaciones: ${_donacionesPorUsuario[usuario]!.length}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _mostrarDonacionesUsuario(usuario),
          );
        },
      )
          : FutureBuilder<bool>(
        future: () async {
          final donaciones = _donacionesPorUsuario[_usuarioSeleccionado]!;
          final nombreUsuario = donaciones[0]['usuario'];
          return await DBHelper.adminYaEvaluoUsuario(nombreUsuario);
        }(),
        builder: (context, snapshot) {
          final donaciones = _donacionesPorUsuario[_usuarioSeleccionado]!;
          final nombreUsuario = donaciones[0]['usuario'];
          final yaEvaluado = snapshot.data ?? false;
          final recibidas = donaciones.where((d) => d['estado'] == 'Recibida').toList();

          final mostrarEvaluacionAdmin = recibidas.length >= 5 && !yaEvaluado;

          return ListView.builder(
            itemCount: donaciones.length + (mostrarEvaluacionAdmin ? 1 : 0),
            itemBuilder: (context, index) {
              if (mostrarEvaluacionAdmin && index == donaciones.length) {
                int estrellasSeleccionadas = 5;

                return Card(
                  margin: const EdgeInsets.all(12),
                  color: Colors.amber[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "⭐ Evaluar al usuario",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        StatefulBuilder(
                          builder: (context, setState) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                return IconButton(
                                  icon: Icon(
                                    i < estrellasSeleccionadas
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      estrellasSeleccionadas = i + 1;
                                    });
                                  },
                                );
                              }),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.send),
                            label: const Text("Enviar evaluación"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () async {
                              await DBHelper.evaluarUsuarioPorAdmin(
                                nombreUsuario,
                                estrellasSeleccionadas,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Evaluación enviada correctamente."),
                                ),
                              );
                              setState(() {});
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }

              final donacion = donaciones[index];
              final estado = donacion['estado'];
              final estadoColor = _getColorEstado(estado);
              final String usuarioDonante = donacion['usuario'];

              final String ubicacion = donacion['ubicacion'] ?? '';
              double? lat;
              double? lng;
              try {
                final partes = ubicacion.split(',');
                lat = double.tryParse(partes[0]);
                lng = double.tryParse(partes[1]);
              } catch (_) {}

              return Card(
                margin: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (donacion['foto'] != null && File(donacion['foto']).existsSync())
                      Image.file(
                        File(donacion['foto']),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Center(child: Text('Sin imagen')),
                      ),
                    ListTile(
                      title: Text(donacion['nombreProducto'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            'Estado: $estado',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: estadoColor,
                            ),
                          ),
                          Text('Descripción: ${donacion['descripcion'] ?? 'No proporcionado'}'),
                          if (donacion['fechaRecojo'] != null && donacion['fechaRecojo'] != '')
                            Text('Fecha de recojo: ${donacion['fechaRecojo']}'),
                          const SizedBox(height: 8),
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
                                    urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                            ),
                          const SizedBox(height: 10),
                          if (estado == 'Pendiente') ...[
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _actualizarEstado(donacion['id'], 'Aprobado'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  child: const Text('Aprobar'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () => _actualizarEstado(donacion['id'], 'Denegado'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Denegar'),
                                ),
                              ],
                            ),
                          ] else if (estado == 'Aprobado') ...[
                            ElevatedButton(
                              onPressed: () => _actualizarEstado(donacion['id'], 'Recibida'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              child: const Text('Marcar como Recibida'),
                            ),
                          ],
                          const SizedBox(height: 12),
                          FutureBuilder<double?>(
                            future: DBHelper.obtenerPromedioEvaluacion(usuarioDonante),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const SizedBox.shrink();
                              }
                              final promedio = snapshot.data;
                              if (promedio == null) {
                                return const Text(
                                  '⭐ Este usuario aún no ha sido evaluado',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                );
                              }
                              return Row(
                                children: [
                                  const Text("Evaluación del donante: "),
                                  RatingBarIndicator(
                                    rating: promedio,
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 20.0,
                                    direction: Axis.horizontal,
                                  ),
                                  const SizedBox(width: 8),
                                  Text("(${promedio.toStringAsFixed(1)})"),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}