import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text("🏠 Página de Inicio", style: TextStyle(fontSize: 20))),
    Center(child: Text("👤 Perfil", style: TextStyle(fontSize: 20))),
    Center(
      child: Column(
        children: [
          Text("⚙️ Ajustes", style: TextStyle(fontSize: 20)),
          ElevatedButton(
            child: Text("cerrar sesion"),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    ),
    Center(child: Text("⭐ Favoritos", style: TextStyle(fontSize: 20))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi App Básica"),
        backgroundColor: Colors.blue,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // evita efecto shifting
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Ajustes"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favoritos"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
