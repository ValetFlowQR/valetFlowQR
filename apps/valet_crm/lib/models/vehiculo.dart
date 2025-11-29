import 'cliente.dart';

class Vehiculo {
  final String id;
  final String clienteId;
  final String marca;
  final String modelo;
  final String placas;
  final String color;
  final String estado; // Ejemplo: "En resguardo", "Entregado"

  // Campo opcional para mantener referencia al cliente seleccionado
  Cliente? cliente;

  Vehiculo({
    required this.id,
    required this.clienteId,
    required this.marca,
    required this.modelo,
    required this.placas,
    required this.color,
    required this.estado,
    this.cliente,
  });

  // Crear Vehiculo desde Firestore
  factory Vehiculo.fromMap(Map<String, dynamic> data, String documentId) {
    return Vehiculo(
      id: documentId,
      clienteId: data['clienteId'] ?? '',
      marca: data['marca'] ?? '',
      modelo: data['modelo'] ?? '',
      placas: data['placas'] ?? '',
      color: data['color'] ?? '',
      estado: data['estado'] ?? '',
    );
  }

  // Convertir Vehiculo a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'marca': marca,
      'modelo': modelo,
      'placas': placas,
      'color': color,
      'estado': estado,
      // No se guarda el objeto cliente, solo el clienteId
    };
  }

  // Método opcional para asignar cliente completo en memoria
  Vehiculo asignarCliente(Cliente c) {
    cliente = c;
    return this;
  }
}
