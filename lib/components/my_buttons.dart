import 'package:flutter/material.dart';

class MyButtons extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color buttonColor;
  final Color textColor;

  const MyButtons({
    super.key,
    required this.text,
    required this.onPressed,
    this.buttonColor = Colors.white,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 18.0,
        ),
      ),
    );
  }
}
