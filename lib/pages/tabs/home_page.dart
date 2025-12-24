import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/user_provider.dart';
import '../../providers/group_provider.dart';
import '../../services/movement_service.dart';
import '../../models/movement.dart';
import '../../models/user.dart';
import '../../utils/date_utils.dart';
import '../../utils/formatters.dart';

// Provider reactivo para obtener el admin del grupo actual
final groupAdminProvider = FutureProvider.autoDispose<User?>((ref) async {
  final group = ref.watch(groupProvider);
  if (group == null) return null;

  // Usamos read del notifier para hacer el fetch
  final userNotifier = ref.read(userProvider.notifier);
  return await userNotifier.getUser(group.admin);
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final group = ref.watch(groupProvider);
    final adminAsync = ref.watch(groupAdminProvider);
    final admin = adminAsync.valueOrNull;

    if (group == null) return const Center(child: CircularProgressIndicator());

    // Cálculos
    final currentAmount = group.currentAmount;
    final goalAmount = group.goalAmount;
    final progress = goalAmount > 0
        ? (currentAmount / goalAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining = (goalAmount - currentAmount).clamp(0, double.infinity);

    // Formato Fecha Header (Ej: "Martes, 23 De Diciembre De 2025")
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM y', 'es_ES').format(now);
    // Capitalizar primera letra de cada palabra aprox
    final capitalizedDate = toBeginningOfSentenceCase(dateStr) ?? dateStr;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Saludo
          Text(
            "¡Hola, ${user?.firstName ?? 'Usuario'}! 👋",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            capitalizedDate, // "Martes, 23 Diciembre 2025"
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 24),

          // 2. Resumen Financiero (Dashboard Card)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Resumen Financiero",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Icon(Icons.refresh, size: 20, color: Colors.grey.shade400),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Columna Saldo Actual
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFDBEAFE), // Azul claro
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.show_chart_rounded,
                              color: Color(0xFF3B82F6),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Saldo Actual",
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.currencyCLP(currentAmount),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Columna Meta
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFDCFCE7), // Verde claro
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.ads_click_rounded,
                              color: Color(0xFF10B981),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Meta",
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.currencyCLP(goalAmount),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Barra de Progreso
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF10B981),
                    ), // Verde
                  ),
                ),

                const SizedBox(height: 12),

                // Footer Progreso
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}% completado",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      "Faltan ${Formatters.currencyCLP(remaining)}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Sección Inferior con Data de Movimientos (Actividad, Admin, Totales)
          StreamBuilder<List<Movement>>(
            stream: MovementService().listenMovements(group.id),
            builder: (context, snapshot) {
              final moves = snapshot.data ?? [];

              // Cálculos para Totales
              double totalIncome = 0;
              double totalExpense = 0;
              int incomeCount = 0;
              int expenseCount = 0;

              // Ordenar por fecha descendente
              moves.sort((a, b) => b.createdAt.compareTo(a.createdAt));

              for (var m in moves) {
                if (m.type == 'income') {
                  totalIncome += m.amount;
                  incomeCount++;
                } else {
                  totalExpense += m.amount;
                  expenseCount++;
                }
              }

              final recentMoves = moves.take(3).toList();

              return Column(
                children: [
                  // CARD LISTA DE ACTIVIDAD
                  Container(
                    padding: const EdgeInsets.all(20),
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
                        // Header dentro de la card
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Actividad Reciente",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            InkWell(
                              onTap:
                                  () {}, // Navegación placeholder para Historial
                              child: const Text(
                                "Ver todo",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B82F6),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (recentMoves.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "Sin movimientos aún",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ...recentMoves.asMap().entries.map((entry) {
                            final index = entry.key;
                            final m = entry.value;
                            final payerName = m.adminId == group.admin
                                ? "Admin"
                                : "Miembro";

                            return Column(
                              children: [
                                _MovementItem(
                                  movement: m,
                                  payerName: payerName,
                                ),
                                if (index < recentMoves.length - 1)
                                  Divider(
                                    height: 24,
                                    color: Colors.grey.shade100,
                                    indent: 60,
                                  ), // Separador
                              ],
                            );
                          }).toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CARD ADMINISTRADOR (Diseño exacto imagen)
                  if (admin != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                          const Text(
                            "Administrador del Grupo",
                            style: TextStyle(
                              fontSize:
                                  16, // Un poco más grande como título de sección
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(
                                  0xFF2563EB,
                                ), // Azul fuerte
                                child: Text(
                                  Formatters.initials(
                                    admin?.firstName ?? "",
                                    admin?.lastName ?? "",
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${Formatters.firstNameAndLastName(admin?.firstName ?? "", admin?.lastName ?? "")}${user?.id == admin?.id ? ' (Tú)' : ''}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // TODO: Hora real dinámica si se desea
                                        const Expanded(
                                          child: Text(
                                            "Última actualización: hace 2 horas",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF64748B),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // CARDS TOTALES (Ingresos vs Gastos)
                  Row(
                    children: [
                      // Ingresos
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
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
                                "Ingresos",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "+${Formatters.currencyCLP(totalIncome)}",
                                style: const TextStyle(
                                  color: Color(0xFF10B981), // Verde
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$incomeCount movimientos",
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Gastos
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
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
                                "Gastos",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "-${Formatters.currencyCLP(totalExpense)}",
                                style: const TextStyle(
                                  color: Color(0xFFEF4444), // Rojo
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$expenseCount movimientos",
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 90), // Espacio extra para FABs
        ],
      ),
    );
  }
}

// Widget compacto para la lista de dashboard
class _MovementItem extends StatelessWidget {
  final Movement movement;
  final String payerName;

  const _MovementItem({required this.movement, required this.payerName});

  @override
  Widget build(BuildContext context) {
    final isIncome = movement.type == 'income';
    final color = isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Icono
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1), // Fondo suave
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_outward_rounded
                  : Icons.call_received_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  payerName, // "Carlos Méndez"
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8), // Slate 400
                  ),
                ),
              ],
            ),
          ),

          // Monto
          Text(
            "${isIncome ? '+' : '-'}${Formatters.currencyCLP(movement.amount)}",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
