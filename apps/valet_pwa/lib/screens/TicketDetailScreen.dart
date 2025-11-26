import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TicketDetailScreen extends StatelessWidget {
  final String ticketId;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
  });

  Future<void> updateStatus(String newStatus) async {
    await FirebaseFirestore.instance
        .collection("qr_codes")
        .doc(ticketId)
        .update({
      "status": newStatus,
      "updatedAt": FieldValue.serverTimestamp(),
      "statusHistory": FieldValue.arrayUnion([
        {
          "status": newStatus,
          "source": "pwa_cliente",
          "time": FieldValue.serverTimestamp()
        }
      ])
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle del Ticket")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("qr_codes")
            .doc(ticketId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Ticket no encontrado ❌"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final plate = data["plate"] ?? "Sin placa";
          final model = data["carModel"] ?? "Sin modelo";
          final color = data["carColor"] ?? "Sin color";
          final photo = data["photoUrl"];
          final parking = data["parkingSpot"] ?? "No asignado";
          final status = data["status"] ?? "desconocido";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto del vehículo
                if (photo != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(photo, height: 220),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.black12,
                    child: const Center(child: Text("Sin foto")),
                  ),

                const SizedBox(height: 20),

                Text("Ticket: $ticketId",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                _info("Placa", plate),
                _info("Modelo", model),
                _info("Color", color),
                _info("Lugar asignado", parking),
                _info("Estado actual", status),

                const SizedBox(height: 30),

                _buildButtons(status),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildButtons(String status) {
    switch (status) {
      case "iniciado":
      case "estacionado":
        return ElevatedButton(
          onPressed: () => updateStatus("solicitado_cliente"),
          child: const Text("Solicitar mi vehículo"),
        );

      case "solicitado_cliente":
        return const Text(
          "El valet está trayendo tu auto...",
          style: TextStyle(fontSize: 16, color: Colors.orange),
        );

      case "listo_para_confirmar":
        return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () => updateStatus("entregado"),
          child: const Text("Confirmar recepción"),
        );

      case "entregado":
        return const Text(
          "Servicio finalizado. ¡Gracias por usar ValetFlowQR!",
          style: TextStyle(fontSize: 16, color: Colors.green),
        );

      default:
        return const SizedBox();
    }
  }
}
