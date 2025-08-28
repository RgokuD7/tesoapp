import 'package:flutter/material.dart';
import '../../widgets/label_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';

import '../../widgets/custom_loader.dart';
import '../../widgets/auth_errors_messages.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = "";
  final Map<String, String> _errorMessages = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    // Limpiamos los errores anteriores antes de la validación
    _errorMessages.clear();
    setState(() {
      _errorMessage = "";
    });

    // Si el formulario no es válido, obtenemos los mensajes de error
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = "Por favor, ingresa los campos requeridos.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      // Si el inicio de sesión es exitoso, navega hacia atrás
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message =
          'Ocurrió un error inesperado. Por favor, inténtalo de nuevo, ${e.message}';
      if (e.code == 'user-not-found') {
        message = 'No existe una cuenta asociada a este correo.';
        // Asignamos el mensaje real al mapa
        _errorMessages['email'] = message;
      } else if (e.code == 'wrong-password') {
        message = 'La contraseña ingresada no es correcta.';
        // Asignamos el mensaje real al mapa
        _errorMessages['password'] = message;
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo electrónico es inválido.';
        // Asignamos el mensaje real al mapa
        _errorMessages['email'] = message;
      }

      setState(() {
        _errorMessage = message;
      });
      // Ya no necesitamos llamar a validate() aquí, el setState() se encargará
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.white,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'Iniciar Sesión',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                child: Text(
                  'Accede a tu tesorería grupal',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(100, 116, 139, 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 25,
                      right: 25,
                      top: 25,
                      bottom: 5,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Muestra el mensaje de error si existe
                                if (_errorMessage.isNotEmpty)
                                  AuthErrorMessages(message: _errorMessage),

                                const SizedBox(height: 8),

                                LabeledTextField(
                                  fieldKey: 'email',
                                  label: 'Correo electrónico',
                                  autofocus: true,
                                  hint: 'ejemplo@correo.com',
                                  controller: _emailController,
                                  icon: const Icon(Icons.email_outlined),
                                  keyboardType: TextInputType.emailAddress,
                                  errors: _errorMessages,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Requerido';
                                    } else if (!RegExp(
                                      r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$',
                                    ).hasMatch(v)) {
                                      return 'Formato de correo inválido';
                                    }
                                    return null;
                                  },
                                ),
                                LabeledTextField(
                                  fieldKey: 'password',
                                  label: 'Contraseña',
                                  hint: 'Ingresa tu contraseña',
                                  isPassword: true,
                                  controller: _passwordController,
                                  icon: const Icon(Icons.lock_outlined),
                                  errors: _errorMessages,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Requerido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () {
                                      // TODO: Implementar navegación a la página de recuperación de contraseña
                                      // Navigator.pushNamed(context, '/forgot_password');
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      "¿Olvidaste tu contraseña?",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontSize: 14,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      55,
                                    ),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.navigate_next_outlined),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        thickness: 1,
                                        color: Colors.grey.shade400,
                                        endIndent: 10,
                                      ),
                                    ),
                                    Text(
                                      "o",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        thickness: 1,
                                        color: Colors.grey.shade400,
                                        indent: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('¿No tienes cuenta?'),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/register',
                                        );
                                      },
                                      child: Text(
                                        'Regístrate',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading) const CustomLoader(),
        ],
      ),
    );
  }
}
