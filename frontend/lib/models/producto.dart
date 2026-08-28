class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precioReferencial;
  final String categoriaNombre;
  final String vendedorNombre;
  final int vendedorId;
  final String? vendedorTelefono;
  final String? imagen; // Puede ser null si aún no subes foto

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioReferencial,
    required this.categoriaNombre,
    required this.vendedorNombre,
    required this.vendedorId,
    this.vendedorTelefono,
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
      vendedorId: int.tryParse(json['vendedor_id'].toString()) ?? 0,
      vendedorTelefono: json['vendedor_telefono']?.toString(),
      imagen: json['imagen'],
    );
  }
}
