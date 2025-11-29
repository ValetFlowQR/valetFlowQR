// lib/services/empleado_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/empleado.dart';

class EmpleadoService {
  final CollectionReference empleados =
      FirebaseFirestore.instance.collection('empleados');

  /// Agrega empleado (retorna id opcional)
  Future<String> addEmpleado(Empleado empleado) async {
    final docRef = await empleados.add(empleado.toMap());
    return docRef.id;
  }

  /// Actualiza empleado (requiere empleado.id)
  Future<void> updateEmpleado(Empleado empleado) async {
    if (empleado.id.isEmpty) {
      throw Exception('El id del empleado es requerido para actualizar.');
    }
    await empleados.doc(empleado.id).set(empleado.toMap(), SetOptions(merge: true));
  }

  /// Elimina empleado por id
  Future<void> deleteEmpleado(String id) async {
    if (id.isEmpty) return;
    await empleados.doc(id).delete();
  }

  /// Stream de empleados en tiempo real
  Stream<List<Empleado>> getEmpleados() {
    return empleados.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Empleado.fromFirestore(doc))
          .toList();
    });
  }

  /// Obtener empleado por id (opcional)
  Future<Empleado?> getEmpleadoById(String id) async {
    final doc = await empleados.doc(id).get();
    if (!doc.exists) return null;
    return Empleado.fromFirestore(doc);
  }
}
