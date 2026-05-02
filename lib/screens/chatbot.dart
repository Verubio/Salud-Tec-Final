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

  Future<void> enviarMensaje() async {
    String texto = _controller.text;
    if (texto.isEmpty) return;

    setState(() {
      mensajes.add({"role": "user", "text": texto});
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chatbot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id_usuario": 1,
          "mensaje": texto
        }),
      );

      final data = jsonDecode(response.body);

      setState(() {
        // Si todo sale bien, toma el 'reply'. Si el backend mandó un error (ej. 500), toma el 'detail'
        String respuestaBot = data['reply'] ?? "Error del servidor: ${data['detail'] ?? 'Desconocido'}";
        mensajes.add({"role": "bot", "text": respuestaBot});
      });
    } catch (e) {
      // Por si se cae el internet o el servidor de Python está apagado
      setState(() {
        mensajes.add({"role": "bot", "text": "Uy, no pude conectarme al servidor 🔌"});
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
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}