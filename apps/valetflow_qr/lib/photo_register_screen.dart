import 'package:flutter/material.dart';

class PhotoRegisterScreen extends StatelessWidget {
  const PhotoRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Vehículo")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              "Automóvil",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Imagen del automóvil
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26),
              ),
              child: const Center(
                child: Icon(Icons.directions_car,
                    size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Botón para tomar fotos
            Column(
              children: const [
                Icon(Icons.camera_alt, size: 40),
                SizedBox(height: 8),
                Text("Tomar Fotografías"),
              ],
            ),

            const SizedBox(height: 30),

            // Campo de placa
            const Text(
              "Placa",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              enabled: false, // no editable aún
              decoration: InputDecoration(
                hintText: "ABC-123",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Campo de propietario
            const Text(
              "Nombre del Propietario",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: "Juanito Pérez",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Campo de lugar designado
            const Text(
              "Lugar Designado",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: "Z - 12",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Botón de continuar
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Registro completado correctamente ✅")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(80, 50),
                ),
                child: const Icon(Icons.arrow_forward, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
