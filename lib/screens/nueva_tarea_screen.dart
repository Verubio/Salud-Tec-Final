import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';

class NuevaTareaScreen extends StatefulWidget {
  const NuevaTareaScreen({super.key});

  @override
  State<NuevaTareaScreen> createState() => _NuevaTareaScreenState();
}

class _NuevaTareaScreenState extends State<NuevaTareaScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  double _cargaEmocional = 50;
  Color _colorSlider = const Color(0xFFFFB74D); // Naranja suave inicial

  String _tipoEvento = "Tarea";
  DateTime? _fechaSeleccionada;
  bool _guardando = false;

  // --- PALETA OCEAN BREEZE (Para hacer match con el Dashboard) ---
  final Color _colorFondoCyan = const Color(0xFFE0F7FA);
  final Color _colorFondoMenta = const Color(0xFFF1F8E9);
  final Color _colorIcono = const Color(0xFF4DB6AC);
  final Color _colorTextoPrimario = const Color(0xFF455A64);

  // Colores suavizados para el slider
  Color _obtenerColorCarga(double valor) {
    if (valor < 30) return const Color(0xFF81C784); // Verde suave
    if (valor < 70) return const Color(0xFFFFB74D); // Naranja suave
    return const Color(0xFFEF5350); // Rojo suave
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _colorIcono, // Color principal del calendario
              onPrimary: Colors.white,
              onSurface: _colorTextoPrimario,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _colorIcono, // Botones del calendario
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _guardarEvento(int idUsuario) async {
    if (_tituloController.text.trim().isEmpty || _fechaSeleccionada == null) {
      _mostrarSnackBar(
        "Completa el título y la fecha porfis ✨",
        Colors.orangeAccent,
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    final fechaAjustada = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      23,
      59,
      59,
    );

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/alumno/eventos"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id_usuario": idUsuario,
          "titulo": _tituloController.text.trim(),
          "descripcion": _descripcionController.text.trim(),
          "fecha_entrega": fechaAjustada.toIso8601String(),
          "carga_emocional": _cargaEmocional.round(),
          "tipo_evento": _tipoEvento,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        _mostrarSnackBar(
          "¡Tarea registrada con éxito! 🌸",
          const Color(0xFF81C784),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception("Error del servidor");
      }
    } catch (e) {
      _mostrarSnackBar("Uy, hubo un error de red. 💤", const Color(0xFFFFB6C1));
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int idUsuario = args['id_usuario'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _colorIcono),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_colorFondoCyan, _colorFondoMenta],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CABECERA ---
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _colorIcono.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.edit_note_rounded,
                      size: 50,
                      color: _colorIcono,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Nueva Tarea",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _colorTextoPrimario,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Registrar tus pendientes nos ayuda a predecir tu estrés.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey.shade400,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 35),

                // --- CAMPOS DE TEXTO (Estilo Nube) ---
                _buildSoftTextField(
                  controller: _tituloController,
                  label: "Título de la Tarea",
                  hint: "Ej. Proyecto de programación",
                  icon: Icons.title_rounded,
                ),
                const SizedBox(height: 20),

                _buildSoftTextField(
                  controller: _descripcionController,
                  label: "Descripción (Opcional)",
                  hint: "Agrega algunos detalles extra...",
                  icon: Icons.subject_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // --- DROPDOWN ---
                _buildSoftDropdown(),
                const SizedBox(height: 20),

                // --- SELECTOR DE FECHA ---
                _buildSelectorFecha(context),
                const SizedBox(height: 35),

                // --- SLIDER EMOCIONAL ---
                Text(
                  "¿Qué tanta carga emocional te genera esto?",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _colorTextoPrimario,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 25,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25), // Burbuja
                    boxShadow: [
                      BoxShadow(
                        color: _colorSlider.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: _colorSlider.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${_cargaEmocional.round()}%",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: _colorSlider,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _cargaEmocional < 30
                            ? "Parece muy manejable ✨"
                            : _cargaEmocional < 70
                            ? "Podría generarte presión 👀"
                            : "Es una carga muy fuerte 🫂",
                        style: TextStyle(
                          color: _colorSlider,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 8.0,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12.0,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 24.0,
                          ),
                          activeTrackColor: _colorSlider,
                          inactiveTrackColor: _colorSlider.withOpacity(0.2),
                          thumbColor: _colorSlider,
                          overlayColor: _colorSlider.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _cargaEmocional,
                          min: 1,
                          max: 100,
                          divisions: 100,
                          onChanged: (double value) {
                            setState(() {
                              _cargaEmocional = value;
                              _colorSlider = _obtenerColorCarga(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- BOTÓN GUARDAR ---
                _guardando
                    ? Center(
                        child: CircularProgressIndicator(color: _colorIcono),
                      )
                    : ElevatedButton(
                        onPressed: () => _guardarEvento(idUsuario),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colorIcono,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: _colorIcono.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Registrar Tarea ✨",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // 🧩 HELPERS VISUALES (Burbujitas Limpias)
  // =========================================================
  Widget _buildSoftTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Color(0xFF5D737E)),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFFB0BEC5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSoftDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _tipoEvento,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFFB0BEC5),
        ),
        style: const TextStyle(color: Color(0xFF5D737E), fontSize: 16),
        decoration: InputDecoration(
          labelText: "Tipo de evento",
          prefixIcon: const Icon(
            Icons.category_rounded,
            color: Color(0xFFB0BEC5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 12,
          ),
        ),
        items: const [
          DropdownMenuItem(value: "Tarea", child: Text("Tarea")),
          DropdownMenuItem(value: "Examen", child: Text("Examen")),
          DropdownMenuItem(value: "Proyecto", child: Text("Proyecto")),
          DropdownMenuItem(value: "Otro", child: Text("Otro")),
        ],
        onChanged: (value) => setState(() => _tipoEvento = value!),
      ),
    );
  }

  Widget _buildSelectorFecha(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _seleccionarFecha(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, right: 12),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFFB0BEC5),
                  ),
                ),
                Text(
                  _fechaSeleccionada == null
                      ? "Seleccionar fecha de entrega"
                      : "${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}",
                  style: TextStyle(
                    color: _fechaSeleccionada == null
                        ? Colors.black45
                        : const Color(0xFF5D737E),
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB0BEC5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
