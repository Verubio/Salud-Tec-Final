import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salud_tec_final/api_config.dart';
import 'package:salud_tec_final/screens/principal_screen.dart';

class AlumnoMainContainer extends StatefulWidget {
  final int idAlumno; // Necesitamos el ID del alumno real

  const AlumnoMainContainer({super.key, required this.idAlumno});

  @override
  State<AlumnoMainContainer> createState() => _AlumnoMainContainerState();
}

class _AlumnoMainContainerState extends State<AlumnoMainContainer> {
  // --- VARIABLES DE ESTADO GLOBAL ---
  Timer? _pollingTimer;
  bool _haySesionActiva = false;
  bool _hayMensajesSinLeer = false;
  int _ultimoConteoMensajes = 0;
  bool _enPantallaDeChat = false; // El candado lógico
  Map<String, dynamic>? _datosSesionActual;

  @override
  void initState() {
    super.initState();
    _iniciarPollingGlobal();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // --- EL CEREBRO DEL POLLING ---
  void _iniciarPollingGlobal() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        // 1. Preguntamos al servidor si el alumno tiene una sesión activa (ejemplo de endpoint)
        final response = await http.get(
          Uri.parse(
            '${ApiConfig.baseUrl}/alumno/${widget.idAlumno}/sesion_activa',
          ),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['sesion_activa'] != null) {
            final sesion = data['sesion_activa'];
            final int cantidadMensajesActual = data['total_mensajes'] ?? 0;

            setState(() {
              _haySesionActiva = true;
              _datosSesionActual = sesion;

              // RIGOR LÓGICO: Si hay MÁS mensajes de los que yo conocía Y NO estoy en el chat...
              if (cantidadMensajesActual > _ultimoConteoMensajes) {
                if (!_enPantallaDeChat) {
                  _hayMensajesSinLeer = true; // ¡Encendemos el punto rojo!
                }
                _ultimoConteoMensajes = cantidadMensajesActual;
              }
            });
          } else {
            // Si el psicólogo finalizó la sesión
            setState(() {
              _haySesionActiva = false;
              _hayMensajesSinLeer = false;
              _ultimoConteoMensajes = 0;
            });
          }
        }
      } catch (e) {
        // Fallo silencioso de red, reintentará en 3 segundos
      }
    });
  }

  Future<void> _abrirChat() async {
    setState(() {
      _hayMensajesSinLeer = false;
      _enPantallaDeChat = true;
    });

    if (_datosSesionActual != null) {
      await Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'id_alumno': widget.idAlumno,
          'id_psicologo':
              _datosSesionActual!['id_psicologo'], // ¡La pieza que faltaba!
          'nombre_psicologo':
              'Psicólogo', // El texto genérico o el nombre real si lo tienes
          'id_emisor_actual':
              widget.idAlumno, // Para que las burbujas azules sean las tuyas
        },
      );
    }

    if (mounted) {
      setState(() {
        _enPantallaDeChat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. TU APP REAL
        const PrincipalScreen(),

        // 2. BOLITA FLOTANTE
        if (_haySesionActiva)
          Positioned(
            bottom: 80, // ajusta según tu UI
            right: 20,
            child: GestureDetector(
              onTap: _abrirChat,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C5F78),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chat_bubble,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  // 🔴 BADGE
                  if (_hayMensajesSinLeer)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
