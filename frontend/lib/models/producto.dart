class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precioReferencial;
  final String categoriaNombre;
  final String vendedorNombre;
  final String? imagen; // Puede ser null si aún no subes foto

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioReferencial,
    required this.categoriaNombre,
    required this.vendedorNombre,
    this.imagen,
  });

  // Esta "fábrica" convierte el JSON de Django en un Objeto de Flutter
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id:
          int.tryParse(json['id'].toString()) ??
          0, // También lo blindamos por si acaso
      nombre: json['nombre']?.toString() ?? 'Sin nombre',
      descripcion: json['descripcion']?.toString() ?? '',
      precioReferencial:
          double.tryParse(json['precio_referencial'].toString()) ?? 0.0,
      categoriaNombre: json['categoria_nombre']?.toString() ?? 'Sin categoría',
      // Le decimos a Dart que lea el nuevo campo que configuramos en Django
      vendedorNombre: json['vendedor_nombre']?.toString() ?? 'Vendedor Anónimo',
      imagen: json['imagen'],
    );
  }
}
