import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Estado para el indicador de carga

  // FUNCIÓN CRÍTICA: Conexión con FastAPI
  Future<void> _conectarConServidor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // IMPORTANTE: 10.0.2.2 es la IP para el emulador de Android. 
    // Si usas un celular físico, cambia esto por la IP de tu PC (ej: 192.168.1.X)
    final url = Uri.parse('http://192.168.100.164:8000/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': _emailController.text.trim()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String nombreUsuario = data['user']['nombre_completo'];

        if (!mounted) return;
        // Navegamos al Dashboard pasando el nombre como argumento
        Navigator.pushReplacementNamed(context, '/home', arguments: nombreUsuario);
      } else {
        _mostrarError("Usuario no encontrado en el sistema del Tec.");
      }
    } catch (e) {
      _mostrarError("No se pudo conectar con el servidor. Revisa que FastAPI esté corriendo.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
    );
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
              const Icon(Icons.self_improvement, size: 80, color: Color(0xFF2C5F78)),
              const SizedBox(height: 20),
              Text(
                "Bienvenido a Salud-Tec", 
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF2C5F78),
                  fontWeight: FontWeight.bold
                )
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo Institucional",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  hintText: "ejemplo@itslp.tecnm.mx"
                ),
                validator: (value) {
                  if (value == null || !value.endsWith('@slp.tecnm.mx')) {
                    return "Usa tu correo @itslp.tecnm.mx";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Botón condicional: Si está cargando, muestra un círculo de progreso
              _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _conectarConServidor,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: const Color(0xFF2C5F78),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: const Text("Ingresar", style: TextStyle(fontSize: 18)),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}