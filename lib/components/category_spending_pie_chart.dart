import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategorySpendingPieChart extends StatelessWidget {
  final Map<String, double> categoryData;

  const CategorySpendingPieChart({
    super.key,
    required this.categoryData,
  });

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = categoryData.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: entry.key,
        color: Colors.primaries[entry.key.hashCode % Colors.primaries.length],
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 80,
        sectionsSpace: 2,
      ),
    );
  }
}
