import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GraficasPage extends StatelessWidget {
  const GraficasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF045E66),
        title: const Text(
          "Gráficas",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildFutureCard(
              title: "Entradas vs Salidas por Hora",
              description: "Horas pico del estacionamiento",
              future: _getEntradasSalidas(),
              builder: (data) => _chartEntradasSalidas(data),
            ),

            const SizedBox(height: 20),

            _buildFutureCard(
              title: "Tiempo Promedio de Estancia",
              description: "Clasificación por rangos de tiempo",
              future: _getTiempoEstancia(),
              builder: (data) => _chartTiempoEstancia(data),
            ),

            const SizedBox(height: 20),

            _buildFutureCard(
              title: "Vehículos por Día de la Semana",
              description: "Flujo semanal",
              future: _getVehiculosPorDia(),
              builder: (data) => _chartVehiculosPorDia(data),
            ),

            const SizedBox(height: 20),

            _buildFutureCard(
              title: "Clientes Frecuentes",
              description: "Porcentaje de clientes recurrentes",
              future: _getClientesFrecuentes(),
              builder: (data) => _chartClientesFrecuentes(data),
            ),

            const SizedBox(height: 20),

            _buildFutureCard(
              title: "Ingresos",
              description: "Tendencia de ingresos por periodo",
              future: _getIngresos(),
              builder: (data) => _chartIngresos(data),
            ),

            const SizedBox(height: 20),

            _buildFutureCard(
              title: "Vehículos por Marca",
              description: "Distribución real según Firestore",
              future: _getTiposVehiculo(),
              builder: (data) => _chartTiposVehiculo(data),
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================
  //
  //   ******* FIREBASE DATA LOADERS (REAL DATA) ********
  //
  // =======================================================

  Future<List<Map<String, dynamic>>> _getEntradasSalidas() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("tickets").get();

    Map<int, int> entradas = {};
    Map<int, int> salidas = {};

    for (var doc in snapshot.docs) {
      String hEntrada = doc["horaEntrada"] ?? "0";
      String hSalida = doc["horaSalida"] ?? "0";

      int e = int.tryParse(hEntrada.split(":")[0]) ?? 0;
      int s = int.tryParse(hSalida.split(":")[0]) ?? 0;

      entradas[e] = (entradas[e] ?? 0) + 1;
      salidas[s] = (salidas[s] ?? 0) + 1;
    }

    return [
      {"entradas": entradas},
      {"salidas": salidas}
    ];
  }

  Future<Map<String, double>> _getTiempoEstancia() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("tickets").get();

    Map<String, double> rangos = {
      "0–30": 0,
      "30–60": 0,
      "60–120": 0,
      "120+": 0,
    };

    for (var doc in snapshot.docs) {
      String entrada = doc["horaEntrada"] ?? "0:0";
      String salida = doc["horaSalida"] ?? "0:0";

      int eMin = _toMinutos(entrada);
      int sMin = _toMinutos(salida);

      int diff = sMin - eMin;

      if (diff <= 30) rangos["0–30"] = rangos["0–30"]! + 1;
      else if (diff <= 60) rangos["30–60"] = rangos["30–60"]! + 1;
      else if (diff <= 120) rangos["60–120"] = rangos["60–120"]! + 1;
      else rangos["120+"] = rangos["120+"]! + 1;
    }

    return rangos;
  }

  int _toMinutos(String hora) {
    final parts = hora.split(":");
    int h = int.tryParse(parts[0]) ?? 0;
    int m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  Future<List<double>> _getVehiculosPorDia() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("tickets").get();

    List<double> dias = List.filled(7, 0);

    for (var doc in snapshot.docs) {
      DateTime fecha = DateTime.tryParse(doc["fecha"] ?? "") ?? DateTime.now();
      int dia = fecha.weekday - 1;
      dias[dia]++;
    }

    return dias;
  }

  Future<Map<String, double>> _getClientesFrecuentes() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("tickets").get();

    Map<String, int> clientes = {};

    for (var doc in snapshot.docs) {
      String id = doc["clienteId"] ?? "";
      clientes[id] = (clientes[id] ?? 0) + 1;
    }

    int frecuentes = clientes.values.where((x) => x >= 3).length;
    int ocasionales = clientes.length - frecuentes;

    return {
      "Ocasionales": ocasionales.toDouble(),
      "Frecuentes": frecuentes.toDouble(),
    };
  }

  Future<List<double>> _getIngresos() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("tickets").get();

    Map<int, double> ingresos = {};

    for (var doc in snapshot.docs) {
      double monto = (doc["monto"] ?? 0).toDouble();

      DateTime fecha = DateTime.tryParse(doc["fecha"] ?? "") ?? DateTime.now();
      int dia = fecha.day;

      ingresos[dia] = (ingresos[dia] ?? 0) + monto;
    }

    return ingresos.values.toList();
  }

  Future<Map<String, double>> _getTiposVehiculo() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("tickets").get();

    Map<String, double> marcas = {};

    for (var doc in snapshot.docs) {
      String marca = doc["vehiculoMarca"] ?? "Sin marca";
      marcas[marca] = (marcas[marca] ?? 0) + 1;
    }

    return marcas;
  }

  // =======================================================
  //
  //   ******* CARDS CON FUTUREBUILDER ********
  //
  // =======================================================

  Widget _buildFutureCard({
    required String title,
    required String description,
    required Future future,
    required Widget Function(dynamic data) builder,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black26,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF045E66),
              ),
            ),
            const SizedBox(height: 6),
            Text(description, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: FutureBuilder(
                future: future,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return builder(snap.data);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================
  //
  //   ******* GRÁFICAS (solo reciben datos) *******
  //
  // =======================================================

  Widget _chartEntradasSalidas(List data) {
    Map<int, int> entradas = Map.from(data[0]["entradas"]);
    Map<int, int> salidas = Map.from(data[1]["salidas"]);

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: true),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.green,
            spots: entradas.entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                .toList(),
          ),
          LineChartBarData(
            isCurved: true,
            color: Colors.red,
            spots: salidas.entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _chartTiempoEstancia(Map<String, double> data) {
    return BarChart(
      BarChartData(
        barGroups: List.generate(data.length, (i) {
          final key = data.keys.elementAt(i);
          final value = data[key]!;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(toY: value, color: Colors.blue),
            ],
          );
        }),
      ),
    );
  }

  Widget _chartVehiculosPorDia(List<double> dias) {
    return BarChart(
      BarChartData(
        barGroups: List.generate(dias.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(toY: dias[i], color: Colors.purple),
            ],
          );
        }),
      ),
    );
  }

  Widget _chartClientesFrecuentes(Map<String, double> data) {
    return PieChart(
      PieChartData(
        centerSpaceRadius: 40,
        sections: data.entries.map((e) {
          return PieChartSectionData(
            color: e.key == "Frecuentes" ? Colors.green : Colors.orange,
            value: e.value,
            title: e.key,
          );
        }).toList(),
      ),
    );
  }

  Widget _chartIngresos(List<double> ingresos) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: true),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.teal,
            spots: List.generate(
              ingresos.length,
              (i) => FlSpot(i.toDouble(), ingresos[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartTiposVehiculo(Map<String, double> data) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        sections: data.entries.map((e) {
          return PieChartSectionData(
            value: e.value,
            title: e.key,
            radius: 60,
          );
        }).toList(),
      ),
    );
  }
}
