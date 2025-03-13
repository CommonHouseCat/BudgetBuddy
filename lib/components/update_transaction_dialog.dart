import 'package:logger/logger.dart';
import '../config/localization/app_localizations.dart';
import '../services/database_service.dart';
import 'my_buttons.dart';
import 'my_textfield.dart';
import 'package:flutter/material.dart';

class UpdateTransactionDialog extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final Function onUpdate;

  const UpdateTransactionDialog({
    super.key,
    required this.transaction,
    required this.onUpdate,
  });

  @override
  State<UpdateTransactionDialog> createState() =>
      _UpdateTransactionDialogState();
}

class _UpdateTransactionDialogState extends State<UpdateTransactionDialog> {
  late TextEditingController amountController;
  late TextEditingController noteController;
  late String selectedType;
  late String selectedTag;
  final logger = Logger();

  final List<String> tags = [
    'Food',
    'Transport',
    'Entertainment',
    'Bills',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    amountController =
        TextEditingController(text: widget.transaction['amount'].toString());
    noteController =
        TextEditingController(text: widget.transaction['description']);
    selectedType = widget.transaction['type'];
    selectedTag = widget.transaction['tag'];
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _onPressed() async {
    try {
      final localizations = AppLocalizations.of(context);
      double? newAmount = double.tryParse(amountController.text);
      if (newAmount == null || newAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.translate('InvalidAmount'))),
        );
        return;
      }

      await DatabaseService.instance.updateTransaction(
        widget.transaction['id'],
        newAmount,
        selectedType,
        noteController.text,
        selectedTag,
      );

      widget.onUpdate();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      logger.e('Error in _onPressed', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(
        localizations.translate('Update Transaction'),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.translate('Amount'),
                style: TextStyle(fontSize: 18),
              ),
              MyTextfield(
                hintText: localizations.translate('Enter Amount'),
                controller: amountController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Transaction Type Selection
              Text(
                localizations.translate('Type: '),
                style: TextStyle(fontSize: 18),
              ),
              Row(
                children: [
                  Radio(
                    value: 'expense',
                    groupValue: selectedType,
                    onChanged: (value) {
                      setState(() {
                        selectedType = value.toString();
                      });
                    },
                  ),
                  Text(
                    localizations.translate("Expense"),
                  ),
                  const SizedBox(width: 20),
                  Radio(
                    value: 'income',
                    groupValue: selectedType,
                    onChanged: (value) {
                      setState(() {
                        selectedType = value.toString();
                      });
                    },
                  ),
                  Text(localizations.translate("Income")),
                ],
              ),
              const SizedBox(height: 16),

              // Tag Selection
              Text(
                localizations.translate("Tag:"),
                style: TextStyle(fontSize: 18),
              ),
              DropdownButton<String>(
                value: selectedTag,
                isExpanded: true,
                items: tags.map((tag) {
                  return DropdownMenuItem<String>(
                    value: tag,
                    child: Text(tag),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedTag = value!);
                },
              ),
              const SizedBox(height: 16),

              // Note Input
              Text(
                localizations.translate("Note:"),
                style: TextStyle(fontSize: 18),
              ),
              MyTextfield(
                hintText: localizations.translate("Add a note..."),
                controller: noteController,
                hasBorder: true,
                maxLines: 5,
              ),
            ],
          ),
        ),
      ),
      actions: [
        MyButtons(
          text: localizations.translate("cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        MyButtons(
          text: localizations.translate("confirm"),
          onPressed: _onPressed,
        ),
      ],
    );
  }
}
