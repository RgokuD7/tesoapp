import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/group_provider.dart';
import '../../services/movement_service.dart';
import '../../models/movement.dart';
import '../../models/group.dart';
import '../../utils/formatters.dart';

class GraphsPage extends ConsumerStatefulWidget {
  const GraphsPage({super.key});

  @override
  ConsumerState<GraphsPage> createState() => _GraphsPageState();
}

class _GraphsPageState extends ConsumerState<GraphsPage> {
  late DateTimeRange _selectedRange;
  String _filterType = 'Mes'; // 'Mes', 'Año', 'Personalizado'

  @override
  void initState() {
    super.initState();
    _setMonthRange();
  }

  void _setMonthRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(
      now.year,
      now.month + 1,
      0,
      23,
      59,
      59,
    ); // Último día del mes
    setState(() {
      _selectedRange = DateTimeRange(start: start, end: end);
      _filterType = 'Mes';
    });
  }

  void _setYearRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31, 23, 59, 59);
    setState(() {
      _selectedRange = DateTimeRange(start: start, end: end);
      _filterType = 'Año';
    });
  }

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedRange,
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF2563EB),
            colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Ajustar fin del día para el rango final
        _selectedRange = DateTimeRange(
          start: picked.start,
          end: DateTime(
            picked.end.year,
            picked.end.month,
            picked.end.day,
            23,
            59,
            59,
          ),
        );
        _filterType = 'Personalizado';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider);

    if (group == null) return const Center(child: CircularProgressIndicator());

    // Texto descriptivo del rango
    String rangeLabel;
    if (_filterType == 'Mes') {
      rangeLabel =
          toBeginningOfSentenceCase(
            DateFormat('MMMM y', 'es_ES').format(_selectedRange.start),
          ) ??
          "";
    } else if (_filterType == 'Año') {
      rangeLabel = "Año ${_selectedRange.start.year}";
    } else {
      rangeLabel =
          "${DateFormat('d MMM', 'es_ES').format(_selectedRange.start)} - ${DateFormat('d MMM', 'es_ES').format(_selectedRange.end)}";
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Análisis y Gráficos",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),

              // 1. Selector de Filtros
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterTab(
                        label: "Mes",
                        isSelected: _filterType == 'Mes',
                        onTap: _setMonthRange,
                      ),
                    ),
                    Expanded(
                      child: _FilterTab(
                        label: "Año",
                        isSelected: _filterType == 'Año',
                        onTap: _setYearRange,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_month_rounded,
                        color: _filterType == 'Personalizado'
                            ? const Color(0xFF2563EB)
                            : Colors.grey,
                      ),
                      onPressed: _selectCustomRange,
                      tooltip: "Rango personalizado",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  rangeLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Data Stream
              StreamBuilder<List<Movement>>(
                stream: MovementService().listenMovements(group.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final allMoves = snapshot.data!;
                  final moves = _filterMovements(allMoves);

                  if (moves.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            Icon(
                              Icons.bar_chart_rounded,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No hay datos para este período",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Cálculos
                  double totalIncome = 0;
                  double totalExpense = 0;
                  final Map<String, Map<String, double>> categoryStats = {};

                  for (var m in moves) {
                    if (m.type == 'income') {
                      totalIncome += m.amount;
                    } else {
                      totalExpense += m.amount;
                    }

                    if (!categoryStats.containsKey(m.category)) {
                      categoryStats[m.category] = {'income': 0, 'expense': 0};
                    }
                    if (m.type == 'income') {
                      categoryStats[m.category]!['income'] =
                          (categoryStats[m.category]!['income'] ?? 0) +
                          m.amount;
                    } else {
                      categoryStats[m.category]!['expense'] =
                          (categoryStats[m.category]!['expense'] ?? 0) +
                          m.amount;
                    }
                  }

                  final netBalance = totalIncome - totalExpense;
                  final totalVolume = totalIncome + totalExpense;
                  final incomePercent = totalVolume > 0
                      ? (totalIncome / totalVolume * 100)
                      : 0.0;
                  final expensePercent = totalVolume > 0
                      ? (totalExpense / totalVolume * 100)
                      : 0.0;

                  return Column(
                    children: [
                      // Tarjeta Distribución General
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Distribución General",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF10B981),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              Formatters.currencyCLP(
                                                totalIncome,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Ingresos (${incomePercent.toStringAsFixed(1)}%)",
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFEF4444),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              Formatters.currencyCLP(
                                                totalExpense,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Gastos (${expensePercent.toStringAsFixed(1)}%)",
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            Divider(height: 1, color: Colors.grey.shade100),
                            const SizedBox(height: 24),

                            const Text(
                              "Balance neto",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.currencyCLP(netBalance),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: netBalance >= 0
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Tarjeta Ritmo Meta (Calculada en base a lo que FALTA vs TIEMPO RESTANTE, no depende del filtro de fecha histórico)
                      // NOTA: Esta tarjeta siempre proyecta a futuro, independientemente del filtro histórico que solo muestra el pasado.
                      // ¿Debería ocultarse si filtro histórico? No, es info útil siempre.
                      if (group.deadline != null && group.goalAmount > 0)
                        _GoalProjectionCard(group: group),

                      const SizedBox(height: 24),

                      // Tarjeta Categorías
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                "Ingresos vs Gastos por Categoría",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 32),

                            ...categoryStats.entries.map((entry) {
                              final catName = entry.key;
                              final income = entry.value['income'] ?? 0.0;
                              final expense = entry.value['expense'] ?? 0.0;

                              double maxVal = 0;
                              categoryStats.forEach((_, v) {
                                double localMax =
                                    (v['income'] ?? 0) > (v['expense'] ?? 0)
                                    ? (v['income'] ?? 0)
                                    : (v['expense'] ?? 0);
                                if (localMax > maxVal) maxVal = localMax;
                              });
                              if (maxVal == 0) maxVal = 1;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      catName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    if (income > 0)
                                      _CategoryBar(
                                        amount: income,
                                        maxAmount: maxVal,
                                        color: const Color(0xFF10B981),
                                      ),

                                    if (income > 0 && expense > 0)
                                      const SizedBox(height: 8),

                                    if (expense > 0)
                                      _CategoryBar(
                                        amount: expense,
                                        maxAmount: maxVal,
                                        color: const Color(0xFFEF4444),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Movement> _filterMovements(List<Movement> allMoves) {
    return allMoves.where((m) {
      return m.createdAt.isAfter(_selectedRange.start) &&
          m.createdAt.isBefore(_selectedRange.end);
    }).toList();
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final double amount;
  final double maxAmount;
  final Color color;

  const _CategoryBar({
    required this.amount,
    required this.maxAmount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Escalar visualmente, pero asegurando que se vea si es muy pequeño
    final double percentage = (amount / maxAmount).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final barSpace = maxWidth - 100; // Espacio para texto a la derecha
        final barWidth = barSpace * percentage;

        return Row(
          children: [
            Container(
              width: barWidth < 6 ? 6 : barWidth,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              Formatters.currencyCLP(amount),
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GoalProjectionCard extends StatelessWidget {
  final Group group;

  const _GoalProjectionCard({required this.group});

  @override
  Widget build(BuildContext context) {
    if (group.deadline == null || group.goalAmount <= 0)
      return const SizedBox.shrink();

    final now = DateTime.now();
    final deadline = group.deadline!;
    final daysRemaining = deadline.difference(now).inDays;

    if (daysRemaining <= 0) return const SizedBox.shrink();

    final remainingAmount = (group.goalAmount - group.currentAmount).clamp(
      0.0,
      double.infinity,
    );
    if (remainingAmount == 0) return const SizedBox.shrink();

    final dailyNeeded = remainingAmount / daysRemaining;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch_rounded, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              const Text(
                "Ritmo para la Meta",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Faltan por juntar",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.currencyCLP(remainingAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFFCBD5E1)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$daysRemaining días restantes",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "Deben juntar\n",
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                          TextSpan(
                            text: "${Formatters.currencyCLP(dailyNeeded)}/día",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
