import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/group.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'groups';

  // --- Obtener un grupo por ID ---
  Future<Group?> getGroup(String id) async {
    final doc = await _firestore.collection(collectionName).doc(id).get();
    if (doc.exists) {
      return Group.fromMap(doc.data()!);
    }
    return null;
  }

  // --- Crear un grupo ---
  Future<Group> createGroup(Group group) async {
    final docRef = _firestore.collection(collectionName).doc();
    final inviteCode = await generateUniqueInviteCode();
    final groupWithId = Group(
      id: docRef.id,
      name: group.name,
      purpose: group.purpose,
      goalAmount: group.goalAmount,
      deadline: group.deadline,
      currentAmount: group.currentAmount,
      admin: group.admin,
      members: group.members,
      subAdmins: group.subAdmins,
      createdAt: group.createdAt,
      updatedAt: group.updatedAt,
      code: inviteCode,
    );
    await docRef.set(groupWithId.toMap());
    return groupWithId;
  }

  // --- Actualizar un grupo ---
  Future<void> updateGroup(Group group) async {
    await _firestore
        .collection(collectionName)
        .doc(group.id)
        .update(group.toMap());
  }

  // --- Eliminar un grupo ---
  Future<void> deleteGroup(String id) async {
    await _firestore.collection(collectionName).doc(id).delete();
  }

  // --- Listar todos los grupos ---
  Future<List<Group>> getAllGroups() async {
    final snapshot = await _firestore.collection(collectionName).get();
    return snapshot.docs.map((doc) => Group.fromMap(doc.data())).toList();
  }

  // --- Listar grupos de un usuario ---
  Future<List<Group>> getGroupsForUser(String userId) async {
    final snapshot = await _firestore
        .collection(collectionName)
        .where('members', arrayContains: userId)
        .get();
    return snapshot.docs.map((doc) => Group.fromMap(doc.data())).toList();
  }

  // Generador de código aleatorio
  String _generateCode({int length = 8}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  // Generar un código único que no exista en Firestore
  Future<String> generateUniqueInviteCode({int length = 8}) async {
    String code;
    bool exists = true;

    do {
      code = _generateCode(length: length);

      final snapshot = await _firestore
          .collection('groups')
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();

      exists = snapshot.docs.isNotEmpty;
    } while (exists);

    return code;
  }
}
