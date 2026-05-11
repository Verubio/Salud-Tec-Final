import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';
import 'dart:async';
import 'dart:ui';

class PsicologoHomeScreen extends StatefulWidget {
  const PsicologoHomeScreen({super.key});

  @override
  State<PsicologoHomeScreen> createState() => _PsicologoHomeScreenState();
}

class _PsicologoHomeScreenState extends State<PsicologoHomeScreen> {
  bool _estaDisponible = false;
  List<dynamic> _sesiones = [];
  List<dynamic> _alertasTriage = [];
  bool _isLoading = true;
  late int _idPsicologo;
  String _nombrePsicologo = "Psicólogo";
  Timer? _timer;

  // 🛡️ AQUÍ ESTÁ LA VARIABLE QUE FALTABA
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🛡️ EL BLINDAJE CONTRA LA AMNESIA
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        _idPsicologo = args['id_usuario'];
        _nombrePsicologo = args['nombre'] ?? "Especialista";
        _estaDisponible = args['esta_disponible'] ?? false;

        // 🔌 SINCRONIZACIÓN FORZADA
        _cambiarDisponibilidad(_estaDisponible);

        _obtenerDisponibilidadReal();
        _cargarSesionesActivas();
        _timer ??= Timer.periodic(const Duration(seconds: 5), (timer) {
          if (mounted) {
            _cargarSesionesActivas(silencioso: true);
            _obtenerDisponibilidadReal();
          }
        });
      }
      _isInitialized = true; // 🛡️ SELLAMOS EL INICIO
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // =========================================
  // ⚙️ LÓGICA INTACTA (¡Ni una coma tocada!) >u<
  // =========================================
  Future<void> _cambiarDisponibilidad(bool nuevoEstado) async {
    setState(() => _estaDisponible = nuevoEstado);
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/psicologo/disponibilidad'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_psicologo': _idPsicologo,
          'esta_disponible': nuevoEstado,
        }),
      );
      if (response.statusCode != 200) throw Exception("Fallo en el servidor");
    } catch (e) {
      setState(() => _estaDisponible = !nuevoEstado);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al cambiar estado.")),
        );
      }
    }
  }

  Future<void> _obtenerDisponibilidadReal() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/psicologo/$_idPsicologo/disponibilidad',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            _estaDisponible =
                data['esta_disponible'] == true || data['esta_disponible'] == 1;
          });
        }
      }
    } catch (e) {
      debugPrint("Error obteniendo disponibilidad: $e");
    }
  }

  Future<void> _cargarSesionesActivas({bool silencioso = false}) async {
    if (!silencioso) setState(() => _isLoading = true);
    try {
      final respuestas = await Future.wait([
        http.get(
          Uri.parse('${ApiConfig.baseUrl}/psicologo/$_idPsicologo/sesiones'),
        ),
        http.get(Uri.parse('${ApiConfig.baseUrl}/psicologo/alertas_triage')),
      ]);

      if (respuestas[0].statusCode == 200 && respuestas[1].statusCode == 200) {
        final dataSesiones = jsonDecode(respuestas[0].body);
        final dataAlertas = jsonDecode(respuestas[1].body);
        if (mounted) {
          setState(() {
            _sesiones = dataSesiones['sesiones'];
            _alertasTriage = dataAlertas['alertas'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!silencioso && mounted) setState(() => _isLoading = false);
    }
  }

  void _abrirChatAlumno(Map<String, dynamic> sesion) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'id_alumno':
            sesion['id_alumno'] ?? sesion['id_usuario'], // Fallback seguro
        'id_psicologo': _idPsicologo,
        'nombre_psicologo':
            sesion['nombre_alumno'] ?? sesion['nombre_completo'],
        'id_emisor_actual': _idPsicologo,
      },
    );
  }

  // =========================================
  // 🎨 UI PREMIUM KAWAII: ESTILOS Y COLORES DE FÁTIMA
  // =========================================
  @override
  Widget build(BuildContext context) {
    // NUESTRA PALETA ESTRELLA ✨
    const colorFondoAzul = Color(0xFFE3F2FD);
    const colorFondoVerde = Color(0xFFE8F5E9);
    const colorLavanda = Color(0xFFE1BEE7);
    const colorLavandaFuerte = Color(0xFF9575CD);
    const colorTextoPrimario = Color(0xFF5D737E);

    return Scaffold(
      extendBodyBehindAppBar: true,

      // =========================================
      // 🍔 DRAWER PREMIUM SUAVIZADO
      // =========================================
      drawer: Drawer(
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
                color: Colors.white.withOpacity(0.9), // Fondo cristalino blanco
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
                      bottom: 30,
                      left: 20,
                      right: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorLavanda.withOpacity(0.8),
                          colorFondoVerde,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorLavandaFuerte.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white.withOpacity(0.9),
                            child: const Icon(
                              Icons.psychology_rounded,
                              color: colorLavandaFuerte,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Dr. ${_nombrePsicologo.split(' ')[0]}",
                          style: const TextStyle(
                            color: colorTextoPrimario,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          "Especialista en Salud Mental",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildDrawerItemPremium(
                    icon: Icons.badge_rounded,
                    label: "ID Profesional",
                    sub: "NEXUS-00$_idPsicologo",
                    color: colorLavandaFuerte,
                  ),
                  _buildDrawerItemPremium(
                    icon: Icons.sensors_rounded,
                    label: "Estado Actual",
                    sub: _estaDisponible
                        ? "Recibiendo pacientes ✨"
                        : "Desconectado 💤",
                    color: _estaDisponible
                        ? const Color(0xFF81C784)
                        : Colors.grey, // Verde pastel o gris
                  ),

                  const Spacer(),

                  // Botón Cerrar Sesión
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () async {
                        await _cambiarDisponibilidad(false);

                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        }
                      },
                      child: Ink(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFCDD2,
                          ), // Rojo pastel suavecito
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFCDD2).withOpacity(0.5),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFD32F2F),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Cerrar Sesión",
                              style: TextStyle(
                                color: Color(0xFFD32F2F),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // =========================================
      // 📱 APP BAR GLASSMORPHISM (Ajustado)
      // =========================================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: const Text(
                "Panel Clínico",
                style: TextStyle(
                  color: colorLavandaFuerte,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              backgroundColor: Colors.white.withOpacity(0.6),
              elevation: 0,
              iconTheme: const IconThemeData(color: colorLavandaFuerte),
              actions: [
                // Switch de estado redondito
                Container(
                  margin: const EdgeInsets.only(right: 15, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _estaDisponible
                        ? const Color(0xFFE8F5E9)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: _estaDisponible
                          ? const Color(0xFF81C784)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: _estaDisponible
                            ? const Color(0xFF81C784)
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 2),
                      Switch(
                        value: _estaDisponible,
                        onChanged: _cambiarDisponibilidad,
                        activeColor: const Color(0xFF81C784),
                        activeTrackColor: const Color(0xFFC8E6C9),
                        inactiveThumbColor: Colors.grey.shade400,
                        inactiveTrackColor: Colors.grey.shade200,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // =========================================
      // 🌿 CUERPO PRINCIPAL
      // =========================================
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorFondoAzul, colorFondoVerde],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: colorLavandaFuerte),
              )
            : RefreshIndicator(
                color: colorLavandaFuerte,
                onRefresh: () => _cargarSesionesActivas(silencioso: false),
                child: ListView(
                  physics:
                      const BouncingScrollPhysics(), // Scroll más rebotón y suave
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
                    // --- SECCIÓN ALERTAS TRIAGE ---
                    if (_alertasTriage.isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(
                            Icons.campaign_rounded, // Icono más suave
                            color: Color(0xFFE53935),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Triage de Emergencia",
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ..._alertasTriage.map(
                        (alerta) => _buildAlertaCard(alerta),
                      ),
                      const SizedBox(height: 10),
                      Divider(
                        color: colorLavanda.withOpacity(0.5),
                        thickness: 2,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // --- SECCIÓN CHATS ACTIVOS ---
                    const Row(
                      children: [
                        Icon(Icons.forum_rounded, color: colorLavandaFuerte),
                        SizedBox(width: 8),
                        Text(
                          "Pacientes Activos",
                          style: TextStyle(
                            color: colorTextoPrimario,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    if (_sesiones.isEmpty)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(35),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.self_improvement_rounded,
                                size: 65,
                                color: colorLavandaFuerte.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Sin pacientes en espera ✨",
                                style: TextStyle(
                                  color: colorTextoPrimario,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                "Es un buen momento para tomar un té.",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._sesiones.map(
                        (sesion) => _buildSesionCard(
                          sesion,
                          colorTextoPrimario,
                          colorLavandaFuerte,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  // =========================================
  // 🧩 COMPONENTES VISUALES MEJORADOS (Fátima Style)
  // =========================================

  Widget _buildDrawerItemPremium({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20), // Más redondito
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF5D737E),
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertaCard(Map<String, dynamic> alerta) {
    bool esCritico = alerta['nivel_riesgo'] == 'Critico';

    // Mantenemos los colores de alerta, pero un poco más amigables a la vista
    Color colorPeligro = esCritico
        ? const Color(0xFFEF5350) // Rojo suave
        : const Color(0xFFFFB74D); // Naranja suave

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), // Burbuja
        boxShadow: [
          BoxShadow(
            color: colorPeligro.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: colorPeligro.withOpacity(0.3), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorPeligro.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            esCritico
                ? Icons.priority_high_rounded
                : Icons.notifications_active_rounded,
            color: colorPeligro,
          ),
        ),
        title: Text(
          alerta['nombre_completo'] ?? 'Paciente',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: Color(0xFF455A64),
          ),
        ),
        subtitle: Text(
          "Nivel: ${alerta['nivel_riesgo']}",
          style: TextStyle(
            color: colorPeligro,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorPeligro,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Botón redondito
            ),
            elevation: 2,
            shadowColor: colorPeligro.withOpacity(0.4),
          ),
          onPressed: () => _abrirChatAlumno({
            'id_alumno': alerta['id_alumno'],
            'nombre_alumno': alerta['nombre_completo'],
          }),
          child: const Text(
            "Atender",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSesionCard(
    Map<String, dynamic> s,
    Color colorPrimario,
    Color colorAcento,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), // Burbuja
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colorAcento.withOpacity(0.3), width: 2),
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: colorAcento.withOpacity(0.15),
            child: Text(
              (s['nombre_alumno'] ?? 'P')[0].toUpperCase(),
              style: TextStyle(
                color: colorAcento,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          s['nombre_alumno'] ?? 'Paciente',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: colorPrimario,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "Inició: ${s['fecha_inicio']?.split(' ')[0] ?? 'Hoy'}",
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD), // Azulito claro para el botón
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE3F2FD).withOpacity(0.5),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.chat_bubble_rounded, // Icono más acorde
            size: 18,
            color: colorAcento,
          ),
        ),
        onTap: () => _abrirChatAlumno(s),
      ),
    );
  }
}
