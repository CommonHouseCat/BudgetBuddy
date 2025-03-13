import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../components/category_spending_pie_chart.dart';
import '../components/spending_trend_bar_chart.dart';
import '../config/localization/app_localizations.dart';
import '../services/database_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, Map<String, double>> _dailyData = {};
  Map<String, double> _categoryData = {};
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
        backgroundColor: const Color(0xFF008080),
        title: Center(
          child: Text(
            localizations.translate('statistics'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
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

  Widget _buildLegend() {
    return Column(
      children: _categoryData.entries.map((entry) {
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
              Text(entry.key),
              const Spacer(),
              Text('\$${entry.value.toStringAsFixed(2)}'),
            ],
          ),
        );
      }).toList(),
    );
  }
}
