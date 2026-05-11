import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';
import 'package:salud_tec_final/screens/verificar_token_screen.dart'; // Lógica de Vianney

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
  bool _obscurePassword = true; // Controla el ojito de Vianney

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
    // =========================================
    // 🛡️ EVITA DOBLE CLICK / DOBLE REQUEST
    // =========================================
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    // Oculta teclado
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${ApiConfig.baseUrl}/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},

        body: jsonEncode({
          'nombre_completo': _nameController.text.trim(),

          // 🔥 Blindaje contra mayúsculas/minúsculas
          'correo': _emailController.text.trim().toLowerCase(),

          'password': _passwordController.text,

          'carrera': _carreraSeleccionada,
        }),
      );

      if (!mounted) return;

      // =========================================
      // ✅ REGISTRO EXITOSO
      // =========================================
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _mostrarMensaje(
          "¡Registro exitoso! Revisa tu correo institucional ✨",
          const Color(0xFFA5D6A7),
        );

        // 🔥 IMPORTANTE:
        // pushReplacement para que NO puedan volver
        // al register con botón atrás
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VerificarTokenScreen(idUsuario: data['id_usuario']),
          ),
        );
      }
      // =========================================
      // ⚠️ ERROR CONTROLADO DEL BACKEND
      // =========================================
      else {
        String mensaje = "No se pudo completar el registro.";

        try {
          final error = jsonDecode(response.body);

          mensaje = error['detail'] ?? mensaje;
        } catch (_) {}

        _mostrarMensaje(mensaje, Colors.redAccent);
      }
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje("Error de conexión con el servidor.", Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // SnackBar estilizado de Fátima
  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D737E),
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const colorFondoAzul = Color(0xFFE3F2FD);
    const colorFondoVerde = Color(0xFFE8F5E9);
    const colorLavanda = Color(0xFFE1BEE7);
    const colorAmarillo = Color(0xFFFFF59D);
    const colorRosaPoquito = Color(0xFFFFD1DC);
    const colorTextoPrimario = Color(0xFF5D737E);
    const colorIconosCampos = Color(0xFF9575CD);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorIconosCampos,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [colorFondoAzul, colorFondoVerde],
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
                  const SizedBox(height: 60),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorAmarillo.withOpacity(0.7),
                          blurRadius: 25,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 65,
                      color: colorAmarillo,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Crea tu cuenta",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorTextoPrimario,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "¡Únete para crear tu espacio seguro! 🌸",
                    style: TextStyle(color: Colors.black45, fontSize: 14),
                  ),
                  const SizedBox(height: 35),

                  _buildSoftTextField(
                    controller: _nameController,
                    label: "Nombre Completo",
                    hint: "Tu nombrecito",
                    icon: Icons.person_rounded,
                    iconColor: colorIconosCampos,
                    validator: (value) =>
                        value!.isEmpty ? "¡No olvides tu nombre!" : null,
                  ),
                  const SizedBox(height: 18),

                  _buildSoftTextField(
                    controller: _emailController,
                    label: "Correo Institucional",
                    hint: "ejemplo@slp.tecnm.mx",
                    icon: Icons.email_rounded,
                    iconColor: colorIconosCampos,
                    isEmail: true,
                    validator: (value) {
                      if (value == null || !value.endsWith('@slp.tecnm.mx')) {
                        return "Usa tu correo del ITSLP porfis";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  _buildSoftDropdown(
                    value: _carreraSeleccionada,
                    label: "Tu Carrera",
                    icon: Icons.school_rounded,
                    iconColor: colorIconosCampos,
                    items: _carreras,
                    onChanged: (val) =>
                        setState(() => _carreraSeleccionada = val),
                  ),
                  const SizedBox(height: 18),

                  // Integración del "Ojito" de Vianney en el diseño de Fátima
                  _buildSoftTextField(
                    controller: _passwordController,
                    label: "Contraseña",
                    hint: "Crea una clave segura",
                    icon: Icons.lock_rounded,
                    iconColor: colorIconosCampos,
                    isPassword: true, // Le decimos al helper que es un password
                    validator: (value) => value!.length < 6
                        ? "Mínimo 6 caracteres para estar seguros 🔒"
                        : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: colorIconosCampos.withOpacity(0.7),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 45),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),

                    child: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              color: colorRosaPoquito,
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,

                            child: ElevatedButton(
                              onPressed: _registrarUsuario,

                              style:
                                  ElevatedButton.styleFrom(
                                    backgroundColor: colorLavanda,
                                    foregroundColor: colorTextoPrimario,
                                    elevation: 5,
                                    shadowColor: colorLavanda.withOpacity(0.5),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    minimumSize: const Size(
                                      double.infinity,
                                      60,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),

                                    enabledMouseCursor:
                                        SystemMouseCursors.click,
                                  ).copyWith(
                                    overlayColor:
                                        WidgetStateProperty.resolveWith<Color?>(
                                          (Set<WidgetState> states) {
                                            if (states.contains(
                                              WidgetState.pressed,
                                            )) {
                                              return colorRosaPoquito
                                                  .withOpacity(0.3);
                                            }
                                            return null;
                                          },
                                        ),
                                  ),

                              child: const Text(
                                "Finalizar Registro ✨",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helpers de UI actualizados (Modificado para aceptar suffixIcon y control de estado) ---

  Widget _buildSoftTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
    bool isPassword = false,
    bool isEmail = false,
    required String? Function(String?) validator,
    Widget? suffixIcon, // <-- AGREGADO para el ojito
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        // Conectado directamente a la variable de estado
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: const TextStyle(color: Color(0xFF5D737E)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black45),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black26),
          prefixIcon: Icon(icon, color: iconColor),
          suffixIcon: suffixIcon, // <-- INYECTADO
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFE1BEE7), width: 1),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildSoftDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFFB0BEC5),
        ),
        style: const TextStyle(color: Color(0xFF5D737E), fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black45),
          prefixIcon: Icon(icon, color: iconColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 12,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFE1BEE7), width: 1),
          ),
        ),
        dropdownColor: Colors.white,
        items: items
            .map(
              (c) => DropdownMenuItem(
                value: c,
                child: Text(
                  c,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF5D737E)),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? "¡Selecciona tu carrera!" : null,
      ),
    );
  }
}
