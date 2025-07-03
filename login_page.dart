import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reciidar/pantalla_usuario.dart';
import 'package:reciidar/admin_page.dart';
import 'package:reciidar/registro_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _credencialesInvalidas = false;
  bool _cargando = false;

  Future<void> _iniciarSesion() async {
    setState(() {
      _cargando = true;
      _credencialesInvalidas = false;
    });

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _correoController.text.trim(),
        password: _claveController.text,
      );

      final email = cred.user?.email ?? '';

      // Obtener datos del usuario desde Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('correo', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();
        final rol = userData['rol'];
        final nombreUsuario = userData['usuario'];

        if (rol == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PantallaAdmin()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PantallaUsuario(nombreUsuario: nombreUsuario),
            ),
          );
        }
      } else {
        setState(() => _credencialesInvalidas = true);
      }
    } on FirebaseAuthException catch (_) {
      setState(() => _credencialesInvalidas = true);
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe8f5e9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Column(
          children: [
            const Icon(Icons.lock, size: 100, color: Colors.green),
            const SizedBox(height: 10),
            const Text(
              'Recidar',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _campo(_correoController, 'Correo'),
                  _campo(_claveController, 'Contraseña', oculto: true),
                  if (_credencialesInvalidas)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Correo o contraseña incorrectos',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: _cargando
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        _iniciarSesion();
                      }
                    },
                    child: _cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Iniciar sesión'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegistroPage()),
                      );
                    },
                    child: const Text('¿No tienes cuenta? Regístrate aquí'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(TextEditingController controller, String label, {bool oculto = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: oculto,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
      ),
    );
  }
}