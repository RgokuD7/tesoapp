import 'package:flutter/material.dart';
import '../../widgets/label_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_loader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  bool _isLoading = false;
  int _currentStep = 0; // 0 = datos personales, 1 = contraseña

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // mostrar loader
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return; // evita usar context si ya no está montado
        Navigator.pop(context);
        // Usuario creado exitosamente
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('¡Error!'),
              content: Text('La contraseña proporcionada es demasiado débil.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        } else if (e.code == 'email-already-in-use') {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('¡Error!'),
              content: Text('El correo electrónico ya está en uso.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('¡Error!'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false); // ocultar loader
      }
    }
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 1) {
        setState(() {
          _currentStep += 1;
        });
      } else {
        _submit();
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
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  '¿Cuál es tu rol?',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                child: Text(
                  'Selecciona cómo participarás en el grupo',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(100, 116, 139, 1),
                  ),
                ),
              ),
              const SizedBox(height: 20),

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
                          /* _buildRoleSelector() */
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(2, (index) {
                              Color color;
                              if (index < _currentStep) {
                                color = Colors.green; // ya pasó
                              } else if (index == _currentStep) {
                                color = Colors.blue; // activo
                              } else {
                                color = Colors.grey.shade300; // pendiente
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 10),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                if (_currentStep == 0) ...[
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Color(0xFFE2E8F0),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: const Color(
                                            0xFFF1F5F9,
                                          ),
                                          child: FaIcon(FontAwesomeIcons.crown),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else if (_currentStep == 1) ...[
                                  LabeledTextField(
                                    label: 'Contraseña',
                                    hint: 'Ingresa tu contraseña',
                                    controller: _passwordController,
                                    icon: Icon(Icons.lock_outlined),
                                    isPassword: true,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Por favor ingresa una contraseña';
                                      }
                                      if (v.length < 6) {
                                        return 'La contraseña debe tener al menos 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  LabeledTextField(
                                    label: 'Confirmar contraseña',
                                    hint: 'Repite la contraseña',
                                    controller: _confirmPasswordController,
                                    icon: Icon(Icons.lock_outlined),
                                    isPassword: true,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Confirma tu contraseña';
                                      }
                                      if (v != _passwordController.text) {
                                        return 'Las contraseñas no coinciden';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tu contraseña debe tener:',
                                          style: TextStyle(
                                            color: Color.fromRGBO(
                                              55,
                                              65,
                                              81,
                                              1,
                                            ),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              "•  ",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Expanded(
                                              child: Text(
                                                "Al menos 6 caracteres",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              "•  ",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Expanded(
                                              child: Text(
                                                "Una letra mayúscula",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              "•  ",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Expanded(
                                              child: Text(
                                                "Un número",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    if (_currentStep == 1)
                                      OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentStep -= 1;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          fixedSize: const Size(
                                            double.infinity,
                                            55,
                                          ),
                                          side: BorderSide(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            width: 2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.navigate_before_outlined,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Atrás',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (_currentStep == 1)
                                      const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _nextStep,
                                        style: ElevatedButton.styleFrom(
                                          fixedSize: const Size(
                                            double.infinity,
                                            55,
                                          ),
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _currentStep == 0
                                                  ? 'Siguiente'
                                                  : 'Registrar',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.navigate_next_outlined,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),
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
