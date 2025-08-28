import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> getUser(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists) {
      return User.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> updateUser(User user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  Future<void> addGroupToUser(String userId, String groupId) async {
    final userRef = _firestore.collection('users').doc(userId);
    await userRef.update({
      'groups': FieldValue.arrayUnion([groupId]),
    });
  }

  Future<void> removeGroupFromUser(String userId, String groupId) async {
  final userDoc = _firestore.collection('users').doc(userId);

  await userDoc.update({
    'groups': FieldValue.arrayRemove([groupId]),
  });
}

}
