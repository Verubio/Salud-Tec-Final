import 'package:flutter/material.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  String _estadoActual = "Estable";
  String _gifPrincipal = 'assets/carita_estable.gif'; 
  Color _colorFondo = Colors.orange.withOpacity(0.1);

  final List<Map<String, String>> _opcionesEmociones = [
    {'nombre': 'Radiante', 'gif': 'assets/carita_riendo.gif'},
    {'nombre': 'Feliz', 'gif': 'assets/carita_feliz.gif'},
    {'nombre': 'Neutral', 'gif': 'assets/carita_neutra.gif'},
    {'nombre': 'Enojado', 'gif': 'assets/carita_enojada.gif'},
    {'nombre': 'Triste', 'gif': 'assets/carita_triste.gif'},
  ];

  void _mostrarMenuEmociones() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
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
                    onTap: () {
                      setState(() {
                        _estadoActual = emocion['nombre']!;
                        _gifPrincipal = emocion['gif']!;
                        if (_estadoActual == 'Radiante' || _estadoActual == 'Feliz') _colorFondo = Colors.green.withOpacity(0.1);
                        if (_estadoActual == 'Enojado' || _estadoActual == 'Triste') _colorFondo = Colors.red.withOpacity(0.1);
                        if (_estadoActual == 'Neutral') _colorFondo = Colors.blue.withOpacity(0.1);
                      });
                      Navigator.pop(context);
                    },
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
            // BURBUJA DE DIÁLOGO
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C5F78),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "¡Hola $nombreUsuario!\n¿Cómo te sientes hoy?",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ClipPath(
                  clipper: TriangleClipper(),
                  child: Container(color: const Color(0xFF2C5F78), height: 10, width: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // CARITA ANIMADA PRINCIPAL
            GestureDetector(
              onTap: _mostrarMenuEmociones,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 250,
                height: 250,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _colorFondo,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  _gifPrincipal,
                  fit: BoxFit.contain,
                  key: ValueKey(_gifPrincipal),
                ),
              ),
            ),
            Text("Estado: $_estadoActual", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Text("(Toca para cambiar)", style: TextStyle(color: Colors.grey, fontSize: 12)),
            
            const SizedBox(height: 30),
            
            // CARD DE PREDICCIÓN DE ESTRÉS
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
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

            // NUEVO BOTÓN DE CHAT KAWAII
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
                    // Tu imagen kawaii personalizada
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

            const SizedBox(height: 20),

            // BOTÓN DE REGISTRO MANUAL
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/registro'),
              icon: const Icon(Icons.edit_note),
              label: const Text("Bitácora de Emociones"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF84A98C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}