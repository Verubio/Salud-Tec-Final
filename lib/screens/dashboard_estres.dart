import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';

class DashboardEstres extends StatefulWidget {
  final int idUsuario;

  const DashboardEstres({super.key, required this.idUsuario});

  @override
  State<DashboardEstres> createState() => _DashboardEstresState();
}

class _DashboardEstresState extends State<DashboardEstres>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _datosEstres;
  List<dynamic> _tareasActivas = [];

  bool _cargando = true;
  bool _mostrarCelebracion = false;

  late AnimationController _celebracionController;
  late Animation<double> _celebracionAnim;

  @override
  void initState() {
    super.initState();

    _celebracionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _celebracionAnim = CurvedAnimation(
      parent: _celebracionController,
      curve: Curves.elasticOut,
    );

    _cargarTodo();
  }

  @override
  void dispose() {
    _celebracionController.dispose();
    super.dispose();
  }

  // ==========================================
  // 🔥 CARGA TOTAL DEL DASHBOARD
  // ==========================================
  Future<void> _cargarTodo() async {
    setState(() => _cargando = true);

    try {
      final resultados = await Future.wait([
        http.get(
          Uri.parse(
            "${ApiConfig.baseUrl}/alumno/${widget.idUsuario}/prediccion_estres",
          ),
        ),

        http.get(
          Uri.parse("${ApiConfig.baseUrl}/alumno/${widget.idUsuario}/eventos"),
        ),
      ]);

      if (resultados[0].statusCode == 200 && resultados[1].statusCode == 200) {
        final datosEstres = jsonDecode(resultados[0].body);

        final eventos =
            jsonDecode(resultados[1].body)['eventos'] as List<dynamic>;

        // ==========================================
        // 🔥 FILTRO DE URGENCIA (5 DÍAS)
        // ==========================================
        final ahora = DateTime.now();

        final eventosUrgentes = eventos.where((evento) {
          final fecha = DateTime.parse(evento['fecha_entrega']);

          final diferencia = fecha.difference(ahora).inDays;

          return diferencia <= 5;
        }).toList();

        if (!mounted) return;

        setState(() {
          _datosEstres = datosEstres;
          _tareasActivas = eventosUrgentes;
          _cargando = false;
        });
      } else {
        // EL PARACAÍDAS
        debugPrint("❌ ERROR DEL BACKEND:");
        debugPrint(
          "Endpoint Estrés Status: ${resultados[0].statusCode} | Body: ${resultados[0].body}",
        );
        debugPrint(
          "Endpoint Tareas Status: ${resultados[1].statusCode} | Body: ${resultados[1].body}",
        );

        if (mounted) {
          setState(() => _cargando = false); // Para quitar la ruedita infinita
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error al cargar los datos del servidor"),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error Dashboard: $e");

      if (!mounted) return;

      setState(() {
        _cargando = false;
      });
    }
  }

  // ==========================================
  // 🔥 COLOR SEGÚN CARGA
  // ==========================================
  Color _obtenerColorCarga(double valor) {
    if (valor < 30) return Colors.green;
    if (valor < 70) return Colors.orange;
    return Colors.red;
  }

  // ==========================================
  // 🔥 COLOR SEGÚN ESTRÉS
  // ==========================================
  Color _obtenerColorNivel(String nivel) {
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

  // ==========================================
  // 🔥 TEXTO EXPLICATIVO DEL ESTRÉS
  // ==========================================
  String _explicacionEstres() {
    final nivel = _datosEstres?['nivel'] ?? "Bajo";

    switch (nivel) {
      case "Moderado":
        return "Tu carga académica empieza a subir. Prioriza pendientes importantes.";

      case "Alto":
        return "Se detectó una combinación de carga académica y presión emocional elevada.";

      case "Critico":
        return "Tu semana parece bastante intensa. Considera descansar y dividir tareas.";

      default:
        return "Tu semana se ve estable y manejable 🌿";
    }
  }

  // ==========================================
  // 🔥 COMPLETAR TAREA
  // ==========================================
  Future<void> _completarTarea(int idEvento) async {
    try {
      final response = await http.patch(
        Uri.parse(
          "${ApiConfig.baseUrl}/alumno/eventos/$idEvento/completar?id_usuario=${widget.idUsuario}",
        ),
      );

      if (response.statusCode == 200) {
        // ==========================================
        // 🔥 ACTIVAR CELEBRACIÓN
        // ==========================================
        setState(() {
          _mostrarCelebracion = true;
        });

        _celebracionController.forward(from: 0);

        await Future.delayed(const Duration(milliseconds: 1700));

        if (!mounted) return;

        setState(() {
          _mostrarCelebracion = false;
        });

        // ==========================================
        // 🔥 RECARGAR DASHBOARD
        // ==========================================
        _cargarTodo();

        // ==========================================
        // 🔥 MEMORIA POSITIVA
        // ==========================================
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green.shade600,
              content: const Text(
                "✨ Buen trabajo. Tu semana acaba de verse más manejable.",
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error completando tarea: $e");
    }
  }

  // ==========================================
  // 🔥 INDICADOR DE ESTRÉS
  // ==========================================
  Widget _crearIndicadorEstres() {
    final nivel = _datosEstres?['nivel'] ?? "Bajo";
    final puntaje = _datosEstres?['puntaje'] ?? 0.0;

    final colorPrincipal = _obtenerColorNivel(nivel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorPrincipal, colorPrincipal.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: colorPrincipal.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Estrés Académico Previsto",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const SizedBox(height: 12),

          Text(
            nivel.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Puntaje de tensión: $puntaje",
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 14),

          Text(
            _explicacionEstres(),
            style: const TextStyle(color: Colors.white, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🔥 TARJETA DE TAREA
  // ==========================================
  Widget _crearTarjetaTarea(Map<String, dynamic> tarea) {
    bool procesando = false;

    final prioridad = tarea['carga_emocional'];

    String prioridadTexto = "Baja";
    String prioridadEmoji = "🟢";

    if (prioridad >= 70) {
      prioridadTexto = "Alta";
      prioridadEmoji = "🔴";
    } else if (prioridad >= 30) {
      prioridadTexto = "Media";
      prioridadEmoji = "🟠";
    }

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: procesando ? 0 : 1,

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),

            margin: const EdgeInsets.only(bottom: 15),

            child: Card(
              elevation: 2,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              child: CheckboxListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                title: Text(
                  tarea['titulo'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Entrega: ${tarea['fecha_entrega'].split(' ')[0]}"),

                    const SizedBox(height: 5),

                    Text(
                      "$prioridadEmoji Prioridad $prioridadTexto",
                      style: TextStyle(
                        color: _obtenerColorCarga(prioridad.toDouble()),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                secondary: Icon(
                  Icons.circle,
                  color: _obtenerColorCarga(prioridad.toDouble()),
                  size: 16,
                ),

                value: false,

                onChanged: procesando
                    ? null
                    : (bool? value) async {
                        if (value == true) {
                          setLocalState(() {
                            procesando = true;
                          });

                          await Future.delayed(
                            const Duration(milliseconds: 400),
                          );

                          await _completarTarea(tarea['id_evento']);
                        }
                      },
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 🔥 CELEBRACIÓN VISUAL
  // ==========================================
  Widget _overlayCelebracion() {
    return IgnorePointer(
      child: Center(
        child: ScaleTransition(
          scale: _celebracionAnim,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),

            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 20),
              ],
            ),

            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 60),

                SizedBox(height: 10),

                Text(
                  "¡Buen trabajo!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  "Liberaste carga académica ✨",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 🔥 UI PRINCIPAL
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Dashboard de Estrés"),
        backgroundColor: const Color(0xFF2C5F78),
        foregroundColor: Colors.white,
      ),

      body: Stack(
        children: [
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _cargarTodo,

                  child: ListView(
                    padding: const EdgeInsets.all(20),

                    children: [
                      _crearIndicadorEstres(),

                      const SizedBox(height: 30),

                      const Text(
                        "Presión inmediata",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F78),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ==========================================
                      // 🔥 ESTADO VACÍO INTELIGENTE
                      // ==========================================
                      if (_tareasActivas.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(25),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: const Column(
                            children: [
                              Icon(
                                Icons.spa_rounded,
                                color: Colors.green,
                                size: 50,
                              ),

                              SizedBox(height: 15),

                              Text(
                                "Tu semana se ve tranquila 🌿",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),

                              SizedBox(height: 8),

                              Text(
                                "No hay pendientes urgentes registrados.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._tareasActivas.map(
                          (tarea) => _crearTarjetaTarea(tarea),
                        ),
                    ],
                  ),
                ),

          // ==========================================
          // 🔥 OVERLAY DE CELEBRACIÓN
          // ==========================================
          if (_mostrarCelebracion) _overlayCelebracion(),
        ],
      ),
    );
  }
}
