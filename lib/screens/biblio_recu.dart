import 'dart:async';
import 'package:flutter/material.dart';

class BiblioRecu extends StatelessWidget {
  const BiblioRecu({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos las categorías con los IDs para las animaciones
    final List<Map<String, dynamic>> categorias = [
      {
        'titulo': 'Respiración',
        'icono': Icons.air,
        'color': const Color.fromARGB(255, 236, 150, 229),
        'descripcion': 'Ejercicios prácticos para el control fisiológico del estrés.',
        'secciones': <Map<String, String>>[
          {
            'id': 'resp_diafragmatica',
            'subtitulo': 'Respiración diafragmática',
            'texto': 'Uso: Relaja la tensión y músculos abdominales.\n\nPasos:\n• Acuéstese o siéntese cómodamente.\n• Coloque una mano sobre el abdomen.\n• Inhale y exhale lentamente guiado por la animación.'
          },
          {
            'id': 'resp_488',
            'subtitulo': 'Respiro profundo 4-8-8',
            'texto': 'Uso: Aumenta el oxígeno y calma rápido.\n\nPasos:\n• Inhala por la nariz 4s.\n• Aguanta 8s.\n• Exhala por la boca 8s.'
          },
          {
            'id': 'resp_resoplidos', // <-- AHORA TIENE ANIMACIÓN
            'subtitulo': 'Resoplidos rápidos',
            'texto': 'Uso: Fortalece el diafragma.\n\nPasos:\n• Inhale profundo.\n• Resople 3 veces rápido (sin exhalar).\n• Exhale lento.\n• Repita 3 veces.'
          },
        ]
      },
      {
        'titulo': 'Ansiedad',
        'icono': Icons.favorite_border,
        'color': const Color(0xFFC7CEEA),
        'descripcion': 'Herramientas rápidas para momentos de crisis o estrés elevado.',
        'secciones': <Map<String, String>>[
          {
            'id': 'ans_54321',
            'subtitulo': 'Técnica 5-4-3-2-1 (Aterrizaje sensorial)',
            'texto': 'Uso: Regresa al presente cuando la ansiedad sube.\n\nPasos:\nBusca 5 cosas que veas, 4 que toques, 3 escuches, 2 huelas y 1 saborees.'
          },
          {
            'id': 'ans_muscular',
            'subtitulo': 'Relajación muscular progresiva',
            'texto': 'Uso: Libera la tensión física.\n\nPasos:\nTensa diferentes partes del cuerpo por 5s y suelta, siguiendo la guía.'
          },
        ]
      },
      {
        'titulo': 'Consejos y Hábitos',
        'icono': Icons.lightbulb_outline,
        'color': const Color(0xFFFFDAC1),
        'descripcion': 'Recomendaciones para el bienestar general durante el estudio.',
        'secciones': <Map<String, String>>[
          {
            'id': 'consejo_vista', // <-- AHORA TIENE ANIMACIÓN (TEMPORIZADOR)
            'subtitulo': 'Cuidar la vista (Regla 20-20-20)',
            'texto': 'Uso: Evita fatiga visual ante pantallas.\n\nLa regla:\nCada 20 minutos, mira un objeto a 6 metros por 20 segundos.'
          },
        ]
      },
      {
        'titulo': 'Higiene del Sueño',
        'icono': Icons.bedtime,
        'color': const Color(0xFFA0C4FF),
        'descripcion': 'Enfoque en el descanso para mejor rendimiento.',
        'secciones': <Map<String, String>>[
          {
            'id': 'sueno_descanso', // <-- AHORA ES VISUAL
            'subtitulo': 'Consejos para un buen descanso',
            'texto': '• Desconexión: Evita pantallas 30min antes de dormir.\n• Filtro nocturno: Activa modo lectura.\n• Rutina: Acuéstate y levántate a la misma hora.'
          },
        ]
      },
      {
        'titulo': 'Organización del Tiempo',
        'icono': Icons.schedule,
        'color': const Color(0xFFFFB7B2),
        'descripcion': 'Estrategias para gestionar la carga académica.',
        'secciones': <Map<String, String>>[
          {
            'id': 'tiempo_pomodoro',
            'subtitulo': 'Técnica Pomodoro',
            'texto': 'Uso: Alta concentración en tareas.\n\nPasos:\nTrabaja 25min sin distracciones, descansa 5min.'
          },
          {
            'id': 'tiempo_matriz', // <-- AHORA ES VISUAL (CUADRÍCULA)
            'subtitulo': 'Matriz de Prioridades',
            'texto': 'Uso: Clasifica tareas si te sientes saturado.\n\n• Urgente/Importante: Hazlo ya.\n• Importante/No Urgente: Planifícalo.\n• Urgente/No Importante: Delégalo/Hazlo rápido.\n• Ni Urgente ni Importante: Elimínalo.'
          },
        ]
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Biblioteca de Recursos',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.1,
          ),
          itemCount: categorias.length,
          itemBuilder: (context, index) {
            final cat = categorias[index];
            return GestureDetector(
              onTap: () {
                _mostrarDetalleCategoria(
                  context,
                  cat['titulo'],
                  cat['descripcion'],
                  cat['secciones'] as List<Map<String, String>>,
                  cat['color'],
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: cat['color'],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cat['icono'], size: 48, color: Colors.black54),
                    const SizedBox(height: 12),
                    Text(
                      cat['titulo'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _mostrarDetalleCategoria(BuildContext context, String titulo, String descripcion, List<Map<String, String>> secciones, Color colorCategoria) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            titulo.toUpperCase(),
            style: TextStyle(fontFamily: 'Montserrat', color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SizedBox(
            width: double.maxFinite, 
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(descripcion, style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black87)),
                  const SizedBox(height: 20),
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
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorCategoria.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: colorCategoria, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(seccion['subtitulo']!, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                                  const SizedBox(height: 4),
                                  Text(
                                    seccion['texto']!.split('\n\n')[0],
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.play_circle_outline, color: Theme.of(context).colorScheme.primary, size: 30),
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
              child: Text('CERRAR', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}

// =========================================================================
// PANTALLA INTERACTIVA PRINCIPAL (AQUÍ AÑADÍ LAS RUTAS NUEVAS)
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
      // Las que ya estaban bien:
      case 'resp_488': contenido = _WidgetAnimacion488(color: colorCategoria); break;
      case 'resp_diafragmatica': contenido = _WidgetAnimacionDiafragmatica(color: colorCategoria); break;
      case 'ans_54321': contenido = _WidgetInteractivo54321(color: colorCategoria); break;
      case 'ans_muscular': contenido = _WidgetInteractivoMuscular(color: colorCategoria); break;
      case 'tiempo_pomodoro': contenido = _WidgetCronometroPomodoro(color: colorCategoria); break;
      
      // LAS 4 NUEVAS QUE ACABO DE AÑADIR:
      case 'resp_resoplidos': contenido = _WidgetAnimacionResoplidos(color: colorCategoria); break;
      case 'consejo_vista': contenido = _WidgetAnimacionVista(color: colorCategoria); break;
      case 'sueno_descanso': contenido = _WidgetInfoSueno(color: colorCategoria); break;
      case 'tiempo_matriz': contenido = _WidgetMatrizPrioridades(color: colorCategoria); break;
      
      default: contenido = _WidgetTextoEstatico(texto: textoCompleto, color: colorCategoria);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), 
      appBar: AppBar(
        title: Text(titulo, style: const TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: contenido,
    );
  }
}

// =========================================================================
// WIDGETS QUE YA ESTABAN BIEN (NO SE MOVIERON)
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
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2)
        ),
        child: Text(texto, style: const TextStyle(fontFamily: 'Inter', fontSize: 18, color: Colors.white, height: 1.5, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _WidgetAnimacion488 extends StatefulWidget {
  final Color color;
  const _WidgetAnimacion488({required this.color});
  @override State<_WidgetAnimacion488> createState() => _WidgetAnimacion488State();
}
class _WidgetAnimacion488State extends State<_WidgetAnimacion488> {
  String instruccion = "Toca el círculo para iniciar";
  int segundos = 0; double tamano = 150; bool corriendo = false;
  Duration duracionAnim = const Duration(milliseconds: 500);

  @override void dispose() { corriendo = false; super.dispose(); }

  Future<void> iniciar() async {
    if (corriendo) return;
    corriendo = true;
    while (corriendo) {
      if (!mounted) break;
      setState(() { instruccion = "INHALA..."; tamano = 320; duracionAnim = const Duration(seconds: 4); });
      await _cuentaRegresiva(4);
      if (!corriendo || !mounted) break;
      setState(() { instruccion = "MANTÉN..."; tamano = 320; }); 
      await _cuentaRegresiva(8);
      if (!corriendo || !mounted) break;
      setState(() { instruccion = "EXHALA..."; tamano = 150; duracionAnim = const Duration(seconds: 8); });
      await _cuentaRegresiva(8);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _cuentaRegresiva(int max) async {
    for (int i = max; i > 0; i--) {
      if (!mounted || !corriendo) break;
      setState(() { segundos = i; });
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(instruccion, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(height: 60),
          GestureDetector(
            onTap: () { if (corriendo) { setState(() { corriendo = false; instruccion = "Pausado"; tamano = 150; }); } else { iniciar(); } },
            child: AnimatedContainer(
              duration: duracionAnim, curve: Curves.easeInOut,
              width: tamano, height: tamano,
              decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color, boxShadow: [BoxShadow(color: widget.color.withOpacity(0.6), blurRadius: 40, spreadRadius: 15)]),
              child: Center(child: corriendo ? Text('$segundos', style: const TextStyle(fontFamily: 'Inter', fontSize: 70, fontWeight: FontWeight.bold, color: Colors.black87)) : const Icon(Icons.play_arrow_rounded, size: 80, color: Colors.black87)),
            ),
          ),
          const SizedBox(height: 60),
          const Text("Inhala(4s)  -  Mantén(8s)  -  Exhala(8s)", style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.white70)),
        ],
      ),
    );
  }
}

class _WidgetAnimacionDiafragmatica extends StatefulWidget {
  final Color color;
  const _WidgetAnimacionDiafragmatica({required this.color});
  @override State<_WidgetAnimacionDiafragmatica> createState() => _WidgetAnimacionDiafragmaticaState();
}
class _WidgetAnimacionDiafragmaticaState extends State<_WidgetAnimacionDiafragmatica> {
  bool corriendo = false; double elevacion = 0; 
  @override void dispose() { corriendo = false; super.dispose(); }
  Future<void> iniciar() async {
    if (corriendo) return;
    setState(() { corriendo = true; });
    while (corriendo) {
      if (!mounted) break;
      setState(() { elevacion = 100; });
      await Future.delayed(const Duration(seconds: 4));
      if (!corriendo || !mounted) break;
      setState(() { elevacion = 0; });
      await Future.delayed(const Duration(seconds: 5));
    }
  }
  @override Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(corriendo ? (elevacion == 100 ? "INHALA LENTO..." : "EXHALA SUAVE...") : "Toca para empezar", style: const TextStyle(fontFamily: 'Montserrat', fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 80),
          GestureDetector(
            onTap: () { if (corriendo) { setState(() { corriendo = false; elevacion = 0; }); } else { iniciar(); } },
            child: Container(
              width: 150, height: 250,
              decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: widget.color, width: 3), borderRadius: BorderRadius.circular(75)),
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: Duration(seconds: elevacion == 100 ? 4 : 5), curve: Curves.easeInOutSine,
                height: 150 + elevacion,
                decoration: BoxDecoration(color: widget.color.withOpacity(0.8), borderRadius: BorderRadius.circular(75)),
                child: Center(child: !corriendo ? const Icon(Icons.play_arrow, size: 60, color: Colors.black87) : null),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: Text("Concéntrate en hacer que el indicador suba llenando tu abdomen de aire.", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.white70))),
        ],
      ),
    );
  }
}

class _WidgetInteractivoMuscular extends StatefulWidget {
  final Color color;
  const _WidgetInteractivoMuscular({required this.color});
  @override State<_WidgetInteractivoMuscular> createState() => _WidgetInteractivoMuscularState();
}
class _WidgetInteractivoMuscularState extends State<_WidgetInteractivoMuscular> {
  int pasoActual = -1; bool tensando = true;
  final List<String> partesCuerpo = ['Pies', 'Piernas', 'Glúteos', 'Abdomen', 'Brazos', 'Manos', 'Hombros', 'Rostro'];
  Future<void> iniciarSecuencia() async {
    for (int i = 0; i < partesCuerpo.length; i++) {
      if (!mounted) break;
      setState(() { pasoActual = i; tensando = true; });
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) break;
      setState(() { tensando = false; });
      await Future.delayed(const Duration(seconds: 5));
    }
    if (mounted) { setState(() { pasoActual = -1; }); }
  }
  @override Widget build(BuildContext context) {
    return Center(
      child: pasoActual == -1
      ? ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: widget.color, padding: const EdgeInsets.all(20)), onPressed: iniciarSecuencia, child: const Text("INICIAR RECORRIDO", style: TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)))
      : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tensando ? "TENSA" : "RELAJA", style: TextStyle(fontFamily: 'Montserrat', fontSize: 50, fontWeight: FontWeight.w900, color: tensando ? Colors.redAccent : widget.color)),
            const SizedBox(height: 20),
            AnimatedSwitcher(duration: const Duration(milliseconds: 500), child: Text(partesCuerpo[pasoActual], key: ValueKey(partesCuerpo[pasoActual]), style: const TextStyle(fontFamily: 'Montserrat', fontSize: 40, color: Colors.white))),
            const SizedBox(height: 60),
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            const SizedBox(height: 20),
            Text(tensando ? "Mantén la tensión por 5s" : "Suelta toda la tensión por 5s", style: const TextStyle(color: Colors.white70, fontSize: 18)),
          ],
        ),
    );
  }
}

