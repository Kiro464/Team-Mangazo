import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vendedor.dart';
import '../models/producto.dart';

class VendedorService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Obtener la lista de usuarios y filtrar solo los Vendedores (Rol ID = 2 según script seed)
  Future<List<Vendedor>> getVendedores() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        // Filtramos por rol == 2 (Vendedor en tu base de datos)
        return jsonResponse
            .where((user) => user['rol'] == 2)
            .map((item) => Vendedor.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo vendedores: $e");
      return [];
    }
  }

  // 2. Obtener los productos que pertenecen exclusivamente a un vendedor
  Future<List<Producto>> getProductosPorVendedor(int vendedorId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/productos/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse
            .map((item) => Producto.fromJson(item))
            .where(
              (p) => true,
            ) // Como en el serializer ya tenemos el id del vendedor implícito o podemos filtrarlo:
            .toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo productos del vendedor: $e");
      return [];
    }
  }
}
