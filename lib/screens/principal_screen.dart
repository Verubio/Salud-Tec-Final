import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // <--- OBLIGATORIO
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  // VARIABLES DE ESTADO INICIALES
  List<dynamic> _historialEmociones = [];
  bool _cargandoHistorial = true;
  String _estadoActual = "Estable";
  String _mensajeActual = "Me da mucha paz verte así, en calma"; 
  String _gifPrincipal = 'assets/carita_estable.gif'; 
  Color _colorFondo = Colors.blue.withOpacity(0.1);

  // LISTA DE EMOCIONES SEGÚN TUS ESPECIFICACIONES
  final List<Map<String, String>> _opcionesEmociones = [
    {
      'nombre': 'Alegre', 
      'gif': 'assets/carita_riendo.gif', 
      'frase': '¡Eres el claro ejemplo de que la felicidad es una elección!'
    },
    {
      'nombre': 'Feliz', 
      'gif': 'assets/carita_feliz.gif', 
      'frase': 'Qué felicidad verte brillar así'
    },
    {
      'nombre': 'Estable', 
      'gif': 'assets/carita_neutra.gif', 
      'frase': 'Me da mucha paz verte así, en calma'
    },
    {
      'nombre': 'Estresado', 
      'gif': 'assets/carita_enojada.gif', 
      'frase': 'No tienes que dar explicaciones, pero si quieres hablar, te prometo que te escucho.'
    },
    {
      'nombre': 'Crisis', 
      'gif': 'assets/carita_triste.gif', 
      'frase': 'No estás solo/a en esto, cuenta conmigo'
    },
  ];

@override
  void initState() {
    super.initState();
    _obtenerHistorial(); // <--- Aquí se llama al iniciar
  }
  
Future<void> _obtenerHistorial() async {
    try {
      // Cambio: Construimos la URL dinámicamente
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/historial_animo/2"), 
      );
      if (response.statusCode == 200) {
        setState(() {
          _historialEmociones = jsonDecode(response.body);
          _cargandoHistorial = false;
        });
      }
    } catch (e) {
      print("Error cargando historial: $e");
    }
  }

  // PUNTO 3: Este también es un método independiente
  String _obtenerGifDeEmocion(String nombre) {
    switch (nombre) {
      case 'Alegre': return 'assets/carita_riendo.gif';
      case 'Feliz': return 'assets/carita_feliz.gif';
      case 'Estable': return 'assets/carita_neutra.gif';
      case 'Estresado': return 'assets/carita_enojada.gif';
      case 'Crisis': return 'assets/carita_triste.gif';
      default: return 'assets/carita_estable.gif';
    }
  }


  void _seleccionarEmocion(Map<String, String> emocion) {
    setState(() {
      _estadoActual = emocion['nombre']!;
      _mensajeActual = emocion['frase']!;
      _gifPrincipal = emocion['gif']!;
      
      // Lógica de colores dinámicos
      if (_estadoActual == 'Alegre' || _estadoActual == 'Feliz') {
        _colorFondo = Colors.green.withOpacity(0.1);
      } else if (_estadoActual == 'Estresado' || _estadoActual == 'Crisis') {
        _colorFondo = Colors.red.withOpacity(0.1);
      } else {
        _colorFondo = Colors.blue.withOpacity(0.1);
      }
    });

    Navigator.pop(context); // Cierra el menú

    // NAVEGACIÓN AUTOMÁTICA AL REGISTRO PASANDO LOS DATOS
    Navigator.pushNamed(
      context, 
      '/registro', 
      arguments: {
        'emocion': _estadoActual,
        'frase': _mensajeActual,
        'gif': _gifPrincipal,
      }
    );
  }

  void _mostrarMenuEmociones() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          height: 220,
          child: Column(
            children: [
              const Text("¿Cómo te sientes?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _opcionesEmociones.map((emocion) {
                  return GestureDetector(
                    onTap: () => _seleccionarEmocion(emocion),
                    child: Column(
                      children: [
                        Image.asset(emocion['gif']!, width: 55, height: 55),
                        const SizedBox(height: 5),
                        Text(emocion['nombre']!, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final String nombreUsuario = ModalRoute.of(context)!.settings.arguments as String? ?? "Estudiante";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Nexus 4 - Salud-Tec"),
        backgroundColor: const Color(0xFF2C5F78),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // BURBUJA DE DIÁLOGO DINÁMICA
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(color: const Color(0xFF2C5F78), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    "¡Hola $nombreUsuario!\n$_mensajeActual",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ClipPath(
                  clipper: TriangleClipper(),
                  child: Container(color: const Color(0xFF2C5F78), height: 10, width: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // CARITA ANIMADA
            GestureDetector(
              onTap: _mostrarMenuEmociones,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 250, height: 250,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: _colorFondo, shape: BoxShape.circle),
                child: Image.asset(_gifPrincipal, fit: BoxFit.contain, key: ValueKey(_gifPrincipal)),
              ),
            ),
            Text("Estado: $_estadoActual", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Text("(Toca para cambiar)", style: TextStyle(color: Colors.grey, fontSize: 12)),
            
            const SizedBox(height: 30),
            
            // CARD ESTRÉS
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
              child: const Row(
                children: [
                  Icon(Icons.analytics, color: Color(0xFF2C5F78), size: 40),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Predicción de Estrés", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Nivel: MEDIO", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BOTÓN DE CHAT KAWAII
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/chat'),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFF2C5F78).withOpacity(0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset('assets/mensaje_kawaii.png', width: 60, height: 60),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "¿Necesitas hablar?",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C5F78)),
                          ),
                          Text(
                            "Un psicólogo está listo para escucharte",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Color(0xFF2C5F78), size: 18),
                  ],
                ),
              ),
            ),
            
          const SizedBox(height: 15), // Un poco de espacio

            // BOTÓN DE BIBLIOTECA DE RECURSOS (Tu código)
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/biblioteca');
              },
              child: Container(
                width: double.infinity, // Hacemos que ocupe el ancho disponible
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF84A98C), // Verde de la paleta
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centramos contenido
                  children: [
                    Icon(Icons.menu_book, color: Colors.white, size: 28), 
                    SizedBox(width: 12),
                    Text(
                      'Biblioteca de Recursos',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25), // Espacio antes del Historial

            // EL BOTÓN VERDE HA SIDO ELIMINADO PARA SIMPLIFICAR LA UX
            const SizedBox(height: 30),
            const SizedBox(height: 25),
const Align(
  alignment: Alignment.centerLeft,
  child: Text("Tu semana en un vistazo", 
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C5F78))),
),
const SizedBox(height: 15),

_cargandoHistorial 
  ? const Center(child: CircularProgressIndicator())
  : _historialEmociones.isEmpty 
    ? const Text("Aún no tienes registros esta semana.")
    : SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _historialEmociones.length,
          itemBuilder: (context, index) {
            final registro = _historialEmociones[index];
            return Container(
              width: 80,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(_obtenerGifDeEmocion(registro['emocion']), width: 40, height: 40),
                  const SizedBox(height: 5),
                  Text(registro['emocion'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(registro['fecha_hora'].split(' ')[0], style: const TextStyle(fontSize: 9, color: Colors.grey)),
                ],
              ),
            );
          },
        ),
      ),
          ],
        ),
      ),
    );
  }
} 

class TriangleClipper extends CustomClipper<Path> {
  @override Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override bool shouldReclip(TriangleClipper oldClipper) => false;
}