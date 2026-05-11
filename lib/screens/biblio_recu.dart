import 'dart:async';
import 'package:flutter/material.dart';

class BiblioRecu extends StatefulWidget {
  const BiblioRecu({super.key});

  @override
  State<BiblioRecu> createState() => _BiblioRecuState();
}

class _BiblioRecuState extends State<BiblioRecu> {
  // --- PALETA OCEAN BREEZE UNIFICADA ✨ ---
  final Color colorResp = const Color(0xFFC5E1A5); // Verde Menta Suave
  final Color colorAns = const Color(0xFFF8BBD0); // Rosa Pastel Suave
  final Color colorHab = const Color(0xFFFFCC80); // Melocotón Suave
  final Color colorSue = const Color(0xFFB3E5FC); // Azul Cielo Claro
  final Color colorOrg = const Color(0xFFE1BEE7); // Lavanda Suave
  final Color colorFondo = const Color(0xFFF5F7FA);

  // Definimos las categorías
  final List<Map<String, dynamic>> categorias = [
    {
      'titulo': 'Respiración',
      'icono': Icons.air_rounded,
      'color': const Color(0xFFC5E1A5),
      'descripcion':
          'Ejercicios prácticos guiados para el control fisiológico del estrés.',
      'secciones': <Map<String, String>>[
        {
          'id': 'resp_diafragmatica',
          'subtitulo': 'Respiración diafragmática',
          'texto':
              'Uso: Relaja la tensión y músculos abdominales.\n\nPasos:\n• Acuéstese o siéntese cómodamente.\n• Coloque una mano sobre el abdomen.\n• Inhale y exhale lentamente guiado por la animación.',
        },
        {
          'id': 'resp_488',
          'subtitulo': 'Respiro profundo 4-8-8',
          'texto':
              'Uso: Aumenta el oxígeno y calma rápido.\n\nPasos:\n• Inhala por la nariz 4s.\n• Aguanta 8s.\n• Exhala por la boca 8s.',
        },
        {
          'id': 'resp_resoplidos',
          'subtitulo': 'Resoplidos rápidos',
          'texto':
              'Uso: Fortalece el diafragma.\n\nPasos:\n• Inhale profundo.\n• Resople 3 veces rápido (sin exhalar).\n• Exhale lento.\n• Repita 3 veces.',
        },
      ],
    },
    {
      'titulo': 'Ansiedad',
      'icono': Icons.favorite_rounded,
      'color': const Color(0xFFF8BBD0),
      'descripcion':
          'Herramientas rápidas para momentos de crisis o estrés elevado.',
      'secciones': <Map<String, String>>[
        {
          'id': 'ans_54321',
          'subtitulo': 'Técnica 5-4-3-2-1 (Aterrizaje sensorial)',
          'texto':
              'Uso: Regresa al presente cuando la ansiedad sube.\n\nPasos:\nBusca 5 cosas que veas, 4 que toques, 3 escuches, 2 huelas y 1 saborees.',
        },
        {
          'id': 'ans_muscular',
          'subtitulo': 'Relajación muscular progresiva',
          'texto':
              'Uso: Libera la tensión física.\n\nPasos:\nTensa diferentes partes del cuerpo por 5s y suelta, siguiendo la guía.',
        },
      ],
    },
    {
      'titulo': 'Consejos',
      'icono': Icons.lightbulb_rounded,
      'color': const Color(0xFFFFCC80),
      'descripcion':
          'Recomendaciones para el bienestar general durante el estudio.',
      'secciones': <Map<String, String>>[
        {
          'id': 'consejo_vista',
          'subtitulo': 'Cuidar la vista (Regla 20-20-20)',
          'texto':
              'Uso: Evita fatiga visual ante pantallas.\n\nLa regla:\nCada 20 minutos, mira un objeto a 6 metros por 20 segundos.',
        },
      ],
    },
    {
      'titulo': 'Sueño',
      'icono': Icons.bedtime_rounded,
      'color': const Color(0xFFB3E5FC),
      'descripcion': 'Enfoque en el descanso para mejor rendimiento.',
      'secciones': <Map<String, String>>[
        {
          'id': 'sueno_descanso',
          'subtitulo': 'Consejos para un buen descanso',
          'texto':
              '• Desconexión: Evita pantallas 30min antes de dormir.\n• Filtro nocturno: Activa modo lectura.\n• Rutina: Acuéstate y levántate a la misma hora.',
        },
      ],
    },
    {
      'titulo': 'Tiempo',
      'icono': Icons.schedule_rounded,
      'color': const Color(0xFFE1BEE7),
      'descripcion': 'Estrategias para gestionar la carga académica.',
      'secciones': <Map<String, String>>[
        {
          'id': 'tiempo_pomodoro',
          'subtitulo': 'Técnica Pomodoro',
          'texto':
              'Uso: Alta concentración en tareas.\n\nPasos:\nTrabaja 25min sin distracciones, descansa 5min.',
        },
        {
          'id': 'tiempo_matriz',
          'subtitulo': 'Matriz de Prioridades',
          'texto':
              'Uso: Clasifica tareas si te sientes saturado.\n\n• Urgente/Importante: Hazlo ya.\n• Importante/No Urgente: Planifícalo.\n• Urgente/No Importante: Delégalo.\n• Ni Urgente ni Importante: Elimínalo.',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text(
          'Recursos de Paz',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        foregroundColor: const Color(0xFF455A64),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                "Tómate un respiro, estamos contigo ✨",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              // ==========================================
              // 🔥 ANIMACIÓN DE ENTRADA (CASCADA)
              // ==========================================
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: categorias.length,
                itemBuilder: (context, index) {
                  final cat = categorias[index];
                  // Staggered animation (nace una después de la otra)
                  return EntradaAnimada(
                    index: index,
                    child: GestureDetector(
                      onTap: () {
                        _mostrarDetalleCategoria(
                          context,
                          cat['titulo'],
                          cat['descripcion'],
                          cat['secciones'] as List<Map<String, String>>,
                          cat['color'],
                          cat['icono'],
                        );
                      },
                      // ==========================================
                      // 🔷 TARJETA KAWAIISTYLE (Glassmorphism sutil)
                      // ==========================================
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: cat['color'].withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: cat['color'].withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cat['color'].withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                cat['icono'],
                                size: 40,
                                color: cat['color'],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              cat['titulo'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF455A64),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              height: 4,
                              width: 30,
                              decoration: BoxDecoration(
                                color: cat['color'],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalleCategoria(
    BuildContext context,
    String titulo,
    String descripcion,
    List<Map<String, String>> secciones,
    Color colorCategoria,
    IconData icono,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(icono, color: colorCategoria, size: 28),
              const SizedBox(width: 12),
              Text(
                titulo.toUpperCase(),
                style: TextStyle(
                  color: colorCategoria,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    descripcion,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 25),
                  ...secciones.map((seccion) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PantallaInteractiva(
                              idMetodo: seccion['id']!,
                              titulo: seccion['subtitulo']!,
                              colorCategoria: colorCategoria,
                              textoCompleto: seccion['texto']!,
                            ),
                          ),
                        );
                      },
                      // ==========================================
                      // 🔷 BOTÓN INTERACTIVO KAWAIISTYLE ✅
                      // ==========================================
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorCategoria.withOpacity(0.05),
                              colorCategoria.withOpacity(0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorCategoria.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    seccion['subtitulo']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: Color(0xFF455A64),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    seccion['texto']!.split('\n\n')[0],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.play_circle_filled_rounded,
                              color: colorCategoria,
                              size: 34,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'CERRAR 🌸',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Helper para animación de entrada en cascada
class EntradaAnimada extends StatelessWidget {
  final int index;
  final Widget child;
  const EntradaAnimada({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(
        milliseconds: 400 + (index * 100),
      ), // Retraso progresivo
      curve: Curves.easeOutBack, // Efecto rebote suave
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: child,
    );
  }
}

// =========================================================================
// PANTALLA INTERACTIVA PRINCIPAL (Cambio de fondo a Pastel)
// =========================================================================

class PantallaInteractiva extends StatelessWidget {
  final String idMetodo;
  final String titulo;
  final Color colorCategoria;
  final String textoCompleto;

  const PantallaInteractiva({
    super.key,
    required this.idMetodo,
    required this.titulo,
    required this.colorCategoria,
    required this.textoCompleto,
  });

  @override
  Widget build(BuildContext context) {
    Widget contenido;

    switch (idMetodo) {
      case 'resp_488':
        contenido = _WidgetAnimacion488(color: colorCategoria);
        break;
      case 'resp_diafragmatica':
        contenido = _WidgetAnimacionDiafragmatica(color: colorCategoria);
        break;
      case 'ans_54321':
        contenido = _WidgetInteractivo54321(color: colorCategoria);
        break;
      case 'ans_muscular':
        contenido = _WidgetInteractivoMuscular(color: colorCategoria);
        break;
      case 'tiempo_pomodoro':
        contenido = _WidgetCronometroPomodoro(color: colorCategoria);
        break;
      case 'resp_resoplidos':
        contenido = _WidgetAnimacionResoplidos(color: colorCategoria);
        break;
      case 'consejo_vista':
        contenido = _WidgetAnimacionVista(color: colorCategoria);
        break;
      case 'sueno_descanso':
        contenido = _WidgetInfoSueno(color: colorCategoria);
        break;
      case 'tiempo_matriz':
        contenido = _WidgetMatrizPrioridades(color: colorCategoria);
        break;
      default:
        contenido = _WidgetTextoEstatico(
          texto: textoCompleto,
          color: colorCategoria,
        );
    }

    return Scaffold(
      // 👇 CHAU FONDO NEGRO, HOLA FONDO PASTEL UNIFICADO ✨
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          titulo,
          style: const TextStyle(
            color: Color(0xFF455A64),
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF455A64),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            //cyan a menta ( Ocean Breeze)
            colors: [Color(0xFFE3F2FD), Color(0xFFE8F5E9)],
          ),
        ),
        child: SafeArea(child: contenido),
      ),
    );
  }
}

// =========================================================================
// WIDGETS ANIMADOS (¡Mejorados estéticamente!)
// =========================================================================

class _WidgetTextoEstatico extends StatelessWidget {
  final String texto;
  final Color color;
  const _WidgetTextoEstatico({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF455A64),
            height: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// RESPIRACIÓN 4-8-8 CON EFECTO DE PULSO EXTERIOR ✅
class _WidgetAnimacion488 extends StatefulWidget {
  final Color color;
  const _WidgetAnimacion488({required this.color});
  @override
  State<_WidgetAnimacion488> createState() => _WidgetAnimacion488State();
}

class _WidgetAnimacion488State extends State<_WidgetAnimacion488>
    with TickerProviderStateMixin {
  String instruccion = "Toca el círculo para iniciar 🌸";
  int segundos = 0;
  double tamano = 160;
  bool corriendo = false;
  Duration duracionAnim = const Duration(milliseconds: 500);

  // Controladores de animación para el efecto de pulso
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    corriendo = false;
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> iniciar() async {
    if (corriendo) return;
    corriendo = true;
    while (corriendo) {
      if (!mounted) break;
      setState(() {
        instruccion = "INHALA... (Nariz) 😤";
        tamano = 320;
        duracionAnim = const Duration(seconds: 4);
      });
      await _cuentaRegresiva(4);
      if (!corriendo || !mounted) break;
      setState(() {
        instruccion = "MANTÉN... (Aguanta) ✋";
        tamano = 320;
      });
      await _cuentaRegresiva(8);
      if (!corriendo || !mounted) break;
      setState(() {
        instruccion = "EXHALA... (Boca) 😉";
        tamano = 160;
        duracionAnim = const Duration(seconds: 8);
      });
      await _cuentaRegresiva(8);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _cuentaRegresiva(int max) async {
    for (int i = max; i > 0; i--) {
      if (!mounted || !corriendo) break;
      setState(() {
        segundos = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              instruccion,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: corriendo ? widget.color : const Color(0xFF455A64),
              ),
            ),
          ),
          const SizedBox(height: 60),
          GestureDetector(
            onTap: () {
              if (corriendo) {
                setState(() {
                  corriendo = false;
                  instruccion = "Pausado 🌸";
                  tamano = 160;
                });
              } else {
                iniciar();
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ==========================================
                // 🔥 ANIMACIÓN DE PULSO EXTERIOR ✅
                // ==========================================
                ScaleTransition(
                  scale: corriendo
                      ? _pulseAnimation
                      : const AlwaysStoppedAnimation(1.0),
                  child: AnimatedContainer(
                    duration: duracionAnim,
                    curve: Curves.easeInOut,
                    width: tamano + 20,
                    height: tamano + 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color.withOpacity(0.3),
                        width: 10,
                      ),
                    ),
                  ),
                ),
                // Círculo principal
                AnimatedContainer(
                  duration: duracionAnim,
                  curve: Curves.easeInOut,
                  width: tamano,
                  height: tamano,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: corriendo
                        ? Text(
                            '$segundos',
                            style: const TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.play_arrow_rounded,
                            size: 80,
                            color: Colors.white.withOpacity(0.9),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              "Inhala(4s)  -  Mantén(8s)  -  Exhala(8s)",
              style: TextStyle(
                fontSize: 14,
                color: widget.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// DIAFRAGMÁTICA CON FONDO PASTEL Y DISEÑO REDONDITO ✅
class _WidgetAnimacionDiafragmatica extends StatefulWidget {
  final Color color;
  const _WidgetAnimacionDiafragmatica({required this.color});
  @override
  State<_WidgetAnimacionDiafragmatica> createState() =>
      _WidgetAnimacionDiafragmaticaState();
}

class _WidgetAnimacionDiafragmaticaState
    extends State<_WidgetAnimacionDiafragmatica> {
  bool corriendo = false;
  double elevacion = 0;
  @override
  void dispose() {
    corriendo = false;
    super.dispose();
  }

  Future<void> iniciar() async {
    if (corriendo) return;
    setState(() {
      corriendo = true;
    });
    while (corriendo) {
      if (!mounted) break;
      setState(() {
        elevacion = 100;
      });
      await Future.delayed(const Duration(seconds: 4));
      if (!corriendo || !mounted) break;
      setState(() {
        elevacion = 0;
      });
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            corriendo
                ? (elevacion == 100
                      ? "INHALA LENTO... 😤"
                      : "EXHALA SUAVE... 😉")
                : "Toca para empezar 🌸",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: corriendo ? widget.color : const Color(0xFF455A64),
            ),
          ),
          const SizedBox(height: 80),
          GestureDetector(
            onTap: () {
              if (corriendo) {
                setState(() {
                  corriendo = false;
                  elevacion = 0;
                });
              } else {
                iniciar();
              }
            },
            child: Container(
              width: 150,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: widget.color.withOpacity(0.3),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(75),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: Duration(seconds: elevacion == 100 ? 4 : 5),
                curve: Curves.easeInOutSine,
                height: 150 + elevacion,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color.withOpacity(0.6), widget.color],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(75),
                ),
                child: Center(
                  child: !corriendo
                      ? Icon(
                          Icons.play_arrow_rounded,
                          size: 70,
                          color: Colors.white.withOpacity(0.9),
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // 👇 AQUÍ ESTÁ EL CONTENEDOR YA CORREGIDO ✨
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              "Concéntrate en hacer que el indicador suba llenando tu abdomen de aire.",
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey.shade400,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MUSCULAR CON BOTÓN KAWAIISTYLE Y COLORES RELAJANTES ✅
class _WidgetInteractivoMuscular extends StatefulWidget {
  final Color color;
  const _WidgetInteractivoMuscular({required this.color});
  @override
  State<_WidgetInteractivoMuscular> createState() =>
      _WidgetInteractivoMuscularState();
}

class _WidgetInteractivoMuscularState
    extends State<_WidgetInteractivoMuscular> {
  int pasoActual = -1;
  bool tensando = true;
  final List<String> partesCuerpo = [
    'Pies',
    'Piernas',
    'Glúteos',
    'Abdomen',
    'Brazos',
    'Manos',
    'Hombros',
    'Rostro',
  ];
  Future<void> iniciarSecuencia() async {
    for (int i = 0; i < partesCuerpo.length; i++) {
      if (!mounted) break;
      setState(() {
        pasoActual = i;
        tensando = true;
      });
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) break;
      setState(() {
        tensando = false;
      });
      await Future.delayed(const Duration(seconds: 5));
    }
    if (mounted) {
      setState(() {
        pasoActual = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: pasoActual == -1
          ? ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                padding: const EdgeInsets.all(22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: iniciarSecuencia,
              icon: const Icon(
                Icons.accessibility_new_rounded,
                color: Colors.white,
              ),
              label: const Text(
                "INICIAR RECORRIDO ✨",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tensando ? "TENSA 🔥" : "RELAJA 🌸",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                    color: tensando
                        ? const Color(0xFFEF5350)
                        : const Color(0xFF81C784),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    partesCuerpo[pasoActual],
                    key: ValueKey(partesCuerpo[pasoActual]),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF455A64),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                CircularProgressIndicator(
                  color: tensando ? const Color(0xFFEF5350) : widget.color,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 30),
                Text(
                  tensando
                      ? "Mantén la tensión por 5s"
                      : "Suelta toda la tensión por 5s",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

// 5-4-3-2-1 CON DISEÑO DE BURBUJAS Y BOTÓN OCEAN BREEZE ✅
class _WidgetInteractivo54321 extends StatefulWidget {
  final Color color;
  const _WidgetInteractivo54321({required this.color});
  @override
  State<_WidgetInteractivo54321> createState() =>
      _WidgetInteractivo54321State();
}

class _WidgetInteractivo54321State extends State<_WidgetInteractivo54321> {
  int pasoActual = 0;
  final List<Map<String, String>> pasos = [
    {
      'num': '5',
      'verbo': 'OBSERVA 👀',
      'desc': 'cosas que puedas ver a tu alrededor.',
    },
    {
      'num': '4',
      'verbo': 'TOCA ✋',
      'desc': 'cosas físicas (tu ropa, una mesa).',
    },
    {
      'num': '3',
      'verbo': 'ESCUCHA 👂',
      'desc': 'sonidos (lejanos o cercanos).',
    },
    {'num': '2', 'verbo': 'HUELE 👃', 'desc': 'aromas en el ambiente o en ti.'},
    {
      'num': '1',
      'verbo': 'SABOREA 👅',
      'desc': 'un sabor (chicle, café, o tu boca).',
    },
  ];
  @override
  Widget build(BuildContext context) {
    final paso = pasos[pasoActual];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Regresa al presente 🌸",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              paso['num']!,
              key: ValueKey(pasoActual),
              style: TextStyle(
                fontSize: 140,
                fontWeight: FontWeight.w900,
                color: widget.color,
              ),
            ),
          ),
          Text(
            paso['verbo']!,
            style: const TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.w900,
              color: Color(0xFF455A64),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              paso['desc']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF455A64),
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                setState(() {
                  pasoActual = (pasoActual + 1) % pasos.length;
                });
              },
              child: Text(
                pasoActual == 4 ? "REPETIR 🌸" : "SIGUIENTE PASO ✨",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// POMODORO CON DISEÑO LIMPIO Y COLORES OCEAN BREEZE ✅
class _WidgetCronometroPomodoro extends StatefulWidget {
  final Color color;
  const _WidgetCronometroPomodoro({required this.color});
  @override
  State<_WidgetCronometroPomodoro> createState() =>
      _WidgetCronometroPomodoroState();
}

class _WidgetCronometroPomodoroState extends State<_WidgetCronometroPomodoro> {
  int segundosTotales = 25 * 60;
  Timer? timer;
  bool corriendo = false;
  bool esTrabajo = true;
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void iniciarDetener() {
    if (corriendo) {
      timer?.cancel();
      setState(() => corriendo = false);
    } else {
      corriendo = true;
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (segundosTotales > 0) {
          setState(() => segundosTotales--);
        } else {
          t.cancel();
          setState(() {
            esTrabajo = !esTrabajo;
            segundosTotales = (esTrabajo ? 25 : 5) * 60;
            corriendo = false;
          });
        }
      });
    }
  }

  String get tiempoFormateado {
    int min = segundosTotales ~/ 60;
    int seg = segundosTotales % 60;
    return '${min.toString().padLeft(2, '0')}:${seg.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    Color colorActual = esTrabajo
        ? widget.color
        : const Color(0xFFB3E5FC); //azul sueño
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: colorActual.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: colorActual, width: 2),
            ),
            child: Text(
              esTrabajo ? "TIEMPO DE TRABAJO 🧠" : "DESCANSO CORTO 🌸",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: colorActual,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            tiempoFormateado,
            style: const TextStyle(
              fontSize: 110,
              fontWeight: FontWeight.w900,
              color: Color(0xFF455A64),
            ),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton.large(
                backgroundColor: colorActual,
                elevation: 5,
                shape: const CircleBorder(),
                onPressed: iniciarDetener,
                child: Icon(
                  corriendo ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 30),
              FloatingActionButton(
                backgroundColor: Colors.white,
                elevation: 3,
                shape: const CircleBorder(),
                onPressed: () {
                  timer?.cancel();
                  setState(() {
                    corriendo = false;
                    esTrabajo = true;
                    segundosTotales = 25 * 60;
                  });
                },
                child: const Icon(Icons.refresh_rounded, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// WIDGETS DE LOS 4 NUEVOS MÉTODOS (¡Mejorados visualmente!) ✅
// =========================================================================

// 1. Resoplidos rápidos (Animación de pulsar 3 veces rápido)
class _WidgetAnimacionResoplidos extends StatefulWidget {
  final Color color;
  const _WidgetAnimacionResoplidos({required this.color});
  @override
  State<_WidgetAnimacionResoplidos> createState() =>
      _WidgetAnimacionResoplidosState();
}

class _WidgetAnimacionResoplidosState
    extends State<_WidgetAnimacionResoplidos> {
  String instruccion = "Toca para empezar 🌸";
  double escala = 1.0;
  bool corriendo = false;

  @override
  void dispose() {
    corriendo = false;
    super.dispose();
  }

  Future<void> iniciar() async {
    if (corriendo) return;
    setState(() {
      corriendo = true;
    });

    while (corriendo) {
      if (!mounted) break;
      setState(() {
        instruccion = "INHALA PROFUNDO... 😤";
        escala = 1.6;
      });
      await Future.delayed(const Duration(seconds: 3));

      for (int i = 0; i < 3; i++) {
        if (!corriendo || !mounted) break;
        setState(() {
          instruccion = "¡RESOPLA! 💨";
          escala = 1.9;
        });
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          escala = 1.6;
        });
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (!corriendo || !mounted) break;
      setState(() {
        instruccion = "EXHALA LENTO... 😉";
        escala = 1.0;
      });
      await Future.delayed(const Duration(seconds: 4));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              instruccion,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: corriendo ? widget.color : const Color(0xFF455A64),
              ),
            ),
          ),
          const SizedBox(height: 80),
          GestureDetector(
            onTap: () {
              if (corriendo) {
                setState(() {
                  corriendo = false;
                  instruccion = "Pausado 🌸";
                  escala = 1.0;
                });
              } else {
                iniciar();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 120 * escala,
              height: 120 * escala,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  corriendo ? Icons.air_rounded : Icons.play_arrow_rounded,
                  size: 60,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              "3 Resoplidos seguidos por la nariz",
              style: TextStyle(
                fontSize: 14,
                color: widget.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 2. Cuidar la vista (Temporizador 20 segundos) con diseño Nube ✅
class _WidgetAnimacionVista extends StatefulWidget {
  final Color color;
  const _WidgetAnimacionVista({required this.color});
  @override
  State<_WidgetAnimacionVista> createState() => _WidgetAnimacionVistaState();
}

class _WidgetAnimacionVistaState extends State<_WidgetAnimacionVista> {
  int segundos = 20;
  bool activo = false;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void iniciar() {
    setState(() => activo = true);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (segundos > 0 && activo) {
        setState(() => segundos--);
      } else {
        t.cancel();
        setState(() {
          activo = false;
          segundos = 20;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Mira un objeto a\n6 metros de distancia 👀",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: activo ? widget.color : const Color(0xFF455A64),
            ),
          ),
          const SizedBox(height: 50),
          Text(
            segundos.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 140,
              fontWeight: FontWeight.w900,
              color: activo ? widget.color : Colors.white,
              shadows: activo
                  ? null
                  : [
                      BoxShadow(
                        color: widget.color.withOpacity(0.5),
                        blurRadius: 15,
                      ),
                    ],
            ),
          ),
          const SizedBox(height: 50),
          SizedBox(
            width: 250,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              onPressed: activo ? null : iniciar,
              child: const Text(
                "INICIAR 20 SEG ✨",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. Consejos para un buen descanso (Tarjetas Visuales Kawaii) ✅
class _WidgetInfoSueno extends StatelessWidget {
  final Color color;
  const _WidgetInfoSueno({required this.color});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        _crearTarjeta(
          Icons.phone_android_rounded,
          "Desconexión",
          "Evita pantallas al menos 30 minutos antes de dormir.",
        ),
        _crearTarjeta(
          Icons.brightness_3_rounded,
          "Filtro Nocturno",
          "Activa el modo lectura o filtro amarillo en tus dispositivos por las noches.",
        ),
        _crearTarjeta(
          Icons.access_time_filled_rounded,
          "Rutina Fija",
          "Intenta acostarte y levantarte a la misma hora todos los días.",
        ),
      ],
    );
  }

  Widget _crearTarjeta(IconData icono, String titulo, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: color, size: 36),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF455A64),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 4. Matriz de Prioridades (Cuadrícula 2x2 Estilo Nube) ✅
class _WidgetMatrizPrioridades extends StatelessWidget {
  final Color color;
  const _WidgetMatrizPrioridades({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              "Clasifica tus tareas cuando te sientas saturado 🤯",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(), // No se scrollea
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _crearCuadrante(
                  "¡HAZLO YA!",
                  "Urgente e Importante",
                  const Color(0xFFEF5350),
                ), // Rojo suave
                _crearCuadrante(
                  "PLANIFÍCALO",
                  "Importante, NO Urgente",
                  const Color(0xFF81C784),
                ), // Verde suave
                _crearCuadrante(
                  "DELÉGALO",
                  "Urgente, NO Importante",
                  const Color(0xFFFFB74D),
                ), // Naranja suave
                _crearCuadrante(
                  "ELIMÍNALO",
                  "Ni Urgente ni Importante",
                  const Color(0xFFB0BEC5),
                ), // Gris suave
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _crearCuadrante(String titulo, String subtitulo, Color c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: c.withOpacity(0.4), width: 2),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: c.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF455A64),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
