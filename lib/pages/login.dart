import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sah/pages/administrador.dart';
import 'package:sah/pages/medico.dart';
import 'package:sah/pages/recepcionista.dart';
import 'package:sah/pages/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RoleSelectionPage(),
    );
  }
}

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? selectedRole;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _loginUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingrese email y contraseña')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener el usuario')),
        );
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Usuario no encontrado en la base de datos')),
        );
        return;
      }

      String userRole = userDoc['rol'];

      if (userRole != selectedRole) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tienes acceso a esta sección')),
        );
        return;
      }

      if (selectedRole == 'Medico') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainPageMedico()));
      } else if (selectedRole == 'Recepcionista') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const RecepcionistaPage()));
      } else if (selectedRole == 'Administrador') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const AdministradorPage()));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido a SAH'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selectedRole == null) ...[
                  const Text(
                    'Seleccione su rol para iniciar sesión:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => setState(() => selectedRole = 'Medico'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      backgroundColor: const Color(0xFF00FF00),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Medico'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => selectedRole = 'Recepcionista'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      backgroundColor: Colors.grey,
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Recepcionista'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => selectedRole = 'Administrador'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      backgroundColor: Colors.red,
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Administrador'),
                  ),
                ] else ...[
                  Text(
                    'Login como $selectedRole',
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario (Email)',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontSize: 20),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _loginUser,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            textStyle: const TextStyle(fontSize: 22),
                          ),
                          child: const Text('Iniciar Sesión'),
                        ),
                  TextButton(
                    onPressed: () => setState(() => selectedRole = null),
                    child: const Text(
                      'Volver',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterPage()));
                    },
                    child: const Text(
                      '¿Aún no te has registrado? ¡Regístrate aquí!',
                      style: TextStyle(color: Colors.blue, fontSize: 18),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
