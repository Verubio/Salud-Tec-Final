import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';
import 'dart:ui'; // Para el Glassmorphism

class ListaPsicologosScreen extends StatefulWidget {
  const ListaPsicologosScreen({super.key});

  @override
  State<ListaPsicologosScreen> createState() => _ListaPsicologosScreenState();
}

class _ListaPsicologosScreenState extends State<ListaPsicologosScreen> {
  List<dynamic> _psicologos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _obtenerPsicologos();
  }

  // =========================================
  // ⚙️ LÓGICA DE SERVIDOR (INTACTA)
  // =========================================
  Future<void> _obtenerPsicologos() async {
    setState(
      () => _isLoading = true,
    ); // Para que el loader se vea si actualizan manualmente
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/psicologos_disponibles"),
      );

      if (response.statusCode == 200) {
        setState(() {
          _psicologos = jsonDecode(response.body);
        });
      } else {
        _mostrarError("Error al cargar la lista del servidor.");
      }
    } catch (e) {
      _mostrarError("Error de conexión. Revisa tu internet.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Future<void> _iniciarChat(Map<String, dynamic> psicologo) async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // VALIDACIÓN ESTRICTA DE SEGURIDAD
    if (args == null || args['id_usuario'] == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
      return;
    }

    final int idAlumno = args['id_usuario'];

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/chat/iniciar"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_alumno': idAlumno,
          'id_psicologo': psicologo['id_usuario'],
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        Navigator.pushNamed(
          context,
          '/chat',
          arguments: {
            'token': args['token'], // Pasamos el token en la cadena de custodia
            'id_alumno': idAlumno,
            'id_psicologo': psicologo['id_usuario'],
            'nombre_psicologo': psicologo['nombre_completo'],
            'id_emisor_actual': idAlumno,
            'id_sesion': data['id_sesion'],
          },
        );
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "El profesional acaba de desconectarse.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.orange.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
        _obtenerPsicologos();
      } else {
        _mostrarError("Error del servidor al intentar conectar.");
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarError("Error de red al intentar iniciar el chat.");
    }
  }

  // =========================================
  // 🎨 UI PREMIUM
  // =========================================
  @override
  Widget build(BuildContext context) {
    const colorPrimario = Color(0xFF2C5F78);
    const colorFondoCyan = Color(0xFFE0F7FA);
    const colorFondoMenta = Color(0xFFF1F8E9);
    const colorAcento = Color(0xFF4DB6AC);

    return Scaffold(
      extendBodyBehindAppBar: true,

      // 🔷 HEADER GLASSMORPHISM
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              title: const Text(
                "Especialistas en Línea",
                style: TextStyle(
                  color: colorPrimario,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              backgroundColor: Colors.white.withOpacity(0.65),
              elevation: 0,
              iconTheme: const IconThemeData(color: colorPrimario),
              centerTitle: true,
            ),
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorFondoCyan, colorFondoMenta],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: colorAcento))
            : _psicologos.isEmpty
            ? _buildEstadoVacio(colorPrimario, colorAcento)
            : RefreshIndicator(
                color: colorAcento,
                onRefresh: _obtenerPsicologos,
                child: _buildListaPsicologos(colorPrimario, colorAcento),
              ),
      ),
    );
  }

  Widget _buildEstadoVacio(Color colorPrimario, Color colorAcento) {
    return Center(
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Permite el Pull-to-Refresh incluso vacío
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.nights_stay_rounded,
                  size: 70,
                  color: colorPrimario.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Nuestros especialistas están descansando",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorPrimario,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "En este momento no hay profesionales en línea.\n\nPor favor, intenta más tarde o visita la Biblioteca de Recursos si necesitas apoyo inmediato.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _obtenerPsicologos,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  "Actualizar Lista",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimario,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 3,
                  shadowColor: colorPrimario.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListaPsicologos(Color colorPrimario, Color colorAcento) {
    return ListView.builder(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      itemCount: _psicologos.length,
      itemBuilder: (context, index) {
        final psi = _psicologos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () => _iniciarChat(psi),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Avatar con indicador de estado
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorAcento.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: colorAcento.withOpacity(0.15),
                            child: Text(
                              psi['nombre_completo'][0].toUpperCase(),
                              style: TextStyle(
                                color: colorPrimario,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade400,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),

                    // Info del Psicólogo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dr. ${psi['nombre_completo'].split(' ')[0]}", // Muestra el primer nombre o título
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF455A64),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Especialista disponible",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Icono de acción
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorPrimario.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chat_bubble_rounded,
                        color: colorPrimario,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
