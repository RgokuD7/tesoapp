import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String memberId; // Usuario que paga
  final String memberName; // Para mostrar en la UI
  final double amount; // Monto de la cuota
  final String category;
  final String description; // "Cuota Julio 2025"
  final String imageUrl; // Comprobante de pago (captura subida)
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final DateTime? updatedAt;

  Payment({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.status,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp)
                .toDate() // <- Aquí usamos Timestamp
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'amount': amount,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
