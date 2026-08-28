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
      productoNombre: json['producto_nombre'] ?? 'Producto',
      cantidad: json['cantidad'],
      precio: double.parse(json['precio_unitario_aplicado'].toString()),
    );
  }
}

class Pedido {
  final int id;
  final String estado;
  final String fecha;
  final List<DetallePedido> detalles;

  Pedido({
    required this.id,
    required this.estado,
    required this.fecha,
    required this.detalles,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    var listaDetalles = json['detalles'] as List? ?? [];
    List<DetallePedido> detallesList = listaDetalles
        .map((i) => DetallePedido.fromJson(i))
        .toList();

    return Pedido(
      id: json['id'],
      estado: json['estado'] ?? 'Pendiente',
      fecha: json['fecha_generacion'] ?? '',
      detalles: detallesList,
    );
  }

  // Calcula el total sumando (precio * cantidad) de cada detalle
  double get total =>
      detalles.fold(0, (sum, item) => sum + (item.precio * item.cantidad));
}
