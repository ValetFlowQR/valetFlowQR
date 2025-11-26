import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceStatusScreen extends StatelessWidget {
  final String? ticketId;

  const ServiceStatusScreen({super.key, this.ticketId});

  @override
  Widget build(BuildContext context) {
    if (ticketId == null || ticketId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Estado del Servicio")),
        body: const Center(child: Text("No hay ticket seleccionado.")),
      );
    }

    final ticketRef =
        FirebaseFirestore.instance.collection("qr_codes").doc(ticketId);

    return Scaffold(
      appBar: AppBar(title: const Text("Estado del Servicio")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: ticketRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Ticket no encontrado ❌"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data["status"] ?? "desconocido";
          final plate = data["plate"] ?? "No disponible";
          final model = data["carModel"] ?? "No disponible";
          final color = data["carColor"] ?? "No disponible";
          final photoUrl = data["photoUrl"];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FOTO DEL VEHÍCULO
                if (photoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(photoUrl, height: 220),
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

                _infoTile("Estado:", status),
                _infoTile("Placa:", plate),
                _infoTile("Modelo:", model),
                _infoTile("Color:", color),

                const SizedBox(height: 30),

                _buildButtonByStatus(context, status, ticketRef),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        "$label $value",
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildButtonByStatus(
      BuildContext context, String status, DocumentReference ref) {
    switch (status) {
      case "iniciado":
      case "estacionado":
        return ElevatedButton(
          onPressed: () async {
            await ref.update({
              "status": "solicitado_cliente",
              "requestedAt": DateTime.now(),
              "statusHistory": FieldValue.arrayUnion([
                {
                  "status": "solicitado_cliente",
                  "source": "pwa_cliente",
                  "time": FieldValue.serverTimestamp()
                }
              ])
            });
          },
          child: const Text("Solicitar mi vehículo"),
        );

      case "solicitado_cliente":
        return const Text(
          "Tu solicitud fue enviada. El valet está trayendo tu vehículo.",
          style: TextStyle(fontSize: 16, color: Colors.orange),
        );

      case "en_camino":
        return const Text(
          "El valet viene en camino con tu auto...",
          style: TextStyle(fontSize: 16, color: Colors.orange),
        );

      case "listo_para_confirmar":
        return ElevatedButton(
          onPressed: () async {
            await ref.update({
              "status": "entregado",
              "deliveredAt": DateTime.now(),
              "statusHistory": FieldValue.arrayUnion([
                {
                  "status": "entregado",
                  "source": "pwa_cliente",
                  "time": FieldValue.serverTimestamp()
                }
              ])
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text("Confirmar recepción"),
        );

      case "entregado":
        return const Text(
          "Servicio finalizado. ¡Gracias por usar ValetFlowQR! 🚗✨",
          style: TextStyle(fontSize: 18, color: Colors.green),
        );

      default:
        return const SizedBox();
    }
  }
}
