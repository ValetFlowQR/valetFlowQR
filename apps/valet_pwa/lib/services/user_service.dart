// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;
  final _box = Hive.box('valetData');

  Future<bool> get isOnline async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> saveUser({
    required String name,
    String? phone,
  }) async {
    final data = {
      'name': name,
      'phone': phone,
      'createdAt': DateTime.now().toIso8601String()
    };

    await _box.put('userInfo', data);

    if (await isOnline) {
      try {
        await _firestore.collection("users").add(data);
        print("Usuario guardado en Firestore");
      } catch (e) {
        print("Error al guardar online: $e");
      }
    }
  }

  Map<String, dynamic>? getLocalUser() {
    return _box.get('userInfo');
  }
}
