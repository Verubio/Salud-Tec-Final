import 'package:flutter/material.dart';

class BiblioRecu extends StatelessWidget {
  const BiblioRecu({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos las categorías basadas en la Ventana #5 del documento
    final List<Map<String, dynamic>> categorias = [
      {'titulo': 'Respiración', 'icono': Icons.air, 'color': const Color(0xFFB5EAD7)}, // Verde pastel
      {'titulo': 'Ansiedad', 'icono': Icons.favorite_border, 'color': const Color(0xFFC7CEEA)}, // Lavanda
      {'titulo': 'Consejos y Hábitos', 'icono': Icons.lightbulb_outline, 'color': const Color(0xFFFFDAC1)}, // Naranja pastel
      {'titulo': 'Higiene del Sueño', 'icono': Icons.bedtime, 'color': const Color(0xFFA0C4FF)}, // Azul pastel
      {'titulo': 'Organización del Tiempo', 'icono': Icons.schedule, 'color': const Color(0xFFFFB7B2)}, // Rosa pastel
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Biblioteca de Recursos', 
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Dos columnas como suele usarse en dashboards modernos
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.1,
          ),
          itemCount: categorias.length,
          itemBuilder: (context, index) {
            final cat = categorias[index];
            return GestureDetector(
              onTap: () {
                // Muestra la ventana de ejercicios o guías al hacer tap
                _mostrarDetalleCategoria(context, cat['titulo']);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: cat['color'],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cat['icono'], size: 48, color: Colors.black54),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        cat['titulo'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Función para mostrar la ventana emergente con la info de la categoría
  void _mostrarDetalleCategoria(BuildContext context, String titulo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            titulo, 
            style: TextStyle(
              fontFamily: 'Montserrat', 
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            )
          ),
          content: Text(
            'Aquí se cargarán los recursos desde el backend (FastAPI) para la categoría de $titulo. Por ejemplo: guías para manejo de crisis o ejercicios comunes.',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}