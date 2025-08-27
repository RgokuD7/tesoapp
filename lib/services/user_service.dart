import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserService {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> updateUser(User user) async {
    await _userCollection.doc(user.id).set(user.toMap());
  }

  Future<User?> getUser(String id) async {
    DocumentSnapshot doc = await _userCollection.doc(id).get();
    if (doc.exists) {
      return User.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null; 
  }
}