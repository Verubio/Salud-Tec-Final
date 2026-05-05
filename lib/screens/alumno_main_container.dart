import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salud_tec_final/api_config.dart';
import 'package:salud_tec_final/screens/principal_screen.dart';

class AlumnoMainContainer extends StatefulWidget {
  final int idAlumno;

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
  bool _enPantallaDeChat = false;
  Map<String, dynamic>? _datosSesionActual;

  // --- SENSORES DE RED ---
  int _fallosDeRed = 0;
  bool _sinConexion = false;

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

  // 🔄 POLLING LIMPIO
  void _iniciarPollingGlobal() {
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) => _verificarSesionYMensajes(),
    );
  }

  //  MÉTODO PRINCIPAL (LÓGICA + RED)
  Future<void> _verificarSesionYMensajes() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/alumno/${widget.idAlumno}/sesion_activa',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // RECUPERACIÓN DE RED
        if (_fallosDeRed > 0 && mounted) {
          setState(() {
            _fallosDeRed = 0;
            _sinConexion = false;
          });
        }

        if (!mounted) return;

        if (data['sesion_activa'] != null) {
          final sesion = data['sesion_activa'];
          final int cantidadMensajesActual = data['total_mensajes'] ?? 0;

          setState(() {
            _haySesionActiva = true;
            _datosSesionActual = sesion;

            if (cantidadMensajesActual > _ultimoConteoMensajes) {
              if (!_enPantallaDeChat) {
                _hayMensajesSinLeer = true;
              }
              _ultimoConteoMensajes = cantidadMensajesActual;
            }
          });
        } else {
          // SESIÓN TERMINADA
          setState(() {
            _haySesionActiva = false;
            _hayMensajesSinLeer = false;
            _ultimoConteoMensajes = 0;
          });
        }
      } else {
        throw Exception("Error de servidor");
      }
    } catch (e) {
      // SENSOR DE FALLA
      _fallosDeRed++;

      if (_fallosDeRed >= 3 && !_sinConexion && mounted) {
        setState(() {
          _sinConexion = true;
        });
      }
    }
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
          'id_psicologo': _datosSesionActual!['id_psicologo'],
          'nombre_psicologo': 'Psicólogo',
          'id_emisor_actual': widget.idAlumno,
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
    return Column(
      children: [
        // 🔴 BANNER SIN CONEXIÓN (Estilizado)
        if (_sinConexion)
          Positioned(
            top: 40, // Ajusta dependiendo de tu SafeArea
            left: 16,
            right: 16,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F), // Un rojo más elegante
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "Sin conexión a internet",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 🧩 CONTENIDO PRINCIPAL
        Expanded(
          child: Stack(
            children: [
              const PrincipalScreen(),

              // 💬 BOLITA FLOTANTE
              if (_haySesionActiva)
                Positioned(
                  bottom: 80,
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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
