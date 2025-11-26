import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  final VoidCallback onAccepted;

  const PrivacyScreen({super.key, required this.onAccepted, required bool readOnly, required Null Function() onDeclined});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToEnd = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() => _hasScrolledToEnd = true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Aviso de Privacidad'),
        backgroundColor: Colors.teal[700],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Image.asset('assets/logo.jpg', height: 120),
            const SizedBox(height: 15),
            const Text(
              'Aviso de Privacidad',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      '''
**Responsable del Tratamiento de Datos:**  
ValetFlowQR es responsable del tratamiento de los datos personales recabados a través de la aplicación web y móvil, conforme a la Ley Federal de Protección de Datos Personales en Posesión de Particulares (LFPDPPP).

**Datos Personales Recabados:**  
Recopilamos los siguientes datos del usuario: nombre completo, número telefónico, correo electrónico, matrícula y fotografía del vehículo.  
Estos datos se utilizan exclusivamente para brindar el servicio de control, registro y seguimiento de los vehículos en el sistema de valet parking.

**Finalidad del Tratamiento:**  
La información proporcionada se utilizará para:  
- Identificar al cliente y su vehículo.  
- Generar y enviar comprobantes de servicio.  
- Notificar al usuario sobre el estado de su vehículo o cualquier incidencia durante el servicio.  
- Mantener registro del servicio por un periodo máximo de 72 horas después de la salida del vehículo.

**Conservación y Eliminación de Datos:**  
Los datos de matrícula y fotografía del vehículo serán eliminados automáticamente 72 horas después de la salida del vehículo del establecimiento.  
Los datos de contacto (correo y teléfono) serán conservados únicamente para fines de envío de comprobantes o avisos relacionados con el servicio solicitado.

**Derechos ARCO (Acceso, Rectificación, Cancelación y Oposición):**  
El usuario puede ejercer sus derechos en cualquier momento enviando una solicitud a través de los canales oficiales del servicio.

**Transferencia de Datos:**  
Los datos personales no serán transferidos a terceros sin el consentimiento expreso del usuario, salvo obligación legal.

**Seguridad de la Información:**  
Se implementan medidas técnicas, administrativas y físicas para proteger los datos personales contra daño, pérdida, alteración, destrucción o uso no autorizado.

**Consentimiento:**  
Al aceptar este aviso, el usuario autoriza el tratamiento de sus datos personales conforme a las finalidades descritas.
                      ''',
                      style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _hasScrolledToEnd ? widget.onAccepted : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _hasScrolledToEnd ? 'Aceptar y continuar' : 'Desplázate hasta el final para continuar',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
