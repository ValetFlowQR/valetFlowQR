// tickets_con_services_embebidos.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

// 💡 IMPORTACIONES DE MODELOS
// Asegúrate de que estas rutas relativas coincidan con la ubicación real de tus archivos.
// (e.g., si el archivo principal está en 'lib/screens/' y los modelos en 'lib/models/').
import '../models/cliente.dart'; 
import '../models/vehiculo.dart'; 

// -------------------------------------------------------------
// DEFINICIÓN DE MODELO TICKET (Se mantiene aquí por ser específico de la UI/Lógica de negocio)
// -------------------------------------------------------------

class Ticket {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String vehiculoId;
  final String vehiculoMarca;
  final String vehiculoPlacas;
  final String fecha;
  final String horaEntrada;
  final String horaSalida;
  final double monto;
  final String tipo;

  Ticket({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.vehiculoId,
    required this.vehiculoMarca,
    required this.vehiculoPlacas,
    required this.fecha,
    required this.horaEntrada,
    required this.horaSalida,
    required this.monto,
    required this.tipo,
  });

  // Constructor que utiliza los datos de los modelos Cliente y Vehiculo
  Ticket.fromSelection({
    required Cliente cliente,
    required Vehiculo vehiculo,
    required DateTime horaEntrada,
    required DateTime horaSalida,
    required double monto,
    required String tipoServicio,
  })  : id = "",
        clienteId = cliente.id,
        clienteNombre = cliente.nombre,
        vehiculoId = vehiculo.id,
        vehiculoMarca = vehiculo.marca,
        vehiculoPlacas = vehiculo.placas,
        fecha = DateTime.now().toIso8601String(),
        horaEntrada = "${horaEntrada.hour}:${horaEntrada.minute.toString().padLeft(2, '0')}",
        horaSalida = "${horaSalida.hour}:${horaSalida.minute.toString().padLeft(2, '0')}",
        monto = monto,
        tipo = tipoServicio;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'vehiculoId': vehiculoId,
      'vehiculoMarca': vehiculoMarca,
      'vehiculoPlacas': vehiculoPlacas,
      'fecha': fecha,
      'horaEntrada': horaEntrada,
      'horaSalida': horaSalida,
      'monto': monto,
      'tipo': tipo,
    };
  }
}

// -------------------------------------------------------------
// PÁGINA DE TICKETS (WIDGET PRINCIPAL)
// -------------------------------------------------------------

class Tickets extends StatefulWidget {
  const Tickets({super.key});

  @override
  State<Tickets> createState() => _TicketsState();
}

class _TicketsState extends State<Tickets> {
  // ---------------------- CONFIG ----------------------
  static const String WEBHOOK_URL =
      "https://dianafabian.app.n8n.cloud/webhook/ticket";

  final ClienteService _clienteService = ClienteService();
  final VehiculoService _vehiculoService = VehiculoService();
  final N8NService _n8n = N8NService(WEBHOOK_URL);

  final Color _baseColor = const Color(0xFF045E66);

  List<Cliente> _clientes = [];
  List<Vehiculo> _vehiculos = [];
  Cliente? _clienteSeleccionado;
  Vehiculo? _vehiculoSeleccionado;

  DateTime? _horaEntrada;
  DateTime? _horaSalida;
  double _montoCalculado = 0.0;
  String _tipoServicio = "Estacionamiento";

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  void _cargarClientes() {
    _clienteService.getClientes().listen((data) {
      setState(() => _clientes = data);
    });
  }
  
  double _calcularMonto() {
    if (_horaEntrada == null || _horaSalida == null) return 0.0;
    final duracion = _horaSalida!.difference(_horaEntrada!).inMinutes / 60;
    return duracion.ceil() * 20.0;
  }

  void _registrarEntrada() => setState(() => _horaEntrada = DateTime.now());

  void _registrarSalida() {
    if (_horaEntrada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Primero registra la hora de entrada")),
      );
      return;
    }

