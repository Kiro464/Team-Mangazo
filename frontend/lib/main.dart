import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MangazoApp(),
    ),
  );
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
          seedColor: const Color(0xFF4CAF50),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFFFFC107),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      // Consumer "escucha" los cambios del AuthProvider
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            // Mientras lee SharedPreferences muestra un indicador
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (auth.isAuthenticated) {
            // Si el login fue exitoso (o ya había token), muestra el inicio temporal
            return Scaffold(
              appBar: AppBar(title: const Text('Inicio')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¡Conectado exitosamente con Django! 🎉',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => auth.logout(),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              ),
            );
          }
          // Si no está autenticado, muestra el Login
          return const LoginScreen();
        },
      ),
    );
  }
}
