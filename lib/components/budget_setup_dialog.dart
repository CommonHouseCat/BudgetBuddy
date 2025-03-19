import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../config/localization/app_localizations.dart';
import 'my_textfield.dart';
import 'package:flutter/material.dart';

/*
* A dialog that prompts the user to set budget amount and date range.
* It appears if the userBudgetTable is empty either due to
* first-time app launch or user wipe the userBudgetTable.
* */
class BudgetSetupDialog extends StatefulWidget {
  // A callback function that for when the user confirms the budget setup.
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
  final logger = Logger();

  // Show date picker for start date
  void _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    // If a start date is selected,
    // update the _startDate and reset _endDate to null
    if (date != null) {
      setState(() {
        _startDate = date;
        _endDate = null;
      });
    }
  }

  // Show date picker for end date
  void _pickEndDate() async {
    final localizations = AppLocalizations.of(context);
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.translate('SelectStartDate'))));
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

  /*
  * If all field are filled,
  * calculate the number of days between start and end dates,
  * calculate daily budget,
  * pass them to the onConfirm callback function
  * and close the dialog.
  * */
  void _onConfirm() {
    try {
      final localizations = AppLocalizations.of(context);
      final initialBudget = double.tryParse(_budgetController.text);

      if (initialBudget != null && _startDate != null && _endDate != null) {
        final days = _endDate!.difference(_startDate!).inDays + 1;
        final dailyBudget = initialBudget / days;
        widget.onConfirm(initialBudget, _startDate!, _endDate!, dailyBudget);
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(localizations.translate('FillCorrectlyWarning'))));
      }
    } catch (e, stackTrace) {
      logger.e('Error in _onConfirm', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      title: Text(localizations.translate('Set Your Budget')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // The initial budget input field
          MyTextfield(
            hintText: localizations.translate('Enter your initial budget'),
            labelText: localizations.translate('Initial Budget'),
            controller: _budgetController,
            keyboardType: TextInputType.number,
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
          ),

          SizedBox(height: 20),

          // Start date picker
          ListTile(
            title: Text(
              _startDate == null
                  ? localizations.translate('Select Start Date')
                  : '${localizations.translate('Start Date:')} ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
            ),
            trailing: Icon(Icons.calendar_today),
            onTap: _pickStartDate,
          ),

          // End date picker
          ListTile(
            title: Text(
              _endDate == null
                  ? localizations.translate('Select End Date')
                  : '${localizations.translate('End Date:')} ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
            ),
            trailing: Icon(Icons.calendar_today),
            onTap: _pickEndDate,
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: _onConfirm,
          child: Text(localizations.translate('Confirm')),
        ),
      ],
    );
  }
}
