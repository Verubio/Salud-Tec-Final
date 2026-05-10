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
        _mostrarMensaje(
          "¡Yei! Registro exitoso ✨ Ya puedes iniciar sesión.",
          const Color(0xFFA5D6A7), // Verde pastel para éxito
        );
        Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body);
        _mostrarMensaje(
          error['detail'] ?? "Ups, hubo un error al registrar 🙈",
          const Color(0xFFFFB6C1), // Rosa pastel para error (aquí queda bajito)
        );
      }
    } catch (e) {
      _mostrarMensaje(
        "Error de conexión. ¿El servidor está dormidito? 💤",
        const Color(0xFFFFB6C1),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D737E))),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- NUEVA PALETA DE COLORES ACTUALIZADA owo ---
    const colorFondoAzul = Color(0xFFE3F2FD);   // Azul cielo muy claro
    const colorFondoVerde = Color(0xFFE8F5E9);  // Verde menta muy claro
    const colorLavanda = Color(0xFFE1BEE7);      // Lavanda pastel (Principal)
    const colorAmarillo = Color(0xFFFFF59D);     // Amarillo pastel (Acento icono)
    const colorRosaPoquito = Color(0xFFFFD1DC);  // Rosa pastel (Solo para carga)
    const colorTextoPrimario = Color(0xFF5D737E); // Gris azulado para textos
    const colorIconosCampos = Color(0xFF9575CD);  // Lavanda un poco más fuerte para iconos

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          // Icono de flecha ahora en Lavanda fuerte
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: colorIconosCampos),
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
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60), // Un poquito más de espacio arriba

                  // --- Icono Principal: Amarillo con resplandor Amarillo ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorAmarillo.withOpacity(0.7), // Resplandor amarillo owo
                          blurRadius: 25,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 65, // Un pelín más grande
                      color: colorAmarillo, // Icono Amarillo
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

                  // --- Campos de texto usando acentos Lavanda ---
                  _buildSoftTextField(
                    controller: _nameController,
                    label: "Nombre Completo",
                    hint: "Tu nombrecito",
                    icon: Icons.person_rounded,
                    iconColor: colorIconosCampos,
                    validator: (value) => value!.isEmpty ? "¡No olvides tu nombre!" : null,
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
                    onChanged: (val) => setState(() => _carreraSeleccionada = val),
                  ),
                  const SizedBox(height: 18),

                  _buildSoftTextField(
                    controller: _passwordController,
                    label: "Contraseña",
                    hint: "Crea una clave segura",
                    icon: Icons.lock_rounded,
                    iconColor: colorIconosCampos,
                    isPassword: true,
                    validator: (value) => value!.length < 6 ? "Mínimo 6 caracteres para estar seguros 🔒" : null,
                  ),
                  const SizedBox(height: 45),

                  // --- Botón de Registro: Ahora es Lavanda ---
                  _isLoading
                      ? const CircularProgressIndicator(color: colorRosaPoquito) // Rosa solo aquí
                      : ElevatedButton(
                          onPressed: _registrarUsuario,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorLavanda, // Fondo Lavanda owo
                            foregroundColor: colorTextoPrimario, // Texto gris suave
                            elevation: 5,
                            shadowColor: colorLavanda.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 18), // Más altito
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            // Un toque rosa muy sutil al presionar (overlay)
                            enabledMouseCursor: SystemMouseCursors.click,
                          ).copyWith(
                            overlayColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return colorRosaPoquito.withOpacity(0.3);
                                }
                                return null;
                              },
                            ),
                          ),
                          child: const Text(
                            "Finalizar Registro ✨",
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, letterSpacing: 1),
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

  // --- Helpers de UI actualizados con los nuevos colores ---

  Widget _buildSoftTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor, // Nuevo parámetro
    bool isPassword = false,
    bool isEmail = false,
    required String? Function(String?) validator,
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
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: const TextStyle(color: Color(0xFF5D737E)), // Color de texto al escribir
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black45),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black26),
          prefixIcon: Icon(icon, color: iconColor), // Icono Lavanda fuerte
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          // Borde sutil cuando el campo está seleccionado
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFE1BEE7), width: 1), // Borde Lavanda sutil
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
    required Color iconColor, // Nuevo parámetro
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
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFB0BEC5)),
        style: const TextStyle(color: Color(0xFF5D737E), fontSize: 16), // Estilo del texto seleccionado
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black45),
          prefixIcon: Icon(icon, color: iconColor), // Icono Lavanda fuerte
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFE1BEE7), width: 1), // Borde Lavanda sutil
          ),
        ),
        // Color de fondo del menú desplegable
        dropdownColor: Colors.white,
        items: items.map((c) => DropdownMenuItem(
          value: c, 
          child: Text(c, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF5D737E)))
        )).toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? "¡Selecciona tu carrera!" : null,
      ),
    );
  }
}