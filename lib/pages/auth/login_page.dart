import 'package:flutter/material.dart';
import '../../widgets/label_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/alert_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return; // evita usar context si ya no está montado
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;

        String message;
        if (e.code == 'user-not-found') {
          message = 'El correo no está registrado.';
        } else if (e.code == 'wrong-password') {
          message = 'La contraseña es incorrecta.';
        } else {
          message = 'Los siguientes errores han ocurrido: ${e.message}';
        }
        await showDialog(
          context: context,
          builder: (_) => CustomAlertDialog(
            message: message,
            title: '¡Error!',
            typeOfDialog: 'error',
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false); // ocultar loader
      }
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
              // Header fijo
              SizedBox(height: 40),
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

              // Formulario scrollable
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
                          const SizedBox(height: 8),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                LabeledTextField(
                                  label: 'Correo electrónico',
                                  autofocus: true,
                                  hint: 'ejemplo@correo.com',
                                  controller: _emailController,
                                  icon: Icon(Icons.email_outlined),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Por favor ingresa tu correo';
                                    }
                                    if (!RegExp(
                                      r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$',
                                    ).hasMatch(v)) {
                                      return 'Correo inválido';
                                    }
                                    return null;
                                  },
                                ),
                                LabeledTextField(
                                  label: 'Contraseña',
                                  hint: 'Ingresa tu contraseña',
                                  isPassword: true,
                                  controller: _passwordController,
                                  icon: Icon(Icons.lock_outlined),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Por favor ingresa tu contraseña';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/');
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets
                                          .zero, // para que no tenga padding extra
                                      minimumSize: Size(
                                        0,
                                        0,
                                      ), // quita restricciones de tamaño
                                      tapTargetSize: MaterialTapTargetSize
                                          .shrinkWrap, // hace que el área clickeable sea justa
                                    ),
                                    child: Text(
                                      "¿Olvidaste tu contraseña?",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary, // color del link
                                        fontSize: 14,
                                        decoration: TextDecoration
                                            .none, // subrayado tipo link
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Iniciar Sesión',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.navigate_next_outlined),
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
                                    Text('¿No tienes cuenta?'),
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
