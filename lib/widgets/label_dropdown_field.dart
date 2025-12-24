import 'package:flutter/material.dart';

class LabeledDropdownField extends StatelessWidget {
  final String fieldKey;
  final String label;
  final String hint;
  final Map<String, String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final Map<String?, String?> errors;
  final Icon? icon;

  const LabeledDropdownField({
    super.key,
    required this.fieldKey,
    required this.label,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.errors = const {},
    this.icon,
  });

  bool get _hasErrors =>
      errors.containsKey(fieldKey) || errors.containsKey("all");

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color.fromRGBO(55, 65, 81, 1),
            ),
          ),
          const SizedBox(height: 4),

          // Dropdown estilizado
          DropdownButtonFormField<String>(
            initialValue: value,
            items: items.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            decoration: InputDecoration(
              prefixIcon: icon,
              prefixIconColor: const Color.fromRGBO(100, 116, 139, 1),
              filled: true,
              fillColor: _hasErrors
                  ? const Color.fromRGBO(254, 242, 242, 1)
                  : Colors.white,
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color.fromRGBO(148, 163, 184, 1),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                  width: 1.5,
                  color: _hasErrors
                      ? const Color.fromRGBO(239, 68, 68, 1)
                      : const Color.fromRGBO(209, 213, 219, 1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                  width: 1.5,
                  color: _hasErrors
                      ? const Color.fromRGBO(239, 68, 68, 1)
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
