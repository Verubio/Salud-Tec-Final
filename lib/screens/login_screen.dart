import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController =
      TextEditingController(); // <-- NUEVO: Controlador para contraseña
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;


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

    final url = Uri.parse('${ApiConfig.baseUrl}/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // --- MODIFICACIÓN CLAVE: Extraer el token de acceso ---
        final String? accessToken = data['access_token']; 
        
        // Extraemos el objeto 'user'
        final userData = data['user']; 

        final String nombreUsuario = userData['nombre_completo'];
        final int idUsuario = userData['id_usuario'];
        final String rolUsuario = userData['rol']; 
        
        final bool estaDisponible = userData['esta_disponible'] == 1 || userData['esta_disponible'] == true;

        if (!mounted) return;

        _mostrarMensaje("¡Bienvenido, $nombreUsuario!", Colors.green);

        // 2. BIFURCACIÓN LÓGICA (Pasando el token en los arguments)
        if (rolUsuario == 'Psicologo') {
          Navigator.pushReplacementNamed(
            context,
            '/psicologo_home',
            arguments: {
              'token': accessToken, // <--- MANDAMOS EL TOKEN
              'id_usuario': idUsuario,
              'nombre': nombreUsuario,
              'rol': rolUsuario,
              
              'esta_disponible': estaDisponible,
            },
          );
        } else {
          // Rol: Alumno
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: {
              'token': accessToken, // <--- MANDAMOS EL TOKEN
              'id_usuario': idUsuario, 
              'nombre': nombreUsuario,
              'rol': rolUsuario,
            },
          );
        }
      } 
      else if (response.statusCode == 403) {
        if (!mounted) return;
        _mostrarError(
          "Tu cuenta aún no ha sido activada desde el correo institucional.",
          esAdvertencia: true,
        );
      } 
      else {
        if (!mounted) return;
        _mostrarError("Credenciales incorrectas o usuario no encontrado.");
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarError("Error de conexión. Asegúrate de que el servidor esté activo.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // Modificamos un poco la función de error para que acepte color naranja en advertencias
  void _mostrarError(String mensaje, {bool esAdvertencia = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esAdvertencia ? Colors.orange : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Agregué un Center para que no se pegue arriba si el teclado se oculta
        child: SingleChildScrollView(
          // <-- NUEVO: Permite hacer scroll si el teclado tapa los campos
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.self_improvement,
                  size: 80,
                  color: Color(0xFF2C5F78),
                ),
                const SizedBox(height: 20),
                Text(
                  "Bienvenido a Salud-Tec",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF2C5F78),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Correo Institucional",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    hintText: "ejemplo@slp.tecnm.mx",
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
                  obscureText: _obscurePassword, // Controla la visibilidad
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    // BOTÓN DEL OJITO
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF2C5F78),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Ingresa tu contraseña" : null,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Ingresar",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                const SizedBox(height: 15),
                // <-- NUEVO: Botón para ir a registrarse
                TextButton(
                  onPressed: () {
                    // Esto buscará la ruta que definiremos en main.dart
                    Navigator.pushNamed(context, '/registro_usuario');
                  },
                  child: const Text(
                    "¿No tienes cuenta? Regístrate aquí",
                    style: TextStyle(
                      color: Color(0xFF2C5F78),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // Esta es la función que te falta para que el error desaparezca
  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
