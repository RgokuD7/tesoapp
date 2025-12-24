// lib/state/group_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../services/group_service.dart';
import '../models/group.dart';
import '../models/user.dart';

final groupProvider = StateNotifierProvider<GroupNotifier, Group?>((ref) {
  return GroupNotifier(ref);
});

class GroupNotifier extends StateNotifier<Group?> {
  final GroupService _groupService = GroupService();
  final Ref ref;

  GroupNotifier(this.ref) : super(null) {
    // Escucha cambios en el usuario y carga el primer grupo automáticamente
    ref.listen<User?>(userProvider, (previous, next) {
      if (next != null && next.groups.isNotEmpty) {
        loadGroup(next.groups.first);
      }
    });
  }

  Future<void> loadGroup(String groupId) async {
    final group = await _groupService.getGroup(groupId);
    state = group;
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

  // Obtener grupo por código
  Future<Group?> getGroupByCode(String code) async {
    state = await _groupService.getGroupByCode(code);
    return state;
  }

  // Agregar usuario a grupo
  Future<void> addUserToGroup(String groupId, String userId) async {
    await _groupService.addUserToGroup(groupId, userId);
    state = state?.copyWith(members: [...?state?.members, userId]);
  }

  // Eliminar usuario de grupo
  Future<void> removeUserFromGroup(String groupId, String userId) async {
    await _groupService.removeUserFromGroup(groupId, userId);
    state = state?.copyWith(
      members: state!.members.where((id) => id != userId).toList(),
    );
  }

  
}
