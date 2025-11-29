import 'dart:convert';
import 'package:http/http.dart' as http;

class EstadosService {
  final String _urlEstados =
      "https://sepomex.icalialabs.com/api/v1/states";

  Future<List<String>> obtenerEstados() async {
    final response = await http.get(Uri.parse(_urlEstados));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List estados = data["states"];

      return estados
          .map<String>((e) => e["name"].toString())
          .toList()
        ..sort();
    } else {
      throw Exception("Error al obtener estados");
    }
  }
}
