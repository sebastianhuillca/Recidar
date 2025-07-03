import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';
import 'registro_page.dart';
import 'pantalla_usuario.dart';
import 'admin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté listo antes de inicializar Firebase
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const ReciidarApp());
}

class ReciidarApp extends StatelessWidget {
  const ReciidarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reciidar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFe8f5e9),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/registro': (_) => const RegistroPage(),
        '/admin': (_) => const PantallaAdmin(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/usuario') {
          final usuario = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => PantallaUsuario(nombreUsuario: usuario),
          );
        }
        return null;
      },
    );
  }
}