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
      home: FichasPage(),
    );
  }
}

const _navBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.view_list),
    activeIcon: Icon(Icons.view_list_rounded),
    label: 'Ver Fichas',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.add),
    activeIcon: Icon(Icons.add_rounded),
    label: 'Crear Ficha',
  ),
];

class FichasPage extends StatefulWidget {
  const FichasPage({super.key});

  @override
  State<FichasPage> createState() => _FichasPageState();
}

class _FichasPageState extends State<FichasPage> {
  int _selectedIndex = 0;


  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _profesionalController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();

  Future<void> _guardarFicha() async {
    if (_nombreController.text.isEmpty ||
        _diagnosticoController.text.isEmpty ||
        _profesionalController.text.isEmpty ||
        _rutController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('fichas').add({
      'Nombre': _nombreController.text,
      'Diagnostico': _diagnosticoController.text,
      'Profesional': _profesionalController.text,
      'Rut': _rutController.text,
      'Fecha': Timestamp.now(),  
    });


    _nombreController.clear();
    _diagnosticoController.clear();
    _profesionalController.clear();
    _rutController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ficha Médica guardada correctamente')),
    );
  }

  Future<void> _eliminarFicha(String id) async {
    await FirebaseFirestore.instance.collection('fichas').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ficha Médica eliminada')),
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
                destinations: _navBarItems
                    .map((item) => NavigationRailDestination(
                        icon: item.icon,
                        selectedIcon: item.activeIcon,
                        label: Text(item.label!)))
                    .toList(),
              ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Center(
                child: _selectedIndex == 0
                    ? StreamBuilder(
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
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      _eliminarFicha(ficha.id);
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
                          const Text('Crear Nueva Ficha', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: TextFormField(
                              controller: _nombreController,
                              decoration: const InputDecoration(labelText: 'Nombre'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: TextFormField(
                              controller: _diagnosticoController,
                              decoration: const InputDecoration(labelText: 'Diagnóstico'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: TextFormField(
                              controller: _profesionalController,
                              decoration: const InputDecoration(labelText: 'Profesional'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: TextFormField(
                              controller: _rutController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'RUT'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _guardarFicha,
                            child: const Text('Guardar Ficha Médica'),
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
              items: _navBarItems,
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
