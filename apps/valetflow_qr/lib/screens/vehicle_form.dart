import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleValidationScreen extends StatefulWidget {
  final String ticketId; // viene del QR escaneado

  const VehicleValidationScreen({super.key, required this.ticketId});

  @override
  State<VehicleValidationScreen> createState() => _VehicleValidationScreenState();
}

class _VehicleValidationScreenState extends State<VehicleValidationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _acceptedPrivacy = false;
  Map<String, dynamic>? _vehicleData;

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
  }

  /// Cargar los datos detectados por IA desde Firestore (placa, modelo, color, foto)
  Future<void> _loadVehicleData() async {
    final doc = await FirebaseFirestore.instance
        .collection('tickets')
        .doc(widget.ticketId)
        .get();

    setState(() {
      _vehicleData = doc.data();
    });
  }

  /// Enviar los datos validados del cliente
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar la Política de Privacidad')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('tickets')
        .doc(widget.ticketId)
        .update({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'validated': true,
      'validationDate': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos enviados correctamente ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_vehicleData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validar información del vehículo'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_vehicleData!['photoUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _vehicleData!['photoUrl'],
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Placa detectada: ${_vehicleData!['plate'] ?? 'No disponible'}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text('Modelo: ${_vehicleData!['model'] ?? 'N/A'}'),
              Text('Color: ${_vehicleData!['color'] ?? 'N/A'}'),
              const Divider(height: 32),

              /// Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obligatorio';
                  }
                  if (value.trim().length < 3) {
                    return 'Debe contener al menos 3 caracteres';
                  }
                  return null;
                },
              ),

              /// Correo electrónico
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obligatorio';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Correo no válido';
                  }
                  return null;
                },
              ),

              /// Teléfono
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obligatorio';
                  }
                  if (value.length < 10) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              /// Checkbox de Política de Privacidad
              CheckboxListTile(
                value: _acceptedPrivacy,
                onChanged: (val) => setState(() => _acceptedPrivacy = val ?? false),
                title: GestureDetector(
                  onTap: () {
                    // Aquí puedes navegar o abrir modal de Política de Privacidad
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Política de Privacidad'),
                        content: const Text(
                          'Al aceptar, autorizas el uso de tus datos únicamente '
                          'para la gestión y resguardo de tu vehículo. '
                          'Los datos se eliminarán automáticamente en 72 horas '
                          'después de usar el servicio.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          )
                        ],
                      ),
                    );
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: 'He leído y acepto la ',
                      children: [
                        TextSpan(
                          text: 'Política de Privacidad',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 20),

              /// Botón de enviar
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmar datos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
