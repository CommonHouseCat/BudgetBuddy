import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../components/category_spending_pie_chart.dart';
import '../components/spending_trend_bar_chart.dart';
import '../config/currency_provider.dart';
import '../config/localization/app_localizations.dart';
import '../services/database_service.dart';

/*
* Statistic Screen of the app, where the daily spending trend is display in bar chart
* and spending amount by category is displayed in pie chart.
* */
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, Map<String, double>> _dailyData = {}; // Map of daily transactions.
  Map<String, double> _categoryData = {}; // Map of total amount spent by category.
  final logger = Logger();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch daily transaction and total amount spent by category from database.
  void _fetchData() async {
    try {
      final db = DatabaseService.instance;
      _dailyData = await db.fetchDailyTransactions();
      _categoryData = await db.fetchCategorySpending();
      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      logger.e('Error in _fetchData', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Center(
          child: Text(
            localizations.translate('statistics'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              // Bar Chart
              Text(
                localizations.translate('Spending Trend'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 300,
                child: SpendingTrendBarChart(dailyData: _dailyData),
              ),
              SizedBox(height: 20),

              // Pie Chart
              Text(
                localizations.translate('Spending Category'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 300,
                child: CategorySpendingPieChart(categoryData: _categoryData),
              ),
              SizedBox(height: 20),

              // Legends
              _buildLegend(),
            ],
          )),
    );
  }

  /*
  * Widget for building a legend (show the amount spend for each category) for
  * the pie chart.
  * */
  Widget _buildLegend() {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currencySymbol = currencyProvider.currencySymbol;

    return Column(
      children: _categoryData.entries.map((entry) {
        // Generate color from the hash code of the category name.
        final color =
        Colors.primaries[entry.key.hashCode % Colors.primaries.length];
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 16.0,
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              // Display the category name.
              Text(entry.key),
              const Spacer(),
              // Display the amount spent for said category.
              Text('$currencySymbol ${entry.value.toStringAsFixed(2)}'),
            ],
          ),
        );
      }).toList(),
    );
  }
}
