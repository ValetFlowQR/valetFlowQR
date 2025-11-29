import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Inicializa GoogleSignIn según plataforma
  final GoogleSignIn _googleSignIn = kIsWeb
      ? GoogleSignIn(
          clientId: "TU_CLIENT_ID_WEB_DE_FIREBASE", // <- Reemplaza con tu clientId web
          scopes: ['email'],
        )
      : GoogleSignIn();

  final Logger _logger = Logger('AuthService');

  /// 🔹 Inicia sesión con correo y contraseña
  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential result =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      _logger.info('Sesión iniciada: ${result.user?.email}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, action: "iniciar sesión");
      return null;
    } catch (e) {
      _logger.severe('Error inesperado al iniciar sesión: $e');
      return null;
    }
  }

  /// 🔹 Registra un nuevo usuario con correo y contraseña
  Future<User?> signUp(String email, String password) async {
    try {
      final UserCredential result =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _logger.info('Usuario registrado: ${result.user?.email}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, action: "registrar usuario");
      return null;
    } catch (e) {
      _logger.severe('Error inesperado al registrar usuario: $e');
      return null;
    }
  }

  /// 🔹 Inicia sesión con Google (web y móvil)
  Future<User?> signInWithGoogle() async {
    try {
      // En web no hace falta cerrar sesión antes
      if (!kIsWeb) await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _logger.warning('Inicio de sesión con Google cancelado por el usuario.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      _logger.info('Sesión iniciada con Google: ${result.user?.email}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, action: "iniciar sesión con Google");
      return null;
    } catch (e) {
      _logger.severe('Error inesperado al iniciar sesión con Google: $e');
      return null;
    }
  }

  /// 🔹 Cierra sesión de Firebase y Google
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (!kIsWeb) await _googleSignIn.signOut();
      _logger.info('Sesión cerrada correctamente.');
    } catch (e) {
      _logger.severe('Error al cerrar sesión: $e');
    }
  }

  /// 🔹 Usuario actualmente autenticado
  User? get currentUser => _auth.currentUser;

  /// 🧩 Manejo centralizado de errores comunes
  void _handleAuthError(FirebaseAuthException e, {required String action}) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = "No existe un usuario con ese correo.";
        break;
      case 'wrong-password':
        message = "Contraseña incorrecta.";
        break;
      case 'invalid-email':
        message = "El formato del correo no es válido.";
        break;
      case 'user-disabled':
        message = "La cuenta ha sido deshabilitada.";
        break;
      case 'email-already-in-use':
        message = "El correo ya está registrado.";
        break;
      case 'weak-password':
        message = "La contraseña es demasiado débil.";
        break;
      case 'account-exists-with-different-credential':
        message = "Ya existe una cuenta con otro método de inicio.";
        break;
      default:
        message = e.message ?? "Error desconocido al $action.";
    }
    _logger.warning('Error al $action: $message');
  }
}
