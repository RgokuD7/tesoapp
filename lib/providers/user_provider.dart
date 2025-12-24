// lib/state/app_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../services/user_service.dart';
import '../models/user.dart';

final userProvider = StateNotifierProvider<UserNotifier, User?>(
  (ref) => UserNotifier(),
);

// This replaces your old AppState class
class UserNotifier extends StateNotifier<User?> {
  final UserService _userService = UserService();

  UserNotifier() : super(null) {
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    final currentUser = fb.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await loadUser(currentUser.uid);
    }
  }

  Future<void> loadUser(String id) async {
    state = await _userService.getUser(id);
  }

  Future<User?> getUser(String id) async {
    return await _userService.getUser(id);
  }

  Future<void> updateUser(User user) async {
    await _userService.updateUser(user);
    state = user;
  }

  Future<void> createUser(User user) async {
    await _userService.createUser(user);
    state = user;
  }

  Future<void> addGroup(String groupId) async {
    if (state == null) return;
    final updatedGroups = [...state!.groups, groupId];
    await _userService.addGroupToUser(state!.id, groupId);
    state = state!.copyWith(groups: updatedGroups);
  }

  Future<void> removeGroup(String groupId) async {
    if (state == null) return;
    final updatedGroups = state!.groups.where((id) => id != groupId).toList();
    await _userService.removeGroupFromUser(state!.id, groupId);
    state = state!.copyWith(groups: updatedGroups);
  }
}
