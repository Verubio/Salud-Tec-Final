import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  // El nombre después de const DEBE ser igual al de la clase
  const ChatScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Emociones')),
      body: const Center(child: Text('Espacio para desarrollar la interfaz')),
    );
  }
}