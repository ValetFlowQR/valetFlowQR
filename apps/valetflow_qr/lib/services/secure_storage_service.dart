import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Guarda un valor de forma segura
  Future<void> saveToken(String key, String? value) async {
    await _storage.write(key: key, value: value);
  }

  /// Recupera un valor guardado
  Future<String?> getToken(String key) async {
    return await _storage.read(key: key);
  }

  /// Elimina un valor (por ejemplo, al cerrar sesión)
  Future<void> deleteToken(String key) async {
    await _storage.delete(key: key);
  }

  /// Limpia todo el almacenamiento seguro
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
