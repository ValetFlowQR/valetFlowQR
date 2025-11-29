import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehiculo.dart';
import '../services/marcas_service.dart';
import '../services/estados_service.dart';

class VehiculoService {
  final CollectionReference vehiculos =
      FirebaseFirestore.instance.collection('vehiculos');

  final MarcasService _marcasService = MarcasService();
  final EstadosService _estadosService = EstadosService();

  /// 🔹 Crear vehículo
  Future<void> addVehiculo(Vehiculo vehiculo) async {
    if (vehiculo.clienteId.isEmpty ||
        vehiculo.marca.isEmpty ||
        vehiculo.placas.isEmpty) {
      throw Exception('Debe seleccionar un cliente, Marca y Placas.');
    }

    // 🔥 Validar marca con API real
    final marcas = await _marcasService.obtenerMarcas();
    if (!marcas.contains(vehiculo.marca.toUpperCase())) {
      throw Exception("La marca '${vehiculo.marca}' no existe en la API.");
    }

    // 🔥 Validar estado (solo si lo llenaron)
    if (vehiculo.estado.isNotEmpty) {
      final estados = await _estadosService.obtenerEstados();
      if (!estados.contains(vehiculo.estado)) {
        throw Exception("El estado '${vehiculo.estado}' no es válido.");
      }
    }

    // Validación placas
    if (vehiculo.placas.length < 6) {
      throw Exception("Las placas deben tener al menos 6 caracteres.");
    }

    try {
      await vehiculos.add(vehiculo.toMap());
    } catch (e) {
      throw Exception("Error al agregar vehículo: $e");
    }
  }

  /// 🔹 Obtener todos los vehículos
  Stream<List<Vehiculo>> getVehiculos() {
    return vehiculos.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Vehiculo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// 🔹 Obtener vehículos por cliente
  Stream<List<Vehiculo>> getVehiculosByCliente(String clienteId) {
    return vehiculos
        .where("clienteId", isEqualTo: clienteId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Vehiculo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// 🔹 Obtener vehículo por ID
  Future<Vehiculo?> getVehiculoById(String id) async {
    if (id.isEmpty) return null;

    try {
      final doc = await vehiculos.doc(id).get();
      if (!doc.exists) return null;

      return Vehiculo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception("Error al obtener vehículo: $e");
    }
  }

  /// 🔹 Actualizar vehículo
  Future<void> updateVehiculo(Vehiculo vehiculo) async {
    if (vehiculo.id.isEmpty) {
      throw Exception('El ID es obligatorio.');
    }

    if (vehiculo.clienteId.isEmpty ||
        vehiculo.marca.isEmpty ||
        vehiculo.placas.isEmpty) {
      throw Exception('Debe seleccionar un cliente, Marca y Placas.');
    }

    // 🔥 Validación de marca
    final marcas = await _marcasService.obtenerMarcas();
    if (!marcas.contains(vehiculo.marca.toUpperCase())) {
      throw Exception("La marca '${vehiculo.marca}' no existe.");
    }

    // 🔥 Validación estado
    if (vehiculo.estado.isNotEmpty) {
      final estados = await _estadosService.obtenerEstados();
      if (!estados.contains(vehiculo.estado)) {
        throw Exception("Estado '${vehiculo.estado}' inválido.");
      }
    }

    try {
      await vehiculos
          .doc(vehiculo.id)
          .set(vehiculo.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception("Error al actualizar: $e");
    }
  }

  /// 🔹 Eliminar
  Future<void> deleteVehiculo(String id) async {
    if (id.isEmpty) return;
    try {
      await vehiculos.doc(id).delete();
    } catch (e) {
      throw Exception("Error al eliminar: $e");
    }
  }
}
