import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            Center(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // la columna ocupa solo lo necesario
                crossAxisAlignment: CrossAxisAlignment
                    .start, // alinea las filas por la izquierda
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.auto_awesome,
                        color: Color.fromRGBO(16, 185, 119, 1),
                      ),
                      SizedBox(width: 8),
                      // Si quieres que el texto haga wrap y no crezca demasiado:
                      // ConstrainedBox(constrains: BoxConstraints(maxWidth: 300), child: Text(...))
                      Text(
                        'Control total de ingresos y gastos',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(100, 116, 139, 1),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.auto_awesome,
                        color: Color.fromRGBO(16, 185, 119, 1),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Transparencia para todos los miembros',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(100, 116, 139, 1),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.auto_awesome,
                        color: Color.fromRGBO(16, 185, 119, 1),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Reportes y gráficos en tiempo real',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(100, 116, 139, 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
}
