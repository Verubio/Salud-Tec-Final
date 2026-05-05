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
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> mensajes = [];
  bool _isTyping = false;
  late int idAlumnoActual;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args == null || args['id_usuario'] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return;
    }

    idAlumnoActual = args['id_usuario'];

    if (mensajes.isEmpty) {
      _cargarHistorial();
    }
  }

  // 🔽 SCROLL AUTOMÁTICO
  void _scrollAlFinal() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _isTyping = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chatbot/historial/$idAlumnoActual'),
      );

      if (response.statusCode == 200) {
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

          _scrollAlFinal();
        } else {
          throw Exception("Formato inesperado del servidor");
        }
      } else {
        throw Exception("Error del servidor (${response.statusCode})");
      }
    } catch (e) {
      print("Error cargando historial: $e");

      setState(() {
        mensajes.add({"role": "bot", "text": "No pude cargar tu historial 😕"});
      });
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  Future<void> enviarMensaje() async {
    String texto = _controller.text.trim(); // ✅ limpieza
    if (texto.isEmpty) return;

    setState(() {
      mensajes.add({"role": "user", "text": texto});
      _isTyping = true;
    });

    _controller.clear();
    _scrollAlFinal();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chatbot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"id_usuario": idAlumnoActual, "mensaje": texto}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          String respuestaBot =
              data['reply'] ?? "El servidor respondió, pero algo salió raro 🤔";
          mensajes.add({"role": "bot", "text": respuestaBot});
        });
      } else {
        throw Exception("Error del servidor (${response.statusCode})");
      }
    } catch (e) {
      setState(() {
        mensajes.add({
          "role": "bot",
          "text": "Sin conexión. Tu mensaje no se envió 📡",
        });
      });
    } finally {
      setState(() {
        _isTyping = false;
      });
      _scrollAlFinal();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ChatBot 💬")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // ✅ scroll conectado
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

          // INDICADOR DE "ESCRIBIENDO"
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
                  onPressed: _isTyping
                      ? null
                      : enviarMensaje, // ✅ botón bloqueado
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
