// lib/models/cliente.dart
class Cliente {
  final String id;
  final String nombre;
  final String telefono;
  final String correo;
  final String fechaRegistro;

  Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.fechaRegistro,
  });

  // Convertir Cliente a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'fechaRegistro': fechaRegistro,
    };
  }

  // Crear Cliente desde Map de Firestore
  factory Cliente.fromMap(Map<String, dynamic> map, String docId) {
    return Cliente(
      id: docId,
      nombre: map['nombre'] ?? '',
      telefono: map['telefono'] ?? '',
      correo: map['correo'] ?? '',
      fechaRegistro: map['fechaRegistro'] ?? '',
    );
  }
}
