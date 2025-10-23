import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'photo_register_screen.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String qrData = "RegistroVehiculo12345";

    return Scaffold(
      appBar: AppBar(title: const Text("Código QR del Vehículo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 20),
            const Text(
              "Escanee este código para continuar con el registro del vehículo",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PhotoRegisterScreen()),
                );
              },
              child: const Text("Simular Escaneo y Continuar"),
            ),
          ],
        ),
      ),
    );
  }
}
