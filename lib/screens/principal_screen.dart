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

class _PrincipalScreenState extends State<PrincipalScreen>
    with SingleTickerProviderStateMixin {
  // <-- Añadido para animar el GIF
  List<dynamic> _historialEmociones = [];
  bool _cargandoHistorial = true;
  String _estadoActual = "Estable";
  String _mensajeActual = "Me da mucha paz verte así, en calma";
  String _gifPrincipal = 'assets/carita_estable.gif';
  Color _colorFondo = Colors.blue.withOpacity(0.1);
  String _nivelEstres = "Bajo";
  Color _colorEstado = Colors.green;
  double _puntajeEstres = 0;

  // --- ANIMACIÓN DEL GIF FLOTANTE ---
  late AnimationController _floatController;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Efecto infinito de subir y bajar

    _floatAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -0.05), // Sube un 5% de su tamaño
        ).animate(
          CurvedAnimation(
            parent: _floatController,
            curve: Curves.easeInOutSine,
          ),
        );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  // ==========================================
  // ⚙️ LÓGICA INTACTA DE DATOS
  // ==========================================
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

  bool _peticionRealizada = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_peticionRealizada) {
      _obtenerHistorial();
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['id_usuario'] != null) {
        final int idUsuario = args['id_usuario'];
        _obtenerEstadoRapido(idUsuario);
      }
      _peticionRealizada = true;
    }
  }

  Future<void> _obtenerHistorial() async {
    setState(() => _cargandoHistorial = true);
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args == null || args['id_usuario'] == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/');
      return;
    }

    final int userId = args['id_usuario'];
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/historial_animo/$userId"),
      );
      if (response.statusCode == 200) {
        setState(() => _historialEmociones = jsonDecode(response.body));
      } else {
        print("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      print("Error de conexión: $e");
    } finally {
      if (mounted) setState(() => _cargandoHistorial = false);
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
            _colorEstado = _obtenerColorSegunNivel(_nivelEstres);
          });
        }
      }
    } catch (e) {
      debugPrint("Error obteniendo estrés: $e");
    }
  }

  Map<String, List<dynamic>> _agruparPorDia(List<dynamic> historial) {
    Map<String, List<dynamic>> agrupados = {};
    for (var registro in historial) {
      String fecha = registro['fecha_hora'].split(' ')[0];
      if (!agrupados.containsKey(fecha)) agrupados[fecha] = [];
      agrupados[fecha]!.add(registro);
    }
    return agrupados;
  }

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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF455A64),
              ),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF455A64),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              registro['detalle'] ?? "No agregaste una nota en este registro.",
              style: const TextStyle(color: Colors.black87),
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

  String _extraerNumeroControl(String correo) {
    if (correo.isEmpty) return "Desconocido";
    final partes = correo.split('@');
    if (partes.length == 2 && partes[0].toLowerCase().startsWith('l')) {
      final posibleNumero = partes[0].substring(1);
      if (RegExp(r'^\d+$').hasMatch(posibleNumero)) return posibleNumero;
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
        _colorFondo = const Color(
          0xFF81C784,
        ).withOpacity(0.15); // Verde Menta Pastel
      } else if (_estadoActual == 'Estresado' || _estadoActual == 'Crisis') {
        _colorFondo = const Color(0xFFEF5350).withOpacity(0.15); // Rojo Suave
      } else {
        _colorFondo = const Color(0xFFE1BEE7).withOpacity(0.2); // Lavanda Suave
      }
    });

    Navigator.pop(context);

    await Navigator.pushNamed(
      context,
      '/registro',
      arguments: {
        'emocion': _estadoActual,
        'frase': _mensajeActual,
        'gif': _gifPrincipal,
        'id_usuario': userId,
      },
    );
    _obtenerHistorial();
  }

  void _mostrarMenuEmociones(int userId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          height: 220,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "¿Cómo te sientes?",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF455A64),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _opcionesEmociones.map((emocion) {
                  return GestureDetector(
                    onTap: () => _seleccionarEmocion(emocion, userId),
                    child: Column(
                      children: [
                        Image.asset(emocion['gif']!, width: 55, height: 55),
                        const SizedBox(height: 5),
                        Text(
                          emocion['nombre']!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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

  // ==========================================
  // 🎨 UI PREMIUM: OCEAN BREEZE & KAWAII
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
        {'nombre': 'Estudiante', 'id_usuario': 2};
    final String nombreUsuario = args['nombre'];
    final int idUsuario = args['id_usuario'];

    // PALETA GLOBAL
    const colorFondoCyan = Color(0xFFE0F7FA);
    const colorFondoMenta = Color(0xFFF1F8E9);
    const colorAcentoTeal = Color(0xFF4DB6AC);

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _buildDrawerPremium(
        context,
        _colorEstado,
        nombreUsuario,
        _nivelEstres,
      ),

      appBar: AppBar(
        title: const Text(
          "Salud-Tec",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2C5F78),
        elevation: 0,
        centerTitle: true,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorFondoCyan, colorFondoMenta],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // =========================================
                // 👋 HEADER LIMPIO (Petición 5)
                // =========================================
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Row(
                    children: [
                      Hero(
                        tag: "avatar_principal",
                        child: AvatarEmocional(
                          nombreCompleto: nombreUsuario,
                          nivelEstres: _nivelEstres,
                          radio: 30,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "¡Hola $nombreUsuario! ✨",
                              style: const TextStyle(
                                color: Color(0xFF455A64),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _mensajeActual,
                              style: TextStyle(
                                color: Colors.blueGrey.shade600,
                                fontSize: 13,
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // =========================================
                // 🌀 GIF CENTRAL ANIMADO Y MÁGICO (Petición 6)
                // =========================================
                SlideTransition(
                  position: _floatAnimation, // Efecto de flote infinito
                  child: GestureDetector(
                    onTap: () => _mostrarMenuEmociones(idUsuario),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 230,
                      height: 230,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _colorFondo, // Cambia según la emoción
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _colorFondo.withOpacity(
                              0.8,
                            ), // Resplandor del mismo color
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(
                              0.5,
                            ), // Brillo interior
                            blurRadius: 10,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        _gifPrincipal,
                        fit: BoxFit.contain,
                        key: ValueKey(_gifPrincipal),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  "Estado: $_estadoActual",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF455A64),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "(Toca la carita para actualizar) 🌸",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 40),

                // =========================================
                // 📊 CARD ESTRÉS COMPACTA (Petición 1)
                // =========================================
                GestureDetector(
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      '/dashboard_estres',
                      arguments: {'id_usuario': idUsuario},
                    );
                    _obtenerEstadoRapido(idUsuario);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ), // Más delgadita
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // Borde más moderno
                      gradient: LinearGradient(
                        colors: [
                          _obtenerColorSegunNivel(_nivelEstres),
                          _obtenerColorSegunNivel(
                            _nivelEstres,
                          ).withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _obtenerColorSegunNivel(
                            _nivelEstres,
                          ).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45, // Icono más compacto
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.psychology_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Predicción de Estrés",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _nivelEstres.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Tensión: ${_puntajeEstres.toStringAsFixed(1)}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =========================================
                // 🌸 BOTONES DE APOYO KAWAII (Petición 2)
                // =========================================
                _buildBotonApoyo(
                  titulo: "¿Necesitas hablar? 🫂",
                  subtitulo: "Un psicólogo está listo para escucharte",
                  icono: Icons.favorite_rounded,
                  colorFondo: const Color(0xFFFFCDD2), // Rojo pastel
                  colorIcono: const Color(0xFFE53935),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/seleccion_psicologo',
                    arguments: {'id_usuario': idUsuario},
                  ),
                ),
                const SizedBox(height: 12),
                _buildBotonApoyo(
                  titulo: "Asistente NexusBot 🤖",
                  subtitulo:
                      "Habla con nuestra IA de apoyo en cualquier momento",
                  icono: Icons.smart_toy_rounded,
                  colorFondo: const Color(0xFFE0F2F1), // Teal clarito
                  colorIcono: colorAcentoTeal,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/chatbot',
                    arguments: {'id_usuario': idUsuario},
                  ),
                ),
                const SizedBox(height: 12),
                _buildBotonApoyo(
                  titulo: "Biblioteca de Paz 📚",
                  subtitulo: "Ejercicios, respiración y consejos",
                  icono: Icons.spa_rounded,
                  colorFondo: const Color(0xFFE8F5E9), // Menta clarito
                  colorIcono: const Color(0xFF81C784),
                  onTap: () => Navigator.pushNamed(context, '/biblioteca'),
                ),

                const SizedBox(height: 40),

                // =========================================
                // 📅 HISTORIAL LIMPIO (Petición 3)
                // =========================================
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Tu semana en un vistazo",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF455A64),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                _cargandoHistorial
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: colorAcentoTeal,
                        ),
                      )
                    : _historialEmociones.isEmpty
                    ? const Center(
                        child: Text(
                          "Aún no tienes registros esta semana. 🌱",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : SizedBox(
                        height: 110, // Más compacto
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: _agruparPorDia(_historialEmociones).entries
                              .map((entry) {
                                String fecha = entry.key;
                                List<dynamic> registrosDelDia = entry.value;

                                return Container(
                                  width: 65,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Pastilla de fecha superior
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorAcentoTeal.withOpacity(
                                            0.15,
                                          ),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(18),
                                              ),
                                        ),
                                        child: Text(
                                          fecha
                                              .substring(5)
                                              .replaceFirst(
                                                '-',
                                                '/',
                                              ), // Formato MM/DD
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: colorAcentoTeal,
                                          ),
                                        ),
                                      ),
                                      // Lista de caritas (Solo toma las primeras 2 para no romper el diseño, o puedes hacer scroll interno)
                                      Expanded(
                                        child: ListView.builder(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          itemCount: registrosDelDia.length,
                                          itemBuilder: (context, idx) {
                                            final reg = registrosDelDia[idx];
                                            return GestureDetector(
                                              onTap: () =>
                                                  _mostrarDetalleRegistro(reg),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 4,
                                                ),
                                                child: Image.asset(
                                                  _obtenerGifDeEmocion(
                                                    reg['emocion'],
                                                  ),
                                                  width: 28,
                                                  height: 28,
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
                const SizedBox(
                  height: 80,
                ), // Espacio para que el FAB no tape el contenido
              ],
            ),
          ),
        ),
      ),

      // =========================================
      // ✨ FAB NUEVA TAREA (Petición 4)
      // =========================================
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Esquina estándar y cómoda
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4DB6AC), Color(0xFF9575CD)], // Teal a Lavanda
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9575CD).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: "fab_tarea",
          backgroundColor:
              Colors.transparent, // El color lo da el Container de atrás
          elevation: 0,
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/nueva_tarea',
              arguments: {'id_usuario': idUsuario},
            );
          },
          child: const Icon(
            Icons.add_task_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }

  // Helper para los botones de apoyo
  Widget _buildBotonApoyo({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color colorFondo,
    required Color colorIcono,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorIcono.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: colorFondo, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorFondo,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: colorIcono, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Color(0xFF455A64),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorIcono.withOpacity(0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================
// 🍔 DRAWER PREMIUM MANTENIDO
// =========================================
// =========================================
// 🍔 DRAWER PREMIUM CORREGIDO ✅
// =========================================
Widget _buildDrawerPremium(
  BuildContext context,
  Color colorEstado,
  String nombreUsuario,
  String nivelEstres,
) {
  final Map<String, dynamic> args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
  final String correoUsuario = args['correo'] ?? "Sin correo";

  String extraerNumeroControl(String correo) {
    if (correo.isEmpty) return "Desconocido";
    final partes = correo.split('@');
    if (partes.length == 2 && partes[0].toLowerCase().startsWith('l')) {
      final posibleNumero = partes[0].substring(1);
      if (RegExp(r'^\d+$').hasMatch(posibleNumero)) return posibleNumero;
    }
    return "No disponible";
  }

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
            color: Colors.white.withOpacity(0.85),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 30,
                  bottom: 25,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4DB6AC), Color(0xFF2C5F78)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2C5F78).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 🔥 ¡AQUÍ REGRESÓ TU AVATAR HERMOSO! 🔥
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: AvatarEmocional(
                        nombreCompleto: nombreUsuario,
                        nivelEstres: nivelEstres,
                        radio:
                            40, // Lo hicimos un poquito más grande para el menú
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      correoUsuario,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _itemDrawerPremium(
                icono: Icons.badge_rounded,
                titulo: "Número de Control",
                subtitulo: extraerNumeroControl(correoUsuario),
                color: const Color(0xFF4DB6AC),
              ),
              _itemDrawerPremium(
                icono: Icons.school_rounded,
                titulo: "Carrera",
                subtitulo: "Ing. Sistemas Computacionales",
                color: const Color(0xFF4DB6AC),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  ),
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: const Text(
                    "Cerrar sesión",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5350),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _itemDrawerPremium({
  required IconData icono,
  required String titulo,
  required String subtitulo,
  required Color color,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: color, size: 22),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Color(0xFF455A64),
                ),
              ),
              Text(
                subtitulo,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
