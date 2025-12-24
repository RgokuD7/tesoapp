import 'package:flutter/material.dart';
import '../../widgets/dismiss_keyboard.dart';
import '../../widgets/label_text_field.dart';
import '../../widgets/label_date_field.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/auth_errors_messages.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:intl/intl.dart';

import '../providers/user_provider.dart';
import '../providers/group_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group.dart';
import '../models/goal.dart';
import '../models/category.dart';
import '../utils/formatters.dart';

class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  final _pageController = PageController();

  bool _isLoading = false;
  int _currentStep = 0;
  String? _selectedRole;
  String? _selectedInitialState;
  String _errorMessage = "";

  final Map<String, String> _errorMessages = {};

  Group? _group;

  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _amountGoalController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _groupCodeController = TextEditingController();
  final _currentAmountController = TextEditingController();

  // Dentro del State de tu StatefulWidget
  String _getTitle() {
    if (_currentStep == 0) {
      return '¿Cuál es tu rol?';
    } else if (_currentStep == 1 || _currentStep == 2) {
      if (_selectedRole == 'admin') {
        return 'Configurar Grupo';
      } else if (_selectedRole == 'member') {
        return 'Unirse a Grupo';
      } else {
        return 'Paso siguiente'; // fallback si no se seleccionó rol
      }
    } else {
      return 'Grupo Creado ';
    }
  }

  String _getSubtitle() {
    if (_currentStep == 0) {
      return 'Selecciona cómo participarás en el grupo';
    } else if (_currentStep == 1) {
      if (_selectedRole == 'admin') {
        return 'Define tu grupo y objetivo';
      } else if (_selectedRole == 'member') {
        return 'Ingresa el código que te compartió el administrador';
      } else {
        return '';
      }
    } else if (_currentStep == 2) {
      return 'Estado inicial de los fondos';
    } else {
      return '¡Todo listo! Comparte el código con tus amigos';
    }
  }

  String _getButtonText() {
    if (_currentStep == 2 && _selectedRole == 'admin') {
      return 'Crear Grupo';
    } else if (_currentStep == 1 && _selectedRole == 'member') {
      return 'Unirse al grupo';
    } else if (_currentStep == 3) {
      return 'Finalizar';
    } else {
      return 'Continuar';
    }
  }

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
    _pageController.dispose();
    _groupNameController.dispose();
    _purposeController.dispose();
    _amountGoalController.dispose();
    _deadlineController.dispose();
    _groupCodeController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  void _adminSubmit() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      final currentUser = ref.read(userProvider);

      if (currentUser == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/");
        return;
      }

      final adminId = currentUser.id;

      final goalAmount = Formatters.currencyToDouble(
        _amountGoalController.text,
      );
      final currentAmount = Formatters.currencyToDouble(
        _currentAmountController.text,
      );

      final deadlineDate = _deadlineController.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(_deadlineController.text)
          : null;

      // Crear la META inicial basada en los datos ingresados
      final initialGoal = Goal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _purposeController.text,
        targetAmount: goalAmount,
        currentAmount: 0.0, // Parte en 0
        deadline: deadlineDate,
      );

      final newGroup = Group(
        name: _groupNameController.text,
        // Mantener campos legacy sincronizados por ahora
        purpose: _purposeController.text,
        goalAmount: goalAmount,
        deadline: deadlineDate,
        currentAmount: _selectedInitialState == "with_funds"
            ? currentAmount
            : 0.0,

        // Agregar la meta a la lista
        goals: [initialGoal],

        admin: adminId,
        members: [adminId],

        // Inicializar con categoría 'Cuota' por defecto (Nuevo Modelo)
        categoriesList: [
          Category(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'Cuota',
            type: CategoryType.income,
          ),
        ],
      );

      final groupNotifer = ref.read(groupProvider.notifier);
      final createdGroup = await groupNotifer.createGroup(newGroup);
      final userNotfier = ref.read(userProvider.notifier);
      await userNotfier.addGroup(createdGroup.id);
      setState(() => _group = createdGroup);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              "Ocurrió un error inesperado. Por favor, inténtalo de nuevo.";
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _memberSubmit() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(userProvider);

      if (currentUser == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/");
        return;
      }

      final userId = currentUser.id;
      final groupCode = _groupCodeController.text.trim();
      final groupNotifier = ref.read(groupProvider.notifier);

      final group = await groupNotifier.getGroupByCode(groupCode);

      if (group == null) {
        if (!mounted) return;
        _errorMessages['group_code'] = "Código inválido";
        setState(() {
          _errorMessage =
              "El código ingresado no es válido. Verifica con el administrador.";
        });
        return;
      }

      if (group.members.contains(userId)) {
        setState(() {
          _errorMessage = "Ya estas en ${group.name}";
        });
        return;
      }

      await groupNotifier.addUserToGroup(group.id, userId);
      final userNotifier = ref.read(userProvider.notifier);
      await userNotifier.addGroup(group.id);
      setState(() => _group = group);
      _pageController.jumpToPage(3);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            "Ocurrió un error inesperado. Por favor, inténtalo de nuevo.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_selectedRole == null) {
        setState(() {
          _errorMessage = "⚠️ Por favor, selecciona tu rol para continuar.";
        });
        return;
      }
      setState(() {
        _errorMessage =
            ""; // Limpiar el mensaje de error si se selecciona un rol
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else if (_currentStep == 1) {
      if (_selectedRole == 'admin') {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _errorMessage = "";
            _currentStep++;
          });
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        } else {
          setState(() {
            _errorMessage = "Por favor, completa todos los campos requeridos.";
          });
        }
      } else if (_selectedRole == 'member') {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _errorMessage = "";
          });
          _memberSubmit();
        } else {
          setState(() {
            _errorMessage = "Por favor, completa todos los campos requeridos.";
          });
        }
      }
    } else if (_currentStep == 2) {
      if (_selectedInitialState == null) {
        setState(() {
          _errorMessage =
              "⚠️ Por favor, selecciona el estado inicial para continuar";
        });
      } else {
        _adminSubmit();
        setState(() {
          _errorMessage =
              ""; // Limpiar el mensaje de error si se selecciona un rol
          _currentStep++;
        });
      }
    } else if (_currentStep == 3) {
      Navigator.pushReplacementNamed(context, "/");
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _errorMessage = ""; // Limpiar el mensaje de error al retroceder
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
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
                  // Header fijo
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: !isKeyboardOpen
                        ? Column(
                            key: const ValueKey('header'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /*                               Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    if (_currentStep == 0)
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
                                      )
                                    else
                                      ElevatedButton(
                                        onPressed: _previousStep,
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
                              ), */
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                ),
                                child: Text(
                                  _getTitle(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 5,
                                ),
                                child: Text(
                                  _getSubtitle(),
                                  style: const TextStyle(
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

                  // Contenido del formulario con PageView
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
                        child: SafeArea(
                          top: false,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _selectedRole == "admin"
                                      ? 4
                                      : (_selectedRole == "member" ? 3 : 2),
                                  (index) {
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
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: PageView(
                                  controller: _pageController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentStep = index;
                                    });
                                  },
                                  children: [
                                    // Step 0: Selección de Rol
                                    SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          if (_errorMessage.isNotEmpty)
                                            AuthErrorMessages(
                                              message: _errorMessage,
                                            ),
                                          const SizedBox(height: 8),
                                          _buildRoleCard(
                                            role: "admin",
                                            icon: FontAwesomeIcons.crown,
                                            iconColor: Colors.blue.shade700,
                                            title: "Administrador",
                                            description:
                                                "Gestiono el dinero del grupo, registro ingresos y gastos, y mantengo la transparencia",
                                            features: [
                                              "Agregar/quitar dinero",
                                              "Ver reportes completos",
                                              "Configurar metas",
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          _buildRoleCard(
                                            role: "member",
                                            icon: FontAwesomeIcons.eye,
                                            iconColor: Colors.green.shade600,
                                            title: "Miembro",
                                            description:
                                                "Participo en el grupo y quiero ver cómo va el progreso del dinero de forma transparente",
                                            features: [
                                              "Ver estado actual",
                                              "Ver historial",
                                              "Ver progreso de metas",
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                    // Step 1: Configuración del Grupo
                                    SingleChildScrollView(
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            if (_selectedRole == "admin") ...[
                                              if (_errorMessage.isNotEmpty)
                                                AuthErrorMessages(
                                                  message: _errorMessage,
                                                ),
                                              const SizedBox(height: 8),
                                              LabeledTextField(
                                                fieldKey: 'group_name',
                                                label: 'Nombre del grupo',
                                                hint:
                                                    'Ej: 4 Medio F, Amigos de Viaje, Club Deportivo',
                                                controller:
                                                    _groupNameController,
                                                icon: const Icon(Icons.group),
                                                validator: (v) {
                                                  if (v == null ||
                                                      v.trim().isEmpty)
                                                    return '';
                                                  return null;
                                                },
                                              ),
                                              LabeledTextField(
                                                fieldKey: 'purpose',
                                                label:
                                                    '¿Para que estan juntando dinero?',
                                                hint:
                                                    'Ej: Gala, Gira de estudios, viaje a la playa, regalo grupal',
                                                controller: _purposeController,
                                                icon: const Icon(Icons.flag),
                                                validator: (v) {
                                                  if (v == null ||
                                                      v.trim().isEmpty)
                                                    return '';
                                                  return null;
                                                },
                                              ),
                                              LabeledTextField(
                                                fieldKey: 'amount_goal',
                                                label: 'Meta de dinero',
                                                hint: 'Ej: \$5.000.000',
                                                controller:
                                                    _amountGoalController,
                                                icon: const Icon(
                                                  Icons.attach_money,
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                isCurrency: true,
                                                validator: (v) {
                                                  if (v == null ||
                                                      v.trim().isEmpty)
                                                    return '';
                                                  return null;
                                                },
                                              ),
                                              LabeledDateField(
                                                fieldKey: 'deadline',
                                                label:
                                                    'Fecha objetivo (Opcional)',
                                                hint:
                                                    '¿Para cuándo necesitan el dinero?',
                                                controller: _deadlineController,
                                                icon: const Icon(
                                                  Icons.date_range,
                                                ),
                                                firstDate:
                                                    DateTime.now(), // fecha mínima seleccionable
                                                lastDate: DateTime(
                                                  2100,
                                                ), // fecha máxima seleccionable
                                              ),
                                            ] else ...[
                                              CircleAvatar(
                                                radius: 40,
                                                backgroundColor:
                                                    const Color.fromRGBO(
                                                      219,
                                                      234,
                                                      254,
                                                      1,
                                                    ),
                                                child: Icon(
                                                  Icons.groups,
                                                  size: 50,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                              const Text(
                                                "Código de grupo",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                    30,
                                                    41,
                                                    59,
                                                    1,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              const Text(
                                                "El administrador te debe haber compartido un código de 8 caracteres.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color.fromRGBO(
                                                    100,
                                                    116,
                                                    139,
                                                    1,
                                                  ),
                                                ),
                                              ),
                                              if (_errorMessage.isNotEmpty)
                                                AuthErrorMessages(
                                                  message: _errorMessage,
                                                ),
                                              const SizedBox(height: 8),
                                              LabeledTextField(
                                                fieldKey: 'group_code',
                                                label: 'Código de grupo',
                                                hint: 'ABC123',
                                                controller:
                                                    _groupCodeController,
                                                icon: const Icon(Icons.tag),
                                                allowedChars: r'[A-Z0-9]',
                                                maxLength: 8,
                                                validator: (v) {
                                                  if (v == null ||
                                                      v.trim().isEmpty)
                                                    return '';
                                                  return null;
                                                },
                                              ),
                                              Text(
                                                "Ingresa el código exactamente como te lo compartieron.",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromRGBO(
                                                    100,
                                                    116,
                                                    139,
                                                    1,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Contenedor principal con los puntos
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          12,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      color:
                                                          const Color.fromRGBO(
                                                            240,
                                                            253,
                                                            244,
                                                            1,
                                                          ), // verde clarito
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: const [
                                                            Icon(
                                                              Icons
                                                                  .remove_red_eye_outlined,
                                                              color:
                                                                  Color.fromRGBO(
                                                                    16,
                                                                    185,
                                                                    129,
                                                                    1,
                                                                  ),
                                                              size: 16,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                "Como miembro del grupo podrás:",
                                                                style: TextStyle(
                                                                  color:
                                                                      Color.fromRGBO(
                                                                        22,
                                                                        101,
                                                                        52,
                                                                        1,
                                                                      ),
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 24,
                                                                vertical: 8,
                                                              ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              _buildPoint(
                                                                "Ver el saldo actual en tiempo real",
                                                              ),
                                                              _buildPoint(
                                                                "Consultar el historial de movimientos",
                                                              ),
                                                              _buildPoint(
                                                                "Seguir el progreso hacia la meta",
                                                              ),
                                                              _buildPoint(
                                                                "Recibir notificaciones de cambios",
                                                              ),
                                                              const SizedBox(
                                                                height: 16,
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      12,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        12,
                                                                      ),
                                                                  color: Colors
                                                                      .white, // fondo blanco
                                                                ),
                                                                child: Row(
                                                                  children: const [
                                                                    Icon(
                                                                      Icons
                                                                          .shield_outlined,
                                                                      color:
                                                                          Color.fromRGBO(
                                                                            100,
                                                                            116,
                                                                            139,
                                                                            1,
                                                                          ),
                                                                      size: 16,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 8,
                                                                    ),
                                                                    Expanded(
                                                                      child: Text(
                                                                        "Solo el administrador puede agregar o quitar dinero",
                                                                        style: TextStyle(
                                                                          color: Color.fromRGBO(
                                                                            100,
                                                                            116,
                                                                            139,
                                                                            1,
                                                                          ),
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
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
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Step 2 Fondo Inicial
                                    SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Text(
                                            "Estado Inicial",
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromRGBO(
                                                30,
                                                41,
                                                59,
                                                1,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "¿Como esta la tesoreria actualmente?",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color.fromRGBO(
                                                100,
                                                116,
                                                139,
                                                1,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 24),
                                          if (_errorMessage.isNotEmpty)
                                            AuthErrorMessages(
                                              message: _errorMessage,
                                            ),
                                          SizedBox(height: 8),
                                          _buildInitialStateCard(
                                            initialState: "without_funds",
                                            icon: FontAwesomeIcons
                                                .creativeCommonsZero,
                                            iconColor: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            title: "Empezamos desde cero",
                                            description:
                                                "Aun no hemos agregado dinero, comenzaremos ahora",
                                          ),
                                          SizedBox(height: 16),
                                          _buildInitialStateCard(
                                            initialState: "with_funds",
                                            icon: FontAwesomeIcons.sackDollar,
                                            iconColor: Colors.green.shade600,
                                            title: "Ya tenemos dinero",
                                            description:
                                                "Ya llevamos tiempo juntando y queremos registrar el monto actual.",
                                          ),
                                          SizedBox(height: 16),
                                          if (_selectedInitialState ==
                                              "with_funds")
                                            LabeledTextField(
                                              fieldKey: 'current_amount',
                                              label:
                                                  '¿Cuanto dinero tienen actualmente?',
                                              hint: '0',
                                              autofocus: true,
                                              controller:
                                                  _currentAmountController,
                                              icon: const Icon(
                                                Icons.attach_money,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              isCurrency: true,
                                              validator: (v) {
                                                if (v == null ||
                                                    v.trim().isEmpty)
                                                  return '';
                                                return null;
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Step 3: Grupo creado
                                    if (_selectedRole == "admin")
                                      SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(height: 40),
                                            Icon(
                                              Icons.celebration,
                                              size: 80,
                                              color: Colors.orange.shade400,
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              "¡Felicidades!",
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              "Tu grupo ha sido creado con éxito",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Color.fromRGBO(
                                                  100,
                                                  116,
                                                  139,
                                                  1,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            // Nombre del grupo
                                            Text(
                                              _groupNameController.text,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            // Código del grupo
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 24,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.vpn_key,
                                                    color: Colors.black54,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    _group != null
                                                        ? _group!.code
                                                        : '',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 32),
                                            // Contenedor futuro para QR
                                            /* Container(
                                              width: 180,
                                              height: 180,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.qr_code_2,
                                                  size: 80,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            Text(
                                              "Comparte este código o escanea el QR para invitar a nuevos miembros",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color.fromRGBO(
                                                  100,
                                                  116,
                                                  139,
                                                  1,
                                                ),
                                              ),
                                            ), */
                                          ],
                                        ),
                                      ),
                                    if (_selectedRole == "member")
                                      // Step 3: Confirmación de unión al grupo
                                      SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(height: 40),
                                            Icon(
                                              Icons.group_add,
                                              size: 80,
                                              color: Colors.green.shade400,
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              "¡Bienvenido!",
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              "Te has unido correctamente al grupo",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Color.fromRGBO(
                                                  100,
                                                  116,
                                                  139,
                                                  1,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            // Nombre del grupo
                                            Text(
                                              _group != null
                                                  ? _group!.name
                                                  : '',
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            // Código del grupo
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 24,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.vpn_key,
                                                    color: Colors.black54,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    _group != null
                                                        ? _group!.code
                                                        : '',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 32),
                                            // Contenedor futuro para QR
                                            /* Container(
                                              width: 180,
                                              height: 180,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.qr_code_2,
                                                  size: 80,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            Text(
                                              "Comparte este código o escanea el QR para invitar a nuevos miembros",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color.fromRGBO(
                                                  100,
                                                  116,
                                                  139,
                                                  1,
                                                ),
                                              ),
                                            ), */
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  if (_currentStep >= 1 &&
                                      _currentStep != 3) ...[
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
                                    const SizedBox(width: 10),
                                  ],
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
                                            _getButtonText(),
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
                              SizedBox(height: 16),
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

  Widget _buildRoleCard({
    required String role,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required List<String> features,
  }) {
    final isSelected = _selectedRole == role;
    Color backgroundColor;
    Color borderColor;

    if (isSelected) {
      backgroundColor = const Color.fromRGBO(248, 250, 252, 1);
      borderColor = Theme.of(context).primaryColor;
    } else if (_errorMessage.isNotEmpty) {
      backgroundColor = const Color.fromRGBO(254, 242, 242, 1);
      borderColor = const Color.fromRGBO(239, 68, 68, 1);
    } else {
      backgroundColor = Colors.white;
      borderColor = Colors.grey.shade300;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
          _errorMessage = "";
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          children: [
            // Icono y título
            CircleAvatar(
              backgroundColor: isSelected ? iconColor : Colors.grey.shade200,
              radius: 35,
              child: FaIcon(icon, color: isSelected ? Colors.white : iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isSelected ? iconColor : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            // Descripción
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromRGBO(55, 65, 81, 1),
              ),
            ),
            const SizedBox(height: 8),
            // Lista de features
            ...features.map(
              (feature) => Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 16, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      feature,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialStateCard({
    required String initialState,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedInitialState == initialState;
    Color backgroundColor;
    Color borderColor;

    if (isSelected) {
      backgroundColor = const Color.fromRGBO(248, 250, 252, 1);
      borderColor = Theme.of(context).primaryColor;
    } else if (_errorMessage.isNotEmpty) {
      backgroundColor = const Color.fromRGBO(254, 242, 242, 1);
      borderColor = const Color.fromRGBO(239, 68, 68, 1);
    } else {
      backgroundColor = Colors.white;
      borderColor = Colors.grey.shade300;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedInitialState = initialState;
          _errorMessage = "";
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          children: [
            // Icono y título
            CircleAvatar(
              backgroundColor: isSelected ? iconColor : Colors.grey.shade200,
              radius: 35,
              child: FaIcon(icon, color: isSelected ? Colors.white : iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isSelected ? iconColor : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            // Descripción
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromRGBO(55, 65, 81, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función para los puntos
  Widget _buildPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              color: Color.fromRGBO(22, 101, 52, 1),
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color.fromRGBO(22, 101, 52, 1),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
