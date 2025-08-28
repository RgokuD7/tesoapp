// lib/state/group_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/group_service.dart';
import '../models/group.dart';

final groupProvider = StateNotifierProvider<GroupNotifier, Group?>(
  (ref) => GroupNotifier(),
);

class GroupNotifier extends StateNotifier<Group?> {
  final GroupService _groupService = GroupService();

  GroupNotifier() : super(null);

  // Cargar un grupo por ID
  Future<void> loadGroup(String id) async {
    state = await _groupService.getGroup(id);
  }

  // Crear un grupo
  Future<Group> createGroup(Group group) async {
    final createdGroup = await _groupService.createGroup(group);
    state = createdGroup; 
    return createdGroup; 
  }

  // Actualizar grupo
  Future<void> updateGroup(Group group) async {
    await _groupService.updateGroup(group);
    state = group;
  }

  // Eliminar grupo
  Future<void> deleteGroup(String id) async {
    await _groupService.deleteGroup(id);
    state = null;
  }
}
