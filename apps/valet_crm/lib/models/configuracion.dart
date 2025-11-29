class Configuracion {
  String id;
  String nombreNegocio;
  String direccion;
  String telefono;
  String email;
  String? logoURL;

  Configuracion({
    required this.id,
    required this.nombreNegocio,
    required this.direccion,
    required this.telefono,
    required this.email,
    this.logoURL,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombreNegocio': nombreNegocio,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'logoURL': logoURL,
    };
  }

  factory Configuracion.fromMap(Map<String, dynamic> data, String id) {
    return Configuracion(
      id: id,
      nombreNegocio: data['nombreNegocio'] ?? '',
      direccion: data['direccion'] ?? '',
      telefono: data['telefono'] ?? '',
      email: data['email'] ?? '',
      logoURL: data['logoURL'],
    );
  }
}
