import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';
import '../components/transaction_item.dart';
import '../components/update_transaction_dialog.dart'
    show UpdateTransactionDialog;
import '../config/localization/app_localizations.dart';
import '../services/database_service.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  late Map<DateTime, List<Map<String, dynamic>>> _transactions;
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _transactions = {};
    _fetchTransactionsForDate(_selectedDay);
  }

  Future<void> _fetchTransactionsForDate(DateTime selectedDate) async {
    try {
      final db = DatabaseService.instance;
      final transactions = await db.fetchTransactionsForDate(selectedDate);
      if (mounted) {
        setState(() {
          _transactions[selectedDate] = transactions;
        });
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching transactions for date',
          error: e, stackTrace: stackTrace);
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _transactions[day] ?? [];
  }

  void deleteTransaction(int id) async {
    try {
      await DatabaseService.instance.deleteTransaction(id);
      _fetchTransactionsForDate(_selectedDay);
    } catch (e, stackTrace) {
      logger.e('Error deleting transaction', error: e, stackTrace: stackTrace);
    }
  }

  void editTransactionDialog(Map<String, dynamic> transaction) {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return UpdateTransactionDialog(
            transaction: transaction,
            onUpdate: () => _fetchTransactionsForDate(_selectedDay),
          );
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error editing transaction', error: e, stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF008080),
        title: Center(
          child: Text(
            localizations.translate('CalenderScreen'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDate, focusedDay) {
              setState(() {
                _selectedDay = selectedDate;
              });
              _fetchTransactionsForDate(selectedDate);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          Expanded(
            child: _transactions[_selectedDay] == null
                ? const Center(child: Text("No transactions found"))
                : ListView.builder(
              itemCount: _transactions[_selectedDay]!.length,
              itemBuilder: (context, index) {
                var transaction = _transactions[_selectedDay]![index];
                return TransactionItem(
                  amount: transaction['amount'],
                  type: transaction['type'],
                  date: transaction['date'],
                  tag: transaction['tag'],
                  note: transaction['description'],
                  deleteFunction: (context) =>
                      deleteTransaction(transaction['id']),
                  editFunction: (context) =>
                      editTransactionDialog(transaction),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
