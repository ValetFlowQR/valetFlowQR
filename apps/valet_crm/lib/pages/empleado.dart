import 'package:flutter/material.dart';
import '../models/empleado.dart';
import '../services/empleado_service.dart';

class EmpleadosPage extends StatefulWidget {
  const EmpleadosPage({Key? key}) : super(key: key);

  @override
  State<EmpleadosPage> createState() => _EmpleadosPageState();
}

class _EmpleadosPageState extends State<EmpleadosPage> {
  final _formKey = GlobalKey<FormState>();
  final EmpleadoService _empleadoService = EmpleadoService();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _rolSeleccionado;

  final Color _baseColor = const Color(0xFF045E66);

  // 🔹 Lista de roles disponibles
  final List<String> _roles = [
    'Valet',
    'Supervisor',
    'Administrador',
    'Cajero',
    'Seguridad',
    'Mantenimiento',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: const Text("Gestión de Empleados"),
        backgroundColor: _baseColor,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_add_rounded,
                                  color: _baseColor, size: 28),
                              const SizedBox(width: 10),
                              Text(
                                "Registrar nuevo empleado",
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
                              "Nombre", _nombreController, Icons.person),
                          const SizedBox(height: 10),
                          _buildTextField("Correo electrónico",
                              _emailController, Icons.email),
                          const SizedBox(height: 10),

                          /// 🔹 Lista desplegable para rol
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "Rol del empleado",
                              prefixIcon: Icon(Icons.badge, color: _baseColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _baseColor, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            value: _rolSeleccionado,
                            items: _roles.map((rol) {
                              return DropdownMenuItem(
                                value: rol,
                                child: Text(rol),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _rolSeleccionado = value;
                              });
                            },
                            validator: (value) => value == null
                                ? 'Selecciona un rol'
                                : null,
                          ),

                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text("Registrar empleado",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _baseColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _guardarEmpleado,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildListaEmpleados()),
          ],
        ),
      ),
    );
  }

  /// 🔹 Campo de texto reutilizable
  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return TextFormField(
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
      validator: (value) =>
          value == null || value.isEmpty ? 'Campo obligatorio' : null,
    );
  }

  /// 🔹 Guardar empleado
  Future<void> _guardarEmpleado() async {
    if (_formKey.currentState!.validate()) {
      final nuevoEmpleado = Empleado(
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        rol: _rolSeleccionado!,
      );

      await _empleadoService.addEmpleado(nuevoEmpleado);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empleado agregado correctamente')),
      );

      _nombreController.clear();
      _emailController.clear();
      setState(() {
        _rolSeleccionado = null;
      });
    }
  }

  /// 🔹 Lista de empleados
  Widget _buildListaEmpleados() {
    return StreamBuilder<List<Empleado>>(
      stream: _empleadoService.getEmpleados(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No hay empleados registrados."));
        }

        final empleados = snapshot.data!;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(_baseColor),
              headingTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              dataRowColor:
                  MaterialStateProperty.all(const Color(0xFFE8F3F4)),
              dividerThickness: 1,
              columns: const [
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Correo')),
                DataColumn(label: Text('Rol')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: empleados.map((emp) {
                return DataRow(cells: [
                  DataCell(Text(emp.nombre)),
                  DataCell(Text(emp.email)),
                  DataCell(Text(emp.rol)),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _empleadoService.deleteEmpleado(emp.id),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
