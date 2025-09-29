import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared/shared.dart'; // aquí ya exportas firebase_service y modelos

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valet Flow QR',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CarsScreen(),
    );
  }
}

class CarsScreen extends StatelessWidget {
  const CarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Coches registrados")),
      body: StreamBuilder(
        stream: FirebaseService.listenCars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final cars = snapshot.data ?? [];
          if (cars.isEmpty) {
            return const Center(child: Text("No hay coches registrados"));
          }
          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return ListTile(
                title: Text(car.plateNumber),
                subtitle: Text(car.model ?? "Modelo desconocido"),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 🔹 Inserta un coche de prueba en Firestore
          await FirebaseService.addCar(
            Car(plateNumber: "ABC-123", model: "Honda Civic", color: "Rojo"),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
