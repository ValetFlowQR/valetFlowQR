import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:valet_crm/services/auth_service.dart';
import 'home.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _error = '';

  final Color baseColor = const Color(0xFF045E66);
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    try {
      final user = await _authService.signUp(email, password);
      setState(() => _loading = false);

      if (user != null) {
        await user.sendEmailVerification();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        setState(() => _error = "Error al registrar. Intenta nuevamente.");
      }
    } on FirebaseAuthException catch (e) {
      String message = "Error al registrar.";
      if (e.code == 'email-already-in-use') {
        message = "El correo ya está en uso.";
      } else if (e.code == 'weak-password') {
        message = "Contraseña demasiado débil.";
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
      backgroundColor: baseColor,
      body: Stack(
        children: [
          // Fondo animado con nuevas posiciones
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF045E66),
                      Color(0xFF047B84),
                      Color(0xFF04949A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Círculos reposicionados
                    _buildAnimatedCircle(
                      top: 40,
                      right: 30,
                      size: 180,
                      opacity: 0.08,
                      offset: math.sin(_controller.value * math.pi) * 10,
                    ),
                    _buildAnimatedCircle(
                      bottom: 60,
                      left: 50,
                      size: 230,
                      opacity: 0.07,
                      offset: math.cos(_controller.value * math.pi) * 18,
                    ),
                    _buildAnimatedCircle(
                      top: 180,
                      left: 120,
                      size: 130,
                      opacity: 0.06,
                      offset: math.sin(_controller.value * 2 * math.pi) * 15,
                    ),
                    _buildAnimatedCircle(
                      bottom: 140,
                      right: 90,
                      size: 110,
                      opacity: 0.05,
                      offset: math.cos(_controller.value * 2 * math.pi) * 10,
                    ),
                  ],
                ),
              );
            },
          ),

          // Contenido principal
          Center(
            child: Padding(
              padding: const EdgeInsets.all(0),
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
                      Icons.person_add_rounded, // nuevo ícono sugerido
                      color: baseColor,
                      size: 70,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Crea tu cuenta",
                      style: TextStyle(
                        color: baseColor,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Regístrate para comenzar a usar ValetFlow",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 35),

                    // Formulario
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
                          const SizedBox(height: 20),
                          _buildInputField(
                            controller: _confirmPasswordController,
                            label: "Confirmar contraseña",
                            icon: Icons.lock_reset_outlined,
                            isPassword: true,
                            obscurePassword: _obscureConfirmPassword,
                            onTogglePassword: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return "Las contraseñas no coinciden";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _loading
                          ? CircularProgressIndicator(color: baseColor)
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: baseColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  "Registrarse",
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
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "¿Ya tienes cuenta? Inicia sesión",
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
    required double opacity,
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
          color: Colors.white.withOpacity(opacity),
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
