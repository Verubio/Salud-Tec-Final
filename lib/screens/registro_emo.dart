import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroEmo extends StatefulWidget {
  const RegistroEmo({super.key});

  @override
  State<RegistroEmo> createState() => _RegistroEmoState();
}

class _RegistroEmoState extends State<RegistroEmo> {
  final TextEditingController _detalleController = TextEditingController();
  String _emocionSeleccionada = "Estable";
  String _gifActual = "assets/carita_neutra.gif";
  bool _estaCargando = false;

  // IMPORTANTE: Asegúrate de que esta IP sea la de tu laptop
  final String _urlBackend = "http://192.168.100.164:8000/registro_animo";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RECIBIR ARGUMENTOS DESDE EL HOME
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    if (args != null) {
      _emocionSeleccionada = args['emocion']!;
      _gifActual = args['gif']!;
    }
  }

  Future<void> _guardarRegistro() async {
    if (_detalleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, cuéntame un poco más sobre cómo te sientes.")),
      );
      return;
    }

    setState(() => _estaCargando = true);

    try {
      final response = await http.post(
        Uri.parse(_urlBackend),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_usuario": 2, // En producción, esto vendría del Login
          "emocion": _emocionSeleccionada,
          "detalle": _detalleController.text,
          "puntuacion_riesgo": _calcularRiesgo(_emocionSeleccionada),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text("¡Registro guardado! Gracias por compartir.")),
        );
        Navigator.pop(context); // Regresa al Home
      } else {
        throw Exception("Error del servidor");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("No se pudo conectar con el servidor: $e")),
      );
    } finally {
      setState(() => _estaCargando = false);
    }
  }

  double _calcularRiesgo(String emocion) {
    if (emocion == 'Crisis') return 10.0;
    if (emocion == 'Estresado') return 7.0;
    if (emocion == 'Triste') return 5.0;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Ánimo"), backgroundColor: const Color(0xFF2C5F78), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Text("Tu selección actual:", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 10),
            Image.asset(_gifActual, height: 120),
            Text(_emocionSeleccionada, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C5F78))),
            const SizedBox(height: 30),
            
            TextField(
              controller: _detalleController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "¿Qué está pasando por tu mente?",
                hintText: "Escribe aquí tus pensamientos...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF2C5F78), width: 2)),
              ),
            ),
            
            const SizedBox(height: 30),
            
            _estaCargando 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _guardarRegistro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C5F78),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("GUARDAR EN MI BITÁCORA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
          ],
        ),
      ),
    );
  }
}