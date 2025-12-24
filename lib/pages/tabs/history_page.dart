import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/movement.dart';
import '../../services/movement_service.dart';
import '../../providers/group_provider.dart';
import '../../widgets/movement_card.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  // Estado local de filtros
  String _filterType = 'all'; // 'all', 'income', 'expense'
  DateTimeRange? _dateRange;

  void _pickDateRange() async {
    final now = DateTime.now();
    final newRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateRange,
      saveText: "FILTRAR",
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              clipBehavior: Clip.hardEdge,
              child: Theme(
                data: ThemeData.light().copyWith(
                  primaryColor: const Color.fromRGBO(37, 99, 235, 1),
                  colorScheme: const ColorScheme.light(
                    primary: Color.fromRGBO(37, 99, 235, 1),
                  ),
                ),
                child: child!,
              ),
            ),
          ),
        );
      },
    );

    if (newRange != null) {
      setState(() => _dateRange = newRange);
    }
  }

  void _showReceipt(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
            IconButton.filled(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String groupId, String movementId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Eliminar movimiento?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await MovementService().deleteMovement(groupId, movementId);
            },
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider);

    if (group == null) {
      return const Center(child: Text("Selecciona un grupo primero"));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Mismo estilo que la imagen)
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20,
              ),
              child: const Text(
                "Historial de Movimientos",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B), // Slate 800
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // 2. Filtros (Estilo exacto "Píldora")
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterTab(
                    label: "Todo",
                    isActive: _filterType == 'all',
                    activeColor: const Color.fromRGBO(37, 99, 235, 1), // Azul
                    onTap: () => setState(() => _filterType = 'all'),
                  ),
                  const SizedBox(width: 10),

                  _FilterTab(
                    label: "Ingresos",
                    isActive: _filterType == 'income',
                    activeColor: const Color(0xFF10B981), // Verde
                    onTap: () => setState(() => _filterType = 'income'),
                  ),
                  const SizedBox(width: 10),

                  _FilterTab(
                    label: "Gastos",
                    isActive: _filterType == 'expense',
                    activeColor: const Color(0xFFEF4444), // Rojo
                    onTap: () => setState(() => _filterType = 'expense'),
                  ),
                  const SizedBox(width: 16),

                  // Separador vertical
                  Container(height: 24, width: 1, color: Colors.grey.shade300),
                  const SizedBox(width: 16),

                  // Selector Fecha (Diseño personalizado con Icono)
                  InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _dateRange == null
                            ? const Color(0xFFE2E8F0)
                            : const Color(0xFFE0E7FF), // Slate 200 vs Indigo 50
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _dateRange == null
                              ? Colors.transparent
                              : Colors.indigoAccent.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: _dateRange == null
                                ? const Color(0xFF475569)
                                : Colors.indigo,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _dateRange == null
                                ? "Cualquier fecha"
                                : "${DateFormat('d/M').format(_dateRange!.start)} - ${DateFormat('d/M').format(_dateRange!.end)}",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _dateRange == null
                                  ? const Color(0xFF475569)
                                  : Colors.indigo,
                            ),
                          ),
                          if (_dateRange != null) ...[
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => setState(() => _dateRange = null),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Lista
            Expanded(
              child: StreamBuilder<List<Movement>>(
                stream: MovementService().listenMovements(group.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final movements = snapshot.data ?? [];

                  // Filtrado
                  final filtered = movements.where((m) {
                    if (_filterType != 'all' && m.type != _filterType)
                      return false;
                    if (_dateRange != null) {
                      final mDate = DateTime(
                        m.createdAt.year,
                        m.createdAt.month,
                        m.createdAt.day,
                      );
                      final start = DateTime(
                        _dateRange!.start.year,
                        _dateRange!.start.month,
                        _dateRange!.start.day,
                      );
                      final end = DateTime(
                        _dateRange!.end.year,
                        _dateRange!.end.month,
                        _dateRange!.end.day,
                      );
                      if (mDate.isBefore(start) || mDate.isAfter(end))
                        return false;
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) return _EmptyState();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final mov = filtered[index];
                      // TODO: Nombre real
                      final payerName = mov.adminId == group.admin
                          ? "Admin"
                          : "Miembro";

                      return MovementCard(
                        movement: mov,
                        payerName: payerName,
                        onViewReceipt:
                            (mov.imageUrl != null && mov.imageUrl!.isNotEmpty)
                            ? () => _showReceipt(context, mov.imageUrl!)
                            : null,
                        onDelete: () =>
                            _confirmDelete(context, group.id, mov.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de Pestaña "Píldora"
class _FilterTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final bool allowInactiveGray; // Para controlar si usar gris al estar inactivo
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isActive,
    required this.activeColor,
    this.allowInactiveGray = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Si está activo -> activeColor
    // Si no -> Gris claro (Slate 200)

    final Color bgColor = isActive
        ? activeColor
        : const Color(0xFFE2E8F0); // Slate 200

    final Color txtColor = isActive
        ? Colors.white
        : const Color(0xFF475569); // Slate 600

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24), // Pill shape
        ),
        child: Text(
          label,
          style: TextStyle(
            color: txtColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history_edu_rounded, size: 60, color: Colors.black12),
          SizedBox(height: 16),
          Text("No hay movimientos", style: TextStyle(color: Colors.black38)),
        ],
      ),
    );
  }
}
