import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:salud_tec_final/api_config.dart';

import 'dart:ui';

import 'package:salud_tec_final/screens/avatar_emocional.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  List<dynamic> _historialEmociones = [];

  bool _cargandoHistorial = true;

  String _estadoActual = "Estable";

  String _mensajeActual = "Me da mucha paz verte así, en calma";

  String _gifPrincipal = 'assets/carita_estable.gif';

  Color _colorFondo = Colors.blue.withOpacity(0.1);

  String _nivelEstres = "Bajo";

  Color _colorEstado = Colors.green;

  double _puntajeEstres = 0;

  Color _obtenerColorSegunNivel(String nivel) {
    switch (nivel) {
      case "Moderado":
        return Colors.orange;

      case "Alto":
        return Colors.red;

      case "Critico":
        return const Color(0xFF8B0000);

      default:
        return Colors.green;
    }
  }

  final List<Map<String, String>> _opcionesEmociones = [
    {
      'nombre': 'Alegre',

      'gif': 'assets/carita_riendo.gif',

      'frase': '¡Eres el claro ejemplo de que la felicidad es una elección!',
    },

    {
      'nombre': 'Feliz',

      'gif': 'assets/carita_feliz.gif',

      'frase': 'Qué felicidad verte brillar así',
    },

    {
      'nombre': 'Estable',

      'gif': 'assets/carita_neutra.gif',

      'frase': 'Me da mucha paz verte así, en calma',
    },

    {
      'nombre': 'Estresado',

      'gif': 'assets/carita_enojada.gif',

      'frase':
          'No tienes que dar explicaciones, pero si quieres hablar, te prometo que te escucho.',
    },

    {
      'nombre': 'Crisis',

      'gif': 'assets/carita_triste.gif',

      'frase': 'No estás solo/a en esto, cuenta conmigo',
    },
  ];

  // 1. Crea una variable booleana para evitar que se llame al API mil veces

  bool _peticionRealizada = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Evita llamadas múltiples al reconstruirse el widget

    if (!_peticionRealizada) {
      _obtenerHistorial();

      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (args != null && args['id_usuario'] != null) {
        final int idUsuario = args['id_usuario'];

        // 🔥 Obtener estrés y aura emocional

        _obtenerEstadoRapido(idUsuario);
      }

      _peticionRealizada = true;
    }
  }

  Future<void> _obtenerHistorial() async {
    setState(() {
      _cargandoHistorial = true;
    });

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // VALIDACIÓN ESTRICTA DE SEGURIDAD

    if (args == null || args['id_usuario'] == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }

      return;
    }

    final int userId = args['id_usuario']; // Asignación limpia

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/historial_animo/$userId"),
      );

      if (response.statusCode == 200) {
        setState(() {
          _historialEmociones = jsonDecode(response.body);
        });
      } else {
        print("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      print("Error de conexión: $e");
    } finally {
      if (mounted) {
        setState(() {
          _cargandoHistorial = false;
        });
      }
    }
  }

  Future<void> _obtenerEstadoRapido(int idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/alumno/$idUsuario/prediccion_estres"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            _nivelEstres = data['nivel'];

            _puntajeEstres = (data['puntaje'] as num).toDouble();

            // 🔥 NUEVO

            _colorEstado = _obtenerColorSegunNivel(_nivelEstres);
          });
        }
      }
    } catch (e) {
      debugPrint("Error obteniendo estrés: $e");
    }
  }

  // --- NUEVAS FUNCIONES DE LÓGICA PARA EL HISTORIAL ---

  // 1. Agrupa la lista plana del API en un Mapa por día

  Map<String, List<dynamic>> _agruparPorDia(List<dynamic> historial) {
    Map<String, List<dynamic>> agrupados = {};

    for (var registro in historial) {
      String fecha = registro['fecha_hora'].split(' ')[0];

      if (!agrupados.containsKey(fecha)) {
        agrupados[fecha] = [];
      }

      agrupados[fecha]!.add(registro);
    }

    return agrupados;
  }

  // 2. Muestra el popup con el comentario/nota del usuario

  void _mostrarDetalleRegistro(dynamic registro) {
    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: Row(
          children: [
            Image.asset(
              _obtenerGifDeEmocion(registro['emocion']),

              width: 40,

              height: 40,
            ),

            const SizedBox(width: 10),

            Text(
              registro['emocion'],

              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Fecha y hora: ${registro['fecha_hora']}",

              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const Divider(),

            const Text(
              "Tu nota de ese momento:",

              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // CORRECCIÓN DE RIGOR: Usamos 'detalle' que es como viene de la DB
            Text(
              registro['detalle'] ?? "No agregaste una nota en este registro.",
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  // --- FIN DE NUEVAS FUNCIONES ---

  // =========================================

  // 🧠 EXTRAER NÚMERO DE CONTROL

  // =========================================

  String _extraerNumeroControl(String correo) {
    if (correo.isEmpty) return "Desconocido";

    final partes = correo.split('@');

    if (partes.length == 2 && partes[0].toLowerCase().startsWith('l')) {
      final posibleNumero = partes[0].substring(1);

      if (RegExp(r'^\d+$').hasMatch(posibleNumero)) {
        return posibleNumero;
      }
    }

    return "No disponible";
  }

  String _obtenerGifDeEmocion(String nombre) {
    switch (nombre) {
      case 'Alegre':
        return 'assets/carita_riendo.gif';

      case 'Feliz':
        return 'assets/carita_feliz.gif';

      case 'Estable':
        return 'assets/carita_neutra.gif';

      case 'Estresado':
        return 'assets/carita_enojada.gif';

      case 'Crisis':
        return 'assets/carita_triste.gif';

      default:
        return 'assets/carita_estable.gif';
    }
  }

  void _seleccionarEmocion(Map<String, String> emocion, int userId) async {
    setState(() {
      _estadoActual = emocion['nombre']!;

      _mensajeActual = emocion['frase']!;

      _gifPrincipal = emocion['gif']!;

      if (_estadoActual == 'Alegre' || _estadoActual == 'Feliz') {
        _colorFondo = Colors.green.withOpacity(0.1);
      } else if (_estadoActual == 'Estresado' || _estadoActual == 'Crisis') {
        _colorFondo = Colors.red.withOpacity(0.1);
      } else {
        _colorFondo = Colors.blue.withOpacity(0.1);
      }
    });

    Navigator.pop(context);

    // AQUÍ USAMOS EL ID: Pasamos el ID al registro para que se guarde en la cuenta correcta

    await Navigator.pushNamed(
      context,

      '/registro',

      arguments: {
        'emocion': _estadoActual,

        'frase': _mensajeActual,

        'gif': _gifPrincipal,

        'id_usuario': userId, // <--- INTEGRIDAD TÉCNICA
      },
    );

    //RECARGA AUTOMÁTICA: Cuando el usuario regresa, ejecutamos esto:

    _obtenerHistorial(); // <--- Rigor de Integridad Funcional (7.1)
  }

  // 1. Agregamos el parámetro int userId

  void _mostrarMenuEmociones(int userId) {
    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),

          height: 220,

          child: Column(
            children: [
              const Text(
                "¿Cómo te sientes?",

                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: _opcionesEmociones.map((emocion) {
                  return GestureDetector(
                    // 2. Pasamos ambos argumentos: la emoción y el ID
                    onTap: () => _seleccionarEmocion(emocion, userId),

                    child: Column(
                      children: [
                        Image.asset(emocion['gif']!, width: 55, height: 55),

                        const SizedBox(height: 5),

                        Text(
                          emocion['nombre']!,

                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Capturamos los argumentos de forma segura

    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
        {'nombre': 'Estudiante', 'id_usuario': 2};

    final String nombreUsuario = args['nombre'];

    final int idUsuario = args['id_usuario']; // <--- YA SE USA ABAJO

    return Scaffold(
      backgroundColor: Colors.white,

      drawer: Builder(
        builder: (context) {
          final Map<String, dynamic> args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>? ??
              {};

          final String nombreUsuario = args['nombre'] ?? "Estudiante";

          final String correoUsuario = args['correo'] ?? "Sin correo";

          return Drawer(
            elevation: 0,

            backgroundColor: Colors.transparent,

            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(35),

                bottomRight: Radius.circular(35),
              ),

              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),

                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,

                      end: Alignment.bottomRight,

                      colors: [
                        Colors.white.withOpacity(0.90),

                        _colorEstado.withOpacity(0.10),
                      ],
                    ),

                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),

                      width: 1.5,
                    ),
                  ),

                  child: Column(
                    children: [
                      // ======================================

                      // HEADER VIVO

                      // ======================================
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),

                        width: double.infinity,

                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 28,

                          bottom: 28,

                          left: 22,

                          right: 22,
                        ),

                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _colorEstado.withOpacity(0.95),

                              _colorEstado.withOpacity(0.65),
                            ],
                          ),

                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(40),
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: _colorEstado.withOpacity(0.35),

                              blurRadius: 30,

                              spreadRadius: 2,

                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),

                        child: Row(
                          children: [
                            Hero(
                              tag: "avatar_principal",

                              child: AvatarEmocional(
                                nombreCompleto: nombreUsuario,

                                nivelEstres: _nivelEstres,

                                radio: 36,
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    nombreUsuario,

                                    maxLines: 1,

                                    overflow: TextOverflow.ellipsis,

                                    style: const TextStyle(
                                      color: Colors.white,

                                      fontSize: 18,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    correoUsuario,

                                    maxLines: 1,

                                    overflow: TextOverflow.ellipsis,

                                    style: const TextStyle(
                                      color: Colors.white70,

                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      _itemDrawerPremium(
                        icono: Icons.badge_outlined,

                        titulo: "Número de Control",

                        subtitulo: _extraerNumeroControl(correoUsuario),

                        color: _colorEstado,
                      ),

                      _itemDrawerPremium(
                        icono: Icons.school_outlined,

                        titulo: "Carrera",

                        subtitulo: "Ing. Sistemas Computacionales",

                        color: _colorEstado,
                      ),

                      const Spacer(),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,

                          vertical: 12,
                        ),

                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),

                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,

                              '/',

                              (route) => false,
                            );
                          },

                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,

                              vertical: 16,
                            ),

                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.redAccent.withOpacity(0.85),

                                  Colors.red.shade900.withOpacity(0.90),
                                ],
                              ),

                              borderRadius: BorderRadius.circular(18),
                            ),

                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Icon(Icons.logout_rounded, color: Colors.white),

                                SizedBox(width: 10),

                                Text(
                                  "Cerrar sesión",

                                  style: TextStyle(
                                    color: Colors.white,

                                    fontWeight: FontWeight.bold,

                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),

      appBar: AppBar(
        title: const Text("Nexus 4 - Salud-Tec"),

        backgroundColor: const Color(0xFF2C5F78),

        foregroundColor: Colors.white,

        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),

                  curve: Curves.easeInOut,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,

                    vertical: 18,
                  ),

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2C5F78),

                        _colorEstado.withOpacity(0.85),
                      ],

                      begin: Alignment.topLeft,

                      end: Alignment.bottomRight,
                    ),

                    borderRadius: BorderRadius.circular(28),

                    boxShadow: [
                      BoxShadow(
                        color: _colorEstado.withOpacity(0.35),

                        blurRadius: 25,

                        spreadRadius: 1,

                        offset: const Offset(0, 8),
                      ),
                    ],

                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),

                      width: 1.2,
                    ),
                  ),

                  child: Row(
                    children: [
                      // =========================================

                      // 🔥 AVATAR EMOCIONAL

                      // =========================================
                      AvatarEmocional(
                        nombreCompleto: nombreUsuario,

                        nivelEstres: _nivelEstres,

                        radio: 30,
                      ),

                      const SizedBox(width: 15),

                      // =========================================

                      // 👋 MENSAJE PRINCIPAL

                      // =========================================
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "¡Hola $nombreUsuario!",

                              style: const TextStyle(
                                color: Colors.white,

                                fontSize: 18,

                                fontWeight: FontWeight.bold,
                              ),

                              maxLines: 1,

                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 5),

                            Text(
                              _mensajeActual,

                              style: const TextStyle(
                                color: Colors.white70,

                                fontSize: 13,

                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // =========================================

                            // ✨ CHIP DE ESTADO

                            // =========================================
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),

                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,

                                vertical: 6,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),

                                borderRadius: BorderRadius.circular(30),

                                border: Border.all(
                                  color: _colorEstado.withOpacity(0.7),

                                  width: 1.4,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: _colorEstado.withOpacity(0.35),

                                    blurRadius: 15,

                                    spreadRadius: 1,
                                  ),
                                ],
                              ),

                              child: Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),

                                    width: 10,

                                    height: 10,

                                    decoration: BoxDecoration(
                                      color: _colorEstado,

                                      shape: BoxShape.circle,

                                      boxShadow: [
                                        BoxShadow(
                                          color: _colorEstado.withOpacity(0.8),

                                          blurRadius: 10,

                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    "Estrés $_nivelEstres",

                                    style: TextStyle(
                                      color: _colorEstado,

                                      fontWeight: FontWeight.bold,

                                      fontSize: 12,

                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                ClipPath(
                  clipper: TriangleClipper(),

                  child: Container(
                    color: _colorEstado.withOpacity(0.85),

                    height: 12,

                    width: 26,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: () => _mostrarMenuEmociones(idUsuario),

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),

                width: 250,

                height: 250,

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: _colorFondo,

                  shape: BoxShape.circle,
                ),

                child: Image.asset(
                  _gifPrincipal,

                  fit: BoxFit.contain,

                  key: ValueKey(_gifPrincipal),
                ),
              ),
            ),

            Text(
              "Estado: $_estadoActual",

              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const Text(
              "(Toca para cambiar)",

              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),

            const SizedBox(height: 30),

            // CARD ESTRÉS (NAVEGABLE)
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(
                  context,

                  '/dashboard_estres',

                  arguments: {'id_usuario': idUsuario},
                );

                // RECARGA AUTOMÁTICA AL VOLVER

                _obtenerEstadoRapido(idUsuario);
              },

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),

                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),

                  gradient: LinearGradient(
                    colors: [
                      _obtenerColorSegunNivel(_nivelEstres),

                      _obtenerColorSegunNivel(_nivelEstres).withOpacity(0.75),
                    ],

                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,
                  ),

                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),

                    width: 1.5,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: _obtenerColorSegunNivel(
                        _nivelEstres,
                      ).withOpacity(0.45),

                      blurRadius: 22,

                      spreadRadius: 3,

                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    // MINI HALO
                    Container(
                      width: 58,

                      height: 58,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        color: Colors.white.withOpacity(0.15),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),

                            blurRadius: 12,

                            spreadRadius: 2,
                          ),
                        ],
                      ),

                      child: const Icon(
                        Icons.psychology_alt,

                        color: Colors.white,

                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Predicción de Estrés",

                            style: TextStyle(
                              color: Colors.white70,

                              fontSize: 13,

                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            _nivelEstres.toUpperCase(),

                            style: const TextStyle(
                              color: Colors.white,

                              fontSize: 24,

                              fontWeight: FontWeight.w900,

                              letterSpacing: 1.2,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Tensión estimada: "
                            "${_puntajeEstres.toStringAsFixed(1)}",

                            style: const TextStyle(
                              color: Colors.white70,

                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios,

                      color: Colors.white70,

                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BOTÓN DE CHAT KAWAII
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,

                '/seleccion_psicologo',

                arguments: {
                  'id_usuario': idUsuario,
                }, // <-- Pasamos el ID del Alumno
              ),

              child: Container(
                padding: const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(25),

                  border: Border.all(
                    color: const Color(0xFF2C5F78).withOpacity(0.3),

                    width: 2,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),

                      blurRadius: 10,

                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Image.asset(
                      'assets/mensaje_kawaii.png',

                      width: 60,

                      height: 60,
                    ),

                    const SizedBox(width: 15),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "¿Necesitas hablar?",

                            style: TextStyle(
                              fontWeight: FontWeight.bold,

                              fontSize: 16,

                              color: Color(0xFF2C5F78),
                            ),
                          ),

                          Text(
                            "Un psicólogo está listo para escucharte",

                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios,

                      color: Color(0xFF2C5F78),

                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // BOTÓN DE CHATBOT (IA)
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,

                '/chatbot',

                arguments: {
                  'id_usuario':
                      idUsuario, // O la variable de ID que tengas disponible en esa pantalla
                },
              ),

              child: Container(
                padding: const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: const Color(0xFF2C5F78),

                  borderRadius: BorderRadius.circular(25),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),

                      blurRadius: 8,

                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: const Row(
                  children: [
                    Icon(
                      Icons.smart_toy_outlined,

                      color: Colors.white,

                      size: 45,
                    ),

                    SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Asistente NexusBot",

                            style: TextStyle(
                              fontWeight: FontWeight.bold,

                              fontSize: 16,

                              color: Colors.white,
                            ),
                          ),

                          Text(
                            "Habla con nuestra IA de apoyo",

                            style: TextStyle(
                              fontSize: 12,

                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios,

                      color: Colors.white,

                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // BOTÓN DE BIBLIOTECA DE RECURSOS
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/biblioteca'),

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,

                  vertical: 16,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFF84A98C),

                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),

                      blurRadius: 8,

                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Icon(Icons.menu_book, color: Colors.white, size: 28),

                    SizedBox(width: 12),

                    Text(
                      'Biblioteca de Recursos',

                      style: TextStyle(
                        fontWeight: FontWeight.w600,

                        color: Colors.white,

                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- SECCIÓN DE HISTORIAL ACTUALIZADA (1 SEMANA / BIDIMENSIONAL) ---
            const Align(
              alignment: Alignment.centerLeft,

              child: Text(
                "Tu semana en un vistazo",

                style: TextStyle(
                  fontSize: 18,

                  fontWeight: FontWeight.bold,

                  color: Color(0xFF2C5F78),
                ),
              ),
            ),

            const SizedBox(height: 15),

            _cargandoHistorial
                ? const Center(child: CircularProgressIndicator())
                : _historialEmociones.isEmpty
                ? const Text("Aún no tienes registros esta semana.")
                : SizedBox(
                    height:
                        220, // Altura para permitir varias caritas hacia abajo

                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: _agruparPorDia(_historialEmociones).entries
                            .map((entry) {
                              String fecha = entry.key;

                              List<dynamic> registrosDelDia = entry.value;

                              return Container(
                                width: 90,

                                margin: const EdgeInsets.only(right: 15),

                                child: Column(
                                  children: [
                                    // Etiqueta del día
                                    Text(
                                      fecha,

                                      style: const TextStyle(
                                        fontSize: 10,

                                        fontWeight: FontWeight.bold,

                                        color: Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Lista de caritas del día (Vertical)
                                    Expanded(
                                      child: ListView.builder(
                                        shrinkWrap: true,

                                        physics: const ClampingScrollPhysics(),

                                        itemCount: registrosDelDia.length,

                                        itemBuilder: (context, idx) {
                                          final reg = registrosDelDia[idx];

                                          return GestureDetector(
                                            onTap: () =>
                                                _mostrarDetalleRegistro(reg),

                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 8,
                                              ),

                                              padding: const EdgeInsets.all(8),

                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],

                                                borderRadius:
                                                    BorderRadius.circular(15),

                                                border: Border.all(
                                                  color: Colors.grey[200]!,
                                                ),
                                              ),

                                              child: Column(
                                                children: [
                                                  Image.asset(
                                                    _obtenerGifDeEmocion(
                                                      reg['emocion'],
                                                    ),

                                                    width: 35,

                                                    height: 35,
                                                  ),

                                                  const SizedBox(height: 4),

                                                  Text(
                                                    reg['emocion'],

                                                    style: const TextStyle(
                                                      fontSize: 8,

                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),

                                                  Text(
                                                    reg['fecha_hora']
                                                        .split(' ')[1]
                                                        .substring(0, 5),

                                                    style: const TextStyle(
                                                      fontSize: 8,

                                                      color: Colors.blueGrey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })
                            .toList(),
                      ),
                    ),
                  ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // BOTÓN FLOTANTE NUEVA TAREA
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2C5F78),

        onPressed: () {
          Navigator.pushNamed(
            context,

            '/nueva_tarea',

            arguments: {'id_usuario': idUsuario},
          );
        },

        icon: const Icon(Icons.add_task, color: Colors.white),

        label: const Text("Nueva tarea", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(size.width / 2, size.height);

    path.lineTo(size.width, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}

Widget _itemDrawerPremium({
  required IconData icono,

  required String titulo,

  required String subtitulo,

  required Color color,

  VoidCallback? onTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),

    child: Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(20),

        onTap: onTap,

        child: Ink(
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),

            borderRadius: BorderRadius.circular(20),

            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),

          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),

                  shape: BoxShape.circle,
                ),

                child: Icon(icono, color: color, size: 22),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      titulo,

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,

                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitulo,

                      style: TextStyle(
                        color: Colors.grey.shade700,

                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
