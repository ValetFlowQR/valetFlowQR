import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/cliente_service.dart';
import '../services/correo_service.dart';

class Correo extends StatefulWidget {
  const Correo({super.key});

  @override
  State<Correo> createState() => _CorreoState();
}

class _CorreoState extends State<Correo> {
  final ClienteService _clienteService = ClienteService();

  List<Cliente> _clientes = [];
  List<Cliente> _clientesSeleccionados = [];

  final TextEditingController _asuntoController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();

  final Color _primaryColor = const Color(0xFF045E66);

  // Mensajes predeterminados
  final List<String> _mensajesPredeterminados = [
    "¡Hola! Gracias por tu preferencia.",
    "Recordatorio: tu cita está próxima.",
    "Promoción especial para ti: 20% de descuento.",
  ];

  // Servicio de correo
  late CorreoService _correoService;

  @override
  void initState() {
    super.initState();
    _cargarClientes();

    // Configura tu correo real de Gmail con App Password
    _correoService = CorreoService(
      usuario: 'TU_CORREO@gmail.com',
      password: 'TU_APP_PASSWORD',
    );
  }

  void _cargarClientes() {
    _clienteService.getClientes().listen((data) {
      setState(() {
        _clientes = data;
      });
    });
  }

  void _toggleClienteSeleccionado(Cliente cliente) {
    setState(() {
      if (_clientesSeleccionados.contains(cliente)) {
        _clientesSeleccionados.remove(cliente);
      } else {
        _clientesSeleccionados.add(cliente);
      }
    });
  }

  Future<void> _enviarCorreo() async {
    if (_clientesSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona al menos un cliente")),
      );
      return;
    }

    if (_asuntoController.text.isEmpty || _mensajeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El asunto y mensaje son obligatorios")),
      );
      return;
    }

    final destinatarios =
        _clientesSeleccionados.map((c) => c.correo).toList();

    await _correoService.enviarCorreo(
      destinatarios: destinatarios,
      asunto: _asuntoController.text,
      mensaje: _mensajeController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Correo enviado a ${_clientesSeleccionados.length} cliente(s)")),
    );

    setState(() {
      _clientesSeleccionados.clear();
      _asuntoController.clear();
      _mensajeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text("Correo"),
        centerTitle: true,
        backgroundColor: _primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Clientes en tarjetas
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _clientes.map((cliente) {
                final selected = _clientesSeleccionados.contains(cliente);
                return GestureDetector(
                  onTap: () => _toggleClienteSeleccionado(cliente),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 48) / 2,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? _primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? _primaryColor : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cliente.nombre,
                            style: TextStyle(
                                color: selected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(cliente.correo,
                            style: TextStyle(
                                color: selected ? Colors.white70 : Colors.grey)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Asunto
            TextField(
              controller: _asuntoController,
              decoration: InputDecoration(
                labelText: "Asunto",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.subject),
              ),
            ),
            const SizedBox(height: 12),

            // Mensaje predeterminado
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Selecciona mensaje predeterminado",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.message),
              ),
              items: _mensajesPredeterminados
                  .map((msg) => DropdownMenuItem(value: msg, child: Text(msg)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _mensajeController.text = value;
                }
              },
            ),
            const SizedBox(height: 12),

            // Mensaje personalizado
            TextField(
              controller: _mensajeController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: "Mensaje",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 16),

            // Botón enviar
            ElevatedButton.icon(
              onPressed: _enviarCorreo,
              icon: const Icon(Icons.send),
              label: const Text("Enviar Correo"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
