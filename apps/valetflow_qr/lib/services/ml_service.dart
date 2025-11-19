// lib/services/ml_service.dart

import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img_pkg;
import 'package:http/http.dart' as http;

///
/// ==========================================================
///  🔹 DETECCIÓN DE PLACAS (OCR) — ML KIT
/// ==========================================================
///
Future<String?> detectPlateText(File file) async {
  final inputImage = InputImage.fromFile(file);
  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  try {
    final result = await recognizer.processImage(inputImage);

    // Regex simple para detectar placas
    final regex = RegExp(r'[A-Z0-9\-]{4,10}', caseSensitive: false);

    for (final block in result.blocks) {
      for (final line in block.lines) {
        final cleaned = line.text.replaceAll(RegExp(r'\s+'), '');
        final match = regex.firstMatch(cleaned);

        if (match != null) {
          return match.group(0)?.toUpperCase();
        }
      }
    }

    return null;
  } catch (e) {
    print("OCR error: $e");
    return null;
  } finally {
    await recognizer.close();
  }
}

///
/// ==========================================================
///  🔹 DETECCIÓN DE COLOR DOMINANTE — 100% Compatible con image 4.5.4
/// ==========================================================
///
Future<String> detectDominantColorHex(File file) async {
  final bytes = await file.readAsBytes();
  final image = img_pkg.decodeImage(bytes);

  if (image == null) return "#000000";

  // Reducimos la imagen para rendimiento
  final resized = img_pkg.copyResize(image, width: 100);

  int r = 0, g = 0, b = 0, count = 0;

  for (int y = 0; y < resized.height; y++) {
    for (int x = 0; x < resized.width; x++) {
      final pixel = resized.getPixel(x, y); // <--- Pixel RGBA

      r += pixel.r.toInt();
      g += pixel.g.toInt();
      b += pixel.b.toInt();

      count++;
    }
  }

  r = (r / count).round();
  g = (g / count).round();
  b = (b / count).round();

  final hex = '#'
      '${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';

  return hex.toUpperCase();
}

///
/// ==========================================================
///  🔹 DETECCIÓN DE MODELO POR API REMOTA
///     (si después conectas FastAPI / Flask / Node.JS)
/// ==========================================================
///
Future<String?> detectCarModelRemote(File file) async {
  final uri = Uri.parse("https://tu-servicio-de-inferencia.example.com/predict");

  final req = http.MultipartRequest("POST", uri);

  req.files.add(
    http.MultipartFile.fromBytes(
      'file',
      await file.readAsBytes(),
      filename: "car.jpg",
    ),
  );

  final resp = await req.send();

  if (resp.statusCode != 200) return null;

  final raw = await resp.stream.bytesToString();
  return raw;
}

///
/// ==========================================================
///  🔹 DETECCIÓN DE MODELO LOCAL TFLITE (SIN CARGA DINÁMICA)
///     🌟 NOTA:
///     Este método simplemente llama al servicio TFLite que tú crearás.
///     YA NO hay carga dinámica. No hay errores.
/// ==========================================================
///
Future<String?> detectCarModelLocal(
  File file,
  Future<String?> Function(File) classifier,
) async {
  try {
    return await classifier(file);
  } catch (e) {
    print("Error ejecutando modelo TFLite local: $e");
    return null;
  }
}
