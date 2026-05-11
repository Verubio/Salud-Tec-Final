import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';

class VerificarTokenScreen extends StatefulWidget {
  final int idUsuario;
  const VerificarTokenScreen({super.key, required this.idUsuario});

  @override
  State<VerificarTokenScreen> createState() => _VerificarTokenScreenState();
}

class _VerificarTokenScreenState extends State<VerificarTokenScreen> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;

  // --- PALETA OCEAN BREEZE ---
  final Color _colorFondoCyan = const Color(0xFFE0F7FA);
  final Color _colorFondoMenta = const Color(0xFFF1F8E9);
  final Color _colorAcento = const Color(0xFF4DB6AC);
  final Color _colorTextoPrimario = const Color(0xFF455A64);

  @override
  void dispose() {
    // ✨ EL BOTÓN DE APAGADO DE LA LICUADORA ✨
    _tokenController.dispose();
    super.dispose();
  }

  // ==========================================
  // ⚙️ LÓGICA DE VALIDACIÓN (INTACTA)
  // ==========================================
  Future<void> _validarToken() async {
    if (_tokenController.text.length < 6) {
      _mostrarSnackBar(
        "Ingresa los 6 dígitos completos 🌸",
        Colors.orangeAccent,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/verificar_token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_usuario': widget.idUsuario,
          'token': _tokenController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        _mostrarSnackBar(
          "¡Cuenta activada! Ya puedes iniciar sesión. ✨",
          const Color(0xFF81C784),
        );
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        _mostrarSnackBar(
          "El código es incorrecto o ya expiró 🙈",
          const Color(0xFFEF5350),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarSnackBar(
        "Error de conexión. Revisa tu internet 📡",
        const Color(0xFFFFB6C1),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // ==========================================
  // 🎨 UI ESTÉTICA PREMIUM
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // --- ICONO FLOTANTE ---
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _colorAcento.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mark_email_read_rounded,
                    size: 65,
                    color: _colorAcento,
                  ),
                ),

                const SizedBox(height: 35),

                Text(
                  "Verificación Institucional",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: _colorTextoPrimario,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  "Ingresa el código de 6 dígitos que enviamos a tu correo del tecnológico.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey.shade400,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 45),

                // --- CAJA DE TEXTO DEL CÓDIGO ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: _colorAcento.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    controller: _tokenController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center, // Centramos el texto
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: _colorAcento,
                      letterSpacing:
                          8.0, // Letras separadas para que parezca un código PIN
                    ),
                    decoration: const InputDecoration(
                      counterText: "", // Quitamos el contador de "0/6" de abajo
                      hintText: "000000",
                      hintStyle: TextStyle(
                        color: Colors.black12,
                        letterSpacing: 8.0,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // --- BOTÓN DE VERIFICACIÓN ---
                _isLoading
                    ? CircularProgressIndicator(color: _colorAcento)
                    : ElevatedButton(
                        onPressed: _validarToken,
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
                          "VERIFICAR CUENTA ✨",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
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
}
