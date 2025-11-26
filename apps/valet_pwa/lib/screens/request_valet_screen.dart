import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestValetScreen extends StatefulWidget {
  const RequestValetScreen({super.key});

  @override
  State<RequestValetScreen> createState() => _RequestValetScreenState();
}

class _RequestValetScreenState extends State<RequestValetScreen> {
  late String ticketId;

  @override
  void initState() {
    super.initState();

    ticketId = Uri.base.queryParameters['ticket'] ?? "";

    if (ticketId.isEmpty) {
      debugPrint("⚠ TicketId no encontrado en la URL");
    }
  }

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
    if (ticketId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Error: Ticket no encontrado ❌")),
      );
    }

    final docRef =
        FirebaseFirestore.instance.collection("qr_codes").doc(ticketId);

    return Scaffold(
      appBar: AppBar(title: const Text("Solicitar mi auto")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Ticket inexistente ❌"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data["status"] ?? "desconocido";

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text("Estado actual del servicio:",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(
                  status,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // BOTÓN: solicitar el auto
                if (status == "iniciado" || status == "estacionado")
                  ElevatedButton(
                    onPressed: () async {
                      await updateStatus("solicitado_cliente");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Solicitud enviada al valet 🚗")),
                      );
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Text("Solicitar mi auto"),
                    ),
                  ),

                if (status == "solicitado_cliente")
                  const Text(
                    "El valet está trayendo tu auto...",
                    style: TextStyle(fontSize: 18, color: Colors.orange),
                  ),

                const SizedBox(height: 30),

                // BOTÓN: confirmar que recibió el auto
                if (status == "listo_para_confirmar")
                  ElevatedButton(
                    onPressed: () async {
                      await updateStatus("entregado");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("¡Gracias! Servicio finalizado.")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Text("Ya recibí mi auto"),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
