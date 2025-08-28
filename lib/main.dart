import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tesoapp/pages/role_selection_page.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/auth/auth_gate.dart';
import 'pages/index_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TesoApp',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: ColorScheme.light(
          primary: const Color.fromRGBO(37, 99, 235, 1),
        ),
      ),
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/index': (context) => const IndexPage(),
        '/role_selection': (context) => const RoleSelectionPage(),
      },
    );
  }
}
