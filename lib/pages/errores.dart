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
      home: ErroresPage(),
    );
  }
}

class ErroresPage extends StatefulWidget {
  const ErroresPage({super.key});

  @override
  State<ErroresPage> createState() => _ErroresPageState();
}

class _ErroresPageState extends State<ErroresPage> {
  int _selectedIndex = 0;

  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _errorController = TextEditingController();

  Future<void> _guardarError() async {
    if (_descripcionController.text.isEmpty || _errorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('errores').add({
      'Descripcion': _descripcionController.text,
      'Error': _errorController.text,
      'Fecha': Timestamp.now(),
    });

    _descripcionController.clear();
    _errorController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error guardado correctamente')),
    );
  }

  Future<void> _eliminarError(String id) async {
    await FirebaseFirestore.instance.collection('errores').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error eliminado')),
    );
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmallScreen = width < 600;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            if (!isSmallScreen)
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                extended: width > 800,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.view_list),
                    selectedIcon: Icon(Icons.view_list_rounded),
                    label: Text('Ver Errores'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.add),
                    selectedIcon: Icon(Icons.add_rounded),
                    label: Text('Crear Error'),
                  ),
                ],
              ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Center(
                child: _selectedIndex == 0
                    ? StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('errores').snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('No hay errores disponibles.'));
                          }

                          final errores = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: errores.length,
                            itemBuilder: (context, index) {
                              var error = errores[index];
                              var fecha = (error['Fecha'] as Timestamp).toDate();
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  title: Text(
                                    error['Descripcion'] ?? 'Sin descripción',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Error: ${error['Error'] ?? 'Sin error'}'),
                                      Text('Fecha: ${fecha.day}/${fecha.month}/${fecha.year}'),
                                    ],
                                  ),
                                  isThreeLine: true,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      _eliminarError(error.id);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Crear Nuevo Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: TextFormField(
                              controller: _descripcionController,
                              decoration: const InputDecoration(labelText: 'Descripción'),
                              maxLines: 3,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: TextFormField(
                              controller: _errorController,
                              decoration: const InputDecoration(labelText: 'Error'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _guardarError,
                            child: const Text('Guardar Error'),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isSmallScreen
          ? BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.view_list),
                  label: 'Ver Errores',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'Crear Error',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              })
          : null,
    );
  }
}
