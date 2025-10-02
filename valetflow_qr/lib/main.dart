import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ValetFlow QR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ===== MENU LATERAL =====
          Container(
            width: 220,
            color: const Color(0xFF094943),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DrawerHeader(
                  child: Text(
                    "ValetFlow QR",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _menuItem("Inicio"),
                _menuItem("Clientes"),
                _menuItem("Vehículos"),
                _menuItem("Tickets"),
                _menuItem("Reportes"),
                _menuItem("Configuración"),
              ],
            ),
          ),

          // ===== CONTENIDO PRINCIPAL SIMPLE =====
          const Expanded(
            child: Center(
              child: Text(
                "Contenido base",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== WIDGET REUTILIZABLE PARA MENÚ =====
  Widget _menuItem(String title) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        // Aquí puedes agregar navegación más adelante si quieres
      },
    );
  }
}
