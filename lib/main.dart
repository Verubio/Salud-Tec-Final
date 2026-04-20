import 'package:flutter/material.dart';
// Importaciones de tus archivos
import 'screens/biblio_recu.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/principal_screen.dart';
import 'screens/registro_emo.dart';

void main() {
  runApp(const MyApp()); // Llamamos a MyApp
}

class MyApp extends StatelessWidget { // Restauramos el nombre MyApp
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salud-Tec',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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