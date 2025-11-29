import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/cliente_service.dart';

class Clientes extends StatefulWidget {
  const Clientes({super.key});

  @override
  State<Clientes> createState() => _ClientesState();
}

class _ClientesState extends State<Clientes> {
  final ClienteService _service = ClienteService();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  String? _editingId;
  final Color _baseColor = const Color(0xFF045E66);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: const Text("Clientes"),
        backgroundColor: _baseColor,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 Tarjeta de formulario elegante 
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.7,
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_add_rounded,
                                color: _baseColor, size: 28),
                            const SizedBox(width: 10),
                            Text(
                              _editingId == null
                                  ? "Registrar nuevo cliente"
                                  : "Editar cliente",
                              style: TextStyle(
                                color: _baseColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(thickness: 1, height: 24),
                        _buildTextField(
                            "Nombre del cliente", _nombreController, Icons.person),
                        const SizedBox(height: 10),
                        _buildTextField(
                            "Teléfono", _telefonoController, Icons.phone),
                        const SizedBox(height: 10),
                        _buildTextField(
                            "Correo electrónico", _correoController, Icons.email),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _baseColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: _guardarCliente,
                                icon: Icon(
                                    _editingId == null
                                        ? Icons.add
                                        : Icons.save_rounded,
                                    color: Colors.white),
                                label: Text(
                                  _editingId == null
                                      ? "Agregar Cliente"
                                      : "Guardar Cambios",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                            if (_editingId != null)
                              IconButton(
                                icon:
                                    const Icon(Icons.cancel, color: Colors.red),
                                onPressed: _cancelarEdicion,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Tabla de clientes
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return StreamBuilder<List<Cliente>>(
                    stream: _service.getClientes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text("No hay clientes registrados"));
                      }

                      final clientes = snapshot.data!;

                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(minWidth: constraints.maxWidth),
                              child: DataTable(
                                headingRowColor:
                                    MaterialStateProperty.all(_baseColor),
                                headingTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                dataRowColor: MaterialStateProperty.all(
                                    const Color(0xFFE8F3F4)),
                                dividerThickness: 1,
                                columns: const [
                                  DataColumn(label: Text('Nombre')),
                                  DataColumn(label: Text('Teléfono')),
                                  DataColumn(label: Text('Correo')),
                                  DataColumn(label: Text('Fecha Registro')),
                                  DataColumn(label: Text('Acciones')),
                                ],
                                rows: clientes.map((cliente) {
                                  return DataRow(cells: [
                                    DataCell(Text(cliente.nombre)),
                                    DataCell(Text(cliente.telefono)),
                                    DataCell(Text(cliente.correo)),
                                    DataCell(Text(
                                        cliente.fechaRegistro.split('T')[0])),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () {
                                            _editarCliente(cliente);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () async {
                                            try {
                                              await _service
                                                  .deleteCliente(cliente.id);
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Error al eliminar: $e")));
                                            }
                                          },
                                        ),
                                      ],
                                    )),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Campo con ícono
  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _baseColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _baseColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _guardarCliente() async {
    if (_nombreController.text.isEmpty ||
        _telefonoController.text.isEmpty ||
        _correoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    final cliente = Cliente(
      id: _editingId ?? '',
      nombre: _nombreController.text,
      telefono: _telefonoController.text,
      correo: _correoController.text,
      fechaRegistro: DateTime.now().toIso8601String(),
    );

    try {
      if (_editingId == null) {
        await _service.addCliente(cliente);
      } else {
        await _service.updateCliente(cliente);
        _editingId = null;
      }

      _nombreController.clear();
      _telefonoController.clear();
      _correoController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() {});
  }

  void _cancelarEdicion() {
    _editingId = null;
    _nombreController.clear();
    _telefonoController.clear();
    _correoController.clear();
    setState(() {});
  }

  void _editarCliente(Cliente cliente) {
    _editingId = cliente.id;
    _nombreController.text = cliente.nombre;
    _telefonoController.text = cliente.telefono;
    _correoController.text = cliente.correo;
    setState(() {});
  }
}
