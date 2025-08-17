import 'package:flutter/material.dart';

class LabeledTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Icon? icon;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool autofocus;
  final bool? isPassword;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.validator,
    this.maxLines = 1,
    this.autofocus = false,
    this.isPassword = false,
  });

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late bool _obscureText; // control interno para el ojo 👁️

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword == true ? true : false; // inicializamos
  }

  @override
  Widget build(BuildContext context) {
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
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: _obscureText,
            validator: widget.validator,
            maxLines: widget.maxLines,
            autofocus: widget.autofocus,
            decoration: InputDecoration(
              prefixIcon: widget.icon,
              prefixIconColor: WidgetStateColor.fromMap({
                WidgetState.focused: Theme.of(context).colorScheme.primary,
                WidgetState.any: const Color.fromRGBO(100, 116, 139, 1),
                WidgetState.disabled: Colors.grey,
                WidgetState.error: Colors.red,
              }),
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
                        splashColor: Colors.transparent, // quita el splash
                        highlightColor:
                            Colors.transparent, // quita el efecto al presionar
                        hoverColor:
                            Colors.transparent, // opcional, para web/desktop
                      ),
                    )
                  : null,
              suffixIconColor: WidgetStateColor.fromMap({
                WidgetState.focused: _obscureText == true
                    ? Theme.of(context).colorScheme.primary
                    : Colors.orange,
                WidgetState.any: const Color.fromRGBO(100, 116, 139, 1),
                WidgetState.disabled: Colors.grey,
                WidgetState.error: Colors.red,
              }),
              filled: true,
              fillColor: Colors.grey.shade100,
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color.fromRGBO(148, 163, 184, 1),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                  width: 1,
                  color: Color.fromRGBO(203, 213, 225, 1),
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
