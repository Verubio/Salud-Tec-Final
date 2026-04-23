import 'package:flutter/material.dart';
import 'chatbot.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> mensajes = [];

  void enviarMensaje() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      mensajes.add(_controller.text.trim());
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5ED3C6),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔷 HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F9D9A), Color(0xFF5ED3C6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const CircleAvatar(
                    backgroundImage:
                        NetworkImage('https://i.pravatar.cc/150?img=3'),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Psicólogo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 🔷 CONTENIDO
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF6F5),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: _buildChatActivo(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🟢 CHAT ACTIVO
  Widget _buildChatActivo() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: mensajes.length,
            itemBuilder: (context, index) {
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F9D9A),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    mensajes[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),

        /// 🔽 INPUT
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Escribe tu mensaje...",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFF0F9D9A),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: enviarMensaje,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}