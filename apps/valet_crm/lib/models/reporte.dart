class Reporte {
  final String id;
  final String titulo;
  final String fecha;
  final double ingresosTotales;
  final int totalClientes;

  Reporte({
    required this.id,
    required this.titulo,
    required this.fecha,
    required this.ingresosTotales,
    required this.totalClientes,
  });

  factory Reporte.fromMap(Map<String, dynamic> data, String documentId) {
    return Reporte(
      id: documentId,
      titulo: data['titulo'] ?? '',
      fecha: data['fecha'] ?? '',
      ingresosTotales: (data['ingresosTotales'] ?? 0).toDouble(),
      totalClientes: data['totalClientes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'fecha': fecha,
      'ingresosTotales': ingresosTotales,
      'totalClientes': totalClientes,
    };
  }
}
