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
  Color _colorSlider = Colors.orange;

  String _tipoEvento = "Tarea";

  DateTime? _fechaSeleccionada;

  bool _guardando = false;

  Color _obtenerColorCarga(double valor) {
    if (valor < 30) return Colors.green;
    if (valor < 70) return Colors.orange;
    return Colors.red;
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _guardarEvento(int idUsuario) async {
    if (_tituloController.text.trim().isEmpty || _fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa los campos obligatorios")),
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Evento registrado correctamente"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        throw Exception("Error del servidor");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final int idUsuario = args['id_usuario'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Nueva tarea"),
        backgroundColor: const Color(0xFF2C5F78),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Organiza tu carga académica",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C5F78),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Registrar tus tareas ayuda a predecir tus niveles de estrés y organizar mejor tu semana.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            /// TÍTULO
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: "Título",
                hintText: "Ej. Proyecto de programación",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// DESCRIPCIÓN
            TextField(
              controller: _descripcionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Descripción",
                hintText: "Detalles opcionales...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// TIPO EVENTO
            DropdownButtonFormField<String>(
              value: _tipoEvento,
              decoration: InputDecoration(
                labelText: "Tipo de evento",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              items: const [
                DropdownMenuItem(value: "Tarea", child: Text("Tarea")),
                DropdownMenuItem(value: "Examen", child: Text("Examen")),
                DropdownMenuItem(value: "Proyecto", child: Text("Proyecto")),
                DropdownMenuItem(value: "Otro", child: Text("Otro")),
              ],
              onChanged: (value) {
                setState(() {
                  _tipoEvento = value!;
                });
              },
            ),

            const SizedBox(height: 25),

            /// FECHA
            InkWell(
              onTap: () => _seleccionarFecha(context),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month),
                    const SizedBox(width: 10),
                    Text(
                      _fechaSeleccionada == null
                          ? "Seleccionar fecha de entrega"
                          : "${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// SLIDER
            Text(
              "¿Qué tanta carga emocional te genera esto?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _colorSlider,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _colorSlider.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Slider(
                    value: _cargaEmocional,
                    min: 1,
                    max: 100,
                    divisions: 100,
                    activeColor: _colorSlider,
                    label: _cargaEmocional.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _cargaEmocional = value;
                        _colorSlider = _obtenerColorCarga(value);
                      });
                    },
                  ),

                  Text(
                    "${_cargaEmocional.round()}%",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _colorSlider,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    _cargaEmocional < 30
                        ? "Parece manejable"
                        : _cargaEmocional < 70
                        ? "Esto podría generarte presión"
                        : "Esta tarea representa una carga fuerte",
                    style: TextStyle(color: _colorSlider),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// BOTÓN GUARDAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C5F78),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _guardando ? null : () => _guardarEvento(idUsuario),
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),

                label: Text(
                  _guardando ? "Guardando..." : "Registrar evento",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
