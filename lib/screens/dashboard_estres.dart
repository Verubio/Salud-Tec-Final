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

  // --- PALETA OCEAN BREEZE (Del Login) ---
  final Color _colorFondoCyan = const Color(0xFFE0F7FA);
  final Color _colorFondoMenta = const Color(0xFFF1F8E9);
  final Color _colorIcono = const Color(0xFF4DB6AC);
  final Color _colorTextoPrimario = const Color(0xFF455A64);

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
  // 🔥 CARGA TOTAL DEL DASHBOARD (Intacta)
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

        // Filtro de 5 días
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
        debugPrint("❌ ERROR DEL BACKEND:");
        debugPrint(
          "Endpoint Estrés Status: ${resultados[0].statusCode} | Body: ${resultados[0].body}",
        );
        debugPrint(
          "Endpoint Tareas Status: ${resultados[1].statusCode} | Body: ${resultados[1].body}",
        );

        if (mounted) {
          setState(() => _cargando = false);
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
  // 🔥 COLORES (Suavizados para que combinen)
  // ==========================================
  Color _obtenerColorCarga(double valor) {
    if (valor < 30) return const Color(0xFF81C784); // Verde suave
    if (valor < 70) return const Color(0xFFFFB74D); // Naranja suave
    return const Color(0xFFEF5350); // Rojo suave
  }

  // Se mantiene el original para no afectar el cuadro principal
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
  // 🔥 COMPLETAR TAREA (Intacta)
  // ==========================================
  Future<void> _completarTarea(int idEvento) async {
    try {
      final response = await http.patch(
        Uri.parse(
          "${ApiConfig.baseUrl}/alumno/eventos/$idEvento/completar?id_usuario=${widget.idUsuario}",
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _mostrarCelebracion = true;
        });

        _celebracionController.forward(from: 0);
        await Future.delayed(const Duration(milliseconds: 1700));

        if (!mounted) return;
        setState(() {
          _mostrarCelebracion = false;
        });

        _cargarTodo();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF81C784), // Verde menta pastel
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: const Text(
                "✨ Buen trabajo. Tu semana acaba de verse más manejable.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
  // 🔥 INDICADOR DE ESTRÉS (Estructura Intacta)
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
        borderRadius: BorderRadius.circular(25), // Bordes ya eran redonditos
        boxShadow: [
          BoxShadow(
            color: colorPrincipal.withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 8), // Sombra un poco más flotante
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Estrés Académico Previsto",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
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
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _explicacionEstres(),
            style: const TextStyle(
              color: Colors.white,
              height: 1.4,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🔥 TARJETA DE TAREA (Estilo Burbuja Fátima)
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              activeColor: _colorIcono, // Color del check
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              title: Text(
                tarea['titulo'],
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF455A64),
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    "Entrega: ${tarea['fecha_entrega'].split(' ')[0]}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(prioridadEmoji),
                      const SizedBox(width: 5),
                      Text(
                        "Prioridad $prioridadTexto",
                        style: TextStyle(
                          color: _obtenerColorCarga(prioridad.toDouble()),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _obtenerColorCarga(
                    prioridad.toDouble(),
                  ).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assignment_rounded,
                  color: _obtenerColorCarga(prioridad.toDouble()),
                  size: 20,
                ),
              ),
              value: false,
              onChanged: procesando
                  ? null
                  : (bool? value) async {
                      if (value == true) {
                        setLocalState(() {
                          procesando = true;
                        });
                        await Future.delayed(const Duration(milliseconds: 400));
                        await _completarTarea(tarea['id_evento']);
                      }
                    },
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 🔥 CELEBRACIÓN VISUAL (Refinada)
  // ==========================================
  Widget _overlayCelebracion() {
    return IgnorePointer(
      child: Center(
        child: ScaleTransition(
          scale: _celebracionAnim,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF81C784), Color(0xFF4DB6AC)], // Verde a Cyan
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4DB6AC).withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 70),
                SizedBox(height: 15),
                Text(
                  "¡Buen trabajo!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Liberaste carga académica ✨",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
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
      extendBodyBehindAppBar: true, // Deja que el degradado suba
      // --- APPBAR INVISIBLE ESTILO LOGIN ---
      appBar: AppBar(
        title: Text(
          "Dashboard de Estrés",
          style: TextStyle(
            color: _colorIcono,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _colorIcono),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Stack(
        children: [
          // Fondo con gradiente Ocean Breeze
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_colorFondoCyan, _colorFondoMenta],
              ),
            ),
          ),

          _cargando
              ? Center(child: CircularProgressIndicator(color: _colorIcono))
              : RefreshIndicator(
                  color: _colorIcono,
                  onRefresh: _cargarTodo,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top:
                          MediaQuery.of(context).padding.top +
                          kToolbarHeight +
                          20,
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    children: [
                      _crearIndicadorEstres(),

                      const SizedBox(height: 35),

                      Row(
                        children: [
                          Icon(
                            Icons.assignment_late_rounded,
                            color: _colorIcono,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Presión inmediata",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: _colorTextoPrimario,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // ==========================================
                      // 🔥 ESTADO VACÍO (Burbuja limpia)
                      // ==========================================
                      if (_tareasActivas.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(35),
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
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.spa_rounded,
                                color: Color(0xFF81C784), // Verde pastel
                                size: 60,
                              ),
                              SizedBox(height: 15),
                              Text(
                                "Tu semana se ve tranquila 🌿",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF81C784),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "No hay pendientes urgentes para los próximos 5 días.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
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

          if (_mostrarCelebracion) _overlayCelebracion(),
        ],
      ),
    );
  }
}
