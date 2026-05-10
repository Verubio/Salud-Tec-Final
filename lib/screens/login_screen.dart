import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math'; // <-- NUEVO: Para poder elegir frases al azar
import 'package:salud_tec_final/api_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- NUEVO: Lista de frases motivadoras ---
  final List<String> _frasesMotivadoras = [
    "Un paso a la vez. ¡Tú puedes con esto!",
    "Respira profundo, hoy será un buen día. 🌱",
    "Tu bienestar mental es tu mayor prioridad.",
    "Incluso los pequeños avances son grandes logros.",
    "No estás solo en este camino, hablemos.",
    "Cuidar de tu mente es cuidar de tu futuro escolar. 📚",
    "Está bien pedir ayuda. ¡Aquí estamos para ti!",
    "Cree en ti, tu potencial es infinito. ✨",
  ];
  
  late String _fraseDelDia; // Guardará la frase elegida al azar

  @override
  void initState() {
    super.initState();
    // Elegimos una frase al azar justo cuando la pantalla carga
    final random = Random();
    _fraseDelDia = _frasesMotivadoras[random.nextInt(_frasesMotivadoras.length)];
  }

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

        final String nombreUsuario = data['user']['nombre_completo'];
        final int idUsuario = data['user']['id_usuario'];
        final String rolUsuario = data['user']['rol'];

        if (!mounted) return;

        if (rolUsuario == 'Psicologo') {
          Navigator.pushReplacementNamed(
            context,
            '/psicologo_home',
            arguments: {
              'nombre': nombreUsuario,
              'id_usuario': idUsuario,
              'esta_disponible': data['user']['esta_disponible'] == 1 ||
                  data['user']['esta_disponible'] == true,
            },
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: {'nombre': nombreUsuario, 'id_usuario': idUsuario},
          );
        }
      } else {
        _mostrarError("Credenciales incorrectas o usuario no encontrado.");
      }
    } catch (e) {
      _mostrarError(
        "No pudimos conectar con el servidor. Revisa tu conexión.",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFEF5350), // Rojo suave para errores
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- NUEVA PALETA NEUTRAL / BIENESTAR ---
    const colorFondoCyan = Color(0xFFE0F7FA); // Cyan ultra suave
    const colorFondoMenta = Color(0xFFF1F8E9); // Verde menta ultra suave
    const colorBotonPrimario = Color(0xFF80CBC4); // Teal claro (Menta)
    const colorIcono = Color(0xFF4DB6AC); // Teal un poco más fuerte
    const colorTextoPrimario = Color(0xFF455A64); // Gris azulado oscuro

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorFondoCyan, colorFondoMenta],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono en burbuja
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorBotonPrimario.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.spa_rounded, // Icono de bienestar/hoja de loto
                      size: 70,
                      color: colorIcono,
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Título principal
                  Text(
                    "Salud-Tec",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colorTextoPrimario,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                  ),
                  const SizedBox(height: 10),
                  
                  // --- FRASE MOTIVADORA ALEATORIA ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      _fraseDelDia,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF607D8B), // Gris medio
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),

                  _buildSoftTextField(
                    controller: _emailController,
                    label: "Correo Institucional",
                    hint: "ejemplo@slp.tecnm.mx",
                    icon: Icons.email_outlined,
                    isEmail: true,
                  ),
                  const SizedBox(height: 20),

                  _buildSoftTextField(
                    controller: _passwordController,
                    label: "Contraseña",
                    hint: "••••••••",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 35),

                  _isLoading
                      ? const CircularProgressIndicator(color: colorIcono)
                      : ElevatedButton(
                          onPressed: _conectarConServidor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorBotonPrimario,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shadowColor: colorBotonPrimario.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Iniciar Sesión",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registro_usuario');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: colorTextoPrimario,
                    ),
                    child: const Text(
                      "¿Eres nuevo? Regístrate aquí",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSoftTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isEmail = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF90A4AE)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Este campo es requerido";
          }
          if (isEmail && !value.endsWith('@slp.tecnm.mx')) {
            return "Usa tu correo @slp.tecnm.mx";
          }
          return null;
        },
      ),
    );
  }
}