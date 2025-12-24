import 'package:intl/intl.dart';

class Formatters {
  // --- Moneda CLP ---
  static String currencyCLP(num value) {
    final formatter = NumberFormat.currency(
      locale: 'es_CL',
      name: 'CLP',
      symbol: '\$',
      decimalDigits: 0,
      customPattern: '¤#,##0',
    );
    return formatter.format(value);
  }

  static double currencyToDouble(String value) {
    if (value.isEmpty) return 0.0;
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  // --- Iniciales  ---
  static String initials(String firstName, String lastName) {
    final firstInitial = firstName.trim().isNotEmpty
        ? firstName.trim()[0].toUpperCase()
        : "";
    final lastInitial = lastName.trim().isNotEmpty
        ? lastName.trim()[0].toUpperCase()
        : "";
    return "$firstInitial$lastInitial";
  }

  // --- Primer nombre + primer apellido ---
  static String firstNameAndLastName(String firstName, String lastName) {
    final cleanFirst = firstName.trim().split(RegExp(r"\s+")).first;
    final cleanLast = lastName.trim().isNotEmpty
        ? lastName.trim().split(RegExp(r"\s+")).first
        : "";
    return "$cleanFirst $cleanLast".trim();
  }
}
