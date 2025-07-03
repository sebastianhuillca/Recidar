import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:reciidar/db_helper.dart';

class RankingUsuariosPage extends StatefulWidget {
  const RankingUsuariosPage({super.key});

  @override
  State<RankingUsuariosPage> createState() => _RankingUsuariosPageState();
}

class _RankingUsuariosPageState extends State<RankingUsuariosPage> {
  List<Map<String, dynamic>> _ranking = [];

  @override
  void initState() {
    super.initState();
    _cargarRanking();
  }

  Future<void> _cargarRanking() async {
    final data = await DBHelper.obtenerRankingEvaluacionAdmin();
    setState(() {
      _ranking = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ranking de Usuarios Evaluados"),
        backgroundColor: Colors.green,
      ),
      body: _ranking.isEmpty
          ? const Center(child: Text("No hay usuarios evaluados aún."))
          : ListView.builder(
        itemCount: _ranking.length,
        itemBuilder: (context, index) {
          final usuario = _ranking[index];
          final nombreCompleto = "${usuario['nombre']} ${usuario['apellido']}";
          final estrellas = usuario['estrellas']?.toDouble() ?? 0.0;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Text("${index + 1}"),
              ),
              title: Text(nombreCompleto),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingBarIndicator(
                    rating: estrellas,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 24.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(height: 4),
                  Text("Puntaje: ${estrellas.toStringAsFixed(1)} estrellas"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
