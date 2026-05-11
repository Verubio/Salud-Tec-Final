import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';
import 'dart:async';
import 'dart:ui'; // Para el Glassmorphism

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  // <-- NUEVO: Necesario para animaciones
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _token;
  List<dynamic> _mensajes = [];
  int? _idSesion;
  int _idAlumno = 0;
  int _idPsicologo = 0;
  String _nombrePsicologo = "Especialista";
  bool _isLoading = true;
  Timer? _timer;
  int _miId = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _token = args['token'];
      _idAlumno = args['id_alumno'];
      _idPsicologo = args['id_psicologo'];
      _nombrePsicologo = args['nombre_psicologo'];
      _miId = args['id_emisor_actual'] ?? args['id_alumno'];

      _iniciarSesionChat();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // =========================================
  // ⚙️ LÓGICA DE SERVIDOR (INTACTA - Luis approved ✅)
  // =========================================
  Future<void> _finalizarSesionBackend() async {
    if (_idSesion == null) return;
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/chat/finalizar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_sesion': _idSesion}),
      );

      if (response.statusCode == 200) {
        if (mounted) Navigator.pop(context);
      } else {
        _mostrarSnackBar(
          "Error al finalizar. Intenta de nuevo.",
          const Color(0xFFFFB6C1),
        );
      }
    } catch (e) {
      _mostrarSnackBar("Error de red.", const Color(0xFFFFB6C1));
    }
  }

  Future<void> _iniciarSesionChat() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chat/iniciar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_alumno': _idAlumno,
          'id_psicologo': _idPsicologo,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _idSesion = data['id_sesion'];
            _mensajes = data['mensajes'];
            _isLoading = false;
          });
          _hacerScrollAlFondo();

          _timer ??= Timer.periodic(const Duration(seconds: 3), (timer) {
            _actualizarMensajes();
          });
        }
      }
    } catch (e) {
      debugPrint("Error al iniciar chat: $e");
    }
  }

  Future<void> _actualizarMensajes() async {
    if (_idSesion == null) return;
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chat/$_idSesion/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;

        if (data['esta_activa'] == false) {
          _timer?.cancel();
          Navigator.pop(context);
          _mostrarSnackBar(
            "La sesión ha concluido. 🌸",
            const Color(0xFFFFB74D),
          );
          return;
        }

        if (data['mensajes'].length > _mensajes.length) {
          setState(() => _mensajes = data['mensajes']);
          _hacerScrollAlFondo();
        }
      }
    } catch (e) {
      // Ignorar errores de polling
    }
  }

  Future<void> _enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _idSesion == null) return;

    final textoRespaldo = texto;
    _controller.clear();

    setState(() {
      _mensajes.add({
        'id_usuario_emisor': _miId,
        'mensaje': textoRespaldo,
        'fecha_hora': 'Ahora',
      });
    });

    _hacerScrollAlFondo();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chat/enviar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_sesion': _idSesion,
          'id_usuario_emisor': _miId,
          'mensaje': textoRespaldo,
        }),
      );

      if (response.statusCode != 200) throw Exception("Error en servidor");
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mensajes.removeLast();
        _controller.text = textoRespaldo;
      });
      _mostrarSnackBar(
        "Error de conexión. Intenta de nuevo. 💤",
        const Color(0xFFFFB6C1),
      );
    }
  }

  void _hacerScrollAlFondo() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(
            milliseconds: 400,
          ), // Scroll un pelín más lento para suavidad
          curve: Curves.easeOutCubic, // Curva más orgánica
        );
      }
    });
  }

  // =========================================
  // 🎨 UI PREMIUM ANIMADA (Fátima & Animations owo)
  // =========================================
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

  void _mostrarDialogoConfirmacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(
              Icons.volunteer_activism_rounded,
              color: Color(0xFFFFB74D),
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              "¿Finalizar sesión?",
              style: TextStyle(
                color: Color(0xFF9575CD),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          "Al confirmar, este chat se cerrará de forma permanente para ambos usuarios. ✨",
          style: TextStyle(color: Colors.black54),
        ),
        actionsPadding: const EdgeInsets.only(right: 20, bottom: 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              _finalizarSesionBackend();
            },
            child: const Text(
              "Finalizar",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- PALETA DE COLORES ---
    const colorFondoAzul = Color(0xFFE3F2FD);
    const colorFondoVerde = Color(0xFFE8F5E9);
    const colorLavanda = Color(0xFFE1BEE7);
    const colorLavandaFuerte = Color(0xFF9575CD);
    const colorTextoPrimario = Color(0xFF5D737E);

    return Scaffold(
      extendBodyBehindAppBar: true,

      // 🔷 HEADER GLASSMORPHISM
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.75),
              elevation: 0,
              iconTheme: const IconThemeData(color: colorLavandaFuerte),
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorLavanda.withOpacity(0.4),
                    child: Text(
                      _nombrePsicologo[0].toUpperCase(),
                      style: const TextStyle(
                        color: colorLavandaFuerte,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nombrePsicologo,
                          style: const TextStyle(
                            color: colorLavandaFuerte,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          "En línea ✨",
                          style: TextStyle(
                            color: Color(0xFF81C784),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                if (_idSesion != null)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCDD2).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.power_settings_new_rounded,
                        color: Color(0xFFE53935),
                      ),
                      tooltip: 'Finalizar Sesión',
                      onPressed: _mostrarDialogoConfirmacion,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorFondoAzul, colorFondoVerde],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 🔷 ÁREA DE MENSAJES ANIMADA ✅
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: colorLavandaFuerte,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          top: 20,
                          left: 15,
                          right: 15,
                          bottom: 20,
                        ),
                        itemCount: _mensajes.length,
                        itemBuilder: (context, index) {
                          final msg = _mensajes[index];
                          final soyYo = msg['id_usuario_emisor'] == _miId;

                          // --- ENVOLTORIO DE ANIMACIÓN DE ENTRADA ---
                          return MessageBubbleAnimation(
                            soyYo: soyYo,
                            child: Align(
                              alignment: soyYo
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  // Degradado sutil para profesionalismo
                                  gradient: soyYo
                                      ? const LinearGradient(
                                          colors: [
                                            colorLavandaFuerte,
                                            Color(0xFF7E57C2),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: soyYo ? null : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: Radius.circular(soyYo ? 20 : 5),
                                    bottomRight: Radius.circular(
                                      soyYo ? 5 : 20,
                                    ),
                                  ),
                                  border: soyYo
                                      ? null
                                      : Border.all(
                                          color: colorLavanda.withOpacity(0.3),
                                          width: 1,
                                        ), // Borde suave receptor
                                  boxShadow: [
                                    BoxShadow(
                                      color: soyYo
                                          ? colorLavandaFuerte.withOpacity(0.15)
                                          : Colors.blueGrey.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: soyYo
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg['mensaje'],
                                      style: TextStyle(
                                        color: soyYo
                                            ? Colors.white
                                            : colorTextoPrimario,
                                        fontSize: 15,
                                        height: 1.3,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      () {
                                        String fullTimeStr = msg['fecha_hora']
                                            .toString();
                                        if (fullTimeStr.split(' ')[0] ==
                                            'Ahora') {
                                          return 'Ahora';
                                        }
                                        if (fullTimeStr.length >= 16) {
                                          return fullTimeStr.substring(11, 16);
                                        }
                                        return fullTimeStr;
                                      }(),
                                      style: TextStyle(
                                        color: soyYo
                                            ? Colors.white.withOpacity(0.8)
                                            : Colors.grey.shade500,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // 🔷 INPUT FLOTANTE (Píldora Kawaii)
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: MediaQuery.of(context).padding.bottom + 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  boxShadow: [
                    BoxShadow(
                      color: colorLavandaFuerte.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorLavanda.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: colorLavandaFuerte.withOpacity(0.2),
                          ),
                        ),
                        child: TextField(
                          controller: _controller,
                          textCapitalization: TextCapitalization.sentences,
                          minLines: 1,
                          maxLines: 4,
                          style: const TextStyle(color: colorTextoPrimario),
                          decoration: const InputDecoration(
                            hintText: "Escribe un mensaje...",
                            hintStyle: TextStyle(color: Colors.black26),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // --- BOTÓN DE ENVIAR CON ANIMACIÓN DE REACCIÓN (POP) ✅ ---
                    AnimatedSendButton(
                      onPressed: _enviarMensaje,
                      gradientColors: const [colorLavanda, colorLavandaFuerte],
                      shadowColor: colorLavandaFuerte.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================
// 🧩 COMPONENTES NUEVOS DE ANIMACIÓN PREMIUM
// =========================================================

/// 🎬 Envoltorio para que la burbuja de chat aparezca suavemente.
/// Hace un efecto combinando Escala (crecer) y Opacidad (desvanecer).
class MessageBubbleAnimation extends StatefulWidget {
  final Widget child;
  final bool soyYo;

  const MessageBubbleAnimation({
    super.key,
    required this.child,
    required this.soyYo,
  });

  @override
  State<MessageBubbleAnimation> createState() => _MessageBubbleAnimationState();
}

class _MessageBubbleAnimationState extends State<MessageBubbleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Configuración de la duración (300ms es perfecto para UI rápida)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Animación de opacidad (0.0 a 1.0)
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_controller));

    // Animación de escala (crece un 15% del tamaño original)
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ), //easeOutBack le da un rebotito cute owo
    );

    // Iniciamos la animación inmediatamente al nacer
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Súper importante liberar memoria
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        // Pequeño truco: cambiamos el punto de origen de la escala según quién envía
        // Así la burbuja parece nacer de la colita del chat
        alignment: widget.soyYo ? Alignment.centerRight : Alignment.centerLeft,
        child: widget.child,
      ),
    );
  }
}

/// 🎬 Botón de enviar que reacciona físicamente al tap ("Pop" effect).
class AnimatedSendButton extends StatefulWidget {
  final VoidCallback onPressed;
  final List<Color> gradientColors;
  final Color shadowColor;

  const AnimatedSendButton({
    super.key,
    required this.onPressed,
    required this.gradientColors,
    required this.shadowColor,
  });

  @override
  State<AnimatedSendButton> createState() => _AnimatedSendButtonState();
}

class _AnimatedSendButtonState extends State<AnimatedSendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 100,
      ), // Súper rápido para sensación táctil
      lowerBound: 0.0,
      upperBound: 0.1, // Se encoge un 10%
    );
    _controller.addListener(() {
      setState(() {
        _scale = 1.0 - _controller.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward(); // Al presionar, se encoge
  }

  void _onTapUp(TapUpDetails details) {
    // Al soltar, rebota a su tamaño normal y ejecuta la lógica de envío
    Future.delayed(const Duration(milliseconds: 100), () {
      _controller.reverse();
    });
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse(); // Si arrastra el dedo fuera, vuelve a la normalidad
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: _scale, // Aplicamos la escala animada al widget completo
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
