import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'chatbot.dart';
=======
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salud_tec_final/api_config.dart';
import 'dart:async'; // Necesario para el Timer de actualización
>>>>>>> c825a49f5041a9c10d4b327c07b91f7fb07da827

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
<<<<<<< HEAD
  final List<String> mensajes = [];

  void enviarMensaje() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      mensajes.add(_controller.text.trim());
    });

    _controller.clear();
=======
  final ScrollController _scrollController =
      ScrollController(); // Para bajar el chat al último mensaje

  List<dynamic> _mensajes = [];
  int? _idSesion;
  int _idAlumno = 0;
  int _idPsicologo = 0;
  String _nombrePsicologo = "Psicólogo";
  bool _isLoading = true;
  Timer? _timer; // Para simular el "En Vivo" temporalmente
  int _miId = 0; // Agrega esta variable

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recuperamos la cadena de custodia
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _idAlumno = args['id_alumno'];
      _idPsicologo = args['id_psicologo'];
      _nombrePsicologo = args['nombre_psicologo'];
      _miId =
          args['id_emisor_actual'] ??
          args['id_alumno']; // Recuperamos quién soy

      _iniciarSesionChat();
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // RIGOR: Evitar fugas de memoria
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _finalizarSesionBackend() async {
    if (_idSesion == null) return;

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/chat/finalizar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_sesion': _idSesion}),
      );

      if (response.statusCode == 200) {
        // RIGOR: Si el backend confirma, sacamos al usuario de la pantalla de chat
        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al finalizar. Intenta de nuevo."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error de red."),
          backgroundColor: Colors.red,
        ),
      );
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

          // RIGOR TÉCNICO: Como aún no tenemos WebSockets, hacemos un "Polling" cada 3 segundos
          // para simular que es "En Vivo".
          _timer ??= Timer.periodic(const Duration(seconds: 3), (timer) {
            _actualizarMensajes();
          });
        }
      }
    } catch (e) {
      print("Error al iniciar chat: $e");
    }
  }

  void _mostrarDialogoConfirmacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("¿Finalizar sesión?"),
          ],
        ),
        content: const Text(
          "Al confirmar, este chat se cerrará. Si el alumno requiere más ayuda, deberá iniciar una nueva sesión.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Solo cierra el diálogo
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              _finalizarSesionBackend(); // Dispara la orden al servidor
            },
            child: const Text(
              "Finalizar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _actualizarMensajes() async {
    if (_idSesion == null) return;
    try {
      // Usamos el nuevo endpoint de sincronización (GET)
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chat/$_idSesion/sync'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        // RIGOR TÉCNICO: Si la sesión fue cerrada por el psicólogo, sacamos al alumno
        if (data['esta_activa'] == false) {
          _timer?.cancel(); // Apagamos el reloj
          Navigator.pop(context); // Lo sacamos de la pantalla
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("La sesión ha concluido."),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // Si sigue activa, actualizamos mensajes sin parpadear
        if (data['mensajes'].length > _mensajes.length) {
          setState(() {
            _mensajes = data['mensajes'];
          });
          _hacerScrollAlFondo();
        }
      }
    } catch (e) {
      // Ignoramos errores de red momentáneos
    }
  }

  Future<void> _enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _idSesion == null) return;

    // 1. RESPALDO
    final textoRespaldo = texto;

    // 2. LIMPIEZA + UI OPTIMISTA
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
      // 3. ENVÍO REAL AL SERVIDOR
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chat/enviar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_sesion': _idSesion,
          'id_usuario_emisor': _miId,
          'mensaje': textoRespaldo,
        }),
      );

      // Si el servidor falla
      if (response.statusCode != 200) {
        throw Exception("Error en servidor");
      }

      // ✅ Todo bien → no haces nada (tu polling lo actualizará)
    } catch (e) {
      // 4. RECUPERACIÓN (el verdadero upgrade)
      if (!mounted) return;

      setState(() {
        // Quitamos el mensaje optimista (porque no se envió realmente)
        _mensajes.removeLast();

        // Devolvemos el texto al input
        _controller.text = textoRespaldo;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Error de conexión. Intenta de nuevo."),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _hacerScrollAlFondo() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
>>>>>>> c825a49f5041a9c10d4b327c07b91f7fb07da827
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5ED3C6),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔷 HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F9D9A), Color(0xFF5ED3C6)],
<<<<<<< HEAD
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
=======
>>>>>>> c825a49f5041a9c10d4b327c07b91f7fb07da827
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
<<<<<<< HEAD
                  const CircleAvatar(
                    backgroundImage:
                        NetworkImage('https://i.pravatar.cc/150?img=3'),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Psicólogo",
                      style: TextStyle(
=======
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      _nombrePsicologo[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF0F9D9A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _nombrePsicologo,
                      style: const TextStyle(
>>>>>>> c825a49f5041a9c10d4b327c07b91f7fb07da827
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
<<<<<<< HEAD
=======
                  // 🔴 AQUÍ VA EL BOTÓN
                  if (_idSesion != null)
                    IconButton(
                      icon: const Icon(
                        Icons.power_settings_new,
                        color: Colors.redAccent,
                        size: 28,
                      ),
                      tooltip: 'Finalizar Sesión',
                      onPressed: _mostrarDialogoConfirmacion,
                    ),
>>>>>>> c825a49f5041a9c10d4b327c07b91f7fb07da827
                ],
              ),
            ),

<<<<<<< HEAD
            /// 🔷 CONTENIDO
=======
            /// 🔷 CONTENIDO (El Chat Real)
>>>>>>> c825a49f5041a9c10d4b327c07b91f7fb07da827
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF6F5),
<<<<<<< HEAD
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: _buildChatActivo(),
=======
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildChatActivo(),
>>>>>>> c825a49f5041a9c10d4b327c07b91f7fb07da827
              ),
            ),
          ],
        ),
      ),
<<<<<<< HEAD
    );
  }

  /// 🟢 CHAT ACTIVO
  Widget _buildChatActivo() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: mensajes.length,
            itemBuilder: (context, index) {
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F9D9A),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    mensajes[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),

        /// 🔽 INPUT
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Escribe tu mensaje...",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFF0F9D9A),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: enviarMensaje,
                ),
              ),
            ],
          ),
        ),
      ],
=======
>>>>>>> c825a49f5041a9c10d4b327c07b91f7fb07da827
    );
  }

  Widget _buildChatActivo() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(15),
            itemCount: _mensajes.length,
            itemBuilder: (context, index) {
              final msg = _mensajes[index];
              // LÓGICA DE BURBUJAS: Si el emisor soy yo (Alumno), va a la derecha. Si no, a la izquierda.
              final soyYo = msg['id_usuario_emisor'] == _miId;

              return Align(
                alignment: soyYo ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: soyYo ? const Color(0xFF0F9D9A) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(15),
                      topRight: const Radius.circular(15),
                      bottomLeft: Radius.circular(soyYo ? 15 : 0),
                      bottomRight: Radius.circular(soyYo ? 0 : 15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
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
                          color: soyYo ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg['fecha_hora'].toString(),
                        style: TextStyle(
                          color: soyYo ? Colors.white70 : Colors.black54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        /// 🔽 INPUT
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Escribe tu mensaje...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFF0F9D9A),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _enviarMensaje,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
