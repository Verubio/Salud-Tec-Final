import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';
import 'dart:async';

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

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

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

      if (response.statusCode != 200) {
        throw Exception("Fallo en el servidor");
      }
    } catch (e) {
      setState(() => _estaDisponible = !nuevoEstado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al cambiar estado. Revisa tu red."),
          ),
        );
      }
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
      if (!silencioso && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 🔽 AGREGA ESTO DENTRO DE TU STATE (debajo de tus funciones actuales)

  Future<void> _marcarAlertaComoAtendida(int idAlumno) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/psicologo/alerta/$idAlumno/atender'),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        // 🔄 Recarga silenciosa del radar
        _cargarSesionesActivas(silencioso: true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Paciente dado de alta del radar."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Error del servidor");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Error al dar de alta."),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  void _mostrarConfirmacionAlta(int idAlumno, String nombreAlumno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 10),
            Text("Confirmar Alta"),
          ],
        ),
        content: Text(
          "¿Deseas marcar la alerta de $nombreAlumno como atendida?\n\n"
          "El paciente desaparecerá del radar activo.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _marcarAlertaComoAtendida(idAlumno);
            },
            child: const Text("Dar de Alta"),
          ),
        ],
      ),
    );
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
      appBar: AppBar(
        title: Text("Dr. ${_nombrePsicologo.split(' ')[0]}"),
        backgroundColor: const Color(0xFF2C5F78),
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              Text(
                _estaDisponible ? "En línea" : "Ocupado",
                style: const TextStyle(fontSize: 12),
              ),
              Switch(
                value: _estaDisponible,
                onChanged: _cambiarDisponibilidad,
                activeThumbColor: Colors.greenAccent,
                inactiveThumbColor: Colors.grey,
              ),
            ],
          ),
        ],
      ),

      // 🔥 NUEVO BODY CON RADAR + SESIONES
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _cargarSesionesActivas(silencioso: false),
              child: ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  /// 🚨 ALERTAS
                  if (_alertasTriage.isNotEmpty) ...[
                    const Text(
                      "⚠️ Requieren Intervención",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._alertasTriage.map((alerta) => _buildAlertaCard(alerta)),
                    const Divider(height: 30, thickness: 2),
                  ],

                  /// 💬 SESIONES
                  const Text(
                    "💬 Sesiones Activas",
                    style: TextStyle(
                      color: Color(0xFF2C5F78),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (_sesiones.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          "No hay chats activos",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._sesiones.map((sesion) => _buildSesionCard(sesion)),
                ],
              ),
            ),
    );
  }

  /// 🚨 TARJETA DE ALERTA
  Widget _buildAlertaCard(Map<String, dynamic> alerta) {
    bool esCritico = alerta['nivel_riesgo'] == 'Critico';

    return Card(
      elevation: 3,
      color: esCritico ? const Color(0xFFFFEBEB) : const Color(0xFFFFF4E5),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: esCritico ? Colors.red : Colors.orange,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.warning_rounded,
                color: Colors.redAccent,
                size: 30,
              ),
              title: Text(
                alerta['nombre_completo'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: esCritico ? Colors.red[900] : Colors.orange[900],
                ),
              ),
              subtitle: Text(
                "Riesgo: ${alerta['nivel_riesgo']}\n${alerta['ultima_alerta']}",
              ),
            ),

            const SizedBox(height: 5),

            // 🔴 BOTONES (Intervenir + Dar de Alta)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 🔥 BOTÓN INTERVENIR
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    _abrirChatAlumno({
                      'id_alumno': alerta['id_alumno'],
                      'nombre_alumno': alerta['nombre_completo'],
                    });
                  },
                  child: const Text("Intervenir"),
                ),

                const SizedBox(width: 10),

                // 🟢 BOTÓN DAR DE ALTA (CON SEGURO)
                TextButton.icon(
                  icon: const Icon(Icons.verified_user, color: Colors.green),
                  label: const Text(
                    "Dar de Alta",
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () {
                    _mostrarConfirmacionAlta(
                      alerta['id_alumno'],
                      alerta['nombre_completo'],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 💬 TARJETA DE SESIÓN NORMAL
  Widget _buildSesionCard(Map<String, dynamic> s) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF5ED3C6),
          child: Text(
            s['nombre_alumno'][0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          s['nombre_alumno'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Iniciada: ${s['fecha_inicio']}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _abrirChatAlumno(s),
      ),
    );
  }
}
