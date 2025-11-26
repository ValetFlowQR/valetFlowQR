import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final _secure = FlutterSecureStorage();

Future<void> login(String email, String password) async {
  final resp = await http.post(
    Uri.parse('https://api.tuservidor.com/auth/login'),
    body: jsonEncode({'email': email, 'password': password}),
    headers: {'Content-Type': 'application/json'},
  );
  final json = jsonDecode(resp.body);
  await _secure.write(key: 'access_token', value: json['access_token']);
  await _secure.write(key: 'refresh_token', value: json['refresh_token']);
}
