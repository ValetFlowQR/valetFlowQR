import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle; 
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class CarModelTFLiteService {
  Interpreter? _interpreter;
  List<String>? _labels;

  final int inputSize = 224;
  final double mean = 127.5;
  final double std = 127.5;

  Future<void> loadModel() async {
    _interpreter ??= await Interpreter.fromAsset(
      'models/car_model_classifier.tflite',
      options: InterpreterOptions()..threads = 2,
    );

    _labels = await _loadLabels("models/labels.txt");

    print("🔥 Modelo TFLite cargado correctamente");
  }

  /// Cargar labels desde assets (CORRECTO en Flutter)
  Future<List<String>> _loadLabels(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final lines = raw.split('\n');
    return lines.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  /// Ejecuta inferencia sobre la imagen
  Future<String?> predict(File imageFile) async {
    if (_interpreter == null) await loadModel();

    final rawBytes = await imageFile.readAsBytes();
    final img.Image? image = img.decodeImage(rawBytes);
    if (image == null) return null;

    // Preprocesar imagen
    img.Image resized = img.copyResize(image, width: inputSize, height: inputSize);
    var input = _imageToByteListFloat32(resized);

    // Salida (MobileNet = 1001)
    var output = List.filled(1001, 0.0).reshape([1, 1001]);

    _interpreter!.run(input, output);

    // Encontrar clase con mayor probabilidad
    double maxProb = -1;
    int maxIndex = -1;

    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > maxProb) {
        maxProb = output[0][i];
        maxIndex = i;
      }
    }

    if (maxIndex == -1 || maxIndex >= _labels!.length) return null;

    return "${_labels![maxIndex]} (${maxProb.toStringAsFixed(2)})";
  }

  /// Convierte la imagen en tensores normalizados
  Uint8List _imageToByteListFloat32(img.Image image) {
    final bytes = Float32List(inputSize * inputSize * 3);
    int index = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);

        bytes[index++] = (pixel.r - mean) / std;
        bytes[index++] = (pixel.g - mean) / std;
        bytes[index++] = (pixel.b - mean) / std;
      }
    }

    return bytes.buffer.asUint8List();
  }
}
