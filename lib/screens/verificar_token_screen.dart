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

  Future<void> _validarToken() async {
    if (_tokenController.text.length < 6) return;

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Cuenta activada! Ya puedes iniciar sesión.")),
        );
        Navigator.pop(context); // Regresa al Login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Token incorrecto o expirado")),
        );
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verificación Institucional")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Ingresa el código de 6 dígitos enviado a tu correo institucional."),
            const SizedBox(height: 20),
            TextField(
              controller: _tokenController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "000000"),
            ),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _validarToken, child: const Text("Verificar Cuenta"))
          ],
        ),
      ),
    );
  }
}