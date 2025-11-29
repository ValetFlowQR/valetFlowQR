// lib/models/empleado.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Empleado {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final dynamic fechaRegistro; // opcional: Timestamp o String

  Empleado({
    this.id = '',
    required this.nombre,
    required this.email,
    required this.rol,
    this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'fechaRegistro': fechaRegistro,
    };
  }

  /// Factory que crea Empleado a partir de un Map (útil al parsear doc.data())
  factory Empleado.fromMap(Map<String, dynamic> map, String id) {
    return Empleado(
      id: id,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      rol: map['rol'] ?? '',
      fechaRegistro: map['fechaRegistro'],
    );
  }

  /// Factory que crea Empleado a partir de DocumentSnapshot (llamada desde el service)
  factory Empleado.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null) {
      return Empleado(id: doc.id, nombre: '', email: '', rol: '');
    }
    final map = data as Map<String, dynamic>;
    return Empleado.fromMap(map, doc.id);
  }
}
