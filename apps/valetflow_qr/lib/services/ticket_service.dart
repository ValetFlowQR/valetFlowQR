import 'package:cloud_firestore/cloud_firestore.dart';

class TicketService {
  static final _db = FirebaseFirestore.instance;

  /// Crea un ticket con el modelo completo final
  static Future<void> createTicket(String ticketId) async {
    final docRef = _db.collection('qr_codes').doc(ticketId);

    return docRef.set({
      "ticketId": ticketId,
      "status": "pendiente",

      "qrUrl": "https://pwa-oorh.vercel.app/#/register?ticket=$ticketId",

      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),

      "customerName": null,
      "customerPhone": null,

      "photoUrl": null,
      "arrivalTime": null,
      "parkingSpot": null,
      "plate": null,
      "carModel": null,
      "carColor": null,

      "deliveredAt": null,
      "deliveryPhotoUrl": null,

      "notes": null,
    }, SetOptions(merge: false)); // Importante: NO mezclar modelos viejos
  }
}
