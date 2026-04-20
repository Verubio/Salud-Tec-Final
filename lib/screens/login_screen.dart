import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _intentarLogin() {
    if (_formKey.currentState!.validate()) {
      // Aquí irá la conexión a tu API de Python después
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // La "Ardilla Meditando" o Logo que planeamos
              const Icon(Icons.self_improvement, size: 80, color: Color(0xFF2C5F78)),
              const SizedBox(height: 20),
              Text("Bienvenido a Salud-Tec", style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Correo Institucional",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || !value.endsWith('@itslp.tecnm.mx')) {
                    return "Usa tu correo @itslp.tecnm.mx";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _intentarLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF2C5F78),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Ingresar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}