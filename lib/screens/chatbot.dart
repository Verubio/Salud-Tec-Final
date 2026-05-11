import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';
import 'dart:ui'; // Para el Glassmorphism

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with TickerProviderStateMixin {
  // <-- Añadimos el TickerProvider
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> mensajes = [];
  bool _isTyping = false;
  late int idAlumnoActual;

  // --- PALETA OCEAN BREEZE ---
  final Color _colorFondoCyan = const Color(0xFFE0F7FA);
  final Color _colorFondoMenta = const Color(0xFFF1F8E9);
  final Color _colorAcento = const Color(0xFF4DB6AC); // Teal suave
  final Color _colorAcentoFuerte = const Color(0xFF00897B); // Teal más oscurito
  final Color _colorTextoPrimario = const Color(0xFF455A64);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args == null || args['id_usuario'] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return;
    }

    idAlumnoActual = args['id_usuario'];

    if (mensajes.isEmpty) {
      _cargarHistorial();
    }
  }

  // 🔽 SCROLL AUTOMÁTICO (Suavizado)
  void _scrollAlFinal() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic, // Curva más orgánica
        );
      }
    });
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _isTyping = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chatbot/historial/$idAlumnoActual'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          List<dynamic> historialDb = data['mensajes'];

          setState(() {
            mensajes = historialDb
                .map<Map<String, String>>(
                  (msg) => {
                    "role": msg['rol'] == 'user' ? 'user' : 'bot',
                    "text": msg['mensaje'].toString(),
                  },
                )
                .toList();
          });

          _scrollAlFinal();
        } else {
          throw Exception("Formato inesperado del servidor");
        }
      } else {
        throw Exception("Error del servidor (${response.statusCode})");
      }
    } catch (e) {
      print("Error cargando historial: $e");

      setState(() {
        mensajes.add({"role": "bot", "text": "No pude cargar tu historial 😕"});
      });
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  Future<void> enviarMensaje() async {
    String texto = _controller.text.trim(); // ✅ limpieza
    if (texto.isEmpty) return;

    setState(() {
      mensajes.add({"role": "user", "text": texto});
      _isTyping = true;
    });

    _controller.clear();
    _scrollAlFinal();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chatbot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"id_usuario": idAlumnoActual, "mensaje": texto}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          String respuestaBot =
              data['reply'] ?? "El servidor respondió, pero algo salió raro 🤔";
          mensajes.add({"role": "bot", "text": respuestaBot});
        });
      } else {
        throw Exception("Error del servidor (${response.statusCode})");
      }
    } catch (e) {
      setState(() {
        mensajes.add({
          "role": "bot",
          "text": "Sin conexión. Tu mensaje no se envió 📡",
        });
      });
    } finally {
      setState(() {
        _isTyping = false;
      });
      _scrollAlFinal();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _colorAcentoFuerte,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: _colorAcento.withOpacity(0.2),
                    child: Icon(
                      Icons.smart_toy_rounded,
                      color: _colorAcentoFuerte,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "NexusBot ✨",
                        style: TextStyle(
                          color: _colorAcentoFuerte,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        "IA de Apoyo",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_colorFondoCyan, _colorFondoMenta],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 🔷 ÁREA DE MENSAJES ANIMADA
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 15,
                    right: 15,
                    bottom: 20,
                  ),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    final msg = mensajes[index];
                    final soyYo = msg["role"] == "user";

                    return MessageBubbleAnimation(
                      soyYo: soyYo,
                      child: Align(
                        alignment: soyYo
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: soyYo
                                ? LinearGradient(
                                    colors: [_colorAcento, _colorAcentoFuerte],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: soyYo ? null : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(soyYo ? 20 : 5),
                              bottomRight: Radius.circular(soyYo ? 5 : 20),
                            ),
                            border: soyYo
                                ? null
                                : Border.all(
                                    color: _colorAcento.withOpacity(0.3),
                                    width: 1,
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: soyYo
                                    ? _colorAcentoFuerte.withOpacity(0.2)
                                    : Colors.blueGrey.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            msg["text"]!,
                            style: TextStyle(
                              color: soyYo ? Colors.white : _colorTextoPrimario,
                              fontSize: 15,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 🔷 INDICADOR DE "ESCRIBIENDO" (Cuter)
              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: _colorAcento,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "NexusBot está pensando... 🌸",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: _colorAcentoFuerte.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
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
                      color: _colorAcentoFuerte.withOpacity(0.08),
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
                          color: _colorAcento.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _colorAcento.withOpacity(0.3),
                          ),
                        ),
                        child: TextField(
                          controller: _controller,
                          textCapitalization: TextCapitalization.sentences,
                          minLines: 1,
                          maxLines: 4,
                          style: TextStyle(color: _colorTextoPrimario),
                          decoration: const InputDecoration(
                            hintText: "Pregúntame algo...",
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
                    // BOTÓN ANIMADO QUE HACE POP ✅
                    AnimatedSendButton(
                      onPressed: _isTyping
                          ? () {}
                          : enviarMensaje, // Bloqueado si escribe
                      gradientColors: _isTyping
                          ? [Colors.grey.shade400, Colors.grey.shade500]
                          : [_colorAcento, _colorAcentoFuerte],
                      shadowColor: _isTyping
                          ? Colors.transparent
                          : _colorAcentoFuerte.withOpacity(0.4),
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
// 🧩 COMPONENTES ANIMADOS (¡Los mismos del chat!)
// =========================================================

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_controller));

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ), // Efecto rebote bonito
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: widget.soyYo ? Alignment.centerRight : Alignment.centerLeft,
        child: widget.child,
      ),
    );
  }
}

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
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
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
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.reverse();
    });
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: _scale,
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
