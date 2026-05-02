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
  bool _isLoading = true;
  late int _idPsicologo;
  String _nombrePsicologo = "Psicólogo";
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 1. Recuperamos los datos del Login
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _idPsicologo = args['id_usuario'];
      _nombrePsicologo = args['nombre'];

      // RIGOR TÉCNICO: Inicializamos el switch con la verdad absoluta de la Base de Datos
      _estaDisponible = args['esta_disponible'] ?? false;

      _cargarSesionesActivas();

      // RIGOR TÉCNICO: Polling para ver si le caen nuevos mensajes
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
    // UI Optimista
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
      // Revertimos si falla
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
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/psicologo/$_idPsicologo/sesiones'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _sesiones = data['sesiones'];
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

  void _abrirChatAlumno(Map<String, dynamic> sesion) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'id_alumno': sesion['id_alumno'],
        'id_psicologo': _idPsicologo,
        'nombre_psicologo': sesion['nombre_alumno'],
        'id_emisor_actual':
            _idPsicologo, // <-- RIGOR: Le decimos que él es el emisor
        // Nota: El ChatScreen actual asume que siempre mostramos el nombre del psicologo en el header.
        // Sería ideal modificar ChatScreen después para que si soy psicólogo, muestre el nombre del alumno.
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
                activeColor: Colors.greenAccent,
                inactiveThumbColor: Colors.grey,
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sesiones.isEmpty
          ? const Center(
              child: Text(
                "Bandeja de entrada vacía",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : _buildListaSesiones(),
    );
  }

  Widget _buildListaSesiones() {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _sesiones.length,
      itemBuilder: (context, index) {
        final s = _sesiones[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
            subtitle: Text("Sesión iniciada: ${s['fecha_inicio']}"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _abrirChatAlumno(s),
          ),
        );
      },
    );
  }
}
