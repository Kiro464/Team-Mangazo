import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MangazoApp());
}

class MangazoApp extends StatelessWidget {
  const MangazoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Mangazo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // Verde agricultura
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFFFFC107), // Amarillo ofertas flash
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'App Mangazo Inicializada 🚀',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
