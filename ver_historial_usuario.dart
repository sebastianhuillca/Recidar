import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reciidar/db_helper.dart';
import 'package:intl/intl.dart';

class VerHistorialUsuario extends StatefulWidget {
  final String nombreUsuario;

  const VerHistorialUsuario({super.key, required this.nombreUsuario});

  @override
  State<VerHistorialUsuario> createState() => _VerHistorialUsuarioState();
}

class _VerHistorialUsuarioState extends State<VerHistorialUsuario> {
  List<Map<String, dynamic>> _donaciones = [];
  int _descuentoActual = 0;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final historial = await DBHelper.obtenerDonacionesPorUsuario(widget.nombreUsuario);
    setState(() {
      _donaciones = historial;
    });

    final recibidas = historial.where((d) => d['estado'] == 'Recibida').length;

    final prefs = await SharedPreferences.getInstance();
    final keyUltimas = 'ultima_cantidad_${widget.nombreUsuario}';
    final keyDescuento = 'descuento_actual_${widget.nombreUsuario}';

    int ultimaCantidad = prefs.getInt(keyUltimas) ?? 0;
    int descuentoActual = prefs.getInt(keyDescuento) ?? 0;

    final nuevasDonaciones = recibidas - ultimaCantidad;

    if (nuevasDonaciones >= 5) {
      int gruposDeCinco = nuevasDonaciones ~/ 5;
      descuentoActual += gruposDeCinco * 5;

      if (descuentoActual > 15) {
        descuentoActual = 0;
        await prefs.setInt(keyUltimas, 0);
        await prefs.setInt(keyDescuento, 0);
      } else {
        await prefs.setInt(keyUltimas, recibidas);
        await prefs.setInt(keyDescuento, descuentoActual);

        if (gruposDeCinco > 0 && descuentoActual != 0) {
          Future.delayed(Duration.zero, () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("🎉 ¡Felicidades!"),
                content: Text(
                  "Has alcanzado $recibidas donaciones recibidas.\n¡Obtienes un $descuentoActual% de descuento en nuestro catálogo!",
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final yaEvaluado = await DBHelper.usuarioYaEvaluado(widget.nombreUsuario);
                      if (!yaEvaluado) {
                        _mostrarEncuestaEstrellas();
                      }
                    },
                    child: const Text("Continuar"),
                  ),
                ],
              ),
            );
          });
        }
      }
    }

    setState(() {
      _descuentoActual = descuentoActual;
    });
  }

  void _mostrarEncuestaEstrellas() {
    int estrellasSeleccionadas = 5;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("⭐ Evalúa tu experiencia"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("¿Qué tan satisfecho estás con la atención recibida?"),
            const SizedBox(height: 10),
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < estrellasSeleccionadas ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          estrellasSeleccionadas = index + 1;
                        });
                      },
                    );
                  }),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await DBHelper.insertarEvaluacion(widget.nombreUsuario, estrellasSeleccionadas);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Gracias por tu evaluación.")),
              );
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(String fecha) {
    try {
      final DateTime fechaDateTime = DateTime.parse(fecha);
      return DateFormat("d 'de' MMMM 'de' y", 'es_ES').format(fechaDateTime);
    } catch (_) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Donaciones"),
        backgroundColor: Colors.green,
      ),
      body: _donaciones.isEmpty
          ? const Center(child: Text("No hay donaciones registradas."))
          : ListView.builder(
        itemCount: _donaciones.length + 1,
        itemBuilder: (context, index) {
          if (index == _donaciones.length) {
            // Último item: mostrar descuento actual
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.discount, color: Colors.green),
                    const SizedBox(width: 10),
                    Text(
                      "Descuento actual: $_descuentoActual%",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final donacion = _donaciones[index];
          final String? imagenPath = donacion['foto'];
          final String estado = donacion['estado'] ?? 'Pendiente';
          final String? fechaRecojo = donacion['fechaRecojo'];

          Color estadoColor;
          if (estado == 'Aprobado') {
            estadoColor = Colors.green;
          } else if (estado == 'Denegado') {
            estadoColor = Colors.red;
          } else if (estado == 'Recibida') {
            estadoColor = Colors.blue;
          } else {
            estadoColor = Colors.orange;
          }

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
                        donacion['nombreProducto'] ?? '',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text("Estado: "),
                          Text(
                            estado,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: estadoColor,
                            ),
                          ),
                        ],
                      ),
                      Text("Descripción: ${donacion['descripcion'] ?? ''}"),
                      Text("Ubicación: ${donacion['ubicacion'] ?? ''}"),
                      if (fechaRecojo != null && fechaRecojo.trim().isNotEmpty)
                        Text("Fecha: ${_formatearFecha(fechaRecojo)}"),
                      const SizedBox(height: 8),
                      if (estado == 'Aprobado')
                        const Text(
                          "Gracias por tu donación, ya ha sido aprobada. Te visitaremos pronto.",
                          style: TextStyle(color: Colors.green),
                        ),
                      if (estado == 'Recibida')
                        const Text(
                          "Donación recibida. Muchas gracias por tu aporte.",
                          style: TextStyle(color: Colors.blue),
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