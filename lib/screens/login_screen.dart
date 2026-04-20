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
  final _passwordController = TextEditingController(); // <-- NUEVO: Controlador para contraseña
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Buena práctica: liberar los controladores cuando el widget se destruye
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _conectarConServidor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('http://192.168.100.164:8000/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // <-- NUEVO: Enviamos el correo Y la contraseña al backend
        body: jsonEncode({
          'correo': _emailController.text.trim(),
          'password': _passwordController.text.trim(), 
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String nombreUsuario = data['user']['nombre_completo'];

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home', arguments: nombreUsuario);
      } else {
        _mostrarError("Credenciales incorrectas o usuario no encontrado.");
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
      body: Center( // Agregué un Center para que no se pegue arriba si el teclado se oculta
        child: SingleChildScrollView( // <-- NUEVO: Permite hacer scroll si el teclado tapa los campos
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
                    hintText: "ejemplo@slp.tecnm.mx"
                  ),
                  validator: (value) {
                    if (value == null || !value.endsWith('@slp.tecnm.mx')) {
                      return "Usa tu correo @slp.tecnm.mx";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // <-- NUEVO: Campo de Contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Oculta el texto
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor ingresa tu contraseña";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
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
                const SizedBox(height: 15),
                // <-- NUEVO: Botón para ir a registrarse
               TextButton(
  onPressed: () {
    // Muestra un mensaje emergente en lugar de cambiar de pantalla
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("La pantalla de registro estará disponible pronto."),
        backgroundColor: Colors.blueGrey,
        duration: Duration(seconds: 2),
      ),
    );
  },
  child: const Text(
    "¿No tienes cuenta? Regístrate aquí",
    style: TextStyle(color: Color(0xFF2C5F78)),
  ),
)
              ],
            ),
          ),
        ),
      ),
    );
  }
}