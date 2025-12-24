enum CategoryType {
  income, // Solo ingresos
  expense, // Solo gastos
  both, // Ambos (ej: Rifa, Evento)
}

class Category {
  final String id;
  final String name;
  final CategoryType type;
  final String icon; // Opcional, para UI futura

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.icon = '',
  });

  // --- Serialización ---
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name, // guardamos como string: 'income', 'expense', 'both'
      'icon': icon,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: CategoryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CategoryType.both, // Default safe
      ),
      icon: map['icon'] ?? '',
    );
  }
}
