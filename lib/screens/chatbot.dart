import 'package:flutter/material.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NexusBot - Asistente IA"),
        backgroundColor: const Color(0xFF2C5F78),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de robot para que se vea pro
            const Icon(Icons.smart_toy_rounded, size: 100, color: Color(0xFF2C5F78)),
            const SizedBox(height: 20),
            const Text(
              "NexusBot está despertando...",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Esta sección está bajo desarrollo por el equipo de ingeniería.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            
            // BOTÓN DE PRUEBA
            ElevatedButton.icon(
              onPressed: () {
                print("✅ [DEBUG]: Navegación exitosa a ChatBotScreen");
              },
              icon: const Icon(Icons.bug_report),
              label: const Text("Probar Conexión (Mira la Consola)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF84A98C),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}