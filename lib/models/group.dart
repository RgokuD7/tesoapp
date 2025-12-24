import 'package:cloud_firestore/cloud_firestore.dart';
import 'goal.dart';
import 'category.dart'; // Importar el nuevo modelo

class Group {
  final String id;
  final String name;

  // CAMPOS LEGACY (Se mantendrán para no romper compatibilidad inmediata,
  // pero la lógica debería migrar a usar 'goals')
  final String purpose;
  final double goalAmount;
  final DateTime? deadline;
  final double currentAmount; // Suma total de todas las metas o saldo general

  // NUEVO: Lista de metas
  final List<Goal> goals;

  final String admin;
  final List<String> members;
  final List<String> subAdmins;

  // LEGACY: Lista de strings
  final List<String> categories;
  // NUEVO: Lista de objetos Categoría
  final List<Category> categoriesList;

  final DateTime createdAt;
  final DateTime? updatedAt;

  final String code;

  Group({
    this.id = '',
    required this.name,
    this.purpose = '',
    this.goalAmount = 0.0,
    this.deadline,
    this.currentAmount = 0.0,
    this.goals = const [],
    required this.admin,
    required this.members,
    this.subAdmins = const [],
    this.categories =
        const [], // Se mantiene vacía por defecto si usamos la nueva
    List<Category>? categoriesList,
    DateTime? createdAt,
    this.updatedAt,
    this.code = '',
  }) : categoriesList =
           categoriesList ??
           [
             // Categorías por Defecto Inteligentes
             Category(id: 'c1', name: 'Cuota', type: CategoryType.income),
             Category(id: 'c2', name: 'Rifa', type: CategoryType.both),
             Category(id: 'c3', name: 'Evento', type: CategoryType.both),
             Category(
               id: 'c4',
               name: 'Compra/Gasto',
               type: CategoryType.expense,
             ),
             Category(id: 'c5', name: 'Varios', type: CategoryType.both),
           ],
       createdAt = createdAt ?? DateTime.now();

  // --- Métodos útiles ---
  bool get isGoalReached => currentAmount >= goalAmount;

  // El progreso total podría ser el promedio de las metas o basado en el general
  double get progressPercent {
    if (goalAmount <= 0) return 0.0;
    final percent = (currentAmount / goalAmount).clamp(0, 1);
    return double.parse(percent.toStringAsFixed(3));
  }

  // --- CopyWith para inmutabilidad ---
  Group copyWith({
    String? id,
    String? name,
    String? purpose,
    double? goalAmount,
    DateTime? deadline,
    double? currentAmount,
    List<Goal>? goals,
    String? admin,
    List<String>? members,
    List<String>? subAdmins,
    List<String>? categories,
    List<Category>? categoriesList,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? code,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      goalAmount: goalAmount ?? this.goalAmount,
      deadline: deadline ?? this.deadline,
      currentAmount: currentAmount ?? this.currentAmount,
      goals: goals ?? List<Goal>.from(this.goals),
      admin: admin ?? this.admin,
      members: members ?? List<String>.from(this.members),
      subAdmins: subAdmins ?? List<String>.from(this.subAdmins),
      categories: categories ?? List<String>.from(this.categories),
      categoriesList:
          categoriesList ?? List<Category>.from(this.categoriesList),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      code: code ?? this.code,
    );
  }

  // --- Serialización ---
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      purpose: map['purpose'] ?? '',
      goalAmount: (map['goalAmount'] ?? 0).toDouble(),
      deadline: map['deadline'] != null && map['deadline'] != ""
          ? (map['deadline'] as Timestamp).toDate()
          : null,
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      goals: map['goals'] != null
          ? (map['goals'] as List).map((x) => Goal.fromMap(x)).toList()
          : [],
      admin: map['admin'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      subAdmins: List<String>.from(map['subAdmins'] ?? []),
      categories: List<String>.from(map['categories'] ?? []),
      categoriesList: map['categoriesList'] != null
          ? (map['categoriesList'] as List)
                .map((x) => Category.fromMap(x))
                .toList()
          : null, // Si es null, el constructor usará los defaults
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      code: map['code'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'purpose': purpose,
      'goalAmount': goalAmount,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'currentAmount': currentAmount,
      'goals': goals.map((x) => x.toMap()).toList(),
      'admin': admin,
      'members': members,
      'subAdmins': subAdmins,
      'categories': categories,
      'categoriesList': categoriesList.map((x) => x.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'code': code,
    };
  }
}
