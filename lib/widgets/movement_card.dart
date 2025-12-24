import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/movement.dart';

class MovementCard extends StatelessWidget {
  final Movement movement;
  final String payerName; // Nombre de quien pagó (Ej: "Carlos Méndez")
  final VoidCallback? onDelete;
  final VoidCallback? onViewReceipt;

  const MovementCard({
    super.key,
    required this.movement,
    required this.payerName,
    this.onDelete,
    this.onViewReceipt,
  });

  @override
  Widget build(BuildContext context) {
    // Colores base
    final isIncome = movement.type == 'income';
    final mainColor = isIncome
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444); // Verde / Rojo
    final lightColor = mainColor.withOpacity(0.1);

    // Formateadores
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('d/M/yyyy');

    // Iniciales para el Avatar
    String initials = payerName.isNotEmpty
        ? payerName
              .trim()
              .split(' ')
              .take(2)
              .map((e) => e.isNotEmpty ? e[0] : '')
              .join()
              .toUpperCase()
        : "?";
    if (initials.isEmpty) initials = "?";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // FILA SUPERIOR: Icono | Categoría+Fecha | Monto
          Row(
            children: [
              // Icono Categoría
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50, // Fondo muy sutil o el lightColor
                  // En la imagen parece gris muy claro o blanco con icono coloreado
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Container(
                    width: 36, // Círculo interno
                    height: 36,
                    decoration: BoxDecoration(
                      color: lightColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isIncome
                          ? Icons.arrow_outward_rounded
                          : Icons.call_received_rounded,
                      color: mainColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Título y Fecha
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movement.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(movement.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Monto
              Text(
                "${isIncome ? '+' : '-'}${currencyFormat.format(movement.amount)}",
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // FILA INFERIOR: Avatar | Detalles | Botones
          Row(
            children: [
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isIncome
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444), // Color sólido igual al tipo
                  // En la imagen parece usar el color principal para el fondo del avatar
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nombre y Descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF334155),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (movement.name.isNotEmpty &&
                        movement.name != movement.category)
                      Text(
                        movement.name,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Botones de Acción
              Row(
                children: [
                  if (movement.imageUrl != null &&
                      movement.imageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _ActionButton(
                        icon: Icons.credit_card_rounded, // Icono tarjeta/recibo
                        bgColor: const Color(0xFFEFF6FF), // Azul muy claro
                        iconColor: const Color(0xFF3B82F6), // Azul
                        onTap: onViewReceipt,
                      ),
                    ),
                  if (onDelete != null)
                    _ActionButton(
                      icon: Icons.delete_outline_rounded,
                      bgColor: const Color(0xFFFEF2F2), // Rojo muy claro
                      iconColor: const Color(0xFFEF4444), // Rojo
                      onTap: onDelete,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}
