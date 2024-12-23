import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RevisarFichasPage(),
    );
  }
}

class RevisarFichasPage extends StatelessWidget {
  const RevisarFichasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fichas Médicas'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('fichas').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No hay fichas disponibles.'));
            }

            final fichas = snapshot.data!.docs;

            return ListView.builder(
              itemCount: fichas.length,
              itemBuilder: (context, index) {
                var ficha = fichas[index];
                var fecha = (ficha['Fecha'] as Timestamp).toDate();
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      ficha['Nombre'] ?? 'Sin nombre',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RUT: ${ficha['Rut'] ?? 'Sin RUT'}'),
                        Text('Profesional: ${ficha['Profesional'] ?? 'Sin profesional'}'),
                        Text('Diagnóstico: ${ficha['Diagnostico'] ?? 'Sin diagnóstico'}'),
                        Text('Fecha: ${fecha.day}/${fecha.month}/${fecha.year}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