class _WidgetInteractivo54321 extends StatefulWidget {
  final Color color;
  const _WidgetInteractivo54321({required this.color});
  @override State<_WidgetInteractivo54321> createState() => _WidgetInteractivo54321State();
}
class _WidgetInteractivo54321State extends State<_WidgetInteractivo54321> {
  int pasoActual = 0;
  final List<Map<String, String>> pasos = [
    {'num': '5', 'verbo': 'OBSERVA', 'desc': 'cosas que puedas ver a tu alrededor.'},
    {'num': '4', 'verbo': 'TOCA', 'desc': 'cosas físicas (tu ropa, una mesa).'},
    {'num': '3', 'verbo': 'ESCUCHA', 'desc': 'sonidos (lejanos o cercanos).'},
    {'num': '2', 'verbo': 'HUELE', 'desc': 'aromas en el ambiente o en ti.'},
    {'num': '1', 'verbo': 'SABOREA', 'desc': 'un sabor (chicle, café, o tu boca).'},
  ];
  @override Widget build(BuildContext context) {
    final paso = pasos[pasoActual];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Técnica de Aterrizaje", style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: Colors.white70)),
          const SizedBox(height: 10),
          AnimatedSwitcher(duration: const Duration(milliseconds: 300), transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child), child: Text(paso['num']!, key: ValueKey(pasoActual), style: TextStyle(fontFamily: 'Montserrat', fontSize: 140, fontWeight: FontWeight.bold, color: widget.color))),
          Text(paso['verbo']!, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          Text(paso['desc']!, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Inter', fontSize: 22, color: Colors.white70, height: 1.4)),
          const SizedBox(height: 60),
          SizedBox(width: double.infinity, height: 60, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: widget.color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: () { setState(() { pasoActual = (pasoActual + 1) % pasos.length; }); }, child: Text(pasoActual == 4 ? "REPETIR" : "SIGUIENTE PASO", style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black))))
        ],
      ),
    );
  }
}

