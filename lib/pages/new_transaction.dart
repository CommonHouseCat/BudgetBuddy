import 'package:budgetbuddy/components/my_buttons.dart';
import 'package:budgetbuddy/components/my_textfield.dart';
import 'package:budgetbuddy/services/database_service.dart';
import 'package:flutter/material.dart';

class NewTransaction extends StatefulWidget {
  const NewTransaction({super.key});

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedType = 'expense'; // Default transaction type
  String _selectedTag = 'Food'; // Default transaction tag

  final List<String> _tags = [
    'Food',
    'Transport',
    'Entertainment',
    'Bills',
    'Others'
  ];

  void _saveTransaction() async {
    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid amount. Please enter a positive number.'),
      ));
      return;
    }

    await DatabaseService.instance.insertTransaction(
      amount: amount,
      type: _selectedType,
      description: _noteController.text,
      tag: _selectedTag,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("AMOUNT:", style: TextStyle(fontSize: 18)),
              MyTextfield(
                hintText: "e.g. 400",
                controller: _amountController,
                keyboardType: TextInputType.number,
                hasBorder: true,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  const Text("TYPE:", style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 20),
                  Radio(
                    value: 'expense',
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value.toString();
                      });
                    },
                  ),
                  const Text("Expense"),
                  Radio(
                    value: 'income',
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value.toString();
                      });
                    },
                  ),
                  const Text("Income"),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text("TAG:", style: TextStyle(fontSize: 18)),
                  SizedBox(width: 20),
                  DropdownButton<String>(
                    value: _selectedTag,
                    items: _tags.map((tag) {
                      return DropdownMenuItem<String>(
                        value: tag,
                        child: Text(tag),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTag = value!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text("NOTE:", style: TextStyle(fontSize: 18)),
              MyTextfield(
                hintText:
                    "e.g. Bought The End and The Death part 1 from Amazon",
                controller: _noteController,
                maxLines: 12,
                hasBorder: true,
              ),
              SizedBox(height: 16),
              Center(
                child: MyButtons(
                  onPressed: _saveTransaction,
                  text: "Save Transaction",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
