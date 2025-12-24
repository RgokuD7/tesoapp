import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';

import '../../widgets/label_text_field.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/auth_errors_messages.dart';
import '../../widgets/dismiss_keyboard.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  bool _isLoading = false;
  int _currentStep = 0;
  String _errorMessage = "";
  final Map<String, String> _errorMessages = {};

  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _passwordValue = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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
    _pageController.dispose();
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    // Clear all previous errors
    _errorMessages.clear();
    setState(() {
      _errorMessage = "";
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = "Por favor, completa los campos requeridos.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await fb.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      // Guardar datos adicionales en Firestore
      // Create User model
      final newUser = User(
        id: credential.user!.uid,
        firstName: _nameController.text.trim(),
        lastName: _lastnameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        groups: [],
        notificationsEnabled: false,
      );
      // Save in Firestore via Riverpod
      if (mounted) {
        final notifier = ref.read(userProvider.notifier);
        await notifier.createUser(newUser);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } on fb.FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message =
          'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.';
      if (e.code == 'weak-password') {
        message =
            'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
        _errorMessages['password'] = message;
        _pageController.jumpToPage(1);
      } else if (e.code == 'email-already-in-use') {
        message = 'Este correo electrónico ya está en uso.';
        _errorMessages['email'] = message;
        _pageController.jumpToPage(0);
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo electrónico es inválido.';
        _errorMessages['email'] = message;
        _pageController.jumpToPage(0);
      }

      setState(() {
        _errorMessage = message;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    // Limpiar errores anteriores
    _errorMessages.clear();
    setState(() {
      _errorMessage = "";
    });

    // Validar campos
    String message = ""; // mensaje global

    // Step 0: Datos personales
    if (_currentStep == 0) {
      _errorMessages.clear(); // limpiar errores previos
      // Validaciones individuales
      if (_nameController.text.trim().isEmpty) {
        _errorMessages['name'] = 'Por favor ingresa tu nombre';
      }
      if (_lastnameController.text.trim().isEmpty) {
        _errorMessages['lastname'] = 'Por favor ingresa tus apellidos';
      }
      if (_emailController.text.trim().isEmpty) {
        _errorMessages['email'] = 'Por favor ingresa tu correo';
      } else if (!RegExp(
        r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$',
      ).hasMatch(_emailController.text)) {
        _errorMessages['email'] = 'Formato de correo inválido';
      }

      // Decidir mensaje general
      if (_errorMessages.isEmpty) {
        message = ''; // no hay errores
      } else if (_errorMessages.length == 1) {
        message = _errorMessages.values.first; // solo un error, mostrarlo
      } else {
        message = 'Completa todos los campos requeridos'; // varios errores
      }
    }

    // Step 1: Seguridad
    if (_currentStep == 1) {
      final password = _passwordController.text;
      final confirm = _confirmPasswordController.text;

      // Validar requisitos de la contraseña
      final bool meetsRequirements =
          password.length >= 6 &&
          RegExp(r'[A-Z]').hasMatch(password) &&
          RegExp(r'[0-9]').hasMatch(password);

      if (!meetsRequirements) {
        message = 'La contraseña debe cumplir con los 3 requisitos de abajo';
      } else if (password != confirm) {
        message = 'Las contraseñas no coinciden';
      }
    }

    if (message.isNotEmpty) {
      setState(() {
        _errorMessage = message;
      });
    } else {
      // Si todo está bien, pasar al siguiente paso o enviar
      if (_currentStep < 1) {
        _currentStep++;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } else {
        _submit();
      }
    }
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    setState(() {
      _currentStep--;
      _errorMessage = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: !isKeyboardOpen
                        ? Column(
                            key: const ValueKey('header'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                      child: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                  'Crear Cuenta',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                  'Únete a la gestión transparente de fondos grupales',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromRGBO(100, 116, 139, 1),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  Flexible(
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
                        child: SafeArea(
                          top: false,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(2, (index) {
                                  Color color;
                                  if (index < _currentStep) {
                                    color = Colors.green;
                                  } else if (index == _currentStep) {
                                    color = Colors.blue;
                                  } else {
                                    color = Colors.grey.shade300;
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
                              Text(
                                _currentStep == 0
                                    ? 'Datos Personales'
                                    : 'Seguridad',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _currentStep == 0
                                    ? 'Cuéntanos un poco sobre ti'
                                    : 'Crea una contraseña segura',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(100, 116, 139, 1),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Expanded(
                                child: Form(
                                  key: _formKey,
                                  child: PageView(
                                    controller: _pageController,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentStep = index;
                                      });
                                    },
                                    children: [
                                      // Step 0: Personal Info
                                      SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            AuthErrorMessages(
                                              message: _errorMessage,
                                            ),
                                            LabeledTextField(
                                              fieldKey: 'name',
                                              label: 'Nombre',
                                              hint: 'Tus nombres',
                                              controller: _nameController,
                                              icon: const Icon(
                                                Icons.person_outlined,
                                              ),
                                              errors: _errorMessages,
                                              validator: (v) {
                                                if (v == null ||
                                                    v.trim().isEmpty) {
                                                  return 'Requerido';
                                                }
                                                return null;
                                              },
                                            ),
                                            LabeledTextField(
                                              fieldKey: 'lastname',
                                              label: 'Apellidos',
                                              hint: 'Tus apellidos',
                                              controller: _lastnameController,
                                              icon: const Icon(
                                                Icons.person_outlined,
                                              ),
                                              errors: _errorMessages,
                                              validator: (v) {
                                                if (v == null ||
                                                    v.trim().isEmpty) {
                                                  return 'Requerido';
                                                }
                                                return null;
                                              },
                                            ),
                                            LabeledTextField(
                                              fieldKey: 'email',
                                              label: 'Correo electrónico',
                                              hint: 'ejemplo@correo.com',
                                              controller: _emailController,
                                              icon: const Icon(
                                                Icons.email_outlined,
                                              ),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              errors: _errorMessages,
                                              validator: (v) {
                                                if (v == null ||
                                                    v.trim().isEmpty) {
                                                  return 'Por favor ingresa tu email';
                                                }
                                                if (!RegExp(
                                                  r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$',
                                                ).hasMatch(v)) {
                                                  return 'Formato de correo inválido';
                                                }
                                                return null;
                                              },
                                            ),
                                            LabeledTextField(
                                              fieldKey: 'phone',
                                              label: 'Teléfono (opcional)',
                                              hint: '+56 9 1234 5678',
                                              controller: _phoneController,
                                              icon: const Icon(
                                                Icons.phone_outlined,
                                              ),
                                              keyboardType: TextInputType.phone,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Step 1: Security
                                      SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            AuthErrorMessages(
                                              message: _errorMessage,
                                            ),
                                            LabeledTextField(
                                              fieldKey: 'password',
                                              label: 'Contraseña',
                                              hint: 'Ingresa tu contraseña',
                                              isPassword: true,
                                              controller: _passwordController,
                                              icon: const Icon(
                                                Icons.lock_outlined,
                                              ),
                                              errors: _errorMessages,
                                              validator: (v) {
                                                if (v == null ||
                                                    v.trim().isEmpty) {
                                                  return 'Requerido';
                                                }
                                                if (v.length < 6) {
                                                  return 'Mínimo 6 caracteres';
                                                }
                                                if (!RegExp(
                                                  r'[A-Z]',
                                                ).hasMatch(v)) {
                                                  return 'Debe contener al menos una letra mayúscula';
                                                }
                                                if (!RegExp(
                                                  r'[0-9]',
                                                ).hasMatch(v)) {
                                                  return 'Debe contener al menos un número';
                                                }
                                                return null;
                                              },
                                              onChanged: (val) {
                                                setState(() {
                                                  _passwordValue = val;
                                                });
                                              },
                                            ),
                                            LabeledTextField(
                                              fieldKey: 'confirm_password',
                                              label: 'Confirmar contraseña',
                                              hint: 'Repite la contraseña',
                                              isPassword: true,
                                              controller:
                                                  _confirmPasswordController,
                                              icon: const Icon(
                                                Icons.lock_outlined,
                                              ),
                                              errors: _errorMessages,
                                              validator: (v) {
                                                if (v == null ||
                                                    v.trim().isEmpty) {
                                                  return 'Requerido';
                                                }
                                                if (v !=
                                                    _passwordController.text) {
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
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _buildPasswordRule(
                                                        "Al menos 6 caracteres",
                                                        _passwordValue.length >=
                                                            6,
                                                      ),
                                                      _buildPasswordRule(
                                                        "Una letra mayúscula",
                                                        _passwordValue.contains(
                                                          RegExp(r'[A-Z]'),
                                                        ),
                                                      ),
                                                      _buildPasswordRule(
                                                        "Un número",
                                                        _passwordValue.contains(
                                                          RegExp(r'[0-9]'),
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
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  if (_currentStep == 1)
                                    OutlinedButton(
                                      onPressed: _previousStep,
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
                                        children: const [
                                          Icon(Icons.navigate_before_outlined),
                                          SizedBox(width: 4),
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
                      ),
                    ),
                  ),
                ],
              ),
              if (_isLoading) const CustomLoader(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRule(String text, bool condition) {
    final bool isEmpty = _passwordValue.isEmpty;
    return Row(
      children: [
        Icon(
          isEmpty
              ? Icons.trip_origin_outlined
              : (condition ? Icons.check_circle : Icons.cancel),
          color: isEmpty
              ? Colors
                    .grey // cuando no escribe nada, gris
              : (condition ? Colors.green : Colors.red),
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: isEmpty
                ? Colors
                      .grey // gris si está vacío
                : (condition ? Colors.green : Colors.red),
          ),
        ),
      ],
    );
  }
}
