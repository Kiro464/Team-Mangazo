import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';

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
}
