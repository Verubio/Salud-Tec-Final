import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';
import 'dart:async';
import 'dart:ui'; // 🔥 Necesario para el efecto Blur

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _idPsicologo = args['id_usuario'];
      _nombrePsicologo = args['nombre'];
      _estaDisponible = args['esta_disponible'] ?? false;

      _cargarSesionesActivas();

      _timer ??= Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted) _cargarSesionesActivas(silencioso: true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Lógica de disponibilidad
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

  Future<void> _cargarSesionesActivas({bool silencioso = false}) async {
    if (!silencioso) setState(() => _isLoading = true);
    try {
      final respuestas = await Future.wait([
        http.get(Uri.parse('${ApiConfig.baseUrl}/psicologo/$_idPsicologo/sesiones')),
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

  Future<void> _marcarAlertaComoAtendida(int idAlumno) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/psicologo/alerta/$idAlumno/atender'),
      );
      if (response.statusCode == 200) {
        _cargarSesionesActivas(silencioso: true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Paciente atendido."), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _abrirChatAlumno(Map<String, dynamic> sesion) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'id_alumno': sesion['id_alumno'],
        'id_psicologo': _idPsicologo,
        'nombre_psicologo': sesion['nombre_alumno'],
        'id_emisor_actual': _idPsicologo,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      
      // 🔥 AÑADIDO: DRAWER PREMIUM PARA EL PSICÓLOGO
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
                color: Colors.white.withOpacity(0.90),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              ),
              child: Column(
                children: [
                  // HEADER DEL DRAWER (Mismo estilo que alumno pero en Azul)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 30,
                      bottom: 30,
                      left: 20,
                      right: 20,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2C5F78), Color(0xFF4A8CA8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.medical_services_outlined, color: Colors.white, size: 35),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Dr. $_nombrePsicologo",
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Especialista en Salud Mental",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // INFO CARD
                  _buildDrawerItem(
                    icon: Icons.badge_outlined,
                    label: "ID Profesional",
                    sub: "NEXUS-00$_idPsicologo",
                  ),
                  _buildDrawerItem(
                    icon: Icons.verified_user_outlined,
                    label: "Estado Actual",
                    sub: _estaDisponible ? "Disponible para atención" : "En modo desconectado",
                  ),

                  const Spacer(),

                  // BOTÓN CERRAR SESIÓN ESTILIZADO
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: InkWell(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFE57373), Color(0xFFC62828)]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.power_settings_new, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Cerrar Sesión", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

      appBar: AppBar(
        title: Text("Dr. ${_nombrePsicologo.split(' ')[0]}"),
        backgroundColor: const Color(0xFF2C5F78),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Row(
            children: [
              Text(_estaDisponible ? "En línea" : "Ocupado", style: const TextStyle(fontSize: 12)),
              Switch(
                value: _estaDisponible,
                onChanged: _cambiarDisponibilidad,
                activeThumbColor: Colors.greenAccent,
              ),
            ],
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _cargarSesionesActivas(silencioso: false),
              child: ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  if (_alertasTriage.isNotEmpty) ...[
                    const Text("⚠️ Requieren Intervención", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    ..._alertasTriage.map((alerta) => _buildAlertaCard(alerta)),
                    const Divider(height: 30, thickness: 2),
                  ],
                  const Text("💬 Sesiones Activas", style: TextStyle(color: Color(0xFF2C5F78), fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  if (_sesiones.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No hay chats activos", style: TextStyle(color: Colors.grey))))
                  else
                    ..._sesiones.map((sesion) => _buildSesionCard(sesion)),
                ],
              ),
            ),
    );
  }

  // Widget auxiliar para los items del Drawer
  Widget _buildDrawerItem({required IconData icon, required String label, required String sub}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF2C5F78).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF2C5F78), size: 22),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertaCard(Map<String, dynamic> alerta) {
    bool esCritico = alerta['nivel_riesgo'] == 'Critico';
    return Card(
      elevation: 3,
      color: esCritico ? const Color(0xFFFFEBEB) : const Color(0xFFFFF4E5),
      shape: RoundedRectangleBorder(side: BorderSide(color: esCritico ? Colors.red : Colors.orange, width: 1.5), borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(alerta['nombre_completo'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Riesgo: ${alerta['nivel_riesgo']}"),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
          onPressed: () => _abrirChatAlumno({'id_alumno': alerta['id_alumno'], 'nombre_alumno': alerta['nombre_completo']}),
          child: const Text("Intervenir"),
        ),
      ),
    );
  }

  Widget _buildSesionCard(Map<String, dynamic> s) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFF5ED3C6), child: Text(s['nombre_alumno'][0], style: const TextStyle(color: Colors.white))),
        title: Text(s['nombre_alumno'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Iniciada: ${s['fecha_inicio']}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _abrirChatAlumno(s),
      ),
    );
  }
}