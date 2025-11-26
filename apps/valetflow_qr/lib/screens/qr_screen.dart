import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valetflow_qr/screens/vehicle_register_screen.dart';
import 'package:valetflow_qr/services/secure_storage_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';
import 'package:valetflow_qr/screens/login_screen.dart';

import 'package:valetflow_qr/services/ticket_service.dart'; // ⭐ IMPORTANTE

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  String? _generatedQrData;
  String? _lastTicketId;
  bool _isLoading = false;

  Future<void> _logout() async {
    final storage = SecureStorageService();
    await storage.clearAll();
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  /// 🔹 Genera ticket y QR con el modelo final REAL
  Future<void> _generateAndSaveQr() async {
    setState(() => _isLoading = true);

    try {
      final valet = FirebaseAuth.instance.currentUser?.email ?? 'valet_desconocido';
      final randomId = Random().nextInt(999999).toString().padLeft(6, '0');

      // ⭐ 1. Creamos documento vacío para obtener el ID
      final doc = await FirebaseFirestore.instance.collection("qr_codes").add({
        "tmp": true, // luego se sobreescribe con el modelo real
      });

      final ticketId = doc.id;

      // ⭐ 2. Crear ticket completo según el modelo final
      await TicketService.createTicket(ticketId);

      // ⭐ 3. Guardar ID para StreamBuilder
      setState(() {
        _lastTicketId = ticketId;
      });

      // ⭐ 4. Generamos URL para PWA
      final pwaUrl = "https://pwa-oorh.vercel.app/#/register?ticket=$ticketId";

      setState(() {
        _generatedQrData = pwaUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR generado correctamente ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar QR: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Valet 🚗'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Generar nuevo QR para cliente",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateAndSaveQr,
              icon: const Icon(Icons.qr_code),
              label: Text(_isLoading ? "Generando..." : "Generar QR"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 40),

            if (_generatedQrData != null && _lastTicketId != null)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("qr_codes")
                    .doc(_lastTicketId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null || snapshot.data!.data() == null) {
                    return Column(
                      children: [
                        QrImageView(data: _generatedQrData!, size: 200),
                        const SizedBox(height: 20),
                        const Text("Esperando a que el cliente escanee el QR...")
                      ],
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  // ⭐ La PWA pondrá status = "iniciado"
                  if (data["status"] == "iniciado") {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => VehicleRegisterScreen(ticketId: snapshot.data!.id),
                          ),
                        );
                      }
                    });
                  }


                  return Column(
                    children: [
                      QrImageView(data: _generatedQrData!, size: 200),
                      const SizedBox(height: 20),
                      const Text("Esperando a que el cliente escanee el QR...")
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
