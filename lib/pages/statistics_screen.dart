import 'package:budgetbuddy/components/category_spending_pie_chart.dart';
import 'package:budgetbuddy/components/spending_trend_bar_chart.dart';
import 'package:budgetbuddy/services/database_service.dart';
import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, Map<String, double>> _dailyData = {};
  Map<String, double> _categoryData = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final db = DatabaseService.instance;
    _dailyData = await db.fetchDailyTransactions();
    _categoryData = await db.fetchCategorySpending();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Statistics')),
      body: SingleChildScrollView(
          child: Column(
        children: [
          // Bar chart
          Text(
            'Spending Trend',
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

          // Pie chart
          Text(
            'Spending Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 300,
            child: CategorySpendingPieChart(categoryData: _categoryData),
          ),

          // =========Use it here =====
          SizedBox(height: 20),

          // Legends
          _buildLegend(),
          //======================
        ],
      )),
    );
  }// ====================== Add this ==============================
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
  // ================================================================
}
