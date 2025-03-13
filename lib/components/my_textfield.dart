import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final EdgeInsets padding;
  final int? maxLines;
  final bool hasBorder;
  final double borderWidth;

  const MyTextfield({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.labelText = "",
    this.maxLines = 1,
    this.hasBorder = false,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            border: hasBorder
                ? OutlineInputBorder(
              borderSide: BorderSide(
                width: borderWidth,
              ),
            )
                : null,
          ),
        ));
  }
}
