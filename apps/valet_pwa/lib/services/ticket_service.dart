import 'package:cloud_firestore/cloud_firestore.dart';

class TicketService {
  final _ref = FirebaseFirestore.instance.collection("qr_codes");

  /// ---------------------------------------------------------
  /// 🔹 Crear ticket con estructura completa (MODELO OFICIAL)
  /// ---------------------------------------------------------
  static Future<void> createTicket(String ticketId) async {
    final ref = FirebaseFirestore.instance.collection("qr_codes").doc(ticketId);

    final now = FieldValue.serverTimestamp();
    final url =
        "https://pwa-oorh.vercel.app/#/register?ticket=$ticketId";

    final ticket = {
      "ticketId": ticketId,
      "status": "pendiente",

      "qrUrl": url,
      "createdAt": now,
      "updatedAt": now,

      "clientName": null,
      "clientPhone": null,

      "photoUrl": null,
      "arrivalTime": null,
      "parkingSpot": null,
      "plate": null,
      "carModel": null,
      "carColor": null,

      "deliveredAt": null,
      "deliveryPhotoUrl": null,
      "notes": null,

      "statusHistory": [
        {"status": "pendiente", "time": now, "source": "system"}
      ],
    };

    await ref.set(ticket);
  }

  /// ---------------------------------------------------------
  /// 🔹 Obtener ticket por ID
  /// ---------------------------------------------------------
  Future<Map<String, dynamic>?> getTicket(String ticketId) async {
    final doc = await _ref.doc(ticketId).get();
    if (!doc.exists) return null;
    return doc.data() as Map<String, dynamic>;
  }

  /// ---------------------------------------------------------
  /// 🔹 Actualizar ticket (merge seguro)
  ///   - siempre agrega updatedAt
  ///   - agrega historial cuando cambia status
  /// ---------------------------------------------------------
  Future<void> updateTicket({
    required String ticketId,
    required Map<String, dynamic> updates,
    String source = "pwa_cliente",
  }) async {
    final ref = _ref.doc(ticketId);

    final Map<String, dynamic> safeUpdate = {
      ...updates,
      "updatedAt": FieldValue.serverTimestamp(),
    };

    // Si el status cambia → agregar al historial
    if (updates.containsKey("status")) {
      safeUpdate["statusHistory"] = FieldValue.arrayUnion([
        {
          "status": updates["status"],
          "time": FieldValue.serverTimestamp(),
          "source": source,
        }
      ]);
    }

    await ref.update(safeUpdate);
  }
}
