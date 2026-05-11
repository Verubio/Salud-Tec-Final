import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';

class RegistroEmo extends StatefulWidget {
  const RegistroEmo({super.key});

  @override
  State<RegistroEmo> createState() => _RegistroEmoState();
}

class _RegistroEmoState extends State<RegistroEmo>
    with SingleTickerProviderStateMixin {
  // <-- Añadido para la animación
  final TextEditingController _detalleController = TextEditingController();
  String _emocionSeleccionada = "Estable";
  String _gifActual = "assets/carita_neutra.gif";
  int _userIdActual = 2; // Valor de respaldo
  bool _estaCargando = false;

  final String _urlBackend = "${ApiConfig.baseUrl}/registro_animo";

  // --- VARIABLES DE ANIMACIÓN ---
  late AnimationController _animController;
  late Animation<double> _breatheAnimation;

  // --- PALETA OCEAN BREEZE ---
  final Color _colorFondoCyan = const Color(0xFFE0F7FA);
  final Color _colorFondoMenta = const Color(0xFFF1F8E9);
  final Color _colorAcento = const Color(0xFF4DB6AC);
  final Color _colorTextoPrimario = const Color(0xFF455A64);

  @override
  void initState() {
    super.initState();
    // Animación de respiración suave para el GIF
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _detalleController
        .dispose(); // <-- ¡Regalito extra para no saturar memoria!
    super.dispose();
  }

  // ==========================================
  // ⚙️ LÓGICA 100% INTACTA
  // ==========================================
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // VALIDACIÓN ESTRICTA DE SEGURIDAD
    if (args == null || args['id_usuario'] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return;
    }

    setState(() {
      _emocionSeleccionada = args['emocion']!;
      _gifActual = args['gif']!;
      _userIdActual = args['id_usuario'];
    });
  }

  Future<void> _guardarRegistro() async {
    String detalleFinal = _detalleController.text.trim();
    if (detalleFinal.isEmpty) {
      detalleFinal = "No agregaste una nota en este registro.";
    }

    setState(() => _estaCargando = true);

    try {
      final response = await http.post(
        Uri.parse(_urlBackend),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_usuario": _userIdActual,
          "emocion": _emocionSeleccionada,
          "detalle": detalleFinal,
          "puntuacion_riesgo": _calcularRiesgo(_emocionSeleccionada),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF81C784), // Verde pastel
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            behavior: SnackBarBehavior.floating,
            content: const Text(
              "¡Registro guardado! Tu historial se ha actualizado. 🌸",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF5350), // Rojo suave
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          behavior: SnackBarBehavior.floating,
          content: Text(
            "No se pudo conectar con el servidor: $e",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  double _calcularRiesgo(String emocion) {
    if (emocion == 'Crisis') return 10.0;
    if (emocion == 'Estresado') return 7.0;
    return 1.0;
  }

  // ==========================================
  // 🎨 UI ESTÉTICA PREMIUM
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Registrar Ánimo",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: _colorAcento,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _colorAcento),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_colorFondoCyan, _colorFondoMenta],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Tu selección actual ✨",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),

                // --- GIF ANIMADO CON RESPIRACIÓN ---
                ScaleTransition(
                  scale: _breatheAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _colorAcento.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(_gifActual, height: 130),
                  ),
                ),

                const SizedBox(height: 25),
                Text(
                  _emocionSeleccionada,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _colorTextoPrimario,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // --- CAJA DE TEXTO TIPO BITÁCORA ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _detalleController,
                    maxLines: 5,
                    style: TextStyle(
                      color: _colorTextoPrimario,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: "¿Qué está pasando por tu mente?",
                      labelStyle: const TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w600,
                      ),
                      hintText:
                          "Escribe aquí tus pensamientos. Este es un espacio seguro para ti...",
                      hintStyle: const TextStyle(color: Colors.black26),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: _colorAcento.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // --- BOTÓN DE GUARDADO ---
                _estaCargando
                    ? CircularProgressIndicator(color: _colorAcento)
                    : ElevatedButton(
                        onPressed: _guardarRegistro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colorAcento,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 60),
                          elevation: 4,
                          shadowColor: _colorAcento.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "GUARDAR EN MI BITÁCORA ✨",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
