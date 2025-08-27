import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LabeledDateField extends StatefulWidget {
  final String fieldKey;
  final String label;
  final String hint;
  final TextEditingController controller;
  final Icon? icon;
  final String? Function(String?)? validator;
  final DateTime firstDate;
  final DateTime lastDate;
  final Map<String?, String?> errors;

  const LabeledDateField({
    super.key,
    required this.fieldKey,
    required this.label,
    required this.hint,
    required this.controller,
    this.icon,
    this.validator,
    required this.firstDate,
    required this.lastDate,
    this.errors = const {},
  });

  @override
  State<LabeledDateField> createState() => _LabeledDateFieldState();
}

class _LabeledDateFieldState extends State<LabeledDateField> {
  @override
  Widget build(BuildContext context) {
    final hasErrors =
        widget.errors.containsKey(widget.fieldKey) ||
        widget.errors.containsKey("all");
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color.fromRGBO(55, 65, 81, 1),
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            key: Key(widget.fieldKey),
            controller: widget.controller,
            validator: widget.validator,
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
              );
              if (pickedDate != null) {
                widget.controller.text = DateFormat(
                  'dd/MM/yyyy',
                ).format(pickedDate);
              }
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color.fromRGBO(148, 163, 184, 1),
              ),
              errorStyle: TextStyle(fontSize: 0),
              prefixIcon: widget.icon,
              prefixIconColor: Color.fromRGBO(100, 116, 139, 1),
              filled: true,
              fillColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.error) || hasErrors) {
                  return Color.fromRGBO(254, 242, 242, 1);
                }
                return Color.fromRGBO(243, 244, 246, 1);
              }),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                  width: 1.5,
                  color: hasErrors
                      ? Color.fromRGBO(239, 68, 68, 1)
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: const BorderSide(
                  width: 1.5,
                  color: Color.fromRGBO(239, 68, 68, 1),
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                  width: 1.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                  width: 1.5,
                  color: hasErrors
                      ? Color.fromRGBO(239, 68, 68, 1)
                      : Color.fromRGBO(209, 213, 219, 1),
                  style: BorderStyle.solid,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
