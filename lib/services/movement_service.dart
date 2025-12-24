import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movement.dart';

class MovementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String groupCollection = 'groups';
  final String movementCollection = 'movements';

  // --- Guardar un movimiento ---
  Future<Movement> addMovement({
    required String groupId,
    required Movement movement,
  }) async {
    final docRef = _firestore
        .collection(groupCollection)
        .doc(groupId)
        .collection(movementCollection)
        .doc();

    // Asignamos el ID generado al objeto
    final movementWithId = movement.copyWith(id: docRef.id);

    await docRef.set(movementWithId.toMap());
    return movementWithId;
  }

  // --- Obtener movimientos ---
  Future<List<Movement>> getMovements(String groupId) async {
    final snapshot = await _firestore
        .collection(groupCollection)
        .doc(groupId)
        .collection(movementCollection)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Movement.fromMap(doc.data())).toList();
  }

  // --- Editar un movimiento ---
  Future<void> updateMovement({
    required String groupId,
    required Movement movement,
  }) async {
    await _firestore
        .collection(groupCollection)
        .doc(groupId)
        .collection(movementCollection)
        .doc(movement.id)
        .update(movement.toMap());
  }

  // --- Eliminar ---
  Future<void> deleteMovement(String groupId, String movementId) async {
    await _firestore
        .collection(groupCollection)
        .doc(groupId)
        .collection(movementCollection)
        .doc(movementId)
        .delete();
  }

  // --- Escuchar en tiempo real ---
  Stream<List<Movement>> listenMovements(String groupId) {
    return _firestore
        .collection(groupCollection)
        .doc(groupId)
        .collection(movementCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Movement.fromMap(doc.data())).toList(),
        );
  }
}
