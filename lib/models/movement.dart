import 'package:cloud_firestore/cloud_firestore.dart';

class Movement {
  final String id;
  final String name; // Ej: "Depósito", "Compra", "Retiro"
  final double amount;
  final String category;
  final String? imageUrl;
  final String type; // Ej: "income", "expense"
  final String adminId; // Quien realizó la acción
  final String? goalId; // ID de la meta asociada (opcional)
  final DateTime createdAt;

  Movement({
    this.id = '',
    required this.name,
    required this.amount,
    required this.category,
    this.imageUrl,
    required this.type,
    required this.adminId,
    this.goalId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // --- CopyWith para inmutabilidad ---
  Movement copyWith({
    String? id,
    String? name,
    double? amount,
    String? category,
    String? imageUrl,
    String? type,
    String? adminId,
    String? goalId,
    DateTime? createdAt,
  }) {
    return Movement(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      adminId: adminId ?? this.adminId,
      goalId: goalId ?? this.goalId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // --- Serialización ---
  factory Movement.fromMap(Map<String, dynamic> map) {
    return Movement(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      type: map['type'] ?? '',
      adminId: map['adminId'] ?? '',
      goalId: map['goalId'], // Puede ser null
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp)
                .toDate() // <- Aquí usamos Timestamp
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'imageUrl': imageUrl,
      'type': type,
      'adminId': adminId,
      'goalId': goalId,
      'createdAt': Timestamp.fromDate(createdAt), // <- Guardamos como Timestamp
    };
  }
}
