import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';

class PedidoService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<bool> enviarPedido(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      // 1. Armamos la lista de detalles como lo exige la 4FN en Django
      List<Map<String, dynamic>> detalles = items
          .map(
            (item) => {
              'producto_id': item.producto.id,
              'cantidad': item.cantidad,
              'precio_unitario_aplicado': item.producto.precioReferencial,
            },
          )
          .toList();

      // 2. Armamos el cuerpo principal del pedido
      // Nota Hackaton: Como atajo rápido de demostración, pondremos los IDs 3 (Comprador) y 1 (Vendedor)
      // que generaste en tu script de Python. En producción, esto se extrae del Token.
      final payload = {
        'comprador': 3,
        'vendedor': 1,
        'estado': 'Pendiente',
        'detalles_creacion': detalles,
      };

      // 3. Enviamos el POST a Django
      final response = await http.post(
        Uri.parse('$baseUrl/pedidos/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      // 201 significa "Created" en el estándar REST
      return response.statusCode == 201;
    } catch (e) {
      print("Error enviando pedido a Django: $e");
      return false;
    }
  }
}
