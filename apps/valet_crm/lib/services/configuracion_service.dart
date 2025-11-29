import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/configuracion.dart';

class ConfiguracionService {
  final CollectionReference _configRef =
      FirebaseFirestore.instance.collection('configuracion');

  /// 🔹 Obtiene la configuración (solo se espera un documento)
  Future<Configuracion?> obtenerConfiguracion() async {
    final snapshot = await _configRef.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return Configuracion.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  /// 🔹 Guarda o actualiza la configuración
  Future<void> guardarConfiguracion(Configuracion config) async {
    await _configRef.doc(config.id).set(config.toMap());
  }

  /// 🔹 Sube una imagen (logo) al Storage
  Future<String> subirLogo(File imagen) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('logos/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(imagen);
    return await ref.getDownloadURL();
  }
}
