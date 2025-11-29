import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'home.dart';
import 'register.dart';
import 'package:valet_crm/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _loading = false;
  bool _obscurePassword = true;
  String _error = '';

  final Color baseColor = const Color(0xFF045E66);

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = '';
    });

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    try {
      final user = await _authService.signIn(email, password);
      if (!mounted) return;
      setState(() => _loading = false);

      if (user != null) {
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          setState(() {
            _error =
                "Debe verificar su correo antes de ingresar. Se ha enviado un nuevo correo de verificación.";
          });
          await _authService.signOut();
          await _secureStorage.delete(key: 'uid');
          return;
        }

        await _secureStorage.write(key: 'uid', value: user.uid);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        setState(() => _error = "❌ Correo o contraseña incorrectos.");
      }
    } on FirebaseAuthException catch (e) {
      String message = "Error al iniciar sesión.";
      if (e.code == 'user-not-found') message = "Usuario no encontrado.";
      if (e.code == 'wrong-password') message = "Contraseña incorrecta.";
      if (e.code == 'too-many-requests') {
        message = "Demasiados intentos. Intente más tarde.";
      }
      setState(() {
        _error = message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Ocurrió un error inesperado. Intente nuevamente.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo animado
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF045E66),
                      Color(0xFF048B94),
                      Color(0xFF049CA6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Burbuja superior izquierda
                    _buildAnimatedCircle(
                        top: 30,
                        left: 50,
                        size: 150,
                        color: Colors.white.withOpacity(0.08),
                        offset: math.sin(_controller.value * math.pi) * 25),
                    // Burbuja grande centro-derecha
                    _buildAnimatedCircle(
                        top: 200,
                        right: 30,
                        size: 250,
                        color: Colors.cyanAccent.withOpacity(0.10),
                        offset: math.cos(_controller.value * 2 * math.pi) * 30),
                    // Burbuja inferior izquierda
                    _buildAnimatedCircle(
                        bottom: 60,
                        left: 40,
                        size: 180,
                        color: Colors.tealAccent.withOpacity(0.07),
                        offset: math.sin(_controller.value * math.pi) * 20),
                    // Burbuja más pequeña al fondo
                    _buildAnimatedCircle(
                        top: 400,
                        left: 220,
                        size: 90,
                        color: Colors.white.withOpacity(0.06),
                        offset:
                            math.cos(_controller.value * 2 * math.pi) * 18),
                    // Nueva burbuja inferior derecha
                    _buildAnimatedCircle(
                        bottom: 40,
                        right: 60,
                        size: 140,
                        color: Colors.lightBlueAccent.withOpacity(0.08),
                        offset:
                            math.sin(_controller.value * 1.5 * math.pi) * 22),
                  ],
                ),
              );
            },
          ),

          // Contenido principal
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 45),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.badge_rounded,
                        color: baseColor,
                        size: 70,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Bienvenido a ValetFlow",
                        style: TextStyle(
                          color: baseColor,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Inicia sesión para continuar",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 35),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildInputField(
                              controller: _emailController,
                              label: "Correo electrónico",
                              icon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Ingrese su correo";
                                }
                                final emailRegex = RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                if (!emailRegex.hasMatch(value)) {
                                  return "Correo inválido";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              controller: _passwordController,
                              label: "Contraseña",
                              icon: Icons.lock_outline,
                              isPassword: true,
                              obscurePassword: _obscurePassword,
                              onTogglePassword: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Ingrese su contraseña";
                                }
                                if (value.length < 6) {
                                  return "Mínimo 6 caracteres";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _loading
                            ? CircularProgressIndicator(color: baseColor)
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: baseColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: const Text(
                                    "Iniciar sesión",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      if (_error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _error,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 25),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()),
                          );
                        },
                        child: Text(
                          "¿No tienes cuenta? Regístrate aquí",
                          style: TextStyle(
                            color: baseColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
    required double offset,
  }) {
    return Positioned(
      top: top != null ? top + offset : null,
      bottom: bottom != null ? bottom - offset : null,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool obscurePassword = false,
    VoidCallback? onTogglePassword,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscurePassword : false,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: baseColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: baseColor,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        labelStyle: const TextStyle(color: Colors.black87),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: baseColor, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
