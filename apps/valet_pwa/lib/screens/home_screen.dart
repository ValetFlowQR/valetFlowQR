import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valet_pwa/screens/privacy_screen.dart';



class HomeScreen extends StatelessWidget {
  final String? ticketId;

  const HomeScreen({super.key, this.ticketId});

  @override
  Widget build(BuildContext context) {
    if (ticketId == null || ticketId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ValetFlowQR - Inicio'),
          backgroundColor: const Color(0xFF0175C2),
        ),
        body: const Center(
          child: Text("No hay Ticket ID disponible."),
        ),
      );
    }

    final docStream = FirebaseFirestore.instance
        .collection('qr_codes')
        .doc(ticketId)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ValetFlowQR - Inicio'),
        backgroundColor: const Color(0xFF0175C2),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: docStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Ticket no encontrado."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? '';
          final plate = data['plate'] ?? '';
          final model = data['carModel'] ?? '';
          final color = data['carColor'] ?? '';
          final photoUrl = data['photoUrl'];
          final history = List.from(data['statusHistory'] ?? []);

          return _buildHome(context, status, plate, model, color, photoUrl, history);
        },
      ),
    );
  }

  Widget _buildHome(BuildContext context, String status, String plate, String model,
      String color, String? photoUrl, List history) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
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

            /// FOTO DEL VEHÍCULO
            if (photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(photoUrl, height: 200, fit: BoxFit.cover),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text("Foto no disponible")),
              ),

            const SizedBox(height: 20),

            /// INFO DEL VEHÍCULO
            _buildInfoTile("Placa", plate),
            _buildInfoTile("Modelo", model),
            _buildInfoTile("Color", color),

            const SizedBox(height: 20),

            /// BOTONES SEGÚN ESTADO
            _buildActionByStatus(context, status),

            const SizedBox(height: 30),

            /// HISTORIAL
            const Text("Historial de estados:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (history.isEmpty)
              const Text("Sin historial registrado."),
            for (var entry in history)
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(entry["status"]),
                subtitle: Text(entry["time"]?.toDate().toString() ?? ""),
              ),

            const SizedBox(height: 20),

            /// MENÚ
            _buildMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionByStatus(BuildContext context, String status) {
    switch (status) {
      case "iniciado":
      case "estacionado":
        return _buildSolicitarAutoButton(context);

      case "solicitado_cliente":
        return const Center(
          child: Text(
            "Solicitud enviada. Esperando al valet...",
            style: TextStyle(fontSize: 18, color: Colors.orange),
          ),
        );

      case "en_camino":
        return const Center(
          child: Text(
            "Tu vehículo viene en camino...",
            style: TextStyle(fontSize: 18, color: Colors.orange),
          ),
        );

      case "listo_para_confirmar":
        return _buildConfirmarRecibido();

      case "entregado":
        return const Center(
          child: Text(
            "Servicio finalizado. ¡Gracias por usar ValetFlowQR! 🚗✨",
            style: TextStyle(fontSize: 18, color: Colors.green),
            textAlign: TextAlign.center,
          ),
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildSolicitarAutoButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.directions_car),
      label: const Text("Solicitar mi auto"),
      onPressed: () async {
        if (ticketId == null) return;

        await FirebaseFirestore.instance
            .collection('qr_codes')
            .doc(ticketId)
            .update({
          'status': 'solicitado_cliente',
          'requestTime': DateTime.now(),
          "statusHistory": FieldValue.arrayUnion([
            {
              "status": "solicitado_cliente",
              "time": DateTime.now(),
              "source": "pwa_cliente"
            }
          ]),
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  Widget _buildConfirmarRecibido() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.check_circle),
      label: const Text("Marcar como recibido"),
      onPressed: () async {
        if (ticketId == null) return;

        await FirebaseFirestore.instance
            .collection('qr_codes')
            .doc(ticketId)
            .update({
          'status': 'entregado',
          'deliveredTime': DateTime.now(),
          "statusHistory": FieldValue.arrayUnion([
            {
              "status": "entregado",
              "time": DateTime.now(),
              "source": "pwa_cliente"
            }
          ]),
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    if (value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        "$label: $value",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Column(
      children: [
        _menuButton(context, "Estado del servicio", Icons.info, "/service_status"),
        _menuButton(context, "Historial", Icons.history, "/history"),
        _menuButton(context, "Configuración", Icons.settings, "", onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text("Política de Privacidad"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrivacyScreen(readOnly: true, onAccepted: () {  }, onDeclined: () {  },),
                      ),
                    );
                  },
                )
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _menuButton(BuildContext context, String title, IconData icon,
      String route, {VoidCallback? onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onTap: onTap ?? () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
