class Group {
  final String id;
  final String name;
  final String purpose;
  final double goalAmount;
  final DateTime? deadline;
  final double currentAmount;

  final String admin;
  final List<String> members;
  final List<String> subAdmins;

  final DateTime createdAt;
  final DateTime? updatedAt;

  final String code;

  Group({
    this.id = '',
    required this.name,
    required this.purpose,
    required this.goalAmount,
    this.deadline,
    required this.currentAmount,
    required this.admin,
    required this.members,
    this.subAdmins = const [],
    DateTime? createdAt,
    this.updatedAt,
    this.code = '',
  }) : createdAt = createdAt ?? DateTime.now();

  // --- Métodos útiles ---
  bool get isGoalReached => currentAmount >= goalAmount;

  double get progressPercent => (currentAmount / goalAmount).clamp(0, 1);

  void addMember(String userId) {
    if (!members.contains(userId)) {
      members.add(userId);
    }
  }

  void removeMember(String userId) {
    members.remove(userId);
  }

  void addSubAdmin(String userId) {
    if (!subAdmins.contains(userId)) {
      subAdmins.add(userId);
    }
  }

  void removeSubAdmin(String userId) {
    subAdmins.remove(userId);
  }

  // --- Serialización para Firebase / APIs ---
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      purpose: map['purpose'] ?? '',
      goalAmount: (map['goalAmount'] ?? 0).toDouble(),
      deadline: map['deadline'] != null && map['deadline'] != ""
          ? DateTime.parse(map['deadline'])
          : null,
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      admin: map['admin'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      subAdmins: List<String>.from(map['subAdmins'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
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
      'deadline': deadline != null ? deadline!.toIso8601String() : "",
      'currentAmount': currentAmount,
      'admin': admin,
      'members': members,
      'subAdmins': subAdmins,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'code': code,
    };
  }
}
