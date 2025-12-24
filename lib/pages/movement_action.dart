import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

import '../../widgets/label_text_field.dart';
import '../../widgets/label_date_field.dart';
import '../../widgets/label_dropdown_field.dart';
import '../../widgets/category_manager_sheet.dart';

import '../providers/group_provider.dart';
import '../providers/movement_provider.dart';
import '../providers/user_provider.dart';

enum MovementAction { add, remove }

class MovementPage extends ConsumerStatefulWidget {
  final MovementAction action;

  const MovementPage({super.key, required this.action});

  @override
  ConsumerState<MovementPage> createState() => _MovementPageState();
}

class _MovementPageState extends ConsumerState<MovementPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final Map<String, String> _validationErrors = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final date = ref.read(movementProvider).selectedDate;
      _dateController.text = DateFormat('dd/MM/yyyy').format(date);

      final initialType = widget.action == MovementAction.add
          ? 'income'
          : 'expense';
      ref.read(movementProvider.notifier).setTransactionType(initialType);

      ref.read(movementProvider.notifier).loadMembers();
      ref.read(movementProvider.notifier).loadUserGroups();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _listenToStateChanges() {
    ref.listen(movementProvider.select((s) => s.selectedDate), (
      previous,
      next,
    ) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(next);
    });
  }

  void _handleSave() async {
    setState(() => _validationErrors.clear());
    if (!_formKey.currentState!.validate()) return;

    final state = ref.read(movementProvider);
    if (state.selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor selecciona una categoría")),
      );
      return;
    }

    final user = ref.read(userProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Usuario no identificado")),
      );
      return;
    }

    final success = await ref
        .read(movementProvider.notifier)
        .submitData(
          amountStr: _amountController.text,
          description: _descriptionController.text,
          userId: user.id,
        );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  void _showImagePickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text("Tomar Foto"),
                onTap: () {
                  Navigator.pop(ctx);
                  ref
                      .read(movementProvider.notifier)
                      .pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text("Galería"),
                onTap: () {
                  Navigator.pop(ctx);
                  ref
                      .read(movementProvider.notifier)
                      .pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _listenToStateChanges();

    final movementState = ref.watch(movementProvider);
    final group = ref.watch(groupProvider);

    if (group == null && movementState.selectedGroupId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isIncome = movementState.transactionType == 'income';
    final mainColor = isIncome
        ? const Color.fromRGBO(16, 185, 129, 1)
        : const Color.fromRGBO(239, 68, 68, 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isIncome ? "Nuevo Ingreso" : "Nuevo Gasto",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: movementState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (movementState.errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          movementState.errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    // Toggle Ingreso/Gasto
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => ref
                                  .read(movementProvider.notifier)
                                  .setTransactionType('income'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isIncome
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: isIncome
                                      ? [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  "Ingreso",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isIncome
                                        ? Colors.green
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => ref
                                  .read(movementProvider.notifier)
                                  .setTransactionType('expense'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: !isIncome
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: !isIncome
                                      ? [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  "Gasto",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !isIncome
                                        ? Colors.red
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Grupo
                            if (movementState.userGroupsOptions.length > 1) ...[
                              LabeledDropdownField(
                                fieldKey: "group_selector",
                                label: "Registrar en grupo",
                                hint: "Selecciona el grupo",
                                items: movementState.userGroupsOptions,
                                value:
                                    movementState.selectedGroupId ?? group?.id,
                                onChanged: (val) {
                                  if (val != null)
                                    ref
                                        .read(movementProvider.notifier)
                                        .changeSelectedGroup(val);
                                },
                                errors: const {},
                                icon: const Icon(Icons.group),
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                            ],

                            // Meta
                            if (movementState.goalOptions.isNotEmpty) ...[
                              LabeledDropdownField(
                                fieldKey: "goal_selector",
                                label: "Asignar a Meta",
                                hint: "Ej: Gala, Paseo (Opcional)",
                                items: movementState.goalOptions,
                                value: movementState.selectedGoalId,
                                onChanged: (val) => ref
                                    .read(movementProvider.notifier)
                                    .setGoal(val),
                                errors: const {},
                                icon: const Icon(Icons.flag),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Monto
                            LabeledTextField(
                              fieldKey: 'amount',
                              label: 'Monto',
                              hint: 'Ej: \$50.000',
                              controller: _amountController,
                              icon: const Icon(Icons.attach_money),
                              keyboardType: TextInputType.number,
                              isCurrency: true,
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? 'Ingresa un monto'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            // Categoría
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Categoría",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    if (group != null) {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) =>
                                            CategoryManagerSheet(group: group),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text(
                                    "Editar",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    foregroundColor: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            if (movementState.categoryOptions.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "No hay categorías disponibles.",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                children: movementState.categoryOptions.keys
                                    .map((catKey) {
                                      final catName = movementState
                                          .categoryOptions[catKey]!;
                                      final selected =
                                          movementState.selectedCategory ==
                                          catName;
                                      return ChoiceChip(
                                        label: Text(catName),
                                        selected: selected,
                                        selectedColor: mainColor,
                                        backgroundColor: Colors.white,
                                        labelStyle: TextStyle(
                                          color: selected
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: selected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        side: BorderSide(
                                          color: selected
                                              ? mainColor
                                              : Colors.grey.shade300,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        onSelected: (_) => ref
                                            .read(movementProvider.notifier)
                                            .setCategory(catName),
                                      );
                                    })
                                    .toList(),
                              ),

                            const SizedBox(height: 16),

                            // Pagador (Ingreso)
                            if (isIncome) ...[
                              const Text(
                                "¿Quién entregó el dinero?",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              movementState.isLoadingMembers
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : LabeledDropdownField(
                                      fieldKey: "payer",
                                      label: "",
                                      hint: "Selecciona un miembro",
                                      items: movementState.memberOptions,
                                      value:
                                          movementState.selectedPayer ??
                                          group?.admin,
                                      onChanged: (val) => ref
                                          .read(movementProvider.notifier)
                                          .setPayer(val),
                                      errors: _validationErrors,
                                      icon: const Icon(Icons.person),
                                    ),
                            ],

                            // Descripción
                            LabeledTextField(
                              fieldKey: 'description',
                              label: 'Descripción (Opcional)',
                              hint: 'Ej: Pago de comida',
                              controller: _descriptionController,
                              icon: const Icon(Icons.description),
                            ),

                            // Fecha
                            LabeledDateField(
                              fieldKey: 'date',
                              label: 'Fecha',
                              hint: 'Selecciona la fecha',
                              controller: _dateController,
                              icon: const Icon(Icons.date_range),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              onDateSelected: (date) => ref
                                  .read(movementProvider.notifier)
                                  .setDate(date),
                            ),

                            // --- Seccion Comprobante (IMAGEN) ---
                            GestureDetector(
                              onTap: () {
                                if (movementState.isLoading) return;
                                _showImagePickerModal(context);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 16),
                                width: double.infinity,
                                height: 120, // Altura fija
                                decoration: BoxDecoration(
                                  color: movementState.selectedImage != null
                                      ? Colors.transparent
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    style: BorderStyle.solid,
                                  ),
                                  image: movementState.selectedImage != null
                                      ? DecorationImage(
                                          image: kIsWeb
                                              ? NetworkImage(
                                                  movementState
                                                      .selectedImage!
                                                      .path,
                                                )
                                              : FileImage(
                                                      File(
                                                        movementState
                                                            .selectedImage!
                                                            .path,
                                                      ),
                                                    )
                                                    as ImageProvider,
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: movementState.selectedImage != null
                                    ? Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: InkWell(
                                              onTap: () => ref
                                                  .read(
                                                    movementProvider.notifier,
                                                  )
                                                  .removeImage(),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            left: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                "Cambiar imagen",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt_outlined,
                                            color: Colors.grey.shade400,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Adjuntar comprobante",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            "(Foto o captura)",
                                            style: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: movementState.isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: movementState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "GUARDAR",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
