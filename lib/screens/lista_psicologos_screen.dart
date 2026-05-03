import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';

class ListaPsicologosScreen extends StatefulWidget {
  const ListaPsicologosScreen({super.key});

  @override
  State<ListaPsicologosScreen> createState() => _ListaPsicologosScreenState();
}

class _ListaPsicologosScreenState extends State<ListaPsicologosScreen> {
  List<dynamic> _psicologos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _obtenerPsicologos();
  }

  Future<void> _obtenerPsicologos() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/psicologos_disponibles"),
      );

      if (response.statusCode == 200) {
        setState(() {
          _psicologos = jsonDecode(response.body);
        });
      } else {
        _mostrarError("Error al cargar la lista del servidor.");
      }
    } catch (e) {
      _mostrarError("Error de conexión. Revisa tu internet.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _iniciarChat(Map<String, dynamic> psicologo) async {
    // 1. Recuperamos el ID del alumno
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final int idAlumno = args?['id_usuario'] ?? 2;

    // RIGOR TÉCNICO: Antes de navegar, tocamos la puerta del servidor (El Gatekeeper)
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/chat/iniciar"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_alumno': idAlumno,
          'id_psicologo': psicologo['id_usuario'],
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // LUZ VERDE: El psicólogo está disponible, la sesión existe. Ahora sí, navegamos.
        final data = jsonDecode(response.body);

        Navigator.pushNamed(
          context,
          '/chat',
          arguments: {
            'id_alumno': idAlumno,
            'id_psicologo': psicologo['id_usuario'],
            'nombre_psicologo': psicologo['nombre_completo'],
            'id_emisor_actual': idAlumno,
            'id_sesion':
                data['id_sesion'], // Pasamos el ID validado por si el ChatScreen lo necesita
          },
        );
      } else if (response.statusCode == 400) {
        // EL BLINDAJE EN ACCIÓN: El servidor nos avisa que el Doc apagó su switch hace un milisegundo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("El profesional acaba de desconectarse."),
            backgroundColor: Colors.orange,
          ),
        );
        // Recargamos la lista silenciosamente para que el psicólogo desaparezca frente a sus ojos
        _obtenerPsicologos();
      } else {
        _mostrarError("Error del servidor al intentar conectar.");
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarError("Error de red al intentar iniciar el chat.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Un fondo relajante
      appBar: AppBar(
        title: const Text("Atención Psicológica"),
        backgroundColor: const Color(0xFF2C5F78),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _psicologos.isEmpty
          ? _buildEstadoVacio() // Manejo riguroso del estado sin datos
          : _buildListaPsicologos(),
    );
  }

  // 🧠 Criterio 7.4 (Usabilidad): Manejo empático de excepciones
  Widget _buildEstadoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "Sin psicólogos disponibles",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C5F78),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "En este momento no hay profesionales en línea. Por favor, intenta más tarde o visita la Biblioteca de Recursos si necesitas apoyo inmediato.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _obtenerPsicologos,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5F78),
              ),
              child: const Text(
                "Actualizar lista",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaPsicologos() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _psicologos.length,
      itemBuilder: (context, index) {
        final psi = _psicologos[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.only(bottom: 15),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF5ED3C6),
                  child: Text(
                    psi['nombre_completo'][0]
                        .toUpperCase(), // Primera letra del nombre
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              psi['nombre_completo'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              "Disponible ahora",
              style: TextStyle(color: Colors.green),
            ),
            trailing: const Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFF2C5F78),
            ),
            onTap: () => _iniciarChat(psi),
          ),
        );
      },
    );
  }
}
