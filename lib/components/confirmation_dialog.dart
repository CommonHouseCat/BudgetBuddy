import '../config/localization/app_localizations.dart';
import 'my_buttons.dart';
import 'package:flutter/material.dart';

/*
* A custom dialog that displays a confirmation message and a confirm and cancel button.
* */
class ConfirmationDialog extends StatelessWidget {
  final String titleText; // Optional dialog's title.
  final String confirmButtonText; // Optional confirm button Text.
  final VoidCallback onConfirm; // Callback function for confirm button
  final VoidCallback onCancel; // Callback function for cancel button

  const ConfirmationDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.titleText = "",
    this.confirmButtonText = "Confirm",
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      title: Text(localizations.translate('confirmation')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(titleText),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Confirm button
              MyButtons(
                text: localizations.translate('confirm'),
                onPressed: onConfirm,
                buttonColor: Colors.green,
                textColor: Colors.white,
              ),

              const SizedBox(width: 8),

              // Cancel button
              MyButtons(
                text: localizations.translate('cancel'),
                onPressed: onCancel,
                buttonColor: Colors.red,
                textColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
