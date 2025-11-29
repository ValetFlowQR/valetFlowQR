import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente.dart';

class ClienteService {
  // 🔹 Referencia a la colección 'clientes'
  final CollectionReference clientes =
      FirebaseFirestore.instance.collection('clientes');

  /// 🔹 Crear un nuevo cliente
  Future<void> addCliente(Cliente cliente) async {
    if (cliente.nombre.isEmpty || cliente.telefono.isEmpty) {
      throw Exception('El nombre y teléfono son obligatorios.');
    }

    try {
      await clientes.add(cliente.toMap());
    } catch (e) {
      throw Exception('Error al agregar cliente: $e');
    }
  }

  /// 🔹 Obtener todos los clientes en tiempo real
  Stream<List<Cliente>> getClientes() {
    return clientes.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  /// 🔹 Obtener un cliente por ID
  Future<Cliente?> getClienteById(String id) async {
    if (id.isEmpty) return null;

    try {
      final doc = await clientes.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener cliente: $e');
    }
  }

  /// 🔹 Actualizar un cliente existente
  Future<void> updateCliente(Cliente cliente) async {
    if (cliente.id.isEmpty) {
      throw Exception('El ID del cliente es obligatorio para actualizar.');
    }

    try {
      await clientes.doc(cliente.id).set(cliente.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error al actualizar cliente: $e');
    }
  }

  /// 🔹 Eliminar un cliente por ID
  Future<void> deleteCliente(String id) async {
    if (id.isEmpty) return;

    try {
      await clientes.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar cliente: $e');
    }
  }
}
