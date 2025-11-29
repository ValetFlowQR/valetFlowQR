import 'dart:convert';
import 'package:http/http.dart' as http;

class MarcasService {
  final String _urlMarcas =
      "https://vpic.nhtsa.dot.gov/api/vehicles/getallmakes?format=json";

  /// Obtener lista de marcas
  Future<List<String>> obtenerMarcas() async {
    final response = await http.get(Uri.parse(_urlMarcas));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List marcas = data["Results"];

      return marcas
          .map<String>((m) => m["Make_Name"].toString())
          .toList()
        ..sort();
    } else {
      throw Exception("Error al obtener marcas");
    }
  }
}
