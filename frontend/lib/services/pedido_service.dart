import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';
import '../models/pedido.dart';

class PedidoService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  // Ahora devuelve un int (El ID del pedido) o null si falla
  Future<int?> enviarPedido(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      List<Map<String, dynamic>> detalles = items
          .map(
            (item) => {
              'producto_id': item.producto.id,
              'cantidad': item.cantidad,
              'precio_unitario_aplicado': item.producto.precioReferencial,
            },
          )
          .toList();

      final payload = {
        'comprador': 3,
        'vendedor': 1,
        'estado': 'Pendiente',
        'detalles_creacion': detalles,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/pedidos/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id']; // Retornamos el ID generado por Django
      }
      return null;
    } catch (e) {
      print("Error enviando pedido: $e");
      return null;
    }
  }

  // Función para enviar la reseña conectada al pedido
  Future<bool> enviarResena(
    int pedidoId,
    int calificacion,
    String comentario,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final payload = {
        'pedido': pedidoId,
        'calificacion': calificacion,
        'comentario': comentario,
        'medios_compra': 'WhatsApp',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/resenas/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error enviando reseña: $e");
      return false;
    }
  }

  // Obtener historial de pedidos
  Future<List<Pedido>> getMisPedidos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('$baseUrl/pedidos/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        // Mapeamos a objetos Pedido y los invertimos para ver los más nuevos arriba
        return jsonResponse
            .map((item) => Pedido.fromJson(item))
            .toList()
            .reversed
            .toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo pedidos: $e");
      return [];
    }
  }

  // Confirmar recepción del pedido
  // 2. Confirmar recepción del pedido
  Future<bool> confirmarEntrega(int pedidoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/pedidos/$pedidoId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'estado': 'Completado'}),
      );

      // Si es exitoso, DRF devuelve 200 OK
      if (response.statusCode == 200) {
        return true;
      } else {
        // Imprimimos la respuesta exacta de Django para saber si falta algún campo
        print(
          "Backend rechazó confirmarEntrega: ${response.statusCode} - ${response.body}",
        );
        return false;
      }
    } catch (e) {
      print("Error confirmando entrega: $e");
      return false;
    }
  }
}
