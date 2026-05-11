import 'dart:async';
import 'dart:convert';
import 'dart:ui'; // <-- IMPORTANTE: Para el efecto Glassmorphism
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

class _AlumnoMainContainerState extends State<AlumnoMainContainer>
    with SingleTickerProviderStateMixin {
  // ==========================================
  // ⚙️ LÓGICA DE LUIS (100% INTACTA)
  // ==========================================
  Timer? _pollingTimer;
  bool _haySesionActiva = false;
  bool _hayMensajesSinLeer = false;
  int _ultimoConteoMensajes = 0;
  bool _enPantallaDeChat = false;
  Map<String, dynamic>? _datosSesionActual;

  int _fallosDeRed = 0;
  bool _sinConexion = false;

  late AnimationController _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Animación de Luis (hace que crezca un 8%)
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _pulseController.stop();

    _iniciarPollingGlobal();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _iniciarPollingGlobal() {
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) => _verificarSesionYMensajes(),
    );
  }

  Future<void> _verificarSesionYMensajes() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/alumno/${widget.idAlumno}/sesion_activa',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

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

            if (cantidadMensajesActual != _ultimoConteoMensajes) {
              final bool llegaronMensajesNuevos =
                  cantidadMensajesActual > _ultimoConteoMensajes;

              _ultimoConteoMensajes = cantidadMensajesActual;

              if (llegaronMensajesNuevos && !_enPantallaDeChat) {
                _hayMensajesSinLeer = true;

                if (!_pulseController.isAnimating) {
                  _pulseController.repeat(reverse: true);
                }
              }
            }
          });
        } else {
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

    _pulseController.stop();
    _pulseController.reset();

    if (_datosSesionActual != null) {
      await Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'id_sesion': _datosSesionActual!['id_sesion'],
          'id_alumno': widget.idAlumno,
          'id_psicologo': _datosSesionActual!['id_psicologo'],
          'nombre_psicologo':
              _datosSesionActual!['nombre_psicologo'] ?? 'Psicólogo',
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

  // ==========================================
  // 🎨 UI PREMIUM: OCEAN BREEZE KAWAIISTYLE
  // ==========================================
  @override
  Widget build(BuildContext context) {
    // Nuestra paleta de confianza ✨
    const colorAcentoTeal = Color(0xFF4DB6AC);
    const colorLavandaFuerte = Color(0xFF9575CD);
    const colorErrorSuave = Color(0xFFEF5350); // Coral/Rojo Suave

    return Stack(
      children: [
        // 🧩 CONTENIDO PRINCIPAL (La pantalla de fondo)
        const PrincipalScreen(),

        // 🔴 BANNER SIN CONEXIÓN (Glassmorphism Suavizado)
        if (_sinConexion)
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: colorErrorSuave.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorErrorSuave.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Uy, perdimos la conexión 📡",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 💬 BURBUJA FLOTANTE PREMIUM (Chat del Psicólogo)
        if (_haySesionActiva)
          Positioned(
            bottom: 95, // Altura perfecta
            right: 20,
            child: ScaleTransition(
              // El latido mágico de Luis
              scale: (_hayMensajesSinLeer && _pulseAnimation != null)
                  ? _pulseAnimation!
                  : const AlwaysStoppedAnimation(1.0),
              child: GestureDetector(
                onTap: _abrirChat,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // --- LA BURBUJA PRINCIPAL ---
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width:
                          60, // Un poquito más grande para ser "clicable" fácil
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [colorAcentoTeal, colorLavandaFuerte],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 2, // Borde blanco elegante
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorLavandaFuerte.withOpacity(
                              0.4,
                            ), // Glow color lavanda
                            blurRadius: _hayMensajesSinLeer
                                ? 20
                                : 10, // Brilla más si hay mensaje
                            spreadRadius: _hayMensajesSinLeer ? 2 : 0,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        // Cambiamos el icono si hay mensajes nuevos
                        _hayMensajesSinLeer
                            ? Icons.mark_chat_unread_rounded
                            : Icons.chat_bubble_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    // --- 🔴 EL BADGE DE "NUEVO MENSAJE" (Puntito Kawaii) ---
                    if (_hayMensajesSinLeer)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF5252,
                            ), // Rojo Fresa brillante
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.5, // Borde gordito para contrastar
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF5252).withOpacity(0.5),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
