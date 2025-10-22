import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ValetFlowQR - Inicio'),
        backgroundColor: const Color(0xFF0175C2),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Bienvenido a ValetFlowQR',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF01579B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.5,
                  children: [
                    _buildCard(context, 'Solicitar Valet', Icons.local_parking,
                        Color(0xFF0175C2), '/request_valet'),
                    _buildCard(context, 'Estado del servicio', Icons.info,
                        Color(0xFF43A047), '/service_status'),
                    _buildCard(
                        context, 'Historial', Icons.history, Color(0xFF8E24AA), '/history'),
                    _buildCard(
                        context, 'Configuración', Icons.settings, Color(0xFF0288D1), '/settings'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, IconData icon, Color color, String route) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, route),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
