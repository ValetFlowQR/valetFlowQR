import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registro con correo y contraseña
  Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // Inicio de sesión con correo y contraseña
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;
}
