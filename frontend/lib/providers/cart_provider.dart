import 'package:flutter/material.dart';
import '../models/producto.dart';

// Modelo interno para saber cuántas unidades llevas de cada producto
class CartItem {
  final Producto producto;
  int cantidad;

  CartItem({required this.producto, this.cantidad = 1});
}

class CartProvider with ChangeNotifier {
  // Usamos un mapa (diccionario) donde la llave es el ID del producto
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;
  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.producto.precioReferencial * cartItem.cantidad;
    });
    return total;
  }

  // Agregar producto (o sumar 1 si ya existe en el carrito)
  void addItem(Producto producto) {
    if (_items.containsKey(producto.id)) {
      _items.update(
        producto.id,
        (existingItem) => CartItem(
          producto: existingItem.producto,
          cantidad: existingItem.cantidad + 1,
        ),
      );
    } else {
      _items.putIfAbsent(producto.id, () => CartItem(producto: producto));
    }
    notifyListeners(); // Avisa a todas las pantallas que el carrito cambió
  }

  // Eliminar un producto completo del carrito
  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Vaciar carrito después de comprar
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
