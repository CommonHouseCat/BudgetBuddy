import 'dart:async';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:budgetbuddy/components/budget_setup_dialog.dart';
import 'package:budgetbuddy/components/my_buttons.dart';
import 'package:budgetbuddy/components/transaction_item.dart';
import 'package:budgetbuddy/components/update_transaction_dialog.dart';
import 'package:budgetbuddy/services/database_service.dart';
import 'package:budgetbuddy/pages/new_transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../config/currency_provider.dart';
import '../config/localization/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? _initialBudget;
  double? _dailyBudget;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOverBudget = false;
  Timer? _timer;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _checkBudget();
    _loadTransactions();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void refreshBudget() {
    _checkBudget();
  }

  Future<void> _checkBudget() async {
    try {
      final userBudget = await DatabaseService.instance.getUserBudget();

      if (userBudget == null) {
        if (mounted) {
          setState(() {
            _initialBudget = null;
            _startDate = null;
            _endDate = null;
            _dailyBudget = null;
          });
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showBudgetSetupDialog();
        });
        return;
      }
      if (mounted) {
        setState(() {
          _startDate = DateTime.parse(userBudget['startDate']);
          _endDate = DateTime.parse(userBudget['endDate']);
          _dailyBudget = userBudget['dailyBudget'];
        });
      }
      if (_endDate != null && _getDaysLeft() == "0") {
        _showCompletionDialog();
      }
    } catch (e, stackTrace) {
      logger.e('Error checking budget', error: e, stackTrace: stackTrace);
    }
  }

  void _showBudgetSetupDialog() {
    try {
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
            if (mounted) {
              setState(() {
                _initialBudget = budget;
                _startDate = startDate;
                _endDate = endDate;
                _dailyBudget = dailyBudget;
              });
            }
          },
        ),
      );
    } catch (e, stackTrace) {
      logger.e('Error showing budget setup dialog',
          error: e, stackTrace: stackTrace);
    }
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
              _wipeBudget();
            },
          )
        ],
      ),
    );
  }

  void _wipeBudget() async {
    try {
      final db = DatabaseService.instance;
      await db.deleteUserBudget();
      await db.deleteTransactionTable();
      if (mounted) {
        setState(() {
          _initialBudget = null;
          _startDate = null;
          _endDate = null;
          _dailyBudget = null;
        });
      }
      _showBudgetSetupDialog();
    } catch (e, stackTrace) {
      logger.e('Error wiping budget', error: e, stackTrace: stackTrace);
    }
  }

  String _getDaysLeft() {
    if (_startDate == null || _endDate == null) return "";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (today.isBefore(_startDate!)) return "Not yet!";
    if (today.isAfter(_endDate!)) {
      return "0";
    }

    return (_endDate!.difference(today).inDays + 1).toString();
  }

  String _getDateRange() {
    if (_startDate == null || _endDate == null) return "";

    final formatter = DateFormat('MMM d');
    final start = formatter.format(_startDate!);
    final end = formatter.format(_endDate!);

    return "($start - $end)";
  }

  List<Map<String, dynamic>> _transactions = [];

  void _loadTransactions() async {
    try {
      final db = DatabaseService.instance;
      final transactions = await db.getTransaction();
      final dailyBudget = await db.getUserBudget();

      if (dailyBudget != null) {
        if (mounted) {
          setState(() {
            _transactions = transactions;
            _dailyBudget = dailyBudget['dailyBudget'];
            _isOverBudget = (_dailyBudget! < 0);
          });
        }
      }
    } catch (e, stackTrace) {
      logger.e('Error loading transactions', error: e, stackTrace: stackTrace);
    }
  }

  void deleteTransaction(int id) async {
    try {
      await DatabaseService.instance.deleteTransaction(id);
      _loadTransactions();
    } catch (e, stackTrace) {
      logger.e('Error deleting transaction', error: e, stackTrace: stackTrace);
    }
  }

  void _editTransactionDialog(Map<String, dynamic> transaction) {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return UpdateTransactionDialog(
            transaction: transaction,
            onUpdate: () => _loadTransactions(),
          );
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error editing transaction', error: e, stackTrace: stackTrace);
    }
  }

  Widget _buildBudgetOverview(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currencySymbol = currencyProvider.currencySymbol;
    final localizations = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color:
        _isOverBudget ? const Color(0xFF9e1b32) : const Color(0xFF008080),
        borderRadius: const BorderRadius.only(
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
                ? Text(
              localizations.translate("Over budget mate!"),
              style: const TextStyle(
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
            '${localizations.translate('Days Left:')} ${_getDaysLeft()} ${_getDateRange()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      children: [
        _buildBudgetOverview(context),
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
                editFunction: (context) => _editTransactionDialog(transaction),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currencySymbol = currencyProvider.currencySymbol;
    final localizations = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            // left side: budget overview
            color: _isOverBudget
                ? const Color(0xFF9e1b32)
                : const Color(0xFF008080),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    localizations.translate("Daily Budget"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 35.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _isOverBudget
                      ? Text(
                    localizations.translate("Over budget mate!"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
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
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '${localizations.translate('Days Left:')} ${_getDaysLeft()} ${_getDateRange()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side - Transactions
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
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
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: isLandscape
          ? null
          : AppBar(
        title: Center(
          child: Text(localizations.translate("Daily Budget"),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              )),
        ),
        backgroundColor: _isOverBudget
            ? const Color(0xFF9e1b32)
            : const Color(0xFF008080),
        centerTitle: true,
      ),
      body: isLandscape
          ? _buildLandscapeLayout(context)
          : _buildPortraitLayout(context),


      floatingActionButton: GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewTransaction()),
            );
            if (result == true) _loadTransactions();
          },
          child: AnimatedScale(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            scale: 1.0,
            child: Container(
              width: 56.0,
              height: 56.0,
              decoration: const BoxDecoration(
                color: Color(0xFF008080),
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30.0,
              ),
            ),
          )
      ),
    );
  }
}
