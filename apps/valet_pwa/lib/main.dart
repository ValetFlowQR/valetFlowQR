import 'package:flutter/material.dart';
import 'screens/privacy_screen.dart';

void main() {
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
          onAccepted: () {
            Navigator.pop(context); // cerrar aviso
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Has aceptado la Política de Privacidad ✅')),
            );
            // aquí puedes luego redirigir al formulario de registro
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
              Image.asset('assets/logo.png', height: 120), // opcional
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
