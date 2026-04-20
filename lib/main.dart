import 'package:flutter/material.dart';
import 'screens/biblio_recu.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/principal_screen.dart';
import 'screens/registro_emo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salud-Tec',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Aplicando la paleta "Serenidad y Confianza"
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C5F78),
          primary: const Color(0xFF2C5F78),
          secondary: const Color(0xFF84A98C),
          surface: const Color(0xFFF8F9FA),
        ),
        // Configurando tipografías (Asegúrate de agregarlas a pubspec.yaml)
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Color(0xFF2C5F78)),
          titleLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const PrincipalScreen(),
        '/biblioteca': (context) => const BiblioRecu(),
        '/chat': (context) => const ChatScreen(),
        '/registro': (context) => const RegistroEmo(),
      },
    );
  }
}