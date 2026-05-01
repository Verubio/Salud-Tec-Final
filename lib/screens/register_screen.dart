import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _carreraSeleccionada;
  bool _isLoading = false;

  // Lista de carreras según el catálogo del ITSLP
  final List<String> _carreras = [
    'Ing. Sistemas Computacionales',
    'Ing. Informática',
    'Ing. Industrial',
    'Ing. Mecatrónica',
    'Ing. Gestión Empresarial',
    'Lic. Administración',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre_completo': _nameController.text.trim(),
          'correo': _emailController.text.trim(),
          'password': _passwordController.text,
          'carrera': _carreraSeleccionada,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        _mostrarMensaje("¡Registro exitoso! Ya puedes iniciar sesión.", Colors.green);
        Navigator.pop(context); // Regresa al Login
      } else {
        final error = jsonDecode(response.body);
        _mostrarMensaje(error['detail'] ?? "Error al registrar.", Colors.redAccent);
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión. Revisa el servidor.", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Cuenta"),
        backgroundColor: const Color(0xFF2C5F78),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.person_add_alt_1, size: 70, color: Color(0xFF2C5F78)),
              const SizedBox(height: 20),
              
              // Campo: Nombre Completo
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre Completo",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Ingresa tu nombre" : null,
              ),
              const SizedBox(height: 15),

              // Campo: Correo Institucional
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo @slp.tecnm.mx",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || !value.endsWith('@slp.tecnm.mx')) {
                    return "Debe ser correo institucional";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Dropdown: Carrera
              DropdownButtonFormField<String>(
                value: _carreraSeleccionada,
                decoration: const InputDecoration(
                  labelText: "Carrera",
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                items: _carreras.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _carreraSeleccionada = val),
                validator: (val) => val == null ? "Selecciona tu carrera" : null,
              ),
              const SizedBox(height: 15),

              // Campo: Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.length < 6 ? "Mínimo 6 caracteres" : null,
              ),
              const SizedBox(height: 30),

              _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _registrarUsuario,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: const Color(0xFF2C5F78),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: const Text("Finalizar Registro", style: TextStyle(fontSize: 16)),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}