import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vendedor.dart';

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

  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      // Django REST Framework devuelve 201 (Created) cuando se crea un registro exitosamente
      if (response.statusCode == 201) {
        return true;
      } else {
        print("Error del servidor: ${response.body}");
        return false;
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

  // Función para obtener Mi Perfil
  Future<Vendedor?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return Vendedor.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Actualizar mi perfil
  Future<bool> actualizarPerfil(
    Map<String, String> datos,
    File? fotoPerfil,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/usuarios/me/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields.addAll(datos);
      if (fotoPerfil != null)
        request.files.add(
          await http.MultipartFile.fromPath('foto_perfil', fotoPerfil.path),
        );

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