    setState(() {
      _horaSalida = DateTime.now();
      _montoCalculado = _calcularMonto();
    });
  }
  
  void _limpiarFormulario() {
    setState(() {
      _clienteSeleccionado = null;
      _vehiculoSeleccionado = null;
      _vehiculos = [];
      _horaEntrada = null;
      _horaSalida = null;
      _montoCalculado = 0.0;
    });
  }

  // -------------------------------------------------
  // GENERAR PDF (sin cambios)
  // -------------------------------------------------

  Future<String> _generarPDFBase64() async {
    final pdf = pw.Document();

    Uint8List? logo;
    try {
      logo = (await rootBundle.load('assets/logo_verde.png'))
          .buffer
          .asUint8List();
    } catch (_) {
      logo = null;
    }

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logo != null) _headerPDF(logo),
              pw.SizedBox(height: 20),
              _datosClientePDF(),
              pw.SizedBox(height: 20),
              _tablaPDF(),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "TOTAL: \$${_montoCalculado.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                    color: PdfColor.fromInt(_baseColor.value),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    Uint8List pdfBytes = await pdf.save();
    return base64Encode(pdfBytes);
  }

  pw.Widget _headerPDF(Uint8List logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(
          children: [
            pw.Image(pw.MemoryImage(logo), width: 55),
            pw.SizedBox(width: 12),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("ValetFlow",
                    style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(_baseColor.value))),
                pw.Text("Estacionamiento Inteligente",
                    style:
                        pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
              ],
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text("TICKET",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.Text(
                "Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  pw.Widget _datosClientePDF() {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("DATOS DEL CLIENTE",
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(_baseColor.value))),
          pw.SizedBox(height: 4),
          pw.Text("Nombre: ${_clienteSeleccionado?.nombre ?? '-'}"),
          pw.Text("Correo: ${_clienteSeleccionado?.correo ?? '-'}"),
          pw.Text(
              "Vehículo: ${_vehiculoSeleccionado != null ? '${_vehiculoSeleccionado!.marca} - ${_vehiculoSeleccionado!.placas}' : '-'}"),
        ],
      ),
    );
  }

  pw.Widget _tablaPDF() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        pw.TableRow(
          decoration:
              pw.BoxDecoration(color: PdfColor.fromInt(_baseColor.value)),
          children: [
            _celdaTabla("Concepto", true),
            _celdaTabla("Hora", true),
            _celdaTabla("Monto", true),
          ],
        ),
        pw.TableRow(children: [
          _celdaTabla("Entrada", false),
          _celdaTabla(
              "${_horaEntrada?.hour}:${_horaEntrada?.minute.toString().padLeft(2, '0')}",
              false),
          _celdaTabla("-", false),
        ]),
        pw.TableRow(children: [
          _celdaTabla("Salida", false),
          _celdaTabla(
              "${_horaSalida?.hour}:${_horaSalida?.minute.toString().padLeft(2, '0')}",
              false),
          _celdaTabla("-", false),
        ]),
        pw.TableRow(children: [
          _celdaTabla("Servicio $_tipoServicio", false),
          _celdaTabla("-", false),
          _celdaTabla("\$${_montoCalculado.toStringAsFixed(2)}", false),
        ]),
      ],
    );
  }

  pw.Widget _celdaTabla(String texto, bool encabezado) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontWeight:
              encabezado ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: encabezado ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  // ------------------- REGISTRAR TICKET Y ENVIAR A N8N ----------------------
  void _registrarTicket() async {
    if (_clienteSeleccionado == null ||
        _vehiculoSeleccionado == null ||
        _horaEntrada == null ||
        _horaSalida == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    // 💡 Usa los datos de los modelos seleccionados
    final cliente = _clienteSeleccionado!;
    final vehiculo = _vehiculoSeleccionado!;

    final ticket = Ticket.fromSelection(
      cliente: cliente,
      vehiculo: vehiculo,
      horaEntrada: _horaEntrada!,
      horaSalida: _horaSalida!,
      monto: _montoCalculado,
      tipoServicio: _tipoServicio,
    );

    final pdfBase64 = await _generarPDFBase64();

    // 💡 Envío de datos al Webhook, incluyendo el correo y los datos del ticket/vehículo
    final datosN8N = {
      "ejecutar": true,
      "cliente": cliente.nombre,
      "clienteCorreo": cliente.correo, // Obtenido del modelo Cliente
      "ticket": ticket.toMap(),
      "pdfBase64": pdfBase64,
    };

    final enviado = await _n8n.enviarTicket(datosN8N);

    if (!enviado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error enviando ticket a n8n")),
      );
      return;
    }

    await Printing.layoutPdf(onLayout: (_) async {
      final decoded = base64Decode(pdfBase64);
      return decoded;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ticket enviado y PDF generado")),
    );
    
    _limpiarFormulario();
  }

  // -------------------------- UI (sin cambios) -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text("Gestión de Tickets"),
        backgroundColor: _baseColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: _formulario(),
          ),
        ),
      ),
    );
  }

  Widget _formulario() {
    return Card(
      elevation: 5,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Registrar Ticket",
                style: TextStyle(
                    fontSize: 22,
                    color: _baseColor,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // CLIENTE
            DropdownButtonFormField<Cliente>(
              value: _clienteSeleccionado,
              decoration: const InputDecoration(
                  labelText: "Cliente", border: OutlineInputBorder()),
              items: _clientes
                  .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c.nombre)))
                  .toList(),
              onChanged: (c) {
                setState(() {
                  _clienteSeleccionado = c;
                  _vehiculos = [];
                  _vehiculoSeleccionado = null;
                });
                if (c != null) {
                  _vehiculoService
                      .getVehiculosByCliente(c.id)
                      .listen((v) => setState(() => _vehiculos = v));
                }
              },
            ),

            const SizedBox(height: 10),

            // VEHÍCULO
            _vehiculos.isEmpty
                ? TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                        labelText: "Vehículo",
                        hintText: "Seleccione un cliente",
                        border: OutlineInputBorder()),
                  )
                : DropdownButtonFormField<Vehiculo>(
                    value: _vehiculoSeleccionado,
                    decoration: const InputDecoration(
                        labelText: "Vehículo",
                        border: OutlineInputBorder()),
                    items: _vehiculos
                        .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text("${v.marca} - ${v.placas}")))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _vehiculoSeleccionado = v),
                  ),

            const SizedBox(height: 20),

            // BOTONES
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: _btnStyle(),
                    onPressed: _registrarEntrada,
                    child: const Text("Registrar Entrada"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: _btnStyle(),
                    onPressed: _registrarSalida,
                    child: const Text("Registrar Salida"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text("Monto: \$${_montoCalculado.toStringAsFixed(2)}",
                style: TextStyle(
                    fontSize: 18,
                    color: _baseColor,
                    fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              style: _btnStyle(),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Registrar Ticket y PDF"),
              onPressed: _registrarTicket,
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _btnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _baseColor,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    );
  }
}

// -------------------------------------------------------------
// SERVICIOS FIRESTORE 💾
// -------------------------------------------------------------

class ClienteService {
  // Asume colección 'clientes'
  final _clientesRef = FirebaseFirestore.instance.collection('clientes');

  Stream<List<Cliente>> getClientes() {
    return _clientesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Cliente.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}

class VehiculoService {
  // Asume colección 'vehiculos'
  final _vehiculosRef = FirebaseFirestore.instance.collection('vehiculos');

  Stream<List<Vehiculo>> getVehiculosByCliente(String clienteId) {
    return _vehiculosRef
        .where('clienteId', isEqualTo: clienteId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Vehiculo.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}

// -------------------------------------------------------------
// SERVICIO N8N (Conexión al Webhook) 🌐
// -------------------------------------------------------------

class N8NService {
  final String webhookUrl;
  N8NService(this.webhookUrl);

  Future<bool> enviarTicket(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(webhookUrl);
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      print("N8N → ${response.statusCode} ${response.body}");
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("ERROR DE CONEXIÓN CON N8N: $e");
      return false;
    }
  }
}