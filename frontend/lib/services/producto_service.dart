import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/producto.dart';

class ProductoService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  // Función interna para obtener los encabezados con el Token JWT
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Obtener todos los productos (Catálogo general)
  Future<List<Producto>> getProductos() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/productos/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((item) => Producto.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo productos: $e");
      return [];
    }
  }

  // 2. Obtener solo las Ofertas Flash
  Future<List<Producto>> getOfertasFlash() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/productos/ofertas-flash/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((item) => Producto.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo ofertas flash: $e");
      return [];
    }
  }

  // 3. Obtener productos del Calendario de Temporada (Mes actual)
  Future<List<Producto>> getCalendarioTemporada() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/productos/calendario-temporada/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((item) => Producto.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo calendario: $e");
      return [];
    }
  }
}
