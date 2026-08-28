class DetallePedido {
  final String productoNombre;
  final int cantidad;
  final double precio;

  DetallePedido({
    required this.productoNombre,
    required this.cantidad,
    required this.precio,
  });

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    return DetallePedido(
      productoNombre:
          json['producto_nombre']?.toString() ?? 'Producto Desconocido',
      // Convertimos a String primero, y luego forzamos a int/double. Si falla, ponemos un 0.
      cantidad: int.tryParse(json['cantidad'].toString()) ?? 1,
      precio:
          double.tryParse(json['precio_unitario_aplicado'].toString()) ?? 0.0,
    );
  }
}

class Pedido {
  final int id;
  final String estado;
  final String fecha;
  final String vendedorNombre;
  final List<DetallePedido> detalles;

  Pedido({
    required this.id,
    required this.estado,
    required this.fecha,
    required this.vendedorNombre,
    required this.detalles,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    var listaDetalles = json['detalles'] as List? ?? [];
    List<DetallePedido> detallesList = listaDetalles
        .map((i) => DetallePedido.fromJson(i))
        .toList();

    return Pedido(
      id: int.tryParse(json['id'].toString()) ?? 0,
      estado: json['estado']?.toString() ?? 'Pendiente',
      fecha:
          json['fecha_generacion']?.toString().substring(0, 10) ??
          'Sin fecha', // Extraemos solo YYYY-MM-DD
      vendedorNombre:
          json['vendedor_nombre']?.toString() ?? 'Vendedor Desconocido',
      detalles: detallesList,
    );
  }

  double get total =>
      detalles.fold(0, (sum, item) => sum + (item.precio * item.cantidad));
}
