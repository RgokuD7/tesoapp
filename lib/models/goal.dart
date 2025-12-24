import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String id;
  final String name; // Ej: "Gala", "Paseo"
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final bool isArchived; // Para ocultar metas antiguas

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    this.isArchived = false,
  });

  // Métodos útiles
  double get progressPercent {
    if (targetAmount <= 0) return 0.0;
    final percent = (currentAmount / targetAmount).clamp(0.0, 1.0);
    return percent;
  }

  bool get isReached => currentAmount >= targetAmount;

  // CopyWith
  Goal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    bool? isArchived,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  // Serialización
  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      deadline: map['deadline'] != null
          ? (map['deadline'] as Timestamp).toDate()
          : null,
      isArchived: map['isArchived'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'isArchived': isArchived,
    };
  }
}
