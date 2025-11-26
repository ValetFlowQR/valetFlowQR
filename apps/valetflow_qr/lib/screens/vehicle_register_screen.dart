// lib/screens/vehicle_register_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

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
    _requestPermissionsAndInitCamera();
  }

  //---------------------------------------------------------------------------
  // 1️⃣ Solicitar permisos de cámara e inicializar
  //---------------------------------------------------------------------------
  Future<void> _requestPermissionsAndInitCamera() async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Se requieren permisos de cámara")),
      );
      return;
    }

    await _initCamera();
  }

  //---------------------------------------------------------------------------
  // 2️⃣ Inicializar cámara en JPEG
  //---------------------------------------------------------------------------
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.first;

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      setState(() => _isCameraReady = true);
    } catch (e) {
      print("ERROR INIT CAMERA: $e");
    }
  }

  //---------------------------------------------------------------------------
  // 3️⃣ Tomar foto + subir + análisis IA + guardar en Firestore
  //---------------------------------------------------------------------------
Future<void> _takePhoto() async {
  if (!_cameraController!.value.isInitialized) return;

  try {
    setState(() => _isUploading = true);

    final XFile picture = await _cameraController!.takePicture();
    await Future.delayed(const Duration(milliseconds: 400));

    final File file = File(picture.path);

    final exists = await file.exists();
    final length = await file.length();
    print("📁 Foto generada: $exists | $length bytes");

    if (!exists || length < 100) {
      throw Exception("La foto no se guardó correctamente.");
    }

    // -------------------------
    // 🔼 Subir a Firebase
    // -------------------------
    final path =
        "tickets/${widget.ticketId}/vehicle_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final ref = FirebaseStorage.instance.ref(path);
    await ref.putFile(file);

    final url = await ref.getDownloadURL();

    // -------------------------
    // 🔎 IA Local + Remota
    // -------------------------
    final String? plate = await detectPlateText(file);
    final String colorHex = await detectDominantColorHex(file);
    final String? carModel = await detectCarModelRemote(file);

    // -------------------------
    // 📌 Datos para Firestore
    // -------------------------
    final updateData = {
      "photoUrl": url,
      "carColor": colorHex,
      "updatedAt": FieldValue.serverTimestamp(),

      // 👇 AQUÍ LA CORRECCIÓN
      "statusHistory": FieldValue.arrayUnion([
        {
          "status": "photo_uploaded",
          "time": DateTime.now().toIso8601String(), 
          "source": "app_valet",
        }
      ]),
    };

    if (plate != null && plate.isNotEmpty) updateData["plate"] = plate;
    if (carModel != null && carModel.isNotEmpty) updateData["carModel"] = carModel;

    // -------------------------
    // 🔥 Guardar en Firestore
    // -------------------------
    await FirebaseFirestore.instance
        .collection("qr_codes")
        .doc(widget.ticketId)
        .set(updateData, SetOptions(merge: true));

    setState(() {
      _uploadedImageUrl = url;
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Foto subida y analizada correctamente 🚗✨")),
    );
  } catch (e, st) {
    print("ERROR VEHICLE REGISTER: $e\n$st");

    setState(() => _isUploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al procesar foto: $e")),
    );
  }
}


  //---------------------------------------------------------------------------
  // 4️⃣ Guardar información adicional del valet
  //---------------------------------------------------------------------------
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
      .set({
    "parkingSpot": _parkingSpotCtrl.text.trim(),
    "arrivalTime": FieldValue.serverTimestamp(),
    "status": "registrado_valet",
    "updatedAt": FieldValue.serverTimestamp(),
    "statusHistory": FieldValue.arrayUnion([
      {
        "status": "vehicle_data_ready",
        "time": DateTime.now().toIso8601String(),
        "source": "app_valet",
      }
    ]),
  }, SetOptions(merge: true));

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Datos guardados correctamente ✔️")),
  );

  Navigator.pop(context);
}


  //---------------------------------------------------------------------------
  // UI
  //---------------------------------------------------------------------------
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
              const Text("Foto subida correctamente",
                  style: TextStyle(color: Colors.green)),
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
