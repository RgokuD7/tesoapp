import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 100,
              child: Text(
                '💰',
                style: TextStyle(fontSize: 100, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'TesoApp',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const Text(
              'Gestión de Tesorería Grupal',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromRGBO(100, 116, 139, 1),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            buildFeatureRow(text: 'Control total de ingresos y gastos'),
            buildFeatureRow(text: 'Transparencia para todos los miembros'),
            buildFeatureRow(text: 'Reportes y gráficos en tiempo real'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(Icons.login),
                  SizedBox(width: 8),
                  Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(Icons.person_add),
                  SizedBox(width: 8),
                  Text(
                    'Crear Cuenta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFeatureRow({
    required String text,
    IconData icon = Icons.auto_awesome,
    Color iconColor = const Color.fromRGBO(16, 185, 119, 1),
    Color textColor = const Color.fromRGBO(100, 116, 139, 1),
    double fontSize = 16,
    double spacing = 8,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor),
          SizedBox(width: spacing),
          // Flexible permite que el texto haga wrap en pantallas pequeñas
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: fontSize, color: textColor),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
