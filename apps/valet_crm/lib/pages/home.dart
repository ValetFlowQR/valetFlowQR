import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:valet_crm/models/empleado.dart';
import 'package:valet_crm/pages/empleado.dart';
import './clientes.dart';
import './vehiculos.dart';
import './tickets.dart';
import 'correo.dart';
import './configuracion.dart';
import './login.dart';
import './graficas.dart';
import '../services/auth_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = _firebaseAuth.currentUser;
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF045E66),
        elevation: 0,
        title: const Text(
          "Panel Administrativo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF045E66)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ==== TARJETA DE USUARIO ====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFF045E66),
                          backgroundImage: _user?.photoURL != null
                              ? NetworkImage(_user!.photoURL!)
                              : null,
                          child: _user?.photoURL == null
                              ? const Icon(Icons.person, color: Colors.white, size: 40)
                              : null,
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _user?.displayName ?? "Administrador",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF045E66),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _user?.email ?? "usuario@correo.com",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Colors.black54),
                          onPressed: () async {
                            await _authService.signOut();
                            if (!mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==== GRID DE MÓDULOS ====
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 4 : 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.1,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildModuleCard(
                        icon: Icons.people_alt_rounded,
                        title: "Clientes",
                        subtitle: "Gestión de clientes",
                        onTap: () => _navigateTo(const Clientes()),
                      ),
                      _buildModuleCard(
                        icon: Icons.directions_car_filled_rounded,
                        title: "Vehículos",
                        subtitle: "Registro y control",
                        onTap: () => _navigateTo(const Vehiculos()),
                      ),
                      _buildModuleCard(
                        icon: Icons.badge_rounded,
                        title: "Empleados",
                        subtitle: "Registro y control del personal",
                        onTap: () => _navigateTo(const EmpleadosPage()),
                    ),
                      _buildModuleCard(
                        icon: Icons.receipt_long_rounded,
                        title: "Tickets",
                        subtitle: "Historial y reportes",
                        onTap: () => _navigateTo(const Tickets()),
                      ),
                      _buildModuleCard(
                        icon: Icons.bar_chart_rounded,
                        title: "Gráficas",
                        subtitle: "Visualización de datos",
                        onTap: () => _navigateTo(const GraficasPage()),
                      ),
                      _buildModuleCard(
                        icon: Icons.settings_rounded,
                        title: "Configuración",
                        subtitle: "Preferencias del sistema",
                        onTap: () => _navigateTo(const ConfiguracionPage()),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  const Text(
                    "© 2025 ValetFlow CRM — Gestión inteligente y rápida",
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF045E66), size: 42),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF045E66),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
