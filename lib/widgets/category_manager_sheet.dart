import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group.dart';
import '../models/category.dart';
import '../services/group_service.dart';
import '../providers/group_provider.dart';

class CategoryManagerSheet extends ConsumerStatefulWidget {
  final Group group;

  const CategoryManagerSheet({super.key, required this.group});

  @override
  ConsumerState<CategoryManagerSheet> createState() =>
      _CategoryManagerSheetState();
}

class _CategoryManagerSheetState extends ConsumerState<CategoryManagerSheet> {
  late List<Category> _categories;
  final TextEditingController _nameController = TextEditingController();
  CategoryType _newCategoryType = CategoryType.expense;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.group.categoriesList);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- Lógica de Persistencia Automática ---
  Future<void> _persistChanges() async {
    // No bloqueamos la UI completamente, solo indicamos carga si es necesario
    setState(() => _isUpdating = true);
    try {
      final updatedGroup = widget.group.copyWith(categoriesList: _categories);
      await GroupService().updateGroup(updatedGroup);

      // Actualizamos el provider para reflejar cambios en la app inmediatamente
      ref.read(groupProvider.notifier).loadGroup(updatedGroup.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _addCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final newId = DateTime.now().millisecondsSinceEpoch.toString();

    // 1. Actualización Optimista Local
    setState(() {
      _categories.add(Category(id: newId, name: name, type: _newCategoryType));
      _nameController.clear();
      // Reset opcional, o mantener el último
      // _newCategoryType = CategoryType.expense;
    });

    // 2. Persistir
    await _persistChanges();
  }

  void _removeCategory(Category cat) async {
    setState(() {
      _categories.remove(cat);
    });
    await _persistChanges();
  }

  void _updateCategoryType(Category cat, CategoryType newType) async {
    if (cat.type == newType) return; // No hacer nada si es igual

    setState(() {
      final index = _categories.indexOf(cat);
      if (index != -1) {
        _categories[index] = Category(
          id: cat.id,
          name: cat.name,
          type: newType,
          icon: cat.icon,
        );
      }
    });
    await _persistChanges();
  }

  // --- UI Helpers ---

  Widget _buildTypeSelector(
    CategoryType currentType,
    Function(CategoryType) onSelect,
  ) {
    final isIncomeActive =
        currentType == CategoryType.income || currentType == CategoryType.both;
    final isExpenseActive =
        currentType == CategoryType.expense || currentType == CategoryType.both;

    void toggleIncome() {
      if (isIncomeActive) {
        if (isExpenseActive) onSelect(CategoryType.expense);
      } else {
        if (isExpenseActive)
          onSelect(CategoryType.both);
        else
          onSelect(CategoryType.income);
      }
    }

    void toggleExpense() {
      if (isExpenseActive) {
        if (isIncomeActive) onSelect(CategoryType.income);
      } else {
        if (isIncomeActive)
          onSelect(CategoryType.both);
        else
          onSelect(CategoryType.expense);
      }
    }

    Widget buildIconBtn(
      bool isActive,
      IconData icon,
      Color activeColor,
      VoidCallback onTap,
    ) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10), // Bordes suaves
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? Colors.white : Colors.grey.shade400,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildIconBtn(
          isIncomeActive,
          Icons.arrow_downward_rounded,
          const Color.fromRGBO(16, 185, 129, 1),
          toggleIncome,
        ),
        const SizedBox(width: 12),
        buildIconBtn(
          isExpenseActive,
          Icons.arrow_upward_rounded,
          const Color.fromRGBO(239, 68, 68, 1),
          toggleExpense,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Editar Categorías",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (_isUpdating)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.black54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24), // Espacio limpio sin linea
          // Lista de Categorías
          Flexible(
            child: _categories.isEmpty
                ? const Center(
                    child: Text(
                      "No hay categorías",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      return Row(
                        children: [
                          // Nombre editable? Por ahora solo display, la edición es compleja inline.
                          Expanded(
                            child: Text(
                              cat.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          // Selector Tipo
                          _buildTypeSelector(
                            cat.type,
                            (newType) => _updateCategoryType(cat, newType),
                          ),
                          const SizedBox(width: 16),
                          // Borrar
                          InkWell(
                            onTap: () => _removeCategory(cat),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 16),

          // --- Sección Agregar Nueva ---
          const Text(
            "Nueva Categoría",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Input
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "Nombre...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      isDense: false, // Centrado vertical mejor
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Selector
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _buildTypeSelector(
                    _newCategoryType,
                    (newType) => setState(() => _newCategoryType = newType),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Botón Agregar Full Width
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _addCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(37, 99, 235, 1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Agregar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
