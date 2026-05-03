import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> mensajes = [];
  bool _isTyping = false; // <-- RIGOR: Separamos la UI de los datos
  late int idAlumnoActual; // Variable para guardar el ID

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

    idAlumnoActual = args['id_usuario']; // Adiós al ?? 2

    if (mensajes.isEmpty) {
      _cargarHistorial();
    }
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _isTyping = true;
    }); // Mostramos que está cargando...
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chatbot/historial/$idAlumnoActual'),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        List<dynamic> historialDb = data['mensajes'];
        setState(() {
          mensajes = historialDb
              .map<Map<String, String>>(
                (msg) => {
                  "role": msg['rol'] == 'user' ? 'user' : 'bot',
                  "text": msg['mensaje'].toString(),
                },
              )
              .toList();
        });
      }
    } catch (e) {
      print("Error cargando historial: $e");
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  Future<void> enviarMensaje() async {
    String texto = _controller.text;
    if (texto.isEmpty) return;

    setState(() {
      mensajes.add({"role": "user", "text": texto});
      _isTyping = true;
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chatbot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id_usuario": idAlumnoActual, // ✅ usamos el que ya guardaste
          "mensaje": texto,
        }),
      );

      final data = jsonDecode(response.body);

      setState(() {
        _isTyping = false;
        String respuestaBot =
            data['reply'] ??
            "Error del servidor: ${data['detail'] ?? 'Desconocido'}";
        mensajes.add({"role": "bot", "text": respuestaBot});
      });
    } catch (e) {
      setState(() {
        _isTyping = false;
        mensajes.add({
          "role": "bot",
          "text": "Uy, no pude conectarme al servidor 🔌",
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ChatBot 💬")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: mensajes.length,
              itemBuilder: (context, index) {
                final msg = mensajes[index];
                return Align(
                  alignment: msg["role"] == "user"
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: msg["role"] == "user"
                          ? Colors.blue[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg["text"]!),
                  ),
                );
              },
            ),
          ),

          // El Gatekeeper Visual
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "NexusBot está pensando...",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ... (aquí sigue tu Padding con el Row del TextField)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Escribe un mensaje...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: enviarMensaje,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
