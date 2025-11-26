import 'dart:io';
import 'package:http/http.dart' as http;

class ServerApiService {
  static const String baseUrl =
      "https://us-central1-valetflowqr-40544.cloudfunctions.net/api";

  static Future<String?> uploadCarPhoto(File file) async {
    final uri = Uri.parse("$baseUrl/detectCar");

    final request = http.MultipartRequest("POST", uri);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        await file.readAsBytes(),
        filename: "car.jpg",
      ),
    );

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return respStr; // Aquí viene la URL de Storage
    } else {
      print("Error server: $respStr");
      return null;
    }
  }
}
