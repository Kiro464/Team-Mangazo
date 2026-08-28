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
  });

  String get nombreCompleto =>
      '$firstName $lastName'.trim().isEmpty ? username : '$firstName $lastName';

  factory Vendedor.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
