import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Pantallas
import 'screens/privacy_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/request_valet_screen.dart';
import 'screens/service_status_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ValetFlowQRApp());
}

class ValetFlowQRApp extends StatelessWidget {
  const ValetFlowQRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ValetFlowQR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const QRHomeScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(ticketId: ''),
        '/home': (context) => HomeScreen(),
        '/request_valet': (context) => RequestValetScreen(),
        '/service_status': (context) => ServiceStatusScreen(),
        '/history': (context) => HistoryScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}

class QRHomeScreen extends StatelessWidget {
  const QRHomeScreen({super.key});

  void _openPrivacyScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrivacyScreen(
          readOnly: false, // ❗ Importante: no es de solo lectura
          onAccepted: () {
            Navigator.pop(context); // Cerrar pantalla
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Has aceptado la Política de Privacidad ✅'),
              ),
            );

            // Redirigir al registro
            Navigator.pushNamed(context, '/register');
          },
          onDeclined: () {
            Navigator.pop(context); // Volver atrás
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Debes aceptar la Política para continuar.'),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.jpg', height: 120),
              const SizedBox(height: 20),
              const Text(
                'Bienvenido a ValetFlowQR',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Escanea el QR en tu ticket para registrar tu vehículo y recibir actualizaciones.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _openPrivacyScreen(context),
                child: const Text('Comenzar Registro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
