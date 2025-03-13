import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

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

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
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
  }

  Future<void> insertUserBudget({
    required double initialBudget,
    required DateTime startDate,
    required DateTime endDate,
    required double dailyBudget,
  }) async {
    final db = await database;
    final String formattedStartDate =
        DateFormat('yyyy-MM-dd').format(startDate);
    final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    await db.insert(_userBudgetTable, {
      _userBudgetColumnInitialBudget: initialBudget,
      _userBudgetColumnStartDate: formattedStartDate,
      _userBudgetColumnEndDate: formattedEndDate,
      _userBudgetColumnDailyBudget: dailyBudget,
    });
  }

  Future<Map<String, dynamic>?> getUserBudget() async {
    final db = await database;
    final result = await db.query(_userBudgetTable);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> deleteUserBudget() async {
    final db = await database;
    await db.delete(_userBudgetTable);
  }

  Future<void> deleteTransactionTable() async {
    final db = await database;
    await db.delete(_transactionTable);
  }

  Future<void> _updateDailyBudget(double change) async {
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
  }

  Future<void> insertTransaction({
    required double amount,
    required String type,
    required String description,
    required String tag,
  }) async {
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

    if (type == "income") {
      await _updateDailyBudget(amount);
    } else {
      await _updateDailyBudget(-amount);
    }
  }

  Future<List<Map<String, dynamic>>> getTransaction() async {
    final db = await database;
    return await db.query(_transactionTable,
        orderBy: '$_transactionColumnDate DESC');
  }

  Future<void> deleteTransaction(int id) async {
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
  }

  Future<void> updateTransaction(int id, double newAmount, String newType,
      String description, String tag) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      _transactionTable,
      where: '$_transactionColumnId = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      final oldTransaction = result.first;
      final double oldAmount = oldTransaction[_transactionColumnAmount] as double;
      final String oldType = oldTransaction[_transactionColumnType] as String;

      if (oldType == "income") {
        await _updateDailyBudget(-oldAmount);
      } else {
        await _updateDailyBudget(oldAmount);
      }

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
  }

  Future<Map<String, Map<String, double>>> fetchDailyTransactions() async {
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
        dailyData[date]!['income'] = (dailyData[date]!['income'] ?? 0.0) + amount;
      } else {
        dailyData[date]!['expense'] = (dailyData[date]!['expense'] ?? 0.0) + amount;
      }
    }

    return dailyData;
  }

  Future<Map<String, double>> fetchCategorySpending() async {
    final db = DatabaseService.instance;
    final transactions = await db.getTransaction();

    Map<String, double> categorySpending = {};

    for(var transaction in transactions) {
      if(transaction['type'] == 'expense') {
        String tag = transaction['tag'];
        double amount = transaction['amount'];

        categorySpending[tag] = (categorySpending[tag] ?? 0) + amount;
      }
    }
    return categorySpending;
  }
}
