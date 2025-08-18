import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String message;
  final String title;
  final String typeOfDialog; // 'error', 'success', 'caution'

  const CustomAlertDialog({
    super.key,
    required this.message,
    this.title = '¡Alerta!',
    this.typeOfDialog = 'error',
  });

  // Método para obtener icono y color según el tipo de alerta
  Map<String, dynamic> _getIconAndColor() {
    switch (typeOfDialog) {
      case 'success':
        return {'icon': Icons.check_circle, 'color': Colors.green};
      case 'caution':
        return {'icon': Icons.warning, 'color': Colors.orange};
      case 'error':
      default:
        return {'icon': Icons.error, 'color': Colors.red};
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconAndColor()['icon'] as IconData;
    final iconColor = _getIconAndColor()['color'] as Color;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado con icono + título
          Row(
            children: [
              Icon(iconData, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mensaje centrado
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          // Botón con color de relleno
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Aceptar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
