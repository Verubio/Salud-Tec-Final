import 'dart:math';
import 'package:flutter/material.dart';

class AvatarEmocional extends StatefulWidget {
  final String nombreCompleto;
  final String nivelEstres;
  final double radio;

  const AvatarEmocional({
    super.key,
    required this.nombreCompleto,
    required this.nivelEstres,
    this.radio = 35,
  });

  @override
  State<AvatarEmocional> createState() => _AvatarEmocionalState();
}

class _AvatarEmocionalState extends State<AvatarEmocional>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _particleController;

  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();

    // =========================================
    // 🌿 BREATHING ANIMATION
    // =========================================
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // =========================================
    // ✨ PARTICLES
    // =========================================
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  // =========================================
  // 🧠 INICIALES INTELIGENTES
  // =========================================
  String _obtenerIniciales(String nombre) {
    if (nombre.trim().isEmpty) return "NX";

    List<String> partes = nombre.trim().split(RegExp(r'\s+'));

    if (partes.length == 1) {
      return partes[0][0].toUpperCase();
    }

    return "${partes[0][0]}${partes[1][0]}".toUpperCase();
  }

  // =========================================
  // 🎨 COLORES PREMIUM
  // =========================================
  List<Color> _obtenerColores() {
    switch (widget.nivelEstres) {
      case "Moderado":
        return [const Color(0xFFFFB75E), const Color(0xFFED8F03)];

      case "Alto":
        return [const Color(0xFFFF5F6D), const Color(0xFFC81D25)];

      case "Critico":
        return [const Color(0xFF5B0E2D), const Color(0xFF2A0A0F)];

      default:
        return [const Color(0xFF43CEA2), const Color(0xFF185A9D)];
    }
  }

  // =========================================
  // ✨ GLOW SEGÚN ESTADO
  // =========================================
  double _obtenerGlow() {
    switch (widget.nivelEstres) {
      case "Critico":
        return 25;

      case "Alto":
        return 18;

      case "Moderado":
        return 14;

      default:
        return 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = _obtenerColores();

    return AnimatedBuilder(
      animation: Listenable.merge([_breathingController, _particleController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _breathingAnimation.value,
          child: SizedBox(
            width: widget.radio * 2.8,
            height: widget.radio * 2.8,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // =========================================
                // ✨ PARTICULAS SUAVES
                // =========================================
                ...List.generate(8, (index) {
                  final random = Random(index);

                  final angle =
                      (_particleController.value * 2 * pi) + (index * pi / 4);

                  final radius =
                      widget.radio +
                      (sin(_particleController.value * pi * 2) * 6);

                  final dx = cos(angle) * radius;
                  final dy = sin(angle) * radius;

                  return Transform.translate(
                    offset: Offset(dx, dy),
                    child: Opacity(
                      opacity: 0.15,
                      child: Container(
                        width: random.nextDouble() * 6 + 2,
                        height: random.nextDouble() * 6 + 2,
                        decoration: BoxDecoration(
                          color: colores.first,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),

                // =========================================
                // 🌈 ANILLO EXTERNO REACTIVO
                // =========================================
                Container(
                  width: widget.radio * 2.4,
                  height: widget.radio * 2.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colores.first.withOpacity(0.25),
                      width: 3,
                    ),
                  ),
                ),

                // =========================================
                // 🔥 AURA / GLOW
                // =========================================
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  width: widget.radio * 2.1,
                  height: widget.radio * 2.1,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colores.last.withOpacity(0.45),
                        blurRadius: _obtenerGlow(),
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),

                // =========================================
                // 👾 AVATAR PRINCIPAL
                // =========================================
                Container(
                  width: widget.radio * 2,
                  height: widget.radio * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: colores,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                    border: Border.all(
                      color: Colors.white.withOpacity(0.85),
                      width: 2,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),

                  alignment: Alignment.center,

                  child: Text(
                    _obtenerIniciales(widget.nombreCompleto),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.radio * 0.7,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
