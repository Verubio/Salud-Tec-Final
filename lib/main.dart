import 'package:flutter/material.dart';
import 'package:salud_tec_final/screens/lista_psicologos_screen.dart';
import 'package:salud_tec_final/screens/psicologo_home_screen.dart';
import 'package:salud_tec_final/screens/register_screen.dart';
import 'screens/biblio_recu.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registro_emo.dart';
import 'package:salud_tec_final/screens/chatbot.dart';
import 'package:salud_tec_final/screens/alumno_main_container.dart';
import 'package:salud_tec_final/screens/nueva_tarea_screen.dart';
import 'package:salud_tec_final/screens/dashboard_estres.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salud-Tec',
      debugShowCheckedModeBanner:
          false, // ¡Adiós a la cintilla roja de "Debug"!
      theme: ThemeData(
        useMaterial3: true,
        // ==========================================
        // 🎨 ADN VISUAL: PALETA OCEAN BREEZE / KAWAII
        // ==========================================
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4DB6AC), // Teal Suave (Acento principal)
          primary: const Color(
            0xFF2C5F78,
          ), // Azul Institucional (Textos fuertes)
          secondary: const Color(0xFFE1BEE7), // Lavanda Suave
          tertiary: const Color(0xFF81C784), // Verde Menta Pastel
          surface: const Color(0xFFF5F7FA), // Fondo gris-azulado muy clarito
        ),
        // Configurando tipografías globales
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w900,
            color: Color(0xFF2C5F78),
          ),
          titleLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
            color: Color(0xFF455A64),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF5D737E),
            fontWeight: FontWeight.w500,
          ),
        ),
        // Estilo global por defecto para botones, por si alguien olvida estilizarlos
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4DB6AC),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;

          return AlumnoMainContainer(
            idAlumno: args['id_usuario'],
            // luego pasaremos también nombre si quieres
          );
        },
        '/biblioteca': (context) => const BiblioRecu(),
        '/chat': (context) => const ChatScreen(),
        '/registro': (context) => const RegistroEmo(),
        '/chatbot': (context) => const ChatBotScreen(),
        '/registro_usuario': (context) => const RegisterScreen(),
        '/seleccion_psicologo': (context) => const ListaPsicologosScreen(),
        '/psicologo_home': (context) => const PsicologoHomeScreen(),
        '/nueva_tarea': (context) => const NuevaTareaScreen(),
        '/dashboard_estres': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;

          return DashboardEstres(idUsuario: args['id_usuario']);
        },
      },
    );
  }
}
