import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class CorreoService {
  final String usuario;
  final String password;

  CorreoService({required this.usuario, required this.password});

  Future<void> enviarCorreo({
    required List<String> destinatarios,
    required String asunto,
    required String mensaje,
  }) async {
    final smtpServer = gmail(usuario, password);

    for (var email in destinatarios) {
      final message = Message()
        ..from = Address(usuario, 'Tu Negocio')
        ..recipients.add(email)
        ..subject = asunto
        ..text = mensaje;

      try {
        final sendReport = await send(message, smtpServer);
        print('Correo enviado a $email: $sendReport');
      } on MailerException catch (e) {
        print('Error al enviar a $email: $e');
      }
    }
  }
}
