import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/configuracion.dart';
import '../services/configuracion_service.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = ConfiguracionService();
  final _picker = ImagePicker();

  Configuracion? _config;
  File? _logoFile;
  bool _cargando = true;

  // Controladores de texto
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    final data = await _service.obtenerConfiguracion();
    if (data != null) {
      setState(() {
        _config = data;
        _nombreCtrl.text = data.nombreNegocio;
        _direccionCtrl.text = data.direccion;
        _telefonoCtrl.text = data.telefono;
        _emailCtrl.text = data.email;
      });
    }
    setState(() => _cargando = false);
  }

  Future<void> _seleccionarLogo() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _logoFile = File(picked.path));
    }
  }

  Future<void> _guardarConfiguracion() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      String? logoURL = _config?.logoURL;

      if (_logoFile != null) {
        logoURL = await _service.subirLogo(_logoFile!);
      }

      final nuevaConfig = Configuracion(
        id: _config?.id ?? 'config1',
        nombreNegocio: _nombreCtrl.text.trim(),
        direccion: _direccionCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        logoURL: logoURL,
      );

      await _service.guardarConfiguracion(nuevaConfig);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración guardada exitosamente')),
      );

      setState(() => _config = nuevaConfig);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar configuración: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración del Sistema"),
        backgroundColor: const Color(0xFF045E66),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _seleccionarLogo,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: const Color(0xFF045E66),
                  backgroundImage: _logoFile != null
                      ? FileImage(_logoFile!)
                      : (_config?.logoURL != null
                          ? NetworkImage(_config!.logoURL!)
                          : null) as ImageProvider?,
                  child: _logoFile == null && _config?.logoURL == null
                      ? const Icon(Icons.camera_alt, color: Colors.white, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: "Nombre del negocio"),
                validator: (v) => v!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _direccionCtrl,
                decoration: const InputDecoration(labelText: "Dirección"),
                validator: (v) => v!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _telefonoCtrl,
                decoration: const InputDecoration(labelText: "Teléfono"),
                validator: (v) => v!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Correo electrónico"),
                validator: (v) =>
                    v!.contains('@') ? null : "Correo electrónico inválido",
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _guardarConfiguracion,
                icon: const Icon(Icons.save),
                label: const Text("Guardar Cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
