import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../models/cliente.dart';
import '../services/vehiculo_service.dart';
import '../services/cliente_service.dart';
import '../services/marcas_service.dart';
import '../services/estados_service.dart';

class Vehiculos extends StatefulWidget {
  const Vehiculos({super.key});

  @override
  State<Vehiculos> createState() => _VehiculosState();
}

class _VehiculosState extends State<Vehiculos> {
  final VehiculoService _vehiculoService = VehiculoService();
  final ClienteService _clienteService = ClienteService();

  final MarcasService _marcasService = MarcasService();
  final EstadosService _estadosService = EstadosService();

  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _placasController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();

  String? _editingId;
  Cliente? _clienteSeleccionado;

  final Color _baseColor = const Color(0xFF045E66);

  List<Cliente> _clientes = [];
  late Stream<List<Vehiculo>> _streamVehiculos;

  @override
  void initState() {
    super.initState();

    /// Cargar clientes
    _clienteService.getClientes().listen((clientes) {
      if (mounted) {
        setState(() => _clientes = clientes);
      }
    });

    /// Stream de vehículos
    _streamVehiculos = _vehiculoService.getVehiculos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Vehículos"),
        backgroundColor: _baseColor,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFormulario(),
            const SizedBox(height: 20),
            _buildTablaVehiculos(),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // FORMULARIO
  // ===========================================================
  Widget _buildFormulario() {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.75,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_car_rounded,
                        color: _baseColor, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      _editingId == null
                          ? "Registrar nuevo vehículo"
                          : "Editar vehículo",
                      style: TextStyle(
                        color: _baseColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const Divider(),
                const SizedBox(height: 10),

                /// Dropdown Cliente
                DropdownButtonFormField<Cliente>(
                  value: _clienteSeleccionado,
                  decoration: const InputDecoration(
                    labelText: "Cliente asociado",
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  items: _clientes.map((cliente) {
                    return DropdownMenuItem(
                      value: cliente,
                      child: Text(cliente.nombre),
                    );
                  }).toList(),
                  onChanged: (cliente) {
                    setState(() => _clienteSeleccionado = cliente);
                  },
                ),
                const SizedBox(height: 12),

                // CAMPO MARCA CON BUSCADOR
                _buildTextFieldConBusqueda(
                  label: "Marca del vehículo",
                  controller: _marcaController,
                  icon: Icons.directions_car,
                  onSearch: () async {
                    final marcas = await _marcasService.obtenerMarcas();
                    _mostrarDialogoBusqueda(
                      titulo: "Buscar marca",
                      opciones: marcas,
                      onSelect: (valor) => _marcaController.text = valor,
                    );
                  },
                ),
                const SizedBox(height: 10),

                _buildTextField(
                    "Modelo", _modeloController, Icons.style_rounded),
                const SizedBox(height: 10),

                _buildTextField("Placas", _placasController,
                    Icons.confirmation_num),
                const SizedBox(height: 10),

                _buildTextField(
                    "Color", _colorController, Icons.color_lens_rounded),
                const SizedBox(height: 10),

                // CAMPO ESTADO CON BUSCADOR
                _buildTextFieldConBusqueda(
                  label: "Estado",
                  controller: _estadoController,
                  icon: Icons.map_rounded,
                  onSearch: () async {
                    final estados = await _estadosService.obtenerEstados();
                    _mostrarDialogoBusqueda(
                      titulo: "Buscar estado",
                      opciones: estados,
                      onSelect: (valor) => _estadoController.text = valor,
                    );
                  },
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _baseColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _guardarVehiculo,
                        icon: Icon(
                          _editingId == null
                              ? Icons.add
                              : Icons.save_rounded,
                          color: Colors.white,
                        ),
                        label: Text(
                          _editingId == null
                              ? "Agregar Vehículo"
                              : "Guardar Cambios",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    if (_editingId != null)
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: _cancelarEdicion,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // TABLA
  // ===========================================================
  Widget _buildTablaVehiculos() {
    return StreamBuilder<List<Vehiculo>>(
      stream: _streamVehiculos,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final vehiculos = snapshot.data!;

        if (vehiculos.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("No hay vehículos registrados"),
            ),
          );
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: _baseColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            height: 320,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      MaterialStatePropertyAll(_baseColor),
                  headingTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  dataRowColor: MaterialStatePropertyAll(
                      const Color(0xFFE0F0F2)),
                  columns: const [
                    DataColumn(label: Text('Cliente')),
                    DataColumn(label: Text('Marca')),
                    DataColumn(label: Text('Modelo')),
                    DataColumn(label: Text('Placas')),
                    DataColumn(label: Text('Color')),
                    DataColumn(label: Text('Estado')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  rows: vehiculos.map((vehiculo) {
                    final cliente = _clientes.firstWhere(
                      (c) => c.id == vehiculo.clienteId,
                      orElse: () => Cliente(
                          id: '',
                          nombre: 'Desconocido',
                          telefono: '',
                          correo: '',
                          fechaRegistro: ''),
                    );

                    return DataRow(cells: [
                      DataCell(Text(cliente.nombre)),
                      DataCell(Text(vehiculo.marca)),
                      DataCell(Text(vehiculo.modelo)),
                      DataCell(Text(vehiculo.placas)),
                      DataCell(Text(vehiculo.color)),
                      DataCell(Text(vehiculo.estado)),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _editarVehiculo(vehiculo, cliente),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _vehiculoService
                                  .deleteVehiculo(vehiculo.id);
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
  }

  // ===========================================================
  // CAMPOS DE TEXTO
  // ===========================================================
  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _baseColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildTextFieldConBusqueda({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Function() onSearch,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: _baseColor),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.search, color: _baseColor, size: 28),
          onPressed: onSearch,
        )
      ],
    );
  }

  // ===========================================================
  // BUSCADOR POPUP
  // ===========================================================
  void _mostrarDialogoBusqueda({
    required String titulo,
    required List<String> opciones,
    required Function(String) onSelect,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        List<String> filtradas = opciones;
        final TextEditingController buscador = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(titulo),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: buscador,
                    decoration: const InputDecoration(
                      labelText: "Buscar...",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filtradas = opciones
                            .where((o) =>
                                o.toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    width: 300,
                    child: ListView.builder(
                      itemCount: filtradas.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filtradas[index]),
                          onTap: () {
                            onSelect(filtradas[index]);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================
  // CRUD
  // ===========================================================
  void _guardarVehiculo() async {
    if (_clienteSeleccionado == null ||
        _marcaController.text.isEmpty ||
        _placasController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Debe seleccionar un cliente y llenar Marca y Placas")));
      return;
    }

    final vehiculo = Vehiculo(
      id: _editingId ?? '',
      clienteId: _clienteSeleccionado!.id,
      marca: _marcaController.text,
      modelo: _modeloController.text,
      placas: _placasController.text,
      color: _colorController.text,
      estado: _estadoController.text,
    );

    try {
      if (_editingId == null) {
        await _vehiculoService.addVehiculo(vehiculo);
      } else {
        await _vehiculoService.updateVehiculo(vehiculo);
        _editingId = null;
      }

      _limpiarCampos();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _cancelarEdicion() {
    _editingId = null;
    _limpiarCampos();
    setState(() {});
  }

  void _editarVehiculo(Vehiculo vehiculo, Cliente cliente) {
    _editingId = vehiculo.id;
    _clienteSeleccionado = cliente;
    _marcaController.text = vehiculo.marca;
    _modeloController.text = vehiculo.modelo;
    _placasController.text = vehiculo.placas;
    _colorController.text = vehiculo.color;
    _estadoController.text = vehiculo.estado;
    setState(() {});
  }

  void _limpiarCampos() {
    _clienteSeleccionado = null;
    _marcaController.clear();
    _modeloController.clear();
    _placasController.clear();
    _colorController.clear();
    _estadoController.clear();
  }
}
