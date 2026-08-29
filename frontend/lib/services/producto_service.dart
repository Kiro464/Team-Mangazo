import 'dart:convert';
import 'dart:io';
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

  // 4. Crear un nuevo producto (Multipart Request para la imagen)
  Future<bool> crearProducto(Map<String, String> datos, File? imagen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      // Creamos la petición "Multipart"
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/productos/'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      // Agregamos los textos (nombre, precio, categoria, etc.)
      request.fields.addAll(datos);

      // Si el vendedor tomó una foto, la adjuntamos
      if (imagen != null) {
        request.files.add(
          await http.MultipartFile.fromPath('imagen', imagen.path),
        );
      }

      // Enviamos el paquete completo
      var response = await request.send();

      if (response.statusCode == 201) {
        return true; // 201 = Creado exitosamente
      } else {
        // Convertimos el Stream de bytes a Texto para leer el error exacto
        final respStr = await response.stream.bytesToString();
        print(
          "Backend rechazó crearProducto: ${response.statusCode} - $respStr",
        );
        return false;
      }
    } catch (e) {
      print("Error creando producto: $e");
      return false;
    }
  }

  // 5. Editar producto existente
  Future<bool> editarProducto(
    int id,
    Map<String, String> datos,
    File? imagen,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      // Usamos PATCH para actualizar
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/productos/$id/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields.addAll(datos);
      if (imagen != null)
        request.files.add(
          await http.MultipartFile.fromPath('imagen', imagen.path),
        );

      var response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
