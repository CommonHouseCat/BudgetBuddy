import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final logger = Logger();

  // User budget table
  final String _userBudgetTable = "UserBudget";
  final String _userBudgetColumnId = "id";
  final String _userBudgetColumnInitialBudget = "initialBudget";
  final String _userBudgetColumnDailyBudget = "dailyBudget";
  final String _userBudgetColumnStartDate = "startDate";
  final String _userBudgetColumnEndDate = "endDate";

  // Transaction table
  final String _transactionTable = "Transactions";
  final String _transactionColumnId = "id";
  final String _transactionColumnAmount = "amount";
  final String _transactionColumnType = "type"; // 'income' or 'expense'
  final String _transactionColumnDate = "date";
  final String _transactionColumnDescription = "description";
  final String _transactionColumnTag = "tag";

  DatabaseService._constructor();

  /*
  * If the database instance exists, do nothing.
  * Otherwise, create the database instance.
  * */
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  /*
  * Initializes and returns the database instance by
  * Getting the database directory, creating a full path
  * and using said path to creates the tables.
  * */
  Future<Database> getDatabase() async {
    try {
      final databaseDirPath = await getDatabasesPath();
      final databasePath = join(databaseDirPath, "mainDB.db");
      final database = await openDatabase(
        databasePath,
        version: 2,
        onCreate: (db, version) {
          db.execute('''CREATE TABLE $_userBudgetTable (
          $_userBudgetColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_userBudgetColumnInitialBudget REAL NOT NULL,
          $_userBudgetColumnDailyBudget REAL NOT NULL,
          $_userBudgetColumnStartDate TEXT NOT NULL,
          $_userBudgetColumnEndDate TEXT NOT NULL
        )''');

          db.execute('''CREATE TABLE $_transactionTable (
          $_transactionColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_transactionColumnAmount REAL NOT NULL,
          $_transactionColumnType TEXT NOT NULL,
          $_transactionColumnDate TEXT NOT NULL,
          $_transactionColumnDescription TEXT NOT NULL,
          $_transactionColumnTag TEXT NOT NULL
        )''');
        },
      );
      return database;
    } catch (e, stackTrace) {
      logger.e('Error in getDatabase', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Wipe _userBudgetTable.
  Future<void> deleteUserBudget() async {
    try {
      final db = await database;
      await db.delete(_userBudgetTable);
    } catch (e, stackTrace) {
      logger.e('Error in deleteUserBudget', error: e, stackTrace: stackTrace);
    }
  }

  // Wipe _transactionTable.
  Future<void> deleteTransactionTable() async {
    try {
      final db = await database;
      await db.delete(_transactionTable);
    } catch (e, stackTrace) {
      logger.e('Error in deleteTransactionTable',
          error: e, stackTrace: stackTrace);
    }
  }

  // Fetch data from _userBudgetTable.
  Future<Map<String, dynamic>?> getUserBudget() async {
    final db = await database;
    final result = await db.query(_userBudgetTable);
    return result.isNotEmpty ? result.first : null;
  }

  // Inserts a new budget record.
  Future<void> insertUserBudget({
    required double initialBudget,
    required DateTime startDate,
    required DateTime endDate,
    required double dailyBudget,
  }) async {
    try {
      final db = await database;
      // Just making sure the date format fits before inserting.
      final String formattedStartDate =
      DateFormat('yyyy-MM-dd').format(startDate);
      final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
      await db.insert(_userBudgetTable, {
        _userBudgetColumnInitialBudget: initialBudget,
        _userBudgetColumnStartDate: formattedStartDate,
        _userBudgetColumnEndDate: formattedEndDate,
        _userBudgetColumnDailyBudget: dailyBudget,
      });
    } catch (e, stackTrace) {
      logger.e('Error in insertUserBudget', error: e, stackTrace: stackTrace);
    }
  }

  /*
  * A helper function that updates the daily budget column
  * after each transaction interaction (add, delete, edit).
  * */
  Future<void> _updateDailyBudget(double change) async {
    try {
      final db = await database;
      final userBudget = await getUserBudget();

      if (userBudget != null) {
        double currentDailyBudget =
        userBudget[_userBudgetColumnDailyBudget] as double;
        double newDailyBudget = currentDailyBudget + change;
        await db.update(
          _userBudgetTable,
          {
            _userBudgetColumnDailyBudget: newDailyBudget,
          },
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error in _updateDailyBudget', error: e, stackTrace: stackTrace);
    }
  }

  // Inserts a new transaction record.
  Future<void> insertTransaction({
    required double amount,
    required String type,
    required String description,
    required String tag,
  }) async {
    try {
      final db = await database;
      final String formattedDate =
      DateFormat('yyyy-MM-dd').format(DateTime.now());

      await db.insert(_transactionTable, {
        _transactionColumnAmount: amount,
        _transactionColumnType: type,
        _transactionColumnDate: formattedDate,
        _transactionColumnDescription: description,
        _transactionColumnTag: tag,
      });
      // Adjust daily budget based on transaction type.
      if (type == "income") {
        await _updateDailyBudget(amount);
      } else {
        await _updateDailyBudget(-amount);
      }
    } catch (e, stackTrace) {
      logger.e('Error in insertTransaction', error: e, stackTrace: stackTrace);
    }
  }

  // Fetch data from _transactionTable.
  Future<List<Map<String, dynamic>>> getTransaction() async {
    try {
      final db = await database;
      return await db.query(_transactionTable,
          orderBy: '$_transactionColumnDate DESC');
    } catch (e, stackTrace) {
      logger.e('Error in getTransaction', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Updates a transaction record.
  Future<void> updateTransaction(int id, double newAmount, String newType,
      String description, String tag) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> result = await db.query(
        _transactionTable,
        where: '$_transactionColumnId = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        final oldTransaction = result.first;
        final double oldAmount =
        oldTransaction[_transactionColumnAmount] as double;
        final String oldType = oldTransaction[_transactionColumnType] as String;

        // Revert the daily budget change for the old transaction type.
        if (oldType == "income") {
          await _updateDailyBudget(-oldAmount);
        } else {
          await _updateDailyBudget(oldAmount);
        }

        // Apply the new daily budget change for the new transaction type.
        if (newType == "income") {
          await _updateDailyBudget(newAmount);
        } else {
          await _updateDailyBudget(-newAmount);
        }

        await db.update(
          _transactionTable,
          {
            _transactionColumnAmount: newAmount,
            _transactionColumnType: newType,
            _transactionColumnDescription: description,
            _transactionColumnTag: tag,
          },
          where: '$_transactionColumnId = ?',
          whereArgs: [id],
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error in updateTransaction', error: e, stackTrace: stackTrace);
    }
  }

  // Deletes a transaction record.
  Future<void> deleteTransaction(int id) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> result = await db.query(
        _transactionTable,
        where: '$_transactionColumnId = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        final transaction = result.first;
        final double amount = transaction[_transactionColumnAmount] as double;
        final String type = transaction[_transactionColumnType] as String;

        // Revert the daily budget change for the transaction type.
        if (type == "income") {
          await _updateDailyBudget(-amount);
        } else {
          await _updateDailyBudget(amount);
        }

        await db.delete(
          _transactionTable,
          where: '$_transactionColumnId = ?',
          whereArgs: [id],
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error in deleteTransaction', error: e, stackTrace: stackTrace);
    }
  }

  // Fetch a map of dates (keys) and their corresponding income and expense amounts (values).
  Future<Map<String, Map<String, double>>> fetchDailyTransactions() async {
    try {
      final db = DatabaseService.instance;
      final transactions = await db.getTransaction();

      Map<String, Map<String, double>> dailyData = {};

      for (var transaction in transactions) {
        String date = transaction['date'];
        double amount = transaction['amount'];
        String type = transaction['type'];

        if (!dailyData.containsKey(date)) {
          dailyData[date] = {'income': 0.0, 'expense': 0.0};
        }

        if (type == 'income') {
          dailyData[date]!['income'] =
              (dailyData[date]!['income'] ?? 0.0) + amount;
        } else {
          dailyData[date]!['expense'] =
              (dailyData[date]!['expense'] ?? 0.0) + amount;
        }
      }

      return dailyData;
    } catch (e, stackTrace) {
      logger.e('Error in fetchDailyTransactions',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Fetch a map of categories (keys) and their corresponding spending amounts (values).
  Future<Map<String, double>> fetchCategorySpending() async {
    try {
      final db = DatabaseService.instance;
      final transactions = await db.getTransaction();

      Map<String, double> categorySpending = {};

      for (var transaction in transactions) {
        if (transaction['type'] == 'expense') {
          String tag = transaction['tag'];
          double amount = transaction['amount'];

          categorySpending[tag] = (categorySpending[tag] ?? 0) + amount;
        }
      }
      return categorySpending;
    } catch (e, stackTrace) {
      logger.e('Error in fetchCategorySpending',
          error: e, stackTrace: stackTrace);
      rethrow;
    }

  }

  // Fetch transaction records for a specific date.
  Future<List<Map<String, dynamic>>> fetchTransactionsForDate(
      DateTime selectedDate) async {
    try {
      final db = await database;

      String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

      final List<Map<String, dynamic>> maps = await db.query(
        _transactionTable,
        where: "$_transactionColumnDate = ?",
        whereArgs: [dateStr],
      );

      return maps;
    } catch (e, stackTrace) {
      logger.e('Error in fetchTransactionsForDate',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
