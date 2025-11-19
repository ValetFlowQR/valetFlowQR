// lib/screens/vehicle_register_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// IA
import 'package:valetflow_qr/services/ml_service.dart';

class VehicleRegisterScreen extends StatefulWidget {
  final String ticketId;

  const VehicleRegisterScreen({
    super.key,
    required this.ticketId,
  });

  @override
  State<VehicleRegisterScreen> createState() => _VehicleRegisterScreenState();
}

class _VehicleRegisterScreenState extends State<VehicleRegisterScreen> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isUploading = false;

  String? _uploadedImageUrl;
  final TextEditingController _parkingSpotCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.first;

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    setState(() => _isCameraReady = true);
  }

  /// -------------------------------------------------------------
  /// 📸 Toma foto, sube al storage y ejecuta IA (placa/color/modelo)
  /// -------------------------------------------------------------
  Future<void> _takePhoto() async {
    if (!_cameraController!.value.isInitialized) return;

    try {
      setState(() => _isUploading = true);

      final XFile picture = await _cameraController!.takePicture();
      final File file = File(picture.path);

      // ---------------------------
      // 🔼 1. Subir a Firebase Storage
      // ---------------------------
      final storagePath =
          "tickets/${widget.ticketId}/vehicle_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final ref = FirebaseStorage.instance.ref().child(storagePath);
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      // ---------------------------
      // 🤖 2. Ejecutar IA
      // ---------------------------

      final String? plate = await detectPlateText(file);
      final String carColorHex = await detectDominantColorHex(file);
      final String? carModel = await detectCarModelRemote(file);

      // ---------------------------
      // 📝 3. Construir datos a guardar
      // ---------------------------
      final updateData = {
        "photoUrl": downloadUrl,
        "carColor": carColorHex,
        "updatedAt": FieldValue.serverTimestamp(),
      };

      if (plate != null && plate.isNotEmpty) {
        updateData["plate"] = plate;
      }

      if (carModel != null && carModel.isNotEmpty) {
        updateData["carModel"] = carModel;
      }

      // Historial
      updateData["statusHistory"] = FieldValue.arrayUnion([
        {
          "status": "photo_uploaded",
          "time": FieldValue.serverTimestamp(),
          "source": "app_valet",
        }
      ]);

      // ---------------------------
      // 🔥 4. Guardar en Firestore
      // ---------------------------
      await FirebaseFirestore.instance
          .collection("qr_codes")
          .doc(widget.ticketId)
          .update(updateData);

      // ---------------------------
      // 🎉 5. Mostrar imagen en la UI
      // ---------------------------
      setState(() {
        _uploadedImageUrl = downloadUrl;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto subida y analizada correctamente 🚗✨")),
      );
    } catch (e, st) {
      setState(() => _isUploading = false);
      print("ERROR VEHICLE REGISTER: $e\n$st");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al procesar la foto: $e")),
      );
    }
  }

  /// -------------------------------------------------------------
  /// 💾 Guardar datos del valet (lugar de estacionamiento)
  /// -------------------------------------------------------------
  Future<void> _saveValetData() async {
    if (_parkingSpotCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa la ubicación del estacionamiento")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("qr_codes")
        .doc(widget.ticketId)
        .update({
      "parkingSpot": _parkingSpotCtrl.text.trim(),
      "arrivalTime": FieldValue.serverTimestamp(),
      "status": "registrado_valet",
      "updatedAt": FieldValue.serverTimestamp(),
      "statusHistory": FieldValue.arrayUnion([
        {
          "status": "registrado_valet",
          "time": FieldValue.serverTimestamp(),
          "source": "app_valet",
        }
      ]),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Datos guardados correctamente ✔️")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro del Vehículo 🚗")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _isCameraReady
                ? AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  )
                : const Center(child: CircularProgressIndicator()),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _isUploading ? null : _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: Text(_isUploading ? "Procesando..." : "Tomar foto"),
            ),

            const SizedBox(height: 20),

            if (_uploadedImageUrl != null) ...[
              Image.network(_uploadedImageUrl!, height: 200),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Foto subida correctamente",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],

            const SizedBox(height: 30),

            TextField(
              controller: _parkingSpotCtrl,
              decoration: InputDecoration(
                labelText: "Ubicación (Ej: Z-12)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveValetData,
                child: const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text("Guardar Registro ✔️"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
