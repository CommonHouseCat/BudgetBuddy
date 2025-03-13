import 'dart:async';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:budgetbuddy/components/my_buttons.dart';
import 'package:budgetbuddy/components/transaction_item.dart';
import 'package:budgetbuddy/components/update_transaction_dialog.dart';
import 'package:budgetbuddy/config/currency_provider.dart';
import 'package:budgetbuddy/pages/new_transaction.dart';
import 'package:flutter/material.dart';
import 'package:budgetbuddy/components/budget_setup_dialog.dart';
import 'package:budgetbuddy/services/database_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: unused_field
  double? _initialBudget;
  double? _dailyBudget;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOverBudget = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkBudget();
    _loadTransactions();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) { // Assign the timer to the variable
      if (mounted) { // Check if the widget is mounted
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void refreshBudget() {
    _checkBudget();
  }

  Future<void> _checkBudget() async {
    final userBudget = await DatabaseService.instance.getUserBudget();

    if (userBudget == null) {
      setState(() {
        _initialBudget = null;
        _startDate = null;
        _endDate = null;
        _dailyBudget = null;
      });

      // Show budget setup dialog outside of setState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBudgetSetupDialog();
      });

      return;
    }

    setState(() {
      _startDate = DateTime.parse(userBudget['startDate']);
      _endDate = DateTime.parse(userBudget['endDate']);
      _dailyBudget = userBudget['dailyBudget'];
    });

    if (_endDate != null && DateTime.now().isAfter(_endDate!)) {
      _showCompletionDialog();
      _wipeBudget();
    }
  }

  void _showBudgetSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BudgetSetupDialog(
        onConfirm: (budget, startDate, endDate, dailyBudget) async {
          final db = DatabaseService.instance;
          await db.insertUserBudget(
            initialBudget: budget,
            startDate: startDate,
            endDate: endDate,
            dailyBudget: dailyBudget,
          );

          setState(() {
            _initialBudget = budget;
            _startDate = startDate;
            _endDate = endDate;
            _dailyBudget = dailyBudget;
          });
        },
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Congratulations!"),
        content:
            const Text("You have successfully completed your budget period."),
        actions: [
          MyButtons(
            text: "OK",
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  void _wipeBudget() async {
    final db = DatabaseService.instance;
    await db.deleteUserBudget();
    await db.deleteTransactionTable();
    setState(() {
      _initialBudget = null;
      _startDate = null;
      _endDate = null;
      _dailyBudget = null;
    });
    _checkBudget();
  }

  int _getDaysLeft() {
    if (_startDate == null || _endDate == null) return 0;

    // Get today's date without time
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // If today is after the end date, budget period is over.
    if (today.isAfter(_endDate!)) {
      return 0;
    }

    // Otherwise, the remaining days is the difference (inclusive)
    return _endDate!.difference(today).inDays + 1;
  }

  List<Map<String, dynamic>> _transactions = [];

  void _loadTransactions() async {
    final db = DatabaseService.instance;
    final transactions = await db.getTransaction();
    final dailyBudget = await db.getUserBudget();

    if (dailyBudget != null) {
      setState(() {
        _transactions = transactions;
        _dailyBudget = dailyBudget['dailyBudget'];
        _isOverBudget = (_dailyBudget! < 0);
      });
    }
  }

  void deleteTransaction(int id) async {
    await DatabaseService.instance.deleteTransaction(id);
    _loadTransactions();
  }

  void _editTransactionDialog(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return UpdateTransactionDialog(
          transaction: transaction,
          onUpdate: () => _loadTransactions(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currencySymbol = currencyProvider.currencySymbol;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Daily Budget',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF007FFF),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 140,
            decoration: const BoxDecoration(
              color: Color(0xFF007FFF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _isOverBudget
                      ? const Text(
                          "Over budget mate!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : AnimatedFlipCounter(
                          duration: const Duration(milliseconds: 500),
                          value: _dailyBudget ?? 0,
                          thousandSeparator: ',',
                          prefix: '$currencySymbol ',
                          fractionDigits: 2,
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  'Days Left: ${_getDaysLeft()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return TransactionItem(
                  amount: transaction['amount'],
                  type: transaction['type'],
                  date: transaction['date'],
                  tag: transaction['tag'],
                  note: transaction['description'],
                  deleteFunction: (context) =>
                      deleteTransaction(transaction['id']),
                  editFunction: (context) =>
                      _editTransactionDialog(transaction),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewTransaction()),
          );

          if (result == true) _loadTransactions();
        },
        backgroundColor: Color(0xFF007FFF),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
