import 'dart:io';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/movement.dart';
import '../models/category.dart';
import '../services/movement_service.dart';
import '../services/group_service.dart';
import 'group_provider.dart';
import 'user_provider.dart';

// --- Estado del Formulario ---
class MovementFormState {
  final bool isLoading;
  final bool isLoadingMembers;
  final String errorMessage;
  final DateTime selectedDate;

  final String transactionType; // 'income' o 'expense'

  final Map<String, String> categoryOptions; // ID -> Nombre
  final String? selectedCategory;

  final Map<String, String> userGroupsOptions;
  final String? selectedGroupId;

  final Map<String, String> memberOptions;
  final String? selectedPayer;

  final Map<String, String> goalOptions;
  final String? selectedGoalId;

  final XFile? selectedImage;

  MovementFormState({
    this.isLoading = false,
    this.isLoadingMembers = false,
    this.errorMessage = '',
    required this.selectedDate,
    this.transactionType = 'income',
    this.categoryOptions = const {},
    this.selectedCategory,
    this.userGroupsOptions = const {},
    this.selectedGroupId,
    this.memberOptions = const {},
    this.selectedPayer,
    this.goalOptions = const {},
    this.selectedGoalId,
    this.selectedImage,
  });

  MovementFormState copyWith({
    bool? isLoading,
    bool? isLoadingMembers,
    String? errorMessage,
    DateTime? selectedDate,
    String? transactionType,
    Map<String, String>? categoryOptions,
    String? selectedCategory,
    Map<String, String>? userGroupsOptions,
    String? selectedGroupId,
    Map<String, String>? memberOptions,
    String? selectedPayer,
    Map<String, String>? goalOptions,
    String? selectedGoalId,
    XFile? selectedImage,
  }) {
    return MovementFormState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMembers: isLoadingMembers ?? this.isLoadingMembers,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedDate: selectedDate ?? this.selectedDate,
      transactionType: transactionType ?? this.transactionType,
      categoryOptions: categoryOptions ?? this.categoryOptions,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      userGroupsOptions: userGroupsOptions ?? this.userGroupsOptions,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
      memberOptions: memberOptions ?? this.memberOptions,
      selectedPayer: selectedPayer ?? this.selectedPayer,
      goalOptions: goalOptions ?? this.goalOptions,
      selectedGoalId: selectedGoalId ?? this.selectedGoalId,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

// --- Notifier / Controller ---
class MovementController extends StateNotifier<MovementFormState> {
  final Ref ref;

  MovementController(this.ref)
    : super(MovementFormState(selectedDate: DateTime.now()));

  Future<void> loadUserGroups() async {
    final user = ref.read(userProvider);
    if (user != null && user.groups.isNotEmpty) {
      final Map<String, String> options = {};
      String? defaultGroupId;

      for (var groupId in user.groups) {
        try {
          final group = await GroupService().getGroup(groupId);
          if (group != null) {
            options[group.id] = group.name;
            if (defaultGroupId == null) defaultGroupId = group.id;
          }
        } catch (e) {
          print("Error cargando grupo $groupId: $e");
        }
      }

      final currentGlobalGroup = ref.read(groupProvider);
      final initialGroup = currentGlobalGroup?.id ?? defaultGroupId;

      state = state.copyWith(
        userGroupsOptions: options,
        selectedGroupId: initialGroup,
      );

      if (initialGroup != null) {
        changeSelectedGroup(initialGroup);
      }
    }
  }

  void changeSelectedGroup(String groupId) async {
    state = state.copyWith(selectedGroupId: groupId, isLoadingMembers: true);

    await ref.read(groupProvider.notifier).loadGroup(groupId);
    final group = ref.read(groupProvider);

    if (group != null) {
      final Map<String, String> goals = {};
      for (var goal in group.goals) {
        goals[goal.id] = goal.name;
      }

      final Map<String, String> members = {};
      for (var mId in group.members) {
        members[mId] = mId == group.admin ? "Admin" : "Miembro ($mId)";
      }

      state = state.copyWith(
        goalOptions: goals,
        memberOptions: members,
        selectedPayer: group.admin,
        selectedGoalId: null,
        isLoadingMembers: false,
      );

      _filterCategories();
    }
  }

  void setTransactionType(String type) {
    state = state.copyWith(transactionType: type, selectedCategory: null);
    _filterCategories();
  }

  void _filterCategories() {
    final group = ref.read(groupProvider);
    if (group == null) return;

    final type = state.transactionType == 'income'
        ? CategoryType.income
        : CategoryType.expense;

    final Map<String, String> filtered = {};

    for (var cat in group.categoriesList) {
      if (cat.type == type || cat.type == CategoryType.both) {
        filtered[cat.id] = cat.name;
      }
    }

    state = state.copyWith(categoryOptions: filtered);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setCategory(String categoryName) {
    state = state.copyWith(selectedCategory: categoryName);
  }

  void setGoal(String? goalId) {
    state = state.copyWith(selectedGoalId: goalId);
  }

  void setPayer(String? payerId) {
    state = state.copyWith(selectedPayer: payerId);
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 80,
      );
      if (image != null) {
        state = state.copyWith(selectedImage: image);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: "Error al seleccionar imagen: $e");
    }
  }

  void removeImage() {
    // Recrear state para forzar null en selectedImage
    state = MovementFormState(
      isLoading: state.isLoading,
      isLoadingMembers: state.isLoadingMembers,
      errorMessage: state.errorMessage,
      selectedDate: state.selectedDate,
      transactionType: state.transactionType,
      categoryOptions: state.categoryOptions,
      selectedCategory: state.selectedCategory,
      userGroupsOptions: state.userGroupsOptions,
      selectedGroupId: state.selectedGroupId,
      memberOptions: state.memberOptions,
      selectedPayer: state.selectedPayer,
      goalOptions: state.goalOptions,
      selectedGoalId: state.selectedGoalId,
      selectedImage: null,
    );
  }

  Future<bool> submitData({
    required String amountStr,
    required String description,
    required String userId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final amount = double.tryParse(
        amountStr.replaceAll(RegExp(r'[^\d]'), ''),
      );
      if (amount == null || amount <= 0) throw "Monto inválido";

      if (state.selectedCategory == null) throw "Selecciona una categoría";

      final groupId = state.selectedGroupId;
      if (groupId == null) throw "Grupo no seleccionado";

      String? imageUrl;
      if (state.selectedImage != null) {
        final ext = state.selectedImage!.name.split('.').last;
        final fileName = '${const Uuid().v4()}.$ext';
        final ref = FirebaseStorage.instance
            .ref()
            .child('receipts')
            .child(groupId)
            .child(fileName);

        if (kIsWeb) {
          final bytes = await state.selectedImage!.readAsBytes();
          await ref.putData(bytes, SettableMetadata(contentType: 'image/$ext'));
        } else {
          await ref.putFile(File(state.selectedImage!.path));
        }

        imageUrl = await ref.getDownloadURL();
      }

      final newMovement = Movement(
        id: const Uuid().v4(),
        name: description.isEmpty ? state.selectedCategory! : description,
        amount: amount,
        category: state.selectedCategory!,
        type: state.transactionType,
        adminId: state.selectedPayer ?? userId,
        goalId: state.selectedGoalId,
        imageUrl: imageUrl,
        createdAt: state.selectedDate,
      );

      await MovementService().addMovement(
        groupId: groupId,
        movement: newMovement,
      );

      await ref.read(groupProvider.notifier).loadGroup(groupId);

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void loadMembers() {
    // Managed in changeSelectedGroup
  }
}

final movementProvider =
    StateNotifierProvider<MovementController, MovementFormState>((ref) {
      return MovementController(ref);
    });
