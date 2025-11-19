import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:valetflow_qr/services/secure_storage_service.dart';
import 'package:valetflow_qr/screens/qr_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final SecureStorageService _secureStorage = SecureStorageService();

  bool _isLoading = false; // 🔄 Para mostrar progreso

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 🔍 Validaciones básicas
    if (email.isEmpty || password.isEmpty) {
      _showMessage("Por favor completa todos los campos");
      return;
    }

    // Validar formato de correo
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showMessage("El formato del correo no es válido");
      return;
    }

    // Validar longitud de contraseña
    if (password.length < 6) {
      _showMessage("La contraseña debe tener al menos 6 caracteres");
      return;
    }

    try {
      setState(() => _isLoading = true);

      // 🔐 Intentar iniciar sesión
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;

      if (user != null) {
        final idToken = await user.getIdToken();
        await _secureStorage.saveToken('refresh_token', idToken ?? '');
        debugPrint('✅ Token guardado correctamente');

        _showMessage("Inicio de sesión exitoso ✅");

        // Redirigir al QR Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QrScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Error al iniciar sesión";

      switch (e.code) {
        case 'user-not-found':
          message = "Usuario no registrado. Comunícate con el administrador.";
          break;
        case 'wrong-password':
          message = "Contraseña incorrecta. Intenta nuevamente.";
          break;
        case 'invalid-email':
          message = "El formato del correo no es válido.";
          break;
        case 'too-many-requests':
          message =
              "Demasiados intentos fallidos. Intenta de nuevo más tarde.";
          break;
        default:
          message = "Error inesperado: ${e.message}";
      }

      _showMessage(message);
    } catch (e) {
      _showMessage("Ocurrió un error inesperado: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  "Iniciar Sesión",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // Campo correo
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Correo electrónico",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : const Text(
                            "Entrar",
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
