import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Cambia esta URL si pruebas en un dispositivo físico (usa la IP de la PC)
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Guardamos los tokens en el almacenamiento del teléfono
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access']);
        await prefs.setString('refresh_token', data['refresh']);

        return true; // Login exitoso
      } else {
        return false; // Credenciales incorrectas
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }

  // Verifica si ya hay un token guardado (para mantener la sesión abierta)
  Future<bool> hasValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }

  // Cierra la sesión borrando los tokens
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
}
