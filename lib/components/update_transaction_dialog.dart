import 'package:budgetbuddy/components/my_buttons.dart';
import 'package:budgetbuddy/components/my_textfield.dart';
import 'package:budgetbuddy/services/database_service.dart';
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

  final List<String> tags = ['Food', 'Transport', 'Entertainment', 'Bills', 'Others'];

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: widget.transaction['amount'].toString());
    noteController = TextEditingController(text: widget.transaction['description']);
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
    double? newAmount = double.tryParse(amountController.text);
    if (newAmount == null || newAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid amount entered")),
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Transaction'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Amount", style: TextStyle(fontSize: 18)),
              MyTextfield(
                hintText: "Enter Amount",
                controller: amountController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Transaction Type Selection
              const Text("Type:", style: TextStyle(fontSize: 18)),
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
                  const Text("Expense"),
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
                  const Text("Income"),
                ],
              ),
              const SizedBox(height: 16),

              // Tag Selection
              const Text("Tag:", style: TextStyle(fontSize: 18)),
              DropdownButton<String>(
                value: selectedTag,
                isExpanded: true, // Ensure it takes full width
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
              const Text("Note:", style: TextStyle(fontSize: 18)),
              MyTextfield(
                hintText: "Add a note...",
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
          text: "Cancel",
          onPressed: () => Navigator.pop(context),
        ),
        MyButtons(
          text: "Confirm",
          onPressed: _onPressed,
        ),
      ],
    );
  }
}
