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
  bool _obscurePassword = true;


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
        
        // --- MODIFICACIÓN CLAVE: Extraer el token de acceso ---
        final String? accessToken = data['access_token']; 
        
        // Extraemos el objeto 'user'
        final userData = data['user']; 

<<<<<<< HEAD
        final String nombreUsuario = data['user']['nombre_completo'];
        final int idUsuario = data['user']['id_usuario'];
        final String rolUsuario = data['user']['rol'];

        if (!mounted) return;

=======
        final String nombreUsuario = userData['nombre_completo'];
        final int idUsuario = userData['id_usuario'];
        final String rolUsuario = userData['rol']; 
        
        final bool estaDisponible = userData['esta_disponible'] == 1 || userData['esta_disponible'] == true;

        if (!mounted) return;

        _mostrarMensaje("¡Bienvenido, $nombreUsuario!", Colors.green);

        // 2. BIFURCACIÓN LÓGICA (Pasando el token en los arguments)
>>>>>>> 8f4657e58408b97946d19bf15c7231289731e169
        if (rolUsuario == 'Psicologo') {
          Navigator.pushReplacementNamed(
            context,
            '/psicologo_home',
            arguments: {
              'token': accessToken, // <--- MANDAMOS EL TOKEN
              'id_usuario': idUsuario,
<<<<<<< HEAD
              'esta_disponible': data['user']['esta_disponible'] == 1 ||
                  data['user']['esta_disponible'] == true,
            },
          );
        } else {
=======
              'nombre': nombreUsuario,
              'rol': rolUsuario,
              
              'esta_disponible': estaDisponible,
            },
          );
        } else {
          // Rol: Alumno
>>>>>>> 8f4657e58408b97946d19bf15c7231289731e169
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
<<<<<<< HEAD
      _mostrarError(
        "No pudimos conectar con el servidor. Revisa tu conexión.",
      );
=======
      if (!mounted) return;
      _mostrarError("Error de conexión. Asegúrate de que el servidor esté activo.");
>>>>>>> 8f4657e58408b97946d19bf15c7231289731e169
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // Modificamos un poco la función de error para que acepte color naranja en advertencias
  void _mostrarError(String mensaje, {bool esAdvertencia = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
<<<<<<< HEAD
        content: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFEF5350), // Rojo suave para errores
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
=======
        content: Text(mensaje),
        backgroundColor: esAdvertencia ? Colors.orange : Colors.redAccent,
>>>>>>> 8f4657e58408b97946d19bf15c7231289731e169
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
<<<<<<< HEAD
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
=======
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
>>>>>>> 8f4657e58408b97946d19bf15c7231289731e169
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
<<<<<<< HEAD

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
=======
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
>>>>>>> 8f4657e58408b97946d19bf15c7231289731e169
