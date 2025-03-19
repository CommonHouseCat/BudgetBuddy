import 'dart:async';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../components/budget_setup_dialog.dart';
import '../components/my_buttons.dart';
import '../components/transaction_item.dart';
import '../components/update_transaction_dialog.dart';
import '../config/currency_provider.dart';
import '../config/localization/app_localizations.dart';
import '../services/database_service.dart';
import 'new_transaction.dart';

/*
* The Home Screen of the app, where the daily budget and the transactions are displayed.
* */
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
    /*
    * This is used to check for the current date and update days left by
    * refreshing the UI every minute when the app is active.
    * */
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

  /*
  * This function is used to check budget, if the user budget fetched from
  * database is null, set all variables to null and call the show budget dialog.
  * Otherwise, set the variables to the values pulled from the database.
  * Also used to check if the days left counter is 0, if it is, trigger the
  * _showCompletionDialog function.
  * */
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

  /*
  * Shows the dialog for user to set the budget and date range
  *  and insert those into the database.
  * */
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

  /*
  * Used to show a congratulatory dialog when the user finished the budget period,
  * Wipe data if hit OK button
  * */
  void _showCompletionDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate("Congratulations!")),
        content: Text(localizations.translate(
            "You have successfully completed your budget period.")),
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

  // Wipe all data
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

  // Used to calculate the days left
  String _getDaysLeft() {
    final localizations = AppLocalizations.of(context);
    if (_startDate == null || _endDate == null) return "";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // If the budget period is before current date
    if (today.isBefore(_startDate!)) return localizations.translate("Not yet!");
    if (today.isAfter(_endDate!)) {
      return "0";
    }

    return (_endDate!.difference(today).inDays + 1).toString();
  }

  // Returns a static date range based on start and end date (e.g. Mar 18 - Mar 19)
  String _getDateRange() {
    if (_startDate == null || _endDate == null) return "";

    final formatter = DateFormat('MMM d');
    final start = formatter.format(_startDate!);
    final end = formatter.format(_endDate!);

    return "($start - $end)";
  }

  // List to store transaction data
  List<Map<String, dynamic>> _transactions = [];

  /*
  * Function used for loading transaction data from the database to be displayed
  * or reload after a transaction is added or deleted, as well as updating the
  * _dailyBudget value.
  * */
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

  // Delete a transaction and reload the _transactions list.
  void deleteTransaction(int id) async {
    try {
      await DatabaseService.instance.deleteTransaction(id);
      _loadTransactions();
    } catch (e, stackTrace) {
      logger.e('Error deleting transaction', error: e, stackTrace: stackTrace);
    }
  }

  // Edit a transaction and reload the _transactions list.
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

  /*
  * A widget used to build the budget overview section in portrait mode.
  * Display the Daily budget, days left counter and day range.
  * */
  Widget _buildBudgetOverview(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currencySymbol = currencyProvider.currencySymbol;
    final localizations = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color:
        _isOverBudget ? const Color(0xFF9e1b32) : const Color(0xFF0BA6B3),
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
              duration: const Duration(milliseconds: 400),
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

  // Portrait layout.
  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      children: [
        _buildBudgetOverview(context),
        // Transaction.
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

  /*
 * A widget used to build the budget overview section for landscape mode
 * Displays the Daily budget, days left counter and day range on the left side.
 */
  Widget _buildBudgetOverviewLandscape(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currencySymbol = currencyProvider.currencySymbol;
    final localizations = AppLocalizations.of(context);

    return Container(
      color: _isOverBudget ? const Color(0xFF9e1b32) : const Color(0xFF0BA6B3),
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
    );
  }

// Landscape layout.
  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        // Left side - Budget Overview.
        Expanded(
          child: _buildBudgetOverviewLandscape(context),
        ),
        // Right side - Transactions.
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
    // A flag to keep track of device orientation.
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: isLandscape
          ? null // Hides if in landscape mode.
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
            : const Color(0xFF0BA6B3),
        centerTitle: true,
      ),
      body: isLandscape
          ? _buildLandscapeLayout(context)
          : _buildPortraitLayout(context),


      // Floating action button to transits into the new transaction page with animation.
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
                color: Color(0xFF0BA6B3),
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

