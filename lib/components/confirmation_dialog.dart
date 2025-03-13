import 'package:budgetbuddy/components/my_buttons.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String titleText;
  final String confirmButtonText;
  final TextEditingController? controller;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.titleText = "",
    this.confirmButtonText = "Confirm",
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Confirmation"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titleText),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyButtons(
                  text: confirmButtonText,
                  onPressed: onConfirm,
                  buttonColor: Colors.green,
                  textColor: Colors.white,
                ),
                const SizedBox(width: 8),
                MyButtons(
                  text: "Cancel",
                  onPressed: onCancel,
                  buttonColor: Colors.red,
                  textColor: Colors.white,
                ),
              ],
            ),
          ],
        ));
  }
}