class _WidgetCronometroPomodoro extends StatefulWidget {
  final Color color;
  const _WidgetCronometroPomodoro({required this.color});
  @override State<_WidgetCronometroPomodoro> createState() => _WidgetCronometroPomodoroState();
}
class _WidgetCronometroPomodoroState extends State<_WidgetCronometroPomodoro> {
  int segundosTotales = 25 * 60; Timer? timer; bool corriendo = false; bool esTrabajo = true;
  @override void dispose() { timer?.cancel(); super.dispose(); }
  void iniciarDetener() {
    if (corriendo) { timer?.cancel(); setState(() => corriendo = false);
    } else {
      corriendo = true;
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (segundosTotales > 0) { setState(() => segundosTotales--);
        } else {
          t.cancel();
          setState(() { esTrabajo = !esTrabajo; segundosTotales = (esTrabajo ? 25 : 5) * 60; corriendo = false; });
        }
      });
    }
  }
  String get tiempoFormateado {
    int min = segundosTotales ~/ 60; int seg = segundosTotales % 60;
    return '${min.toString().padLeft(2, '0')}:${seg.toString().padLeft(2, '0')}';
  }
  @override Widget build(BuildContext context) {
    Color colorActual = esTrabajo ? widget.color : const Color(0xFFA0C4FF);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), decoration: BoxDecoration(color: colorActual.withOpacity(0.3), borderRadius: BorderRadius.circular(20), border: Border.all(color: colorActual)), child: Text(esTrabajo ? "TIEMPO DE TRABAJO" : "DESCANSO CORTO", style: TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.bold, color: colorActual))),
          const SizedBox(height: 40),
          Text(tiempoFormateado, style: const TextStyle(fontFamily: 'Inter', fontSize: 110, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton.large(backgroundColor: colorActual, onPressed: iniciarDetener, child: Icon(corriendo ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 60, color: Colors.black)),
              const SizedBox(width: 30),
              FloatingActionButton(backgroundColor: Colors.grey[800], onPressed: () { timer?.cancel(); setState(() { corriendo = false; esTrabajo = true; segundosTotales = 25 * 60; }); }, child: const Icon(Icons.refresh_rounded, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// LAS 4 NUEVAS CLASES ANIMADAS / VISUALES (REEMPLAZANDO LOS TEXTOS ESTÁTICOS)
// =========================================================================

// 1. Resoplidos rápidos (Animación de pulsar 3 veces rápido)
class _WidgetAnimacionResoplidos extends StatefulWidget {
  final Color color;
  const _WidgetAnimacionResoplidos({required this.color});
  @override State<_WidgetAnimacionResoplidos> createState() => _WidgetAnimacionResoplidosState();
}
class _WidgetAnimacionResoplidosState extends State<_WidgetAnimacionResoplidos> {
  String instruccion = "Toca para empezar";
  double escala = 1.0;
  bool corriendo = false;

  @override void dispose() { corriendo = false; super.dispose(); }

  Future<void> iniciar() async {
    if (corriendo) return;
    setState(() { corriendo = true; });

    while (corriendo) {
      if (!mounted) break;
      setState(() { instruccion = "INHALA PROFUNDO..."; escala = 1.8; });
      await Future.delayed(const Duration(seconds: 3));

      for (int i = 0; i < 3; i++) {
        if (!corriendo || !mounted) break;
        setState(() { instruccion = "¡RESOPLA!"; escala = 2.2; });
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() { escala = 1.8; });
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (!corriendo || !mounted) break;
      setState(() { instruccion = "EXHALA LENTO..."; escala = 1.0; });
      await Future.delayed(const Duration(seconds: 4));
    }
  }

  @override Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(instruccion, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 80),
          GestureDetector(
            onTap: () { if (corriendo) { setState(() { corriendo = false; instruccion = "Pausado"; escala = 1.0; }); } else { iniciar(); } },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 120 * escala, height: 120 * escala,
              decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color, boxShadow: [BoxShadow(color: widget.color.withOpacity(0.5), blurRadius: 40)]),
              child: Center(child: Icon(corriendo ? Icons.air : Icons.play_arrow_rounded, size: 60, color: Colors.black87)),
            ),
          ),
          const SizedBox(height: 80),
          const Text("3 Resoplidos seguidos por la nariz", style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.white70)),
        ],
      ),
    );
  }
}

