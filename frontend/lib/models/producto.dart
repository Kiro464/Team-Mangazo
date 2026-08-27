class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precioReferencial;
  final String categoriaNombre;
  final String? imagen; // Puede ser null si aún no subes foto

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioReferencial,
    required this.categoriaNombre,
    this.imagen,
  });

  // Esta "fábrica" convierte el JSON de Django en un Objeto de Flutter
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      // Convertimos a double por si Django envía un entero o string
      precioReferencial: double.parse(json['precio_referencial'].toString()),
      categoriaNombre: json['categoria_nombre'] ?? 'Sin categoría',
      imagen: json['imagen'],
    );
  }
}
