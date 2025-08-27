import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LabeledTextField extends StatefulWidget {
  final String fieldKey;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Icon? icon;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool autofocus;
  final bool isPassword;
  final Map<String?, String?> errors;
  final Function(String)? onChanged;
  final bool isCurrency;

  const LabeledTextField({
    super.key,
    required this.fieldKey,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.validator,
    this.maxLines = 1,
    this.autofocus = false,
    this.isPassword = false,
    this.errors = const {},
    this.onChanged,
    this.isCurrency = false,
  });

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;

    // Si es currency, formateamos el valor inicial
    if (widget.isCurrency && widget.controller.text.isNotEmpty) {
      widget.controller.text = _formatCurrency(
        widget.controller.text.replaceAll(RegExp(r'[^0-9]'), ''),
      );
    }
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value);
    if (number == null) return '';
    final formatter = NumberFormat.currency(
      locale: 'es_CL',
      name: 'CLP',
      symbol: '\$',
      decimalDigits: 0,
      customPattern: '¤#,##0',
    );
    return formatter.format(number);
  }

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
            keyboardType: widget.isCurrency
                ? TextInputType.number
                : widget.keyboardType,
            obscureText: _obscureText,
            validator: widget.validator,
            maxLines: widget.maxLines,
            autofocus: widget.autofocus,
            onChanged: (val) {
              if (widget.isCurrency) {
                final newText = _formatCurrency(
                  val.replaceAll(RegExp(r'[^0-9]'), ''),
                );
                // mover el cursor al final
                widget.controller.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: newText.length),
                );
              }
              if (widget.onChanged != null) widget.onChanged!(val);
            },
            decoration: InputDecoration(
              errorStyle: const TextStyle(fontSize: 0),
              prefixIcon: widget.icon,
              prefixIconColor: const Color.fromRGBO(100, 116, 139, 1),
              suffixIcon: widget.isPassword == true
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    )
                  : null,
              suffixIconColor: const Color.fromRGBO(100, 116, 139, 1),
              filled: true,
              fillColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.error) || hasErrors) {
                  return const Color.fromRGBO(254, 242, 242, 1);
                }
                return const Color.fromRGBO(243, 244, 246, 1);
              }),
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color.fromRGBO(148, 163, 184, 1),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                  width: 1.5,
                  color: hasErrors
                      ? const Color.fromRGBO(239, 68, 68, 1)
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                  width: 1.5,
                  color: Color.fromRGBO(239, 68, 68, 1),
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                  width: 1.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                  width: 1.5,
                  color: hasErrors
                      ? const Color.fromRGBO(239, 68, 68, 1)
                      : const Color.fromRGBO(209, 213, 219, 1),
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
