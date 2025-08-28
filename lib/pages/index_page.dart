import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../providers/user_provider.dart';

import 'role_selection_page.dart';

class IndexPage extends ConsumerStatefulWidget {
  const IndexPage({super.key});

  @override
  ConsumerState<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends ConsumerState<IndexPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    // Si el usuario existe pero no tiene grupos, redirige
    if (user != null && user.groups.isEmpty) {
      // Espera a que la UI se renderice antes de navegar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/role_selection');
      });
    }

    final List<Widget> pages = [
      Center(
        child: Text("🏠 Página de Inicio", style: TextStyle(fontSize: 20)),
      ),
      Center(child: Text("👤 Perfil", style: TextStyle(fontSize: 20))),
      Center(
        child: Column(
          children: [
            Text("⚙️ Ajustes", style: TextStyle(fontSize: 20)),
            ElevatedButton(
              child: Text("Cerrar sesión"),
              onPressed: () async {
                await fb.FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      Center(child: Text("⭐ Favoritos", style: TextStyle(fontSize: 20))),
    ];

    void onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi App Básica"),
        backgroundColor: Colors.blue,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Ajustes"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favoritos"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: onItemTapped,
      ),
    );
  }
}
