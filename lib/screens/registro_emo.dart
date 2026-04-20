import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroEmo extends StatefulWidget {
  const RegistroEmo({super.key});

  @override
  State<RegistroEmo> createState() => _RegistroEmoState();
}

class _RegistroEmoState extends State<RegistroEmo> {
  String? _emocionSeleccionada;
  final _detalleController = TextEditingController();
  bool _isSaving = false;

  final List<Map<String, dynamic>> _emociones = [
    {'label': 'Feliz', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.green},
    {'label': 'Estable', 'icon': Icons.sentiment_satisfied, 'color': Colors.blue},
    {'label': 'Estresado', 'icon': Icons.sentiment_neutral, 'color': Colors.orange},
    {'label': 'Triste', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.indigo},
    {'label': 'Crisis', 'icon': Icons.warning_amber_rounded, 'color': Colors.red},
  ];

  Future<void> _guardarRegistro() async {
    if (_emocionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Por favor selecciona una emoción")));
      return;
    }

    setState(() => _isSaving = true);

    // RECUERDA: Usa tu IP 192.168.100.164
    final url = Uri.parse('http://192.168.100.164:8000/registro_animo');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_usuario': 1, // Por ahora estático, luego lo jalamos del login
          'emocion': _emocionSeleccionada,
          'detalle': _detalleController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context); // Regresa al home
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registro guardado con éxito")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al conectar con el servidor")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("¿Cómo va tu día?"), backgroundColor: const Color(0xFF2C5F78), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Selecciona la emoción que más te represente ahora:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 15,
              children: _emociones.map((e) => ChoiceChip(
                label: Text(e['label']),
                selected: _emocionSeleccionada == e['label'],
                onSelected: (val) => setState(() => _emocionSeleccionada = val ? e['label'] : null),
                avatar: Icon(e['icon'], color: _emocionSeleccionada == e['label'] ? Colors.white : e['color']),
              )).toList(),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _detalleController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "¿Quieres contarme más sobre esto? (Opcional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            _isSaving 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _guardarRegistro,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: const Color(0xFF84A98C), foregroundColor: Colors.white),
                  child: const Text("Guardar Registro"),
                ),
          ],
        ),
      ),
    );
  }
}