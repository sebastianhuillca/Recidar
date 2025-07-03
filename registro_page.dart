import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reciidar/db_helper.dart';
import 'package:reciidar/login_page.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();
  final _telefonoController = TextEditingController();

  bool _aceptaTerminos = false;
  String? _errorMensaje;

  Future<void> _registrar() async {
    final usuario = _usuarioController.text.trim();
    final existe = await DBHelper.existeUsuario(usuario);

    if (existe) {
      setState(() {
        _errorMensaje = 'El nombre de usuario ya está en uso';
      });
      return;
    }

    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final correo = _correoController.text.trim();
    final clave = _claveController.text.trim();
    final telefono = _telefonoController.text.trim();

    try {
      // ✅ Crear cuenta en Firebase Auth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correo,
        password: clave,
      );

      // ✅ Guardar en SQLite
      await DBHelper.insertarUsuarioConDatos(
        nombre: nombre,
        apellido: apellido,
        usuario: usuario,
        correo: correo,
        clave: clave,
        telefono: telefono,
      );

      // ✅ Guardar en Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(usuario).set({
        'nombre': nombre,
        'apellido': apellido,
        'usuario': usuario,
        'correo': correo,
        'telefono': telefono,
        'rol': correo == 'sebastian_huillca38@hotmail.com' ? 'admin' : 'usuario',
      });

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          _errorMensaje = 'Ese correo ya está registrado en otra cuenta.';
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          _errorMensaje = 'El correo ingresado no es válido.';
        });
      } else if (e.code == 'weak-password') {
        setState(() {
          _errorMensaje = 'La contraseña es muy débil (usa al menos 6 caracteres).';
        });
      } else {
        setState(() {
          _errorMensaje = 'Error al registrar usuario: ${e.message}';
        });
      }
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
                  _campo(_nombreController, 'Nombre'),
                  _campo(_apellidoController, 'Apellido'),
                  _campo(_usuarioController, 'Nombre de usuario'),
                  _campo(_correoController, 'Correo electrónico'),
                  _campo(_claveController, 'Contraseña', oculto: true),
                  _campo(_telefonoController, 'Teléfono'),
                  Row(
                    children: [
                      Checkbox(
                        value: _aceptaTerminos,
                        onChanged: (value) => setState(() => _aceptaTerminos = value!),
                      ),
                      const Expanded(
                        child: Text('Acepto los términos y políticas de privacidad'),
                      ),
                    ],
                  ),
                  if (!_aceptaTerminos)
                    const Text('Debes aceptar los términos para continuar',
                        style: TextStyle(color: Colors.red)),
                  if (_errorMensaje != null)
                    Text(_errorMensaje!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () {
                      setState(() => _errorMensaje = null);
                      if (_formKey.currentState!.validate() && _aceptaTerminos) {
                        _registrar();
                      }
                    },
                    child: const Text('Registrarse'),
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