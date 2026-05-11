import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
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
  bool _obscurePassword = true; // Funcionalidad de Vianney

  // --- Frases motivadoras de tu autoría ---
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

  late String _fraseDelDia;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _fraseDelDia =
        _frasesMotivadoras[random.nextInt(_frasesMotivadoras.length)];
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
        final String? accessToken = data['access_token'];
        final userData = data['user'];

        final String nombreUsuario = userData['nombre_completo'];
        final int idUsuario = userData['id_usuario'];
        final String rolUsuario = userData['rol'];
        final String correoUsuario = _emailController.text
            .trim(); // Necesario para el Drawer
        final bool estaDisponible =
            userData['esta_disponible'] == 1 ||
            userData['esta_disponible'] == true;

        if (!mounted) return;

        _mostrarMensaje("¡Bienvenido, $nombreUsuario!", Colors.green);

        // --- BIFURCACIÓN DE ROLES CON INTEGRACIÓN TOTAL ---
        if (rolUsuario == 'Psicologo') {
          Navigator.pushReplacementNamed(
            context,
            '/psicologo_home',
            arguments: {
              'token': accessToken,
              'id_usuario': idUsuario,
              'nombre': nombreUsuario,
              'rol': rolUsuario,
              'esta_disponible': estaDisponible,
            },
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: {
              'token': accessToken,
              'id_usuario': idUsuario,
              'nombre': nombreUsuario,
              'correo':
                  correoUsuario, // 👈 Clave para extraer el número de control
              'rol': rolUsuario,
            },
          );
        }
      } else if (response.statusCode == 403) {
        if (!mounted) return;
        _mostrarError(
          "Tu cuenta aún no ha sido activada desde el correo institucional.",
          esAdvertencia: true,
        );
      } else {
        if (!mounted) return;
        _mostrarError("Credenciales incorrectas o usuario no encontrado.");
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarError(
        "Error de conexión. Asegúrate de que el servidor esté activo.",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje, {bool esAdvertencia = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: esAdvertencia
            ? Colors.orange
            : const Color(0xFFEF5350),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const colorFondoCyan = Color(0xFFE0F7FA);
    const colorFondoMenta = Color(0xFFF1F8E9);
    const colorBotonPrimario = Color(0xFF2C5F78); // Teal oscuro institucional
    const colorIcono = Color(0xFF4DB6AC);
    const colorTextoPrimario = Color(0xFF455A64);

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
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono en burbuja premium
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorIcono.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      size: 70,
                      color: colorIcono,
                    ),
                  ),
                  const SizedBox(height: 25),

                  Text(
                    "Salud-Tec",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF2C5F78),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Frase motivadora dinámica
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      _fraseDelDia,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF607D8B),
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
                    // Integración del "ojito" en tu widget personalizado
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF90A4AE),
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
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
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/registro_usuario'),
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
    Widget? suffixIcon,
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
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF90A4AE)),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Este campo es requerido";
          if (isEmail && !value.endsWith('@slp.tecnm.mx')) {
            return "Usa tu correo @slp.tecnm.mx";
          }
          return null;
        },
      ),
    );
  }
}
