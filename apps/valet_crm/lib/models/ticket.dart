class Ticket {
  final String id;
  final String clienteId;
  final String clienteNombre;   // Nombre del cliente
  final String vehiculoId;
  final String vehiculoMarca;   // Marca del vehículo
  final String vehiculoPlacas;  // Placas del vehículo
  final String fecha;           // Fecha de registro (ISO)
  final String horaEntrada;     // Hora de entrada (HH:mm)
  final String horaSalida;      // Hora de salida (HH:mm)
  final double monto;           // Monto calculado
  final String tipo;            // Tipo de servicio (Estacionamiento, Lavado, etc.)

  Ticket({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.vehiculoId,
    required this.vehiculoMarca,
    required this.vehiculoPlacas,
    required this.fecha,
    required this.horaEntrada,
    required this.horaSalida,
    required this.monto,
    required this.tipo,
  });

  // Crear un Ticket desde Map (Firestore)
  factory Ticket.fromMap(Map<String, dynamic> data, String documentId) {
    return Ticket(
      id: documentId,
      clienteId: data['clienteId'] ?? '',
      clienteNombre: data['clienteNombre'] ?? '',
      vehiculoId: data['vehiculoId'] ?? '',
      vehiculoMarca: data['vehiculoMarca'] ?? '',
      vehiculoPlacas: data['vehiculoPlacas'] ?? '',
      fecha: data['fecha'] ?? '',
      horaEntrada: data['horaEntrada'] ?? '',
      horaSalida: data['horaSalida'] ?? '',
      monto: (data['monto'] ?? 0).toDouble(),
      tipo: data['tipo'] ?? '',
    );
  }

  // Convertir un Ticket a Map (para Firestore o n8n)
  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'vehiculoId': vehiculoId,
      'vehiculoMarca': vehiculoMarca,
      'vehiculoPlacas': vehiculoPlacas,
      'fecha': fecha,
      'horaEntrada': horaEntrada,
      'horaSalida': horaSalida,
      'monto': monto,
      'tipo': tipo,
    };
  }
}
