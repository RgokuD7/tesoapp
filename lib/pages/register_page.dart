import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  int selectedIndex = 0;
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final role = selectedIndex == 0 ? 'Administrador' : 'Miembro';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registrando usuario:\n'
            'Nombre: ${_nameController.text}\n'
            'Apellido: ${_lastnameController.text}\n'
            'Email: ${_emailController.text}\n'
            'Rol: $role',
          ),
        ),
      );
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header fijo
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              'Crear Cuenta',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            child: Text(
              'Únete a la gestión transparente de fondos grupales',
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                            margin: const EdgeInsets.symmetric(horizontal: 3),
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
                        _currentStep == 0 ? 'Datos Personales' : 'Seguridad',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currentStep == 0
                            ? 'Cuéntanos un poco sobre ti'
                            : 'Crea una contraseña segura',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(100, 116, 139, 1),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (_currentStep == 0) ...[
                              _buildLabeledTextField(
                                label: 'Nombre',
                                hint: 'Tu nombre completo',
                                controller: _nameController,
                                icon: const Icon(Icons.person_outlined),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Por favor ingresa tu nombre'
                                    : null,
                              ),
                              _buildLabeledTextField(
                                label: 'Apellidos',
                                hint: 'Tus apellidos',
                                controller: _lastnameController,
                                icon: const Icon(Icons.person_outlined),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Por favor ingresa tu apellido'
                                    : null,
                              ),
                              _buildLabeledTextField(
                                label: 'Correo electrónico',
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
                              _buildLabeledTextField(
                                label: 'Teléfono (opcional)',
                                hint: '+56 9 1234 5678',
                                controller: _phoneController,
                                icon: Icon(Icons.phone_outlined),
                                keyboardType: TextInputType.phone,
                              ),
                            ] else if (_currentStep == 1) ...[
                              _buildLabeledTextField(
                                label: 'Contraseña',
                                hint: 'Ingresa tu contraseña',
                                controller: _passwordController,
                                icon: Icon(Icons.lock_outlined),
                                obscureText: true,
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
                              _buildLabeledTextField(
                                label: 'Confirmar contraseña',
                                hint: 'Repite la contraseña',
                                controller: _confirmPasswordController,
                                icon: Icon(Icons.lock_outlined),
                                obscureText: true,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tu contraseña debe tener:',
                                      style: TextStyle(
                                        color: Color.fromRGBO(55, 65, 81, 1),
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
                                        borderRadius: BorderRadius.circular(12),
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
                                        borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: _roleButtonStyle(selectedIndex == 0),
              onPressed: () => setState(() => selectedIndex = 0),
              child: const Text(
                '👑 Administrador',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: OutlinedButton(
              style: _roleButtonStyle(selectedIndex == 1),
              onPressed: () => setState(() => selectedIndex = 1),
              child: const Text(
                '👥 Miembro',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _roleButtonStyle(bool selected) {
    return OutlinedButton.styleFrom(
      backgroundColor: selected
          ? Theme.of(context).colorScheme.primary
          : Colors.grey.shade100,
      foregroundColor: selected ? Colors.white : Colors.black,
      side: BorderSide(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade100,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 17),
    );
  }

  Widget _buildStepper() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: _roleButtonStyle(selectedIndex == 0),
              onPressed: () => setState(() => selectedIndex = 0),
              child: const Text(
                '👑 Administrador',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: OutlinedButton(
              style: _roleButtonStyle(selectedIndex == 1),
              onPressed: () => setState(() => selectedIndex = 1),
              child: const Text(
                '👥 Miembro',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Icon? icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color.fromRGBO(55, 65, 81, 1),
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: icon,
              prefixIconColor:
                  WidgetStateColor.fromMap(<WidgetStatesConstraint, Color>{
                    WidgetState.focused: Theme.of(context).colorScheme.primary,
                    WidgetState.any: Color.fromRGBO(100, 116, 139, 1),
                    WidgetState.disabled: Colors.grey,
                    WidgetState.error: Colors.red,
                  }),
              filled: true, // Activa el color de fondo
              fillColor: Colors.grey.shade100, // Color de fondo
              hintText: hint,
              hintStyle: TextStyle(color: Color.fromRGBO(148, 163, 184, 1)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                  width: 1,
                  color: Color.fromRGBO(203, 213, 225, 1),
                  style: BorderStyle.solid,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
