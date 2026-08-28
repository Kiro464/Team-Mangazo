class Resena {
  final double calificacion;
  final String comentario;
  final String compradorNombre;
  final String fecha;

  Resena({
    required this.calificacion,
    required this.comentario,
    required this.compradorNombre,
    required this.fecha,
  });

  factory Resena.fromJson(Map<String, dynamic> json) {
    return Resena(
      calificacion: double.tryParse(json['calificacion'].toString()) ?? 5.0,
      comentario: json['comentario']?.toString() ?? '',
      compradorNombre: json['comprador_nombre']?.toString() ?? 'Anónimo',
      fecha: json['fecha']?.toString().substring(0, 10) ?? '',
    );
  }
}

class Vendedor {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String? telefonoWhatsapp;
  final bool esPremium;
  final String? fotoPerfil;
  final String? historiaVendedor;
  final String? linkRedes;
  final String? videoYoutube; // <-- NUEVO
  final double promedioCalificaciones; // <-- NUEVO
  final List<Resena> resenas; // <-- NUEVO

  Vendedor({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.telefonoWhatsapp,
    required this.esPremium,
    this.fotoPerfil,
    this.historiaVendedor,
    this.linkRedes,
    this.videoYoutube,
    required this.promedioCalificaciones,
    required this.resenas,
  });

  String get nombreCompleto =>
      '$firstName $lastName'.trim().isEmpty ? username : '$firstName $lastName';

  factory Vendedor.fromJson(Map<String, dynamic> json) {
    var listaResenas = json['resenas'] as List? ?? [];
    return Vendedor(
      id: int.tryParse(json['id'].toString()) ?? 0,
      username: json['username']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telefonoWhatsapp: json['telefono_whatsapp']?.toString(),
      esPremium: json['es_premium'] ?? false,
      fotoPerfil: json['foto_perfil']?.toString(),
      historiaVendedor: json['historia_vendedor']?.toString(),
      linkRedes: json['link_redes']?.toString(),
      videoYoutube: json['video_youtube']?.toString(),
      promedioCalificaciones:
          double.tryParse(json['promedio_calificaciones'].toString()) ?? 0.0,
      resenas: listaResenas.map((i) => Resena.fromJson(i)).toList(),
    );
  }
}
