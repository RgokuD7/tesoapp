import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
//import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:tesoapp/providers/group_provider.dart';

import '../providers/user_provider.dart';

import 'movement_action.dart';
import 'tabs/home_page.dart';
import 'tabs/history_page.dart';
import 'tabs/graphs_page.dart';
import 'tabs/members_page.dart';

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
    final group = ref.watch(groupProvider);

    // Si el usuario existe pero no tiene grupos, redirige
    if (user != null && user.groups.isEmpty) {
      // Espera a que la UI se renderice antes de navegar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/role_selection');
      });
    }

    final List<Widget> pages = [
      const HomePage(),
      const HistoryPage(),
      const GraphsPage(), // Tab 2: Gráficos
      const MembersPage(), // Tab 3: Miembros
      Center(
        // Tab 4: Ajustes
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "⚙️ Ajustes",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Cerrar sesión"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await fb.FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
    ];

    void onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: "Historial",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: "Graficos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: "Miembros",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Ajustes"),
        ],
        selectedFontSize: 16,
        unselectedFontSize: 14,
        selectedIconTheme: IconThemeData(size: 30),
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        onTap: onItemTapped,
        elevation: 10,
      ),
      floatingActionButton: (_selectedIndex == 0 && group?.admin == user?.id)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: FloatingActionButton(
                    heroTag: 'fab_add',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const MovementPage(action: MovementAction.add),
                        ),
                      );
                    },
                    backgroundColor: const Color(0xFF10B981), // Verde Esmeralda
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 8,
                    child: const Icon(Icons.add_rounded, size: 36),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 64,
                  height: 64,
                  child: FloatingActionButton(
                    heroTag: 'fab_remove',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const MovementPage(action: MovementAction.remove),
                        ),
                      );
                    },
                    backgroundColor: const Color(0xFFEF4444), // Rojo
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 8,
                    child: const Icon(Icons.remove_rounded, size: 36),
                  ),
                ),
              ],
            )
          : null,
      /*       floatingActionButton: (_selectedIndex == 0 || _selectedIndex == 1)
          ? SpeedDial(
              activeIcon: Icons.close,
              backgroundColor: Color.fromRGBO(16, 185, 129, 1),
              foregroundColor: Colors.white,

              children: [
                SpeedDialChild(
                  child: Icon(Icons.add),
                  backgroundColor: Color.fromRGBO(16, 185, 129, 1),
                  label: 'Agregar',
                  onTap: () {
                    // acción +
                  },
                ),
                SpeedDialChild(
                  child: Icon(Icons.remove),
                  backgroundColor: Color.fromRGBO(239, 68, 68, 1),
                  label: 'Restar',
                  onTap: () {
                    // acción -
                  },
                ),
              ],
              child: Text(
                '\u00B1', // Símbolo ±
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          : null, */
    );
  }
}
