import 'package:budgetbuddy/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetSetupDialog extends StatefulWidget {
  final Function(double, DateTime, DateTime, double) onConfirm;

  const BudgetSetupDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  State<BudgetSetupDialog> createState() => _BudgetSetupDialogState();
}

class _BudgetSetupDialogState extends State<BudgetSetupDialog> {
  final _budgetController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  void _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        _endDate = null;
      });
    }
  }

  void _pickEndDate() async {
    if(_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please select a start date first.')));
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _onConfirm() {
    final initialBudget = double.tryParse(_budgetController.text);
    if (initialBudget != null && _startDate != null && _endDate != null) {
      final days = _endDate!.difference(_startDate!).inDays + 1;
      final dailyBudget = initialBudget / days;
      widget.onConfirm(initialBudget, _startDate!, _endDate!, dailyBudget);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please fill all fields correctly, you cunt.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Thine Budget'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyTextfield(
            hintText: 'Enter your initial budget',
            labelText: 'Initial Budget',
            controller: _budgetController,
            keyboardType: TextInputType.number,
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
          ),
          SizedBox(height: 20),
          ListTile(
            title: Text(
              _startDate == null
                  ? 'Select Start Date'
                  : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
            ),
            trailing: Icon(Icons.calendar_today),
            onTap: _pickStartDate,
          ),
          ListTile(
            title: Text(
              _endDate == null
                  ? 'Select End Date'
                  : 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
            ),
            trailing: Icon(Icons.calendar_today),
            onTap: _pickEndDate,
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: _onConfirm,
          child: Text('Confirm'),
        ),
      ],
    );
  }
}