// 2. Cuidar la vista (Temporizador 20 segundos)
class _WidgetAnimacionVista extends StatefulWidget {
  final Color color;
  const _WidgetAnimacionVista({required this.color});
  @override State<_WidgetAnimacionVista> createState() => _WidgetAnimacionVistaState();
}
class _WidgetAnimacionVistaState extends State<_WidgetAnimacionVista> {
  int segundos = 20;
  bool activo = false;
  Timer? timer;

  @override void dispose() { timer?.cancel(); super.dispose(); }

  void iniciar() {
    setState(() => activo = true);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (segundos > 0 && activo) {
        setState(() => segundos--);
      } else {
        t.cancel();
        setState(() { activo = false; segundos = 20; });
      }
    });
  }

  @override Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Mira un objeto a\n6 metros de distancia", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 50),
          Text(segundos.toString().padLeft(2, '0'), style: TextStyle(fontFamily: 'Inter', fontSize: 140, fontWeight: FontWeight.w900, color: widget.color)),
          const SizedBox(height: 50),
          SizedBox(
            width: 250, height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: widget.color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              onPressed: activo ? null : iniciar,
              child: const Text("INICIAR 20 SEG", style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. Consejos para un buen descanso (Tarjetas Visuales)
class _WidgetInfoSueno extends StatelessWidget {
  final Color color;
  const _WidgetInfoSueno({required this.color});

  @override Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _crearTarjeta(Icons.phone_android, "Desconexión", "Evita pantallas al menos 30 minutos antes de dormir."),
        _crearTarjeta(Icons.brightness_3, "Filtro Nocturno", "Activa el modo lectura o filtro de luz amarilla en tus dispositivos por las noches."),
        _crearTarjeta(Icons.access_time, "Rutina Fija", "Intenta acostarte y levantarte a la misma hora todos los días."),
      ],
    );
  }

  Widget _crearTarjeta(IconData icono, String titulo, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(20), border: Border.all(color: color, width: 2)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icono, color: color, size: 36)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(fontFamily: 'Inter', color: Colors.white70, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 4. Matriz de Prioridades (Cuadrícula 2x2)
class _WidgetMatrizPrioridades extends StatelessWidget {
  final Color color;
  const _WidgetMatrizPrioridades({required this.color});

  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("Clasifica tus tareas cuando te sientas saturado", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: Colors.white70)),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.9,
              children: [
                _crearCuadrante("¡HAZLO YA!", "Urgente e Importante", const Color(0xFFFF6B6B)), // Rojo
                _crearCuadrante("PLANIFÍCALO", "Importante, NO Urgente", const Color(0xFF4ECDC4)), // Verde/Teal
                _crearCuadrante("DELÉGALO", "Urgente, NO Importante", const Color(0xFFFFD93D)), // Amarillo
                _crearCuadrante("ELIMÍNALO", "Ni Urgente ni Importante", const Color(0xFF95A5A6)), // Gris
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
      decoration: BoxDecoration(color: c.withOpacity(0.15), border: Border.all(color: c, width: 2), borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(titulo, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Montserrat', color: c, fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 12),
          Text(subtitulo, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}