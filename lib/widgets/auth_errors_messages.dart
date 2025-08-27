import 'package:flutter/material.dart';

class AuthErrorMessages extends StatelessWidget {
  final String message;

  const AuthErrorMessages({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) {
      return SizedBox.shrink();
    } else {
      return Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color.fromRGBO(254, 242, 242, 1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color.fromRGBO(254, 202, 202, 1),
            width: 1.5,
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Color.fromRGBO(220, 38, 38, 1),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }
}
